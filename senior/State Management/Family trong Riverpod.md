# Hai cú pháp, cùng một kết quả

## Trả lời ngắn

**Không khác gì cả.** Đây là hai cú pháp khác nhau để khai báo cùng một thứ.

```dart
// Cú pháp 1: Modifier chain (recommended)
final provider = AsyncNotifierProvider.autoDispose.family<MyNotifier, Data, String>(
  MyNotifier.new,
);

// Cú pháp 2: Full class name
final provider = AutoDisposeFamilyAsyncNotifierProvider<MyNotifier, Data, String>(
  MyNotifier.new,
);

// → Cả hai sinh ra CÙNG MỘT type, cùng một behavior, cùng một runtime result
```

---

## Cơ chế bên trong

Modifier chain chỉ là **syntax sugar**. Khi bạn viết:

```dart
AsyncNotifierProvider          // trả về builder object
    .autoDispose               // trả về AutoDisposeModifier
    .family                    // trả về constructor cho AutoDisposeFamilyAsyncNotifierProvider
```

Mỗi `.` trả về một intermediate object, cuối cùng gọi đến **đúng cái class** mà cú pháp 2 gọi trực tiếp. Bạn có thể verify bằng cách hover lên provider trong IDE — cả hai đều resolve về cùng một type.

---

## Tại sao tồn tại hai cú pháp

### Full class name — cú pháp gốc

Riverpod ban đầu chỉ có cách này. Vấn đề rõ ràng: bạn phải **nhớ đúng thứ tự keyword** trong class name.

```dart
// Đúng
AutoDisposeFamilyAsyncNotifierProvider

// Nhầm thứ tự? → compile error, nhưng khó debug
FamilyAutoDisposeAsyncNotifierProvider  // ❌ không tồn tại
AsyncAutoDisposeFamilyNotifierProvider  // ❌ không tồn tại
```

Với 9 provider type × 4 variant = 36+ class name, việc nhớ chính xác là không thực tế.

### Modifier chain — cú pháp cải tiến

Remi Rousselet thêm modifier chain để giải quyết chính xác pain point trên:

```dart
// IDE autocomplete dẫn đường từng bước
AsyncNotifierProvider          // Bước 1: chọn provider type
    .autoDispose               // Bước 2: cần auto dispose? thêm vào
    .family                    // Bước 3: cần family? thêm vào
```

Lợi ích thực tế: **IDE autocomplete hoạt động ở mỗi bước**. Bạn gõ `AsyncNotifierProvider.` → IDE gợi ý `.autoDispose`, `.family`. Gõ tiếp `.autoDispose.` → IDE gợi ý `.family`. Không cần nhớ gì cả.

---

## So sánh trực quan tất cả variant

```dart
// Base
AsyncNotifierProvider<N, T>(...)

// AutoDispose only
AsyncNotifierProvider.autoDispose<N, T>(...)
// tương đương: AutoDisposeAsyncNotifierProvider<N, T>(...)

// Family only
AsyncNotifierProvider.family<N, T, Param>(...)
// tương đương: FamilyAsyncNotifierProvider<N, T, Param>(...)

// AutoDispose + Family
AsyncNotifierProvider.autoDispose.family<N, T, Param>(...)
// tương đương: AutoDisposeFamilyAsyncNotifierProvider<N, T, Param>(...)
```

Bốn dòng bên trái dễ đọc hơn rõ rệt so với bốn dòng bên phải.

---

## Notifier class tương ứng vẫn phải đúng

Một điểm hay bị nhầm: dù provider declaration dùng cú pháp nào, **notifier class bạn extend phải match đúng variant**:

```dart
// Provider dùng modifier chain
final provider = AsyncNotifierProvider.autoDispose.family<TodoNotifier, List<Todo>, String>(
  TodoNotifier.new,
);

// Notifier vẫn phải extend đúng class
class TodoNotifier extends AutoDisposeFamilyAsyncNotifier<List<Todo>, String> {
  @override
  Future<List<Todo>> build(String categoryId) async {
    return ref.watch(todoRepoProvider).getByCategory(categoryId);
  }
}
```

Provider declaration được cải tiến syntax, nhưng notifier base class **không có modifier chain** — bạn vẫn phải viết `AutoDisposeFamilyAsyncNotifier`. Đây là một trong những inconsistency còn tồn tại khi dùng manual declaration.

---

## Code generation loại bỏ cả hai cú pháp

```dart
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build(String categoryId) async {
    return ref.watch(todoRepoProvider).getByCategory(categoryId);
  }
}
// Generator tự quyết định dùng AutoDisposeFamilyAsyncNotifierProvider
// Bạn không bao giờ phải viết hay nhìn thấy nó
```

Tóm lại, modifier chain là **ergonomic improvement** cho cùng một hệ thống class. Trong codebase hiện tại nếu thấy cả hai style, chúng hoạt động giống hệt nhau — chỉ khác ở mức readability. Nếu team chưa dùng code generation, nên thống nhất dùng modifier chain cho consistency.
