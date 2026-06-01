Chào bạn, đây là câu hỏi cốt lõi khi bắt đầu học Flutter. Hiểu rõ sự khác biệt giữa **StatelessWidget** và **StatefulWidget** sẽ giúp bạn thiết kế kiến trúc ứng dụng đúng đắn và tối ưu hiệu năng.

Hãy tưởng tượng đơn giản:

* **StatelessWidget** giống như một **bức ảnh chụp**. Khi đã in ra, nội dung của nó cố định, không thể thay đổi.
* **StatefulWidget** giống như một **đoạn video**. Nội dung của nó có thể chuyển động và thay đổi theo thời gian.

Dưới đây là giải thích chi tiết về kỹ thuật và cách sử dụng.

---

### 1. StatelessWidget (Widget phi trạng thái)

#### Định nghĩa

Là một Widget **bất biến (Immutable)**. Nghĩa là một khi nó đã được khởi tạo và vẽ lên màn hình, các thuộc tính (biến) bên trong nó **không thể thay đổi** được nữa.

#### Cơ chế hoạt động

* Nó chỉ phụ thuộc vào dữ liệu được truyền vào từ cha (thông qua Constructor).
* Nó chỉ được vẽ lại (rebuild) khi **Widget cha** của nó thay đổi hoặc được vẽ lại.
* Bản thân nó **không thể tự vẽ lại chính mình**.

#### Vòng đời (Lifecycle)

Rất đơn giản, chỉ có một hàm chính:

* `build()`: Trả về giao diện người dùng.

#### Khi nào dùng?

Dùng cho các thành phần giao diện tĩnh, chỉ dùng để hiển thị thông tin và không cần tương tác thay đổi giao diện nội tại.

* Logo, Icon.
* Text hiển thị tiêu đề.
* Các nút bấm đơn giản (chỉ nhận sự kiện `onTap` rồi gọi hàm của cha).

---

### 2. StatefulWidget (Widget có trạng thái)

#### Định nghĩa

Là một Widget **khả biến (Mutable)**. Nó có thể lưu trữ dữ liệu nội bộ (gọi là **State**) và có thể thay đổi giao diện dựa trên sự thay đổi của dữ liệu đó trong suốt quá trình ứng dụng chạy.

#### Cấu trúc đặc biệt

Một `StatefulWidget` thực chất được tách làm **2 class riêng biệt**:

1. **Class Widget:** Vẫn là bất biến (chứa các cấu hình từ cha truyền vào).
2. **Class State:** Là nơi chứa dữ liệu có thể thay đổi (mutable state) và hàm `build`.

> **Tại sao phải tách ra?** Để Flutter tối ưu hiệu năng. Khi vẽ lại giao diện, Flutter có thể vứt bỏ class Widget cũ và tạo cái mới rất nhanh, nhưng nó sẽ **giữ lại** class State (nơi chứa dữ liệu quan trọng) để không bị mất thông tin.

#### Cơ chế hoạt động (setState)

Vũ khí bí mật của StatefulWidget là hàm **`setState()`**.

* Khi bạn muốn thay đổi giao diện (ví dụ: bấm nút cộng số), bạn gọi `setState()`.
* Hàm này báo hiệu cho Flutter biết: *"Dữ liệu đã đổi rồi, hãy chạy lại hàm `build` đi!"*.

#### Vòng đời (Lifecycle)

Phức tạp hơn nhiều:

1. `createState()`: Tạo ra object State.
2. `initState()`: Chạy 1 lần duy nhất khi khởi tạo (dùng để gọi API, khởi tạo biến).
3. `build()`: Vẽ giao diện.
4. `setState()`: Kích hoạt vẽ lại (`build`).
5. `dispose()`: Chạy khi Widget bị hủy (dùng để đóng Stream, Controller).

#### Khi nào dùng?

Dùng cho bất kỳ thành phần nào cần tương tác và thay đổi giao diện:

* Checkbox, Radio button.
* Form nhập liệu (TextField).
* Màn hình có Loading, Animation.
* Màn hình đếm số (Counter).

---

### 3. Bảng so sánh tóm tắt

| Đặc điểm | StatelessWidget | StatefulWidget |
| --- | --- | --- |
| **Trạng thái (State)** | Không có (Tĩnh). | Có (Động). |
| **Thay đổi giao diện** | Không thể tự thay đổi. | Có thể tự thay đổi qua `setState()`. |
| **Cấu trúc** | 1 Class duy nhất. | 2 Class (Widget + State). |
| **Hàm quan trọng** | `build()`. | `initState()`, `setState()`, `dispose()`, `build()`. |
| **Hiệu năng** | Nhẹ, render nhanh hơn. | Nặng hơn một chút do phải quản lý State. |
| **Ví dụ** | `Text`, `Icon`, `Container`. | `Checkbox`, `Slider`, `TextField`. |

---

### 4. Ví dụ Code minh họa

#### StatelessWidget (Chỉ hiển thị Text)

```dart
class MyText extends StatelessWidget {
  final String text;
  
  // Dữ liệu nhận từ cha, không thể thay đổi bên trong class này
  const MyText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text); // Chỉ hiển thị
  }
}

```

#### StatefulWidget (Thay đổi màu nền khi bấm)

```dart
class MyButton extends StatefulWidget {
  const MyButton({super.key});

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  // Biến State: Có thể thay đổi
  bool isRed = false; 

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isRed ? Colors.red : Colors.blue, // UI phụ thuộc vào State
      ),
      onPressed: () {
        // Gọi setState để cập nhật UI
        setState(() {
          isRed = !isRed;
        });
      },
      child: const Text("Đổi màu"),
    );
  }
}

```

### Lời khuyên (Best Practice)

* **Luôn ưu tiên dùng StatelessWidget:** Hãy cố gắng dùng `StatelessWidget` nhiều nhất có thể vì nó nhẹ và ít lỗi.
* **Chỉ dùng StatefulWidget khi cần thiết:** Khi cần lưu trạng thái nội bộ hoặc dùng các hàm vòng đời (`initState`, `dispose`).
* **Kết hợp State Management:** Trong các dự án lớn, người ta thường dùng các thư viện quản lý State (như **Riverpod**, **Bloc**, **Provider**) để tách logic ra khỏi UI. Khi đó, ranh giới giữa StatelessWidget và StatefulWidget sẽ mờ dần (ví dụ `ConsumerWidget` trong Riverpod hoạt động giống Stateless nhưng lại lắng nghe được State).
