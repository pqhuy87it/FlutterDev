Chào bạn, **ScopedModel** có thể được xem là "ông tổ" của Provider. Trước khi Provider trở thành chuẩn mực của Google, ScopedModel là thư viện quản lý trạng thái phổ biến nhất vì nó đơn giản hóa việc sử dụng `InheritedWidget`.

Nếu bạn hiểu **ScopedModel**, bạn sẽ thấy **Provider** hoạt động y hệt, chỉ là Provider xịn hơn và đa năng hơn.

Dưới đây là giải thích chi tiết.

---

### 1. ScopedModel là gì?

Nó là một thư viện bên thứ 3 (không phải có sẵn trong Flutter core, phải cài thêm gói `scoped_model`).

Cơ chế hoạt động của nó dựa trên mô hình **MVC (Model - View - Controller)** nhưng đơn giản hóa:

1. **Model:** Chứa dữ liệu và logic.
2. **ScopedModel (Widget):** Cung cấp Model cho toàn bộ widget con bên dưới (nhúng Model vào cây Widget).
3. **ScopedModelDescendant (Widget):** Lắng nghe thay đổi từ Model để vẽ lại giao diện.

---

### 2. Ba bước triển khai ScopedModel

Giả sử chúng ta làm ứng dụng đếm số (Counter App).

#### Bước 1: Tạo Model

Bạn phải tạo một class kế thừa từ `Model`. Class này giữ dữ liệu (`_count`) và hàm thay đổi dữ liệu (`increment`).

Quan trọng nhất là hàm **`notifyListeners()`**. Khi gọi hàm này, ScopedModel sẽ biết là dữ liệu đã đổi và báo cho giao diện vẽ lại.

```dart
import 'package:scoped_model/scoped_model.dart';

class CounterModel extends Model {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    // Báo hiệu cho các widget đang lắng nghe biết để vẽ lại
    notifyListeners();
  }
}

```

#### Bước 2: Cung cấp Model (Inject)

Bạn dùng widget `ScopedModel` bọc lấy phần cây widget muốn sử dụng dữ liệu này (thường là bọc ở đỉnh - Root).

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Tạo instance của Model
  final CounterModel counterModel = CounterModel();

  @override
  Widget build(BuildContext context) {
    // Bọc app bằng ScopedModel để truyền model xuống dưới
    return ScopedModel<CounterModel>(
      model: counterModel,
      child: MaterialApp(
        home: CounterScreen(),
      ),
    );
  }
}

```

#### Bước 3: Sử dụng dữ liệu (Consume)

Dùng widget `ScopedModelDescendant` để lấy dữ liệu. Bất cứ khi nào `notifyListeners()` được gọi, hàm `builder` này sẽ chạy lại.

```dart
class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scoped Model Demo')),
      body: Center(
        // Lắng nghe thay đổi từ CounterModel
        child: ScopedModelDescendant<CounterModel>(
          builder: (context, child, model) {
            return Text(
              'Số đếm: ${model.count}',
              style: TextStyle(fontSize: 30),
            );
          },
        ),
      ),
      floatingActionButton: ScopedModelDescendant<CounterModel>(
        builder: (context, child, model) {
          return FloatingActionButton(
            onPressed: model.increment, // Gọi hàm trong model
            child: Icon(Icons.add),
          );
        },
      ),
    );
  }
}

```

---

### 3. Ưu và nhược điểm

#### Ưu điểm:

* **Cực kỳ dễ hiểu:** Tách biệt rõ ràng Data (Model) và UI (View).
* **Không cần StatefulWidget:** Bạn có thể dùng `StatelessWidget` hoàn toàn vì trạng thái đã được `ScopedModel` quản lý.
* **Tự động cập nhật:** Không cần gọi `setState` thủ công.

#### Nhược điểm (Lý do nó bị thay thế bởi Provider):

* **Phụ thuộc vào class `Model`:** Bạn bắt buộc phải kế thừa class `Model` của thư viện. Trong khi `Provider` cho phép bạn dùng bất kỳ class nào (ChangeNotifier, Stream, Future...).
* **Rebuild diện rộng:** `ScopedModelDescendant` sẽ rebuild toàn bộ subtree bên trong nó mỗi khi model thay đổi. Nếu không cẩn thận đặt nó quá cao, hiệu năng sẽ kém.
* **Khó quản lý nhiều Model:** Nếu app cần nhiều model, bạn phải lồng nhau: `ScopedModel<A>(child: ScopedModel<B>(...))`. Provider giải quyết việc này tốt hơn bằng `MultiProvider`.

---

### 4. So sánh ScopedModel vs Provider

Thực tế, **Provider** chính là phiên bản tiến hóa của ScopedModel.

| Đặc điểm | ScopedModel | Provider |
| --- | --- | --- |
| **Class dữ liệu** | Phải kế thừa `Model`. | Bất kỳ class nào (dùng `ChangeNotifier`). |
| **Widget cung cấp** | `ScopedModel<T>` | `ChangeNotifierProvider`, `Provider`, v.v. |
| **Widget lắng nghe** | `ScopedModelDescendant<T>` | `Consumer<T>` |
| **Trạng thái hiện tại** | **Legacy (Cũ)** | **Standard (Chuẩn)** |

---

### 5. Kết luận: Có nên dùng ScopedModel không?

* **Nếu bạn đang bắt đầu dự án mới:** **KHÔNG**. Hãy dùng **Provider** hoặc **Riverpod**. Chúng mạnh mẽ hơn, hỗ trợ tốt hơn và là tiêu chuẩn hiện nay.
* **Nếu bạn đang bảo trì dự án cũ (3-4 năm trước):** Bạn cần hiểu ScopedModel để sửa code hoặc để migrate (chuyển đổi) nó sang Provider.

Việc chuyển từ `ScopedModel` sang `Provider` rất dễ:

1. Đổi `Model` thành `ChangeNotifier`.
2. Đổi `ScopedModel` thành `ChangeNotifierProvider`.
3. Đổi `ScopedModelDescendant` thành `Consumer`.

Logic bên trong gần như giữ nguyên 100%.
