## Riverpod Code Generation — Hướng dẫn chi tiết

### 1. Vấn đề Code Generation giải quyết

Riverpod không dùng code generation có rất nhiều Provider type, mỗi type lại có variant `autoDispose` và `family`, tạo ra ma trận phức tạp:

```
                          Thường        AutoDispose       Family         AutoDispose + Family
─────────────────────────────────────────────────────────────────────────────────────────────
Provider                  Provider      Provider.ad       Provider.f     Provider.ad.f
StateProvider             StateP...     StateP.ad         StateP.f       StateP.ad.f
FutureProvider            FutureP...    FutureP.ad        FutureP.f      FutureP.ad.f
StreamProvider            StreamP...    StreamP.ad        StreamP.f      StreamP.ad.f
NotifierProvider          NotifierP...  NotifierP.ad      NotifierP.f    NotifierP.ad.f
AsyncNotifierProvider     AsyncNP...    AsyncNP.ad        AsyncNP.f      AsyncNP.ad.f
StateNotifierProvider     StateNP...    StateNP.ad        StateNP.f      StateNP.ad.f
ChangeNotifierProvider    ChangeNP...   ChangeNP.ad       ChangeNP.f     ChangeNP.ad.f

// → 32+ loại Provider, mỗi loại có class name khác nhau
// → Dễ nhầm, khó nhớ, khó refactor
```

Code generation rút gọn thành: **viết class hoặc function + thêm `@riverpod`** → tool tự quyết định Provider type phù hợp.

---

### 2. Setup

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

dev_dependencies:
  riverpod_generator: ^2.6.3
  build_runner: ^2.4.9
  riverpod_lint: ^2.6.3      # lint rules (khuyên dùng)
  custom_lint: ^0.7.0         # required by riverpod_lint
```

```bash
flutter pub get

# Chạy code generation
dart run build_runner build --delete-conflicting-outputs

# Hoặc watch mode — tự generate khi file thay đổi
dart run build_runner watch --delete-conflicting-outputs
```

---

### 3. So sánh chi tiết: Không codegen vs Có codegen

#### 3.1 Simple Provider (đồng bộ, không tham số)

```dart
// ❌ Không codegen
final greetingProvider = Provider<String>((ref) {
  return 'Hello World';
});
```

```dart
// ✅ Có codegen
// file: greeting_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'greeting_provider.g.dart';  // file generated

@riverpod
String greeting(Ref ref) {
  return 'Hello World';
}
// → Generator tạo: greetingProvider (AutoDispose mặc định)
```

**Quy tắc đặt tên:** function name `greeting` → provider name `greetingProvider`. Generator tự thêm suffix `Provider`.

#### 3.2 FutureProvider (async, không tham số)

```dart
// ❌ Không codegen
final servicesProvider =
    FutureProvider.autoDispose<List<ServicesDocumentData>>((ref) async {
  try {
    final value = await FirebaseFunctionsClient.instance.getServiceInfo();
    return value;
  } catch (e) {
    DebugUtil.logger.e('get services failed: $e');
    return [];
  }
});
```

```dart
// ✅ Có codegen
// Generator thấy return type là Future → tự tạo FutureProvider
@riverpod
Future<List<ServicesDocumentData>> services(Ref ref) async {
  try {
    final value = await FirebaseFunctionsClient.instance.getServiceInfo();
    return value;
  } catch (e) {
    DebugUtil.logger.e('get services failed: $e');
    return [];
  }
}
// → Generator tạo: servicesProvider (AutoDispose + FutureProvider)
```

#### 3.3 StreamProvider

```dart
// ❌ Không codegen
final messagesProvider = StreamProvider.autoDispose<List<Message>>((ref) {
  return FirebaseFirestore.instance
      .collection('messages')
      .snapshots()
      .map((snap) => snap.docs.map(Message.fromDoc).toList());
});
```

```dart
// ✅ Có codegen
// Generator thấy return type là Stream → tự tạo StreamProvider
@riverpod
Stream<List<Message>> messages(Ref ref) {
  return FirebaseFirestore.instance
      .collection('messages')
      .snapshots()
      .map((snap) => snap.docs.map(Message.fromDoc).toList());
}
```

#### 3.4 Family Provider (có tham số)

```dart
// ❌ Không codegen — phức tạp, phải dùng .family
final pointExchangeDetailProvider = FutureProvider.autoDispose
    .family<PointExchangeModel?, String>((ref, settingId) async {
  final exchanges = await ref.watch(pointExchangeAsyncNotifierProvider.future);
  return exchanges.firstWhereOrNull(
    (e) => e.pointExchangeSettingId == settingId,
  );
});

