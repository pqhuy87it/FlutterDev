# Provider vs Riverpod

Cả hai đều do **Remi Rousselet** viết. Riverpod (anagram của "Provider") là bản viết lại để sửa những giới hạn cốt lõi mà Provider không thể sửa được vì nó bị ràng buộc vào `InheritedWidget`.

## Bảng so sánh nhanh

| Tiêu chí | Provider | Riverpod |
|---|---|---|
| Nền tảng | Wrapper quanh `InheritedWidget` | Độc lập, không phụ thuộc widget tree |
| Truy cập state | Bắt buộc có `BuildContext` | `ref` — dùng được cả ngoài UI layer |
| Lỗi không tìm thấy provider | Runtime (`ProviderNotFoundException`) | Compile-time |
| 2 provider cùng type | Không phân biệt được | Được, mỗi provider là 1 identity riêng |
| Kết hợp provider | `ProxyProvider` (rườm rà) | `ref.watch` bên trong provider |
| Async state | Tự quản lý loading/error | `AsyncValue` có sẵn |
| Auto dispose | Không có | `autoDispose` (mặc định với codegen) |
| Tham số hoá | Không | `family` |
| Testing | Cần `pumpWidget` để test qua context | `ProviderContainer` thuần Dart |
| Code generation | Không | `riverpod_generator` |
| Trạng thái dự án | Maintenance mode | Đang phát triển tích cực (v3.x) |

---

## 1. Sự khác biệt gốc rễ: phụ thuộc BuildContext

Đây là điểm quyết định mọi khác biệt còn lại.

**Provider** đọc state bằng cách đi ngược lên widget tree:

```dart
// Chỉ chạy được khi context nằm DƯỚI provider trong tree
final vm = context.read<UserViewModel>();

// Ngoài widget tree (service, repository, background isolate) → bó tay
```

Hệ quả thực tế bạn hay gặp:

```dart
// LỖI KINH ĐIỂN: dùng context của chính widget khai báo provider
Widget build(BuildContext context) {
  return Provider<Foo>(
    create: (_) => Foo(),
    child: Text(context.read<Foo>().name), // ProviderNotFoundException lúc runtime
  );
}
```

**Riverpod** khai báo provider ở top-level, `ref` là cửa duy nhất:

```dart
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider));
});

// Trong widget
class UserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(userRepositoryProvider);
    ...
  }
}
```

> **Lưu ý quan trọng:** provider là biến global nhưng **state không global**. State thực sự sống trong `ProviderContainer` (do `ProviderScope` tạo). Biến top-level chỉ là *declaration* — giống như một key type-safe.

---

## 2. Dependency injection: ProxyProvider vs ref.watch

Đây là chỗ Provider đau nhất trong app production.

### Provider

```dart
MultiProvider(
  providers: [
    Provider<ApiClient>(create: (_) => ApiClient()),

    ProxyProvider<ApiClient, UserRepository>(
      update: (_, api, previous) => UserRepository(api),
      dispose: (_, repo) => repo.dispose(),
    ),

    ChangeNotifierProxyProvider<UserRepository, UserViewModel>(
      create: (ctx) => UserViewModel(ctx.read<UserRepository>()),
      update: (_, repo, vm) => vm!..updateRepository(repo), // phải tự viết setter
    ),
  ],
  child: const MyApp(),
)
```

Vấn đề: thứ tự khai báo **có ý nghĩa**, sai thứ tự → crash runtime. Có 3 dependency thì phải dùng `ProxyProvider3`. Và `update` bắt buộc bạn phải mutate object cũ thay vì tạo mới, dễ sinh bug.

### Riverpod (codegen)

```dart
part 'user_providers.g.dart';

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final client = ApiClient();
  ref.onDispose(client.close);
  return client;
}

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  return UserRepository(ref.watch(apiClientProvider));
}
```

