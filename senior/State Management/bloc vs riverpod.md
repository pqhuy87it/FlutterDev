# Bloc vs Riverpod — So sánh chi tiết cho Senior Flutter Developer

---

## 1. Triết lý thiết kế gốc

### Bloc: "Mọi thay đổi phải có lý do"

Bloc sinh ra từ tư duy **event-driven architecture**. Triết lý cốt lõi là: không có state nào thay đổi mà không có một event tường minh gây ra nó. Điều này tạo ra một **audit trail hoàn chỉnh** — bạn luôn biết *cái gì* gây ra thay đổi, *khi nào*, và *từ đâu*.

Bloc lấy cảm hứng trực tiếp từ Redux trong React ecosystem, nhưng adapt cho Dart/Flutter với stream-based architecture.

### Riverpod: "State là dependency, hãy quản lý nó như dependency"

Riverpod tiếp cận từ góc độ **dependency injection + reactive programming**. Triết lý là: state cũng chỉ là một dạng dependency — khai báo nó, mô tả cách nó phụ thuộc vào các state khác, và framework lo phần còn lại. Riverpod quan tâm đến **dependency graph** hơn là event flow.

---

## 2. Kiến trúc & Data Flow

### Bloc: Unidirectional, explicit

```
UI ──dispatch──▶ Event ──▶ Bloc ──▶ State ──▶ UI rebuild
                            │
                            ▼
                     (side effects:
                      API call, DB, etc.)
```

Mỗi bước đều tường minh. Bạn **không thể** thay đổi state mà không qua event.

```dart
// Event — mô tả "chuyện gì xảy ra"
sealed class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email, password;
  LoginRequested(this.email, this.password);
}
class LogoutRequested extends AuthEvent {}

// State — mô tả "app đang ở trạng thái nào"
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState { final User user; AuthSuccess(this.user); }
class AuthFailure extends AuthState { final String message; AuthFailure(this.message); }

// Bloc — xử lý event, emit state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repo.login(event.email, event.password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _repo.logout();
    emit(AuthInitial());
  }
}
```

### Riverpod: Reactive graph, implicit propagation

```
Provider A ◀──watch── Provider B ◀──watch── Widget
    │                      │
    ▼                      ▼
(auto-recompute)    (auto-recompute)
```

State thay đổi tự lan truyền qua dependency graph. Bạn khai báo mối quan hệ, Riverpod lo phần reactivity.

```dart
// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

// Auth state + logic
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // auto-called, có thể check cached session
    return ref.watch(authRepositoryProvider).getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(authRepositoryProvider).login(email, password);
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
```

**Quan sát quan trọng:** Riverpod dùng `AsyncValue` (data/loading/error) thay cho sealed class thủ công. Bạn không cần tự định nghĩa `AuthLoading`, `AuthFailure` — framework đã abstract hóa pattern này.

---

## 3. Event Layer — Sự khác biệt bản chất nhất

Đây là điểm phân tách lớn nhất giữa hai giải pháp.

### Bloc: Event là first-class citizen

```dart
// Bloc event transformer — debounce search
on<SearchQueryChanged>(
  _onSearchQueryChanged,
  transformer: debounce(const Duration(milliseconds: 300)),
);

// Bloc có thể xử lý event concurrency
on<AddToCart>(
  _onAddToCart,
  transformer: droppable(), // bỏ event mới nếu đang xử lý
);
```

Event layer cho phép bạn:

**Debounce/throttle** ngay tại bloc level — không cần Timer thủ công. **Concurrency control** — `sequential()`, `droppable()`, `restartable()` kiểm soát cách xử lý khi nhiều event cùng loại đến liên tiếp. **Event replay** — lưu lại danh sách event và replay để reproduce bug. **Event sourcing pattern** — nếu cần, bạn có thể rebuild state từ event history.

### Riverpod: Không có event layer

Method gọi trực tiếp, giống OOP thông thường:

```dart
ref.read(authProvider.notifier).login(email, password);
```

Không có debounce/throttle built-in — bạn tự handle ở UI hoặc trong notifier. Không có event log tự động. Nhưng đổi lại, ít ceremony hơn đáng kể cho các thao tác đơn giản.

**Senior insight:** Nếu app có nhiều async interaction phức tạp (real-time chat, collaborative editing, payment flow), event layer của Bloc là lợi thế lớn. Nếu app chủ yếu là CRUD, event layer trở thành overhead không cần thiết.

---

## 4. Dependency Injection

### Bloc: Cần giải pháp bên ngoài

Bloc tự nó **không phải** DI framework. Bạn cần inject dependency vào bloc qua constructor:

```dart
// Phải truyền repository vào bloc
final authBloc = AuthBloc(authRepository);

// Trong widget tree, dùng BlocProvider
BlocProvider(
  create: (context) => AuthBloc(
    context.read<AuthRepository>(), // Provider hoặc GetIt cho DI
  ),
  child: LoginPage(),
)
```

Trong thực tế, hầu hết Bloc project dùng thêm **GetIt** hoặc **injectable** cho DI, hoặc dùng chính **Provider/Riverpod** chỉ để inject dependency — tạo ra sự phụ thuộc vào thêm một package.