// Gọi:
ref.watch(pointExchangeDetailProvider('setting_docomo'));
```

```dart
// ✅ Có codegen — thêm tham số vào function signature, xong
@riverpod
Future<PointExchangeModel?> pointExchangeDetail(
  Ref ref,
  String settingId,  // ← tham số family
) async {
  final exchanges = await ref.watch(pointExchangeAsyncNotifierProvider.future);
  return exchanges.firstWhereOrNull(
    (e) => e.pointExchangeSettingId == settingId,
  );
}

// Gọi: giống hệt
ref.watch(pointExchangeDetailProvider('setting_docomo'));
```

#### 3.5 Family với nhiều tham số

```dart
// ❌ Không codegen — chỉ hỗ trợ 1 tham số, nhiều tham số phải tạo record/class
final filteredExchangesProvider = FutureProvider.autoDispose
    .family<List<PointExchangeModel>, ({String query, bool favoriteOnly})>(
  (ref, params) async {
    final exchanges = await ref.watch(pointExchangeAsyncNotifierProvider.future);
    return exchanges
        .where((e) => e.providerName.contains(params.query))
        .where((e) => !params.favoriteOnly || e.isFavorite)
        .toList();
  },
);

// Gọi:
ref.watch(filteredExchangesProvider((query: 'docomo', favoriteOnly: true)));
```

```dart
// ✅ Có codegen — thêm nhiều tham số thoải mái
@riverpod
Future<List<PointExchangeModel>> filteredExchanges(
  Ref ref,
  String query,        // tham số 1
  bool favoriteOnly,   // tham số 2
) async {
  final exchanges = await ref.watch(pointExchangeAsyncNotifierProvider.future);
  return exchanges
      .where((e) => e.providerName.contains(query))
      .where((e) => !favoriteOnly || e.isFavorite)
      .toList();
}

// Gọi:
ref.watch(filteredExchangesProvider('docomo', true));
// → Tự nhiên hơn, không cần record
```

#### 3.6 Notifier (có method để mutate state)

```dart
// ❌ Không codegen — phải nhớ đúng base class
final counterProvider =
    NotifierProvider.autoDispose<CounterNotifier, int>(CounterNotifier.new);

class CounterNotifier extends AutoDisposeNotifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}
```

```dart
// ✅ Có codegen
part 'counter_provider.g.dart';

@riverpod
class Counter extends _$Counter {
  //                  ↑
  //    class generated, chứa ref, state, build() signature
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}
// → Generator tạo: counterProvider, _$Counter base class
```

#### 3.7 AsyncNotifier (async + methods) — Ví dụ chính từ câu hỏi

```dart
// ❌ Không codegen
final provider = AsyncNotifierProvider.autoDispose
    .family<TodoNotifier, List<Todo>, String>(
  TodoNotifier.new,
);

class TodoNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Todo>, String> {
  //     ↑
  //     Tên class dài, dễ nhầm với:
  //     - AutoDisposeAsyncNotifier (không family)
  //     - FamilyAsyncNotifier (không autoDispose)
  //     - AsyncNotifier (không autoDispose, không family)