Không cần khai báo thứ tự, không cần `MultiProvider`, dependency graph tự suy ra. Khi `apiClientProvider` bị invalidate, `userRepositoryProvider` tự rebuild theo.

---

## 3. Async state: chỗ Riverpod thắng đậm nhất

### Provider — bạn tự quản lý 3 trạng thái

```dart
class UserViewModel extends ChangeNotifier {
  UserViewModel(this._repo);
  final UserRepository _repo;

  bool _isLoading = false;
  Object? _error;
  List<User> _users = const [];

  bool get isLoading => _isLoading;
  Object? get error => _error;
  List<User> get users => _users;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await _repo.fetchUsers();
    } catch (e, st) {
      _error = e;
      debugPrintStack(stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

Bạn viết đoạn boilerplate này lặp lại ở **mọi** ViewModel. Và nó không xử lý được race condition khi user gọi `load()` hai lần liên tiếp.

### Riverpod — `AsyncValue` lo hết

```dart
@riverpod
class UserList extends _$UserList {
  @override
  Future<List<User>> build() {
    return ref.watch(userRepositoryProvider).fetchUsers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userRepositoryProvider).fetchUsers(),
    );
  }

  Future<void> delete(String id) async {
    final previous = state;                    // optimistic update
    state = AsyncData([
      ...?state.valueOrNull?.where((u) => u.id != id),
    ]);
    try {
      await ref.read(userRepositoryProvider).delete(id);
    } catch (_) {
      state = previous;                        // rollback
      rethrow;
    }
  }
}
```

UI:

```dart
class UserListView extends ConsumerWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userListProvider);

    return users.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(userListProvider),
      ),
      data: (list) => ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) => UserTile(user: list[i]),
      ),
    );
  }
}
```

Thêm nữa, `AsyncValue` giữ `previousData` khi đang refresh — bạn có thể hiện list cũ + loading indicator thay vì nháy trắng màn hình:

```dart
data: (list) => Stack(children: [
  UserListBody(list),
  if (users.isRefreshing) const LinearProgressIndicator(),
]),
```

---

## 4. `family` và `autoDispose`

Provider không có khái niệm này. Muốn có provider theo `userId` bạn phải tự tạo `Map<String, ViewModel>` và tự dispose.

```dart
@riverpod
Future<UserDetail> userDetail(Ref ref, String userId) async {
  // autoDispose là mặc định với @riverpod
  final link = ref.keepAlive();                     // giữ cache tạm thời
  final timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(timer.cancel);

  return ref.watch(userRepositoryProvider).fetchDetail(userId);
}

// Sử dụng
final detail = ref.watch(userDetailProvider('u_123'));
```

Khi màn hình detail bị pop, provider tự dispose sau 5 phút — không leak, không phải viết `dispose()` thủ công.

---

## 5. Testing

### Provider

Test `ChangeNotifier` thuần thì dễ (nó chỉ là class Dart), nhưng test **cây DI** thì phải dựng widget:

```dart
testWidgets('hiển thị danh sách user', (tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: MockUserRepository()),
        ChangeNotifierProvider(create: (ctx) => UserViewModel(ctx.read())),
      ],
      child: const MaterialApp(home: UserListView()),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(UserTile), findsNWidgets(3));
});
```

### Riverpod — test được không cần Flutter

```dart
void main() {
  late MockUserRepository repo;

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => repo = MockUserRepository());

  test('load thành công trả về AsyncData', () async {
    when(() => repo.fetchUsers()).thenAnswer((_) async => [fakeUser]);

    final container = makeContainer();
    final sub = container.listen(userListProvider, (_, __) {});

    expect(sub.read(), const AsyncLoading<List<User>>());
    await container.read(userListProvider.future);
    expect(sub.read().value, [fakeUser]);
  });

  test('delete rollback khi API lỗi', () async {
    when(() => repo.fetchUsers()).thenAnswer((_) async => [fakeUser]);
    when(() => repo.delete(any())).thenThrow(Exception('500'));

    final container = makeContainer();
    await container.read(userListProvider.future);

    await expectLater(
      container.read(userListProvider.notifier).delete(fakeUser.id),
      throwsException,
    );
    expect(container.read(userListProvider).value, [fakeUser]); // đã rollback
  });
}
```

Chạy bằng `test` package thuần, nhanh hơn `flutter_test` rất nhiều — quan trọng với CI.

---

## 6. Tối ưu rebuild

Cả hai đều có `select`, nhưng cú pháp khác nhau:

```dart
// Provider
final name = context.select<UserViewModel, String>((vm) => vm.name);

