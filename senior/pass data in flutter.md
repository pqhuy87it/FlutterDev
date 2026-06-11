Chào bạn, việc truyền dữ liệu giữa các màn hình là một kỹ năng cốt lõi. Trong Flutter, có 3 cách phổ biến nhất, từ đơn giản đến nâng cao.

Vì bạn đang dùng **Riverpod** trong dự án của mình, mình sẽ nhấn mạnh cách thứ 3 (cách hiện đại nhất).

---

### Cách 1: Truyền trực tiếp qua Constructor (Cơ bản nhất)

Đây là cách đơn giản, trực quan nhất. Bạn gửi dữ liệu giống như truyền tham số vào một hàm.

**Kịch bản:** Từ màn hình Danh sách (`ListPage`) bấm vào một item để sang màn hình Chi tiết (`DetailPage`).

**1. Màn hình nhận (DetailPage):**
Khai báo biến trong `constructor`.

```dart
class DetailPage extends StatelessWidget {
  // Khai báo biến cần nhận
  final String userName;

  const DetailPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chi tiết")),
      body: Center(child: Text("Hello, $userName")),
    );
  }
}

```

**2. Màn hình gửi (ListPage):**
Truyền dữ liệu khi gọi `Navigator.push`.

```dart
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      // Truyền dữ liệu vào đây
      builder: (context) => DetailPage(userName: "Nguyễn Văn A"),
    ),
  );
}

```

---

### Cách 2: Truyền qua Route Settings (Named Routes)

Cách này dùng khi bạn quản lý điều hướng bằng tên (`/home`, `/detail`) trong `MaterialApp`.

**1. Màn hình gửi:**
Sử dụng `arguments`.

```dart
Navigator.pushNamed(
  context, 
  '/detail', 
  arguments: "Nguyễn Văn A", // Dữ liệu được gói ở đây
);

```

**2. Màn hình nhận:**
Lấy dữ liệu ra từ `ModalRoute`.

```dart
class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu ra và ép kiểu (Cast)
    final userName = ModalRoute.of(context)!.settings.arguments as String;

    return Text(userName);
  }
}

```

*Nhược điểm:* Không an toàn về kiểu dữ liệu (Type-safe). Nếu bạn truyền `String` mà màn hình kia ép kiểu sang `int` thì sẽ crash app.

---

### Cách 3: Dùng Riverpod (Khuyên dùng cho dự án của bạn) 🚀

Với kiến trúc bạn đang dùng, đây là cách chuyên nghiệp nhất để **tránh việc phải truyền dữ liệu qua quá nhiều lớp constructor**.

**Kịch bản:** Bạn muốn xem chi tiết một `Todo` dựa trên `todoId`.

#### Phương pháp A: Provider Family (Truyền ID và tự load lại)

Thay vì truyền cả object `Todo` to đùng, bạn chỉ truyền `id` sang màn hình mới. Màn hình mới dùng `id` đó để lấy dữ liệu từ Provider.

```dart
// 1. Tạo Provider có tham số (Family)
final todoDetailProvider = Provider.family<Todo, String>((ref, todoId) {
  // Logic tìm Todo trong list dựa vào ID
  final list = ref.watch(todoListProvider);
  return list.firstWhere((todo) => todo.id == todoId);
});

// 2. Màn hình chi tiết
class DetailScreen extends ConsumerWidget {
  final String todoId; // Chỉ cần nhận ID
  const DetailScreen({required this.todoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe dữ liệu dựa trên ID
    final todo = ref.watch(todoDetailProvider(todoId));
    
    return Text(todo.title);
  }
}

```

#### Phương pháp B: Shared State (Provider trung gian)

Dùng khi bạn muốn chọn một item và dùng nó ở nhiều nơi khác nhau.

```dart
// 1. Tạo một StateProvider để lưu item đang được chọn
final selectedTodoProvider = StateProvider<Todo?>((ref) => null);

// 2. Tại màn hình Danh sách (Lúc bấm chọn)
onTap: (todo) {
  // Gán dữ liệu vào Provider
  ref.read(selectedTodoProvider.notifier).state = todo;
  // Chuyển màn hình (Không cần truyền tham số gì cả)
  Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen()));
}

// 3. Tại màn hình Chi tiết (DetailScreen)
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Lấy dữ liệu từ kho chung
  final todo = ref.watch(selectedTodoProvider);
  
  if (todo == null) return Text("Chưa chọn gì cả");
  return Text(todo.title);
}

```

### Cách 4: Truyền ngược dữ liệu (Từ con về cha)

Ví dụ: Màn hình chọn ngày tháng, sau khi chọn xong thì quay lại màn hình chính và hiển thị ngày đã chọn.

**1. Màn hình con (CalendarScreen):**

```dart
// Khi chọn xong
Navigator.pop(context, "20/10/2023"); // Trả dữ liệu về khi đóng màn hình

```

**2. Màn hình cha:**

```dart
onTap: () async {
  // Phải dùng await để đợi kết quả trả về
  final result = await Navigator.push(
    context, 
    MaterialPageRoute(builder: (_) => CalendarScreen())
  );

  if (result != null) {
    print("Ngày đã chọn: $result");
  }
}

```

### Tổng kết: Nên dùng cách nào?

| Trường hợp | Nên dùng | Lý do |
| --- | --- | --- |
| Dữ liệu đơn giản, ít (String, Int, Object nhỏ) | **Cách 1 (Constructor)** | Nhanh, dễ hiểu, code ngắn. |
| Dữ liệu dùng chung cho toàn app, object phức tạp | **Cách 3 (Riverpod)** | Tách biệt UI và Data, dễ test, reactive. |
| Quản lý điều hướng bằng tên (Deep link) | **Cách 2 (Named Routes)** | Cần thiết cho Deep linking web/app. |

Với source code bạn gửi, khi bấm vào một Todo để sửa (Edit), mình khuyên dùng **Cách 1 (Constructor)** để truyền `Todo` object sang `TodoFormPage` cho đơn giản, hoặc dùng **Cách 3 (Riverpod Family)** nếu muốn đảm bảo dữ liệu luôn đồng bộ realtime.