### Riverpod: DI là built-in

```dart
// Repository tự động được inject
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(dio, storage);
});

// AuthNotifier tự access repository qua ref
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // ref.watch tự tạo dependency link
    return ref.watch(authRepositoryProvider).getCurrentUser();
  }
}
```

**Ưu thế quan trọng của Riverpod:** Khi `dioProvider` thay đổi (ví dụ token refresh), mọi provider phụ thuộc vào nó tự động invalidate và rebuild. Bloc không có cơ chế này — bạn phải tự handle cascade update.

**Testing DI:**

```dart
// Riverpod: override cực kỳ clean
final container = ProviderContainer(
  overrides: [
    authRepositoryProvider.overrideWithValue(MockAuthRepository()),
  ],
);

// Bloc: truyền mock qua constructor
final bloc = AuthBloc(MockAuthRepository());
```

Cả hai đều test được, nhưng Riverpod elegant hơn khi dependency chain dài (A → B → C → D), vì bạn chỉ cần override một provider, tất cả downstream tự nhận mock.

---

## 5. Rebuild Optimization

### Bloc: `buildWhen` + `BlocSelector`

```dart
// Chỉ rebuild khi state type thay đổi
BlocBuilder<AuthBloc, AuthState>(
  buildWhen: (previous, current) => current is AuthSuccess,
  builder: (context, state) {
    if (state is AuthSuccess) return Text(state.user.name);
    return const SizedBox.shrink();
  },
)

// Hoặc select một phần state
BlocSelector<CartBloc, CartState, int>(
  selector: (state) => state.items.length,
  builder: (context, itemCount) => Text('$itemCount items'),
)
```

Hoạt động tốt, nhưng bạn phải **chủ động** sử dụng `buildWhen`/`BlocSelector`. Mặc định, `BlocBuilder` rebuild mỗi khi state thay đổi.

### Riverpod: `select` + provider granularity

```dart
// Select field cụ thể
final itemCount = ref.watch(
  cartProvider.select((cart) => cart.items.length),
);

// Hoặc tách thành provider riêng — tự động optimize
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).items.length;
});
```

Riverpod có thêm một chiêu mà Bloc không có: **derived provider**. Bạn tạo provider mới từ provider cũ, chỉ compute lại khi input thực sự thay đổi. Đây chính là pattern `computed`/`selector` trong các reactive framework, nhưng được nâng lên thành first-class concept.

**Senior insight:** Với app có nhiều widget phụ thuộc vào các "slice" khác nhau của cùng một state lớn, Riverpod's derived provider pattern thường cho performance tốt hơn vì nó cache kết quả computed ở framework level, không phải widget level.

---

## 6. Side Effects & Async

### Bloc

```dart
on<FetchProducts>(_onFetch);

Future<void> _onFetch(FetchProducts event, Emitter<ProductState> emit) async {
  emit(state.copyWith(status: Status.loading));
  try {
    final products = await _repo.fetchProducts(page: event.page);
    emit(state.copyWith(
      status: Status.success,
      products: [...state.products, ...products],
      hasReachedMax: products.isEmpty,
    ));
  } catch (e) {
    emit(state.copyWith(status: Status.failure, error: e.toString()));
  }
}
```

Side effect xảy ra **bên trong** event handler. Rõ ràng, dễ trace, nhưng mọi side effect đều phải đi qua event dispatch → handler.

### Riverpod

```dart
class ProductNotifier extends AsyncNotifier<List<Product>> {
  int _page = 0;

  @override
  Future<List<Product>> build() => _fetch();

  Future<List<Product>> _fetch() {
    return ref.read(productRepoProvider).fetchProducts(page: _page);
  }

  Future<void> loadMore() async {
    _page++;
    final previous = state.valueOrNull ?? [];
    state = const AsyncLoading<List<Product>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final next = await _fetch();
      return [...previous, ...next];
    });
  }
}
```

Riverpod có `ref.listen` cho fire-and-forget side effect (navigation, snackbar):

```dart
ref.listen(authProvider, (prev, next) {
  if (next.value == null) {
    navigator.pushReplacementNamed('/login');
  }
});
```

Bloc tương đương dùng `BlocListener`:

```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthInitial) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  },
)
```

Cả hai đều xử lý được, nhưng Riverpod's `ref.listen` linh hoạt hơn vì không cần nằm trong widget tree.

---

## 7. Lifecycle Management

### Bloc

Bloc lifecycle gắn với widget tree qua `BlocProvider`. Khi widget bị dispose, bloc cũng `close()`. Bạn kiểm soát scope bằng cách đặt `BlocProvider` ở vị trí phù hợp trong tree.

```dart
// Bloc sống trong scope của MaterialApp → global
MaterialApp(
  home: BlocProvider(
    create: (_) => AuthBloc(repo),
    child: AppShell(),
  ),
)

// Bloc sống trong scope của một page → page-level
BlocProvider(
  create: (_) => ProductDetailBloc(repo)..add(LoadProduct(id)),
  child: ProductDetailPage(),
)
```