  @override
  Future<List<Todo>> build(String categoryId) async {
    return ref.watch(todoRepoProvider).getByCategory(categoryId);
  }

  Future<void> addTodo(Todo todo) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(todoRepoProvider).add(todo);
      return ref.read(todoRepoProvider).getByCategory(arg);
      //                                              ↑
      //                            "arg" là tên mặc định cho family parameter
      //                            không rõ ràng, dễ nhầm
    });
  }
}
```

```dart
// ✅ Có codegen
part 'todo_list_provider.g.dart';

@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build(String categoryId) async {
    //                      ↑
    //    tham số family nằm ngay trong build() — rõ ràng
    return ref.watch(todoRepoProvider).getByCategory(categoryId);
  }

  Future<void> addTodo(Todo todo) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(todoRepoProvider).add(todo);
      return ref.read(todoRepoProvider).getByCategory(categoryId);
      //                                              ↑
      //                            truy cập trực tiếp bằng tên tham số
      //                            thay vì "arg" mơ hồ
    });
  }
}

// Gọi:
ref.watch(todoListProvider('category_work'));
ref.read(todoListProvider('category_work').notifier).addTodo(newTodo);
```

---

### 4. File Generated trông như thế nào

Khi viết:

```dart
// file: todo_list_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'todo_list_provider.g.dart';

@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build(String categoryId) async {
    return ref.watch(todoRepoProvider).getByCategory(categoryId);
  }

  Future<void> addTodo(Todo todo) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(todoRepoProvider).add(todo);
      return ref.read(todoRepoProvider).getByCategory(categoryId);
    });
  }
}
```

Generator tạo file `todo_list_provider.g.dart`:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'todo_list_provider.dart';

// ━━━ Base class ━━━
abstract class _$TodoList
    extends BuildlessAutoDisposeAsyncNotifier<List<Todo>> {
  late final String categoryId;

  FutureOr<List<Todo>> build(String categoryId);

  @override
  FutureOr<List<Todo>> runBuild() {
    return build(categoryId);  // truyền categoryId vào build()
  }
}

// ━━━ Provider ━━━
final todoListProvider = AutoDisposeAsyncNotifierProviderFamily
    TodoList, List<Todo>, String>(
  TodoList.new,
  name: 'todoListProvider',
  debugGetCreateSourceHash: /* ... */,
);

// ━━━ Family override ━━━
// ... thêm code hỗ trợ .overrideWith() cho testing
```

Bạn không cần đọc hay sửa file `.g.dart`. Nó tự động được tạo và import qua directive `part`.

---

### 5. Quy tắc Generator tự quyết định Provider type

```dart
// Generator nhìn vào 2 yếu tố:
// 1. Function hay Class?
// 2. Return type là gì?

// ┌──────────────────┬───────────────────┬──────────────────────────────┐
// │ Viết gì          │ Return type       │ Generator tạo               │
// ├──────────────────┼───────────────────┼──────────────────────────────┤
// │ Function         │ T                 │ Provider<T>                 │
// │ Function         │ Future<T>         │ FutureProvider<T>           │
// │ Function         │ Stream<T>         │ StreamProvider<T>           │
// │ Function + param │ T                 │ Provider.family<T, Param>   │
// │ Class            │ T (build)         │ NotifierProvider<T>         │
// │ Class            │ Future<T> (build) │ AsyncNotifierProvider<T>    │
// │ Class            │ Stream<T> (build) │ StreamNotifierProvider<T>   │
// │ Class + param    │ Future<T> (build) │ AsyncNotifierProvider.family│
// └──────────────────┴───────────────────┴──────────────────────────────┘

// autoDispose là MẶC ĐỊNH cho tất cả
// Family được tự động thêm khi build() có tham số ngoài Ref
```

Ví dụ minh hoạ:

```dart
// Function + đồng bộ → Provider
@riverpod
String greeting(Ref ref) => 'Hello';

// Function + Future → FutureProvider
@riverpod
Future<List<Service>> services(Ref ref) async => fetchServices();

// Function + Stream → StreamProvider
@riverpod
Stream<User> userStream(Ref ref) => firestore.snapshots();

// Function + tham số → Provider.family
@riverpod
String greeting(Ref ref, String name) => 'Hello $name';

// Class + đồng bộ → NotifierProvider
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
}

// Class + Future → AsyncNotifierProvider
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build() async => fetchTodos();
}

// Class + Future + tham số → AsyncNotifierProvider.family
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build(String categoryId) async => fetchByCategory(categoryId);
}
```

---

### 6. Tắt autoDispose — `@Riverpod(keepAlive: true)`

Mặc định codegen tạo `autoDispose`. Muốn provider tồn tại vĩnh viễn:

```dart
// ❌ Không codegen
final serviceOperatorsProvider = StateNotifierProvider
    ServiceOperatorsNotifier, ServiceOperatorsDocumentData?>(
  (ref) => ServiceOperatorsNotifier(),
  // Không có autoDispose → sống mãi
);
```

```dart
// ✅ Có codegen
@Riverpod(keepAlive: true)  // ← tắt autoDispose
class ServiceOperators extends _$ServiceOperators {
  @override
  ServiceOperatorsDocumentData? build() {
    // setup Firestore listener...
    return null;
  }
}
```

So sánh:

```dart
@riverpod                        // → autoDispose (mặc định)
@Riverpod(keepAlive: true)       // → KHÔNG autoDispose, sống mãi
```

---

### 7. Migrate project hiện tại sang codegen

#### 7.1 servicesProvider

```dart
// TRƯỚC
final servicesProvider =
    FutureProvider.autoDispose<List<ServicesDocumentData>>((ref) async {
  try {
    final value = await FirebaseFunctionsClient.instance.getServiceInfo();
    return value;
  } catch (e) {
    DebugUtil.logger.e('get services failed: $e');
    return [];
  }
});
```

```dart
// SAU
part 'services_provider.g.dart';

@riverpod
Future<List<ServicesDocumentData>> services(Ref ref) async {
  try {
    final value = await FirebaseFunctionsClient.instance.getServiceInfo();
    return value;
  } catch (e) {
    DebugUtil.logger.e('get services failed: $e');
    return [];
  }
}
```

**Tên provider không đổi** — vẫn là `servicesProvider`. Mọi chỗ `ref.watch(servicesProvider)` giữ nguyên.

#### 7.2 serviceOperatorsStateNotifierProvider

```dart
// TRƯỚC
final serviceOperatorsStateNotifierProvider = StateNotifierProvider
    ServiceOperatorsNotifier, ServiceOperatorsDocumentData?>((ref) {
  return ServiceOperatorsNotifier();
});

class ServiceOperatorsNotifier
    extends StateNotifier<ServiceOperatorsDocumentData?> {
  StreamSubscription<DocumentSnapshot>? serviceOperatorsListener;

  ServiceOperatorsNotifier({Ref? ref}) : super(null) {
    // setup listener...
  }

  @override
  void dispose() {
    serviceOperatorsListener?.cancel();
    super.dispose();
  }
}
```

```dart
// SAU
part 'service_operators_provider.g.dart';

@Riverpod(keepAlive: true)  // không autoDispose vì cần sống suốt app
class ServiceOperators extends _$ServiceOperators {
  StreamSubscription<DocumentSnapshot>? _listener;

  @override
  ServiceOperatorsDocumentData? build() {
    // ref.onDispose thay cho override dispose()
    ref.onDispose(() {
      _listener?.cancel();
    });

    _setupListener();
    return null;
  }

  void _setupListener() {
    final collection = FirebaseFirestore.instance
        .collection(FirestoreCollectionNames.serviceOperators);

    _listener = collection
        .doc(ApiClient.instance.serviceOperatorId)
        .snapshots(includeMetadataChanges: false)
        .listen(
      (snapshot) {
        if (snapshot.exists) {
          state = ServiceOperatorsDocumentData.fromJson(
            snapshot.data() as Map<String, dynamic>,
          );
          if (state?.enableApigee != null) {
            ApigeeClient.instance.useApigee = state!.enableApigee!;
          }
        } else {
          state = null;
        }
      },
      onError: (error) =>
          DebugUtil.logger.e('serviceOperators listen failed: $error'),
    );
  }
}

// Gọi:
// TRƯỚC: ref.watch(serviceOperatorsStateNotifierProvider)
// SAU:   ref.watch(serviceOperatorsProvider)
```