// Riverpod
final name = ref.watch(userProvider.select((u) => u.name));
```

Riverpod thêm `ref.listen` để tách side-effect ra khỏi `build` (đúng chuẩn, không gây rebuild):

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  ref.listen(userListProvider, (prev, next) {
    next.whenOrNull(
      error: (e, _) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e'))),
    );
  });
  ...
}
```

Với Provider bạn phải nhét cái này vào `didChangeDependencies` hoặc dùng `addListener` thủ công.

---

## 7. Điểm mạnh còn lại của Provider

Nói công bằng, Provider chưa chết:

- **API nhỏ, học trong 1 buổi.** Riverpod có `Provider`, `NotifierProvider`, `AsyncNotifierProvider`, `StreamProvider`, `family`, `autoDispose`, `keepAlive`, `ref.watch/read/listen/invalidate`... — dễ dùng sai.
- **Không cần build_runner.** Riverpod với codegen bắt buộc chạy `dart run build_runner watch` — thêm một bước trong dev loop và trong CI.
- **Flutter team dùng Provider trong architecture guide chính thức** (MVVM + `ChangeNotifier` + `Command`). Nếu team bạn theo tài liệu chính chủ thì Provider hợp hơn.
- **Codebase legacy.** Migrate nửa vời còn tệ hơn giữ nguyên.
- Provider vẫn được maintain, không có deprecation warning.

---

## 8. Khuyến nghị chọn

**Chọn Riverpod khi:**
- Dự án mới, quy mô vừa/lớn
- Nhiều async data + caching (API-heavy app)
- Cần unit test DI graph mạnh
- Có nhiều dependency lồng nhau
- Team có kinh nghiệm, chấp nhận learning curve

**Giữ/chọn Provider khi:**
- App nhỏ, ít async state
- Codebase đang chạy ổn định, không có pain point rõ ràng
- Team junior hoặc onboarding nhanh là ưu tiên
- Không muốn thêm code generation vào pipeline

---

## 9. Đường migrate thực tế

Hai package **chạy song song được**. Đừng làm big-bang rewrite.

1. Thêm `flutter_riverpod` + bọc `ProviderScope` **bên ngoài** `MultiProvider` hiện tại.
2. Chuyển tầng dưới cùng trước: `ApiClient`, `Repository`, `SharedPreferences` → Riverpod `Provider`.
3. Cho Riverpod đọc ngược lên Provider tạm thời qua override lúc khởi tạo, hoặc ngược lại đọc Riverpod trong widget bằng `Consumer`.
4. Migrate từng feature/màn hình: `ChangeNotifier` → `Notifier` / `AsyncNotifier`.
5. Gỡ `MultiProvider` khi feature cuối cùng xong.

Có `riverpod_lint` với assist "Convert to Notifier" hỗ trợ bước 4.

---

## Về phiên bản

Riverpod 3.x đã ra stable, trong đó `StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider` bị đánh dấu legacy — mặc định nên dùng `Notifier`/`AsyncNotifier`. Codegen cũng đã thống nhất kiểu `ref` thành `Ref` thay vì các type sinh riêng như `UserRepositoryRef`.

Kiến thức của mình dừng ở khoảng tháng 5/2026, nên trước khi setup dự án bạn nên kiểm tra changelog mới nhất trên pub.dev — API của Riverpod thay đổi khá nhiều giữa các major version.