**Vấn đề:** Nếu bạn cần access bloc ngoài scope (ví dụ deep link handler), bạn phải đảm bảo bloc đã được provide ở level cao đủ, hoặc dùng global service locator. Điều này dễ gây scope leak.

### Riverpod

```dart
// Auto-dispose khi không còn listener
@riverpod
Future<ProductDetail> productDetail(Ref ref, String id) async {
  ref.onDispose(() => print('Cleaned up for $id'));
  return ref.watch(productRepoProvider).getDetail(id);
}

// Keep alive thủ công khi cần
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository();
}
```

Riverpod quản lý lifecycle **tự động** dựa trên listener count. Provider không có ai watch → auto dispose. Bạn có thể override bằng `keepAlive`. Điều này elegant hơn đáng kể so với việc phải suy nghĩ "đặt BlocProvider ở đâu trong tree".

**Senior insight:** Trong app có nhiều feature module lazy-loaded, Riverpod's auto-dispose giúp memory management tốt hơn mà không cần quản lý thủ công.

---

## 8. Testing

### Bloc: Structured, predictable

```dart
blocTest<AuthBloc, AuthState>(
  'emits [loading, success] when login succeeds',
  build: () {
    when(() => mockRepo.login(any(), any()))
        .thenAnswer((_) async => testUser);
    return AuthBloc(mockRepo);
  },
  act: (bloc) => bloc.add(LoginRequested('a@b.com', '123')),
  expect: () => [
    AuthLoading(),
    AuthSuccess(testUser),
  ],
);
```

`blocTest` là gold standard cho predictable state testing. Input (event) → Output (state sequence). Cực kỳ dễ đọc, dễ review.

### Riverpod: Flexible, nhưng ít structured

```dart
test('login updates state correctly', () async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ],
  );
  addTearDown(container.dispose);

  when(() => mockRepo.login(any(), any()))
      .thenAnswer((_) async => testUser);

  final notifier = container.read(authProvider.notifier);
  await notifier.login('a@b.com', '123');

  expect(
    container.read(authProvider).value,
    testUser,
  );
});
```

Test được nhưng không có built-in utility tương đương `blocTest` để assert **sequence of states**. Bạn phải tự collect states nếu muốn verify intermediate states (loading → success).

**Senior take:** Nếu team bạn coi trọng state transition testing (verify rằng loading state luôn xuất hiện trước success), Bloc có tooling tốt hơn out-of-the-box. Riverpod test functional hơn — verify kết quả cuối, ít quan tâm intermediate.

---

## 9. DevTools & Debugging

### Bloc

`BlocObserver` là killer feature:

```dart
class AppBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    log('${bloc.runtimeType}: ${transition.event} → ${transition.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('${bloc.runtimeType} error: $error');
  }
}
```

Mỗi event dispatch, mỗi state transition, mỗi error — đều được capture globally. Khi production có bug report, bạn replay event log là reproduce được. Đây là lợi thế chiến lược cho app phức tạp.

### Riverpod

Riverpod có `ProviderObserver` tương tự nhưng observe ở mức **provider state change**, không có event context:

```dart
class AppObserver extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderBase provider, Object? prev, Object? next, ProviderContainer container) {
    log('${provider.name}: $prev → $next');
  }
}
```

Bạn biết state thay đổi, nhưng không biết **tại sao** nó thay đổi (method nào được gọi). Để debug, bạn phải thêm logging vào từng method trong notifier.

---

## 10. Khi nào chọn cái nào

### Chọn **Bloc** khi:

- App có business logic phức tạp với nhiều branching (payment flow, booking system, multi-step wizard)
- Team lớn (5+ dev) cần convention chung — Bloc enforce pattern nên code giữa các dev consistent
- Cần audit trail, event replay, hoặc analytics tracking theo user action
- Regulatory requirement cần trace mọi state change (fintech, healthcare)
- App xử lý nhiều concurrent event cần throttle/debounce/drop tại logic layer

### Chọn **Riverpod** khi:

- App phụ thuộc nhiều vào async data (REST/GraphQL), cần caching và auto-refresh
- Cần DI phức tạp với dependency chain dài mà không muốn thêm package
- Team thích functional/reactive style hơn OOP/event-driven
- Cần fine-grained rebuild optimization cho UI performance-critical app
- App có nhiều feature module cần lazy loading và auto-dispose state
- Cần access state ngoài widget tree (background task, deep link handler)

### Hoặc kết hợp cả hai:

Nhiều production app dùng **Riverpod cho DI + simple state** và **Bloc cho complex business flow**. Ví dụ: Riverpod manage theme, locale, auth token, API client. Bloc handle checkout flow, chat messaging, form validation phức tạp. Điều quan trọng là team phải có guideline rõ ràng khi nào dùng gì để tránh inconsistency.

---

## Tóm tắt một dòng

**Bloc** giỏi trả lời *"chuyện gì đã xảy ra và tại sao state thay đổi"*. **Riverpod** giỏi trả lời *"state hiện tại phụ thuộc vào những gì và khi nào nên dispose"*. Senior developer hiểu cả hai và chọn dựa trên bài toán thực tế, không phải sở thích cá nhân.