#### 7.3 PointExchangeAsyncNotifier

```dart
// TRƯỚC
class PointExchangeAsyncNotifier
    extends AutoDisposeAsyncNotifier<List<PointExchangeModel>> {
  // ...
  @override
  Future<List<PointExchangeModel>> build() async {
    final services = await ref.watch(servicesProvider.future);
    // ...
  }
}

// Provider declaration ở đâu đó:
final pointExchangeAsyncNotifierProvider = AsyncNotifierProvider.autoDispose
    PointExchangeAsyncNotifier, List<PointExchangeModel>>(
  PointExchangeAsyncNotifier.new,
);
```

```dart
// SAU
part 'point_exchange_notifier.g.dart';

@riverpod
class PointExchangeAsyncNotifier extends _$PointExchangeAsyncNotifier {
  // Không cần khai báo provider riêng
  // Không cần nhớ AutoDisposeAsyncNotifier
  // Không cần generic type dài

  @override
  Future<List<PointExchangeModel>> build() async {
    final services = await ref.watch(servicesProvider.future);

    ref.onDispose(() {
      _pointExchangeSettingsListener?.cancel();
    });

    // ... giữ nguyên logic
  }

  // Tất cả method giữ nguyên
  Future<ExchangePointForDocomoResponse> exchangePointForDocomo(
    ExchangePointForDocomoRequest request,
  ) async {
    // ...
  }
}

// Gọi:
// TRƯỚC: ref.watch(pointExchangeAsyncNotifierProvider)
// SAU:   ref.watch(pointExchangeAsyncNotifierProvider)
//        ↑ tên tự generate từ class name, giống hệt
```

---

### 8. Codegen trong Testing

Override provider khi test:

```dart
// Không codegen — override bình thường
final container = ProviderContainer(
  overrides: [
    servicesProvider.overrideWith((ref) async => mockServices),
  ],
);

// Có codegen — giống hệt, API không đổi
final container = ProviderContainer(
  overrides: [
    servicesProvider.overrideWith((ref) async => mockServices),

    // Class provider override notifier
    pointExchangeAsyncNotifierProvider.overrideWith(
      () => MockPointExchangeNotifier(),
    ),

    // Family provider override
    todoListProvider.overrideWith(
      () => MockTodoList(),
    ),
  ],
);
```

---

### 9. Khi nào nên và không nên dùng codegen

**Nên dùng khi:**

Project mới bắt đầu hoặc đang refactor lớn. Team có nhiều người, cần consistency — codegen enforce cùng pattern cho mọi provider. Dùng nhiều family provider với nhiều tham số. Muốn tận dụng `riverpod_lint` đầy đủ (nhiều lint rule chỉ hoạt động với codegen).

**Cân nhắc khi:**

Project đang chạy ổn định với nhiều provider viết tay — migrate tốn effort và rủi ro regression. Team không quen `build_runner` hoặc thời gian generate lâu (project lớn). Chỉ có vài provider đơn giản — overhead setup không đáng.

**Lưu ý thực tế:**

`build_runner` có thể chạy chậm ở project lớn (30s–2min). Dùng `watch` mode để tự generate khi save file. File `.g.dart` phải được commit vào git, nếu không CI/CD phải chạy `build_runner` trước khi build app.
