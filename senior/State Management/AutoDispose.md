# AutoDispose trong Riverpod — Bức tranh toàn cảnh

Đây là một trong những "pain point" nổi tiếng nhất của Riverpod khi dùng **manual declaration** (không dùng code generation). Lý do: mỗi provider type nhân với mỗi modifier (AutoDispose, Family) tạo ra **combinatorial explosion**.

---

## Cấu trúc tổ hợp

Riverpod 2.x có **mỗi provider type** đều sinh ra 4 biến thể:

```
Base
Base.autoDispose
Base.family
Base.autoDispose.family
```

---

## Danh sách đầy đủ các class chứa "AutoDispose"

### Provider classes (AutoDispose variant)

| Base Provider | AutoDispose variant | AutoDispose + Family variant |
|---|---|---|
| `Provider` | `AutoDisposeProvider` | `AutoDisposeFamilyProvider` |
| `StateProvider` | `AutoDisposeStateProvider` | `AutoDisposeFamilyStateProvider` |
| `FutureProvider` | `AutoDisposeFutureProvider` | `AutoDisposeFamilyFutureProvider` |
| `StreamProvider` | `AutoDisposeStreamProvider` | `AutoDisposeFamilyStreamProvider` |
| `StateNotifierProvider` | `AutoDisposeStateNotifierProvider` | `AutoDisposeFamilyStateNotifierProvider` |
| `ChangeNotifierProvider` | `AutoDisposeChangeNotifierProvider` | `AutoDisposeFamilyChangeNotifierProvider` |
| `NotifierProvider` | `AutoDisposeNotifierProvider` | `AutoDisposeFamilyNotifierProvider` |
| `AsyncNotifierProvider` | `AutoDisposeAsyncNotifierProvider` | `AutoDisposeFamilyAsyncNotifierProvider` |
| `StreamNotifierProvider` | `AutoDisposeStreamNotifierProvider` | `AutoDisposeFamilyStreamNotifierProvider` |

→ **18 provider classes** chứa AutoDispose

### Notifier base classes (AutoDispose variant)

| Base Notifier | AutoDispose variant | AutoDispose + Family variant |
|---|---|---|
| `Notifier` | `AutoDisposeNotifier` | `AutoDisposeFamilyNotifier` |
| `AsyncNotifier` | `AutoDisposeAsyncNotifier` | `AutoDisposeFamilyAsyncNotifier` |
| `StreamNotifier` | `AutoDisposeStreamNotifier` | `AutoDisposeFamilyStreamNotifier` |

→ **6 notifier classes** chứa AutoDispose

### Ref classes

| Base | AutoDispose variant |
|---|---|
| `Ref` | `AutoDisposeRef` |
| Các typed ref khác | `AutoDisposeProviderRef`, `AutoDisposeNotifierProviderRef`, v.v. |

→ Khoảng **3–5 ref classes** tùy version

---

## Tổng cộng: ~**27–29 class** chứa keyword AutoDispose

Và nếu tính cả **base + Family** variant (không chứa AutoDispose keyword nhưng cùng hệ thống), mỗi provider type có 4 biến thể, tổng hệ thống provider lên tới **36+ provider class** chỉ riêng phần declaration.

---

## Tại sao lại nhiều như vậy?

Dart **không có union type** hay **type-level modifier** kiểu TypeScript. Trong TypeScript bạn có thể viết:

```typescript
// Giả sử TypeScript — chỉ cần 1 type với generic modifier
Provider<T, { autoDispose: true, family: true }>
```

Dart không làm được vậy, nên Riverpod buộc phải tạo **class riêng** cho mỗi tổ hợp modifier. Đây là hạn chế của ngôn ngữ, không phải design choice.

---

## Code Generation giải quyết triệt để

Đây chính là lý do Riverpod **strongly recommend** dùng `riverpod_generator`. Với code generation, bạn chỉ cần viết:

```dart
// AutoDispose là DEFAULT — không cần nhớ class name nào
@riverpod
Future<User> userProfile(Ref ref, String userId) async {
  return ref.watch(userRepoProvider).getProfile(userId);
}
// Generator tự sinh: AutoDisposeFamilyFutureProvider
// Bạn không bao giờ phải nhìn thấy class name đó

// Muốn keep alive? Chỉ cần 1 annotation
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository();
}
// Generator tự sinh: Provider (không AutoDispose)
```

Với Notifier:

```dart
@riverpod
class Cart extends _$Cart {
  @override
  List<Item> build() => [];

  void add(Item item) {
    state = [...state, item];
  }
}
// Generator sinh AutoDisposeNotifierProvider + tất cả boilerplate
```

So sánh trực quan:

```dart
// ❌ Manual: phải nhớ đúng class name
final userProvider = AutoDisposeFamilyFutureProvider<User, String>((ref, userId) {
  return ref.watch(userRepoProvider).getProfile(userId);
});

// ✅ Code gen: viết function bình thường, annotation lo phần còn lại
@riverpod
Future<User> user(Ref ref, String userId) async {
  return ref.watch(userRepoProvider).getProfile(userId);
}
```

---

## Senior Insight

Việc tồn tại ~27+ class AutoDispose là **technical debt từ thiết kế ban đầu**, và Remi Rousselet (tác giả Riverpod) đã thừa nhận điều này. Hướng đi chính thức của Riverpod là **code generation là default**, manual declaration chỉ còn cho những trường hợp đặc biệt.

Nếu team bạn dùng Riverpod mà **không dùng code generation**, bạn đang chấp nhận toàn bộ cognitive overhead của 30+ class name. Đây là một trong những lý do khiến nhiều team chọn Bloc — dù nhiều boilerplate hơn, nhưng class taxonomy đơn giản hơn đáng kể: chỉ có `Bloc`, `Cubit`, `BlocProvider`, `BlocBuilder`, `BlocListener`, `BlocConsumer`.
