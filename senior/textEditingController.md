Chào bạn, **TextEditingController** là "cánh tay phải" đắc lực khi làm việc với `TextField` hoặc `TextFormField` trong Flutter.

Hãy tưởng tượng:

* **TextField** là cái Tivi hiển thị hình ảnh (nội dung text).
* **TextEditingController** là cái **Remote (Điều khiển từ xa)**. Nếu bạn muốn chuyển kênh (sửa chữ), tắt tivi (xóa chữ), hay biết tivi đang chiếu gì (lấy nội dung), bạn phải dùng cái Remote này.

Dưới đây là hướng dẫn chi tiết từ A-Z.

---

### 1. Ba tác dụng chính của Controller

1. **Đọc dữ liệu:** Lấy nội dung người dùng đang nhập (`controller.text`).
2. **Ghi dữ liệu:** Thay đổi nội dung hiển thị từ code (`controller.text = "Hello"`).
3. **Lắng nghe:** Thực hiện hành động ngay khi người dùng gõ phím (Validation, Search).

---

### 2. Quy trình sử dụng chuẩn (4 Bước)

Vì Controller cần khởi tạo và hủy bỏ để tránh rò rỉ bộ nhớ, bạn **luôn luôn phải dùng nó trong `StatefulWidget**`.

#### Bước 1: Khai báo

```dart
class _MyScreenState extends State<MyScreen> {
  // 1. Tạo controller
  final TextEditingController _emailController = TextEditingController(); 

```

#### Bước 2: Gắn vào TextField

```dart
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _emailController, // 2. Kết nối Remote với Tivi
      decoration: InputDecoration(labelText: "Nhập Email"),
    );
  }

```

#### Bước 3: Sử dụng (Đọc/Ghi)

```dart
  void _submit() {
    // Đọc dữ liệu
    print("Email là: ${_emailController.text}");
    
    // Ghi dữ liệu (Ví dụ: Reset form)
    _emailController.text = ""; // Hoặc dùng _emailController.clear();
  }

```

#### Bước 4: Hủy (Dispose) - Cực kỳ quan trọng ⭐

Nếu bạn quên bước này, mỗi khi màn hình tắt đi bật lại, một controller mới được tạo ra nhưng cái cũ không mất đi -> **Tràn RAM (Memory Leak)**.

```dart
  @override
  void dispose() {
    _emailController.dispose(); // 3. Vứt bỏ Remote khi không xem Tivi nữa
    super.dispose();
  }
}

```

---

### 3. Kỹ thuật nâng cao: Lắng nghe sự thay đổi (Listener)

Bạn muốn làm tính năng: *Gõ đến đâu, validate hoặc search đến đó*. Có 2 cách, nhưng dùng Controller mạnh mẽ hơn.

```dart
@override
void initState() {
  super.initState();
  
  // Đăng ký lắng nghe
  _emailController.addListener(() {
    final text = _emailController.text;
    print("Người dùng đang gõ: $text");
    
    // Ví dụ: Kiểm tra xem có chứa @ chưa
    if (text.contains("@")) {
      print("Email hợp lệ");
    }
  });
}

```

*Lưu ý: Đã addListener thì nhớ removeListener hoặc dispose cẩn thận.*

---

### 4. Kỹ thuật "Khó": Xử lý con trỏ (Cursor/Selection)

Một vấn đề kinh điển người mới hay gặp: **Khi gán text bằng code (`controller.text = ...`), con trỏ chuột tự động nhảy về đầu dòng.**

Để khắc phục, bạn cần thao tác với thuộc tính `selection`.

```dart
// Ví dụ: Bạn muốn format số tiền: nhập 1000 -> tự sửa thành 1.000
_controller.text = "1.000";

// Lệnh này giữ con trỏ nằm ở cuối dòng sau khi sửa text
_controller.selection = TextSelection.fromPosition(
  TextPosition(offset: _controller.text.length)
);

```

---

### 5. So sánh: Dùng Controller hay onChanged?

`TextField` có thuộc tính `onChanged`. Vậy khi nào dùng cái nào?

| Tiêu chí | `onChanged` | `TextEditingController` |
| --- | --- | --- |
| **Mục đích** | Chỉ để **lấy** dữ liệu khi gõ. | Vừa lấy, vừa sửa, vừa xóa, vừa điều khiển con trỏ. |
| **Độ phức tạp** | Đơn giản, dùng cho Stateless được. | Phức tạp hơn, phải dùng Stateful và Dispose. |
| **Sức mạnh** | Yếu. Không thể gán giá trị mặc định lúc đầu. | Mạnh. Có thể gán giá trị ban đầu: `TextEditingController(text: "Abc")`. |

### 6. Code ví dụ tổng hợp

Dưới đây là một ví dụ hoàn chỉnh: Màn hình nhập tên, có nút Xóa, và hiển thị lời chào realtime.

```dart
import 'package:flutter/material.dart';

class ControllerDemo extends StatefulWidget {
  const ControllerDemo({super.key});

  @override
  State<ControllerDemo> createState() => _ControllerDemoState();
}

class _ControllerDemoState extends State<ControllerDemo> {
  // 1. Khai báo
  final _nameController = TextEditingController();
  String _greeting = "";

  @override
  void initState() {
    super.initState();
    // 2. Lắng nghe
    _nameController.addListener(() {
      setState(() {
        _greeting = "Xin chào, ${_nameController.text}";
      });
    });
  }

  @override
  void dispose() {
    // 3. Dọn dẹp
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController, // Gắn controller
              decoration: InputDecoration(
                labelText: "Nhập tên của bạn",
                // Nút xóa nhanh
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _nameController.clear(); // Xóa sạch text
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _greeting,
              style: const TextStyle(fontSize: 20, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

```
