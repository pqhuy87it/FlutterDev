Chào bạn, **StatefulWidget Lifecycle** (Vòng đời của StatefulWidget) là một trong những kiến thức nền tảng quan trọng nhất để kiểm soát ứng dụng Flutter. Nếu không hiểu rõ nó, bạn sẽ dễ gặp các lỗi như: rò rỉ bộ nhớ (memory leak), cập nhật UI không đúng lúc, hoặc ứng dụng bị crash khi gọi `setState` trên một widget đã bị hủy.

Hãy hình dung vòng đời này giống như cuộc đời của con người: **Sinh ra (Khởi tạo) -> Sống & Làm việc (Build/Update) -> Mất đi (Hủy).**

Dưới đây là sơ đồ và giải thích chi tiết từng giai đoạn.

---

### 1. Giai đoạn Khởi tạo (Initialization)

Đây là lúc Widget được sinh ra và đưa vào cây Widget (Widget Tree).

#### 1.1. `createState()`

* **Khi nào chạy:** Ngay lập tức khi Flutter bắt gặp `StatefulWidget`.
* **Nhiệm vụ:** Tạo ra một instance của class `State` đi kèm.
* **Lưu ý:** Hàm này thuộc về class Widget, không phải class State.

#### 1.2. `initState()` (Quan trọng ⭐)

* **Khi nào chạy:** Chạy **1 lần duy nhất** ngay sau khi State được tạo.
* **Nhiệm vụ:**
* Khởi tạo các biến (variables).
* Khởi tạo Controller (AnimationController, ScrollController, TextEditingController).
* Đăng ký lắng nghe Stream (Stream Subscription).


* **Lưu ý:**
* Không được dùng `context` để lấy dữ liệu (như `Theme.of(context)`) ở đây vì context chưa thiết lập xong.
* Không được gọi `setState()` ở đây.



#### 1.3. `didChangeDependencies()`

* **Khi nào chạy:**
* Chạy ngay sau `initState()`.
* Chạy mỗi khi các `InheritedWidget` mà nó phụ thuộc (như `Provider`, `Theme`, `MediaQuery`) thay đổi.


* **Nhiệm vụ:** Đây là nơi an toàn đầu tiên để bạn gọi `context` (ví dụ: lấy kích thước màn hình, lấy dữ liệu từ Provider).

---

### 2. Giai đoạn Xây dựng & Cập nhật (Building & Updating)

Đây là giai đoạn widget "đang sống" và hiển thị trên màn hình.

#### 2.1. `build()` (Quan trọng nhất ⭐)

* **Khi nào chạy:**
* Sau `didChangeDependencies()`.
* Sau khi gọi `setState()`.
* Sau khi `didUpdateWidget()`.


* **Nhiệm vụ:** Vẽ giao diện (UI). Hàm này phải chạy thật nhanh, không được để logic nặng (như gọi API) ở đây.

#### 2.2. `didUpdateWidget(oldWidget)`

* **Khi nào chạy:** Khi Widget cha (Parent) thay đổi cấu hình và render lại Widget con này (với cùng Runtime Type và Key).
* **Ví dụ:** Bạn có widget `Item(id: 1)`, sau đó cha nó đổi thành `Item(id: 2)`.
* **Nhiệm vụ:** So sánh dữ liệu cũ (`oldWidget`) và mới (`widget`) để cập nhật lại State nếu cần.
```dart
@override
void didUpdateWidget(MyWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.id != oldWidget.id) {
    _loadData(widget.id); // Load lại dữ liệu nếu ID thay đổi
  }
}

```



#### 2.3. `setState()`

* **Khi nào chạy:** Do lập trình viên chủ động gọi.
* **Nhiệm vụ:** Báo cho Flutter biết dữ liệu nội bộ đã thay đổi -> Kích hoạt chạy lại hàm `build()`.

---

### 3. Giai đoạn Hủy (Destruction)

Đây là lúc Widget bị xóa khỏi màn hình.

#### 3.1. `deactivate()`

* **Khi nào chạy:** Khi State bị gỡ khỏi cây Widget tạm thời (nhưng có thể được chèn lại vào chỗ khác). Ít khi dùng.

#### 3.2. `dispose()` (Cực kỳ quan trọng ⭐)

* **Khi nào chạy:** Khi Widget bị **xóa vĩnh viễn** khỏi cây Widget (ví dụ: chuyển sang màn hình khác, hoặc xóa item khỏi list).
* **Nhiệm vụ:** Dọn dẹp tài nguyên để tránh **Memory Leak**.
* `controller.dispose()`
* `streamSubscription.cancel()`
* Đóng kết nối Socket/Database.


* **Lưu ý:** Tuyệt đối không gọi `setState` sau khi đã dispose.

---

### 4. Tổng hợp bằng Code

Dưới đây là một ví dụ đầy đủ có gắn Log để bạn chạy thử và quan sát thứ tự:

```dart
import 'package:flutter/material.dart';

class LifecycleDemo extends StatefulWidget {
  final int count;
  const LifecycleDemo({super.key, required this.count});

  @override
  State<LifecycleDemo> createState() {
    print("1. createState");
    return _LifecycleDemoState();
  }
}

class _LifecycleDemoState extends State<LifecycleDemo> {
  
  @override
  void initState() {
    super.initState();
    print("2. initState - Khởi tạo biến, Controller");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("3. didChangeDependencies - Lắng nghe Provider/Theme");
  }

  @override
  void didUpdateWidget(covariant LifecycleDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("X. didUpdateWidget - Cha truyền dữ liệu mới: ${oldWidget.count} -> ${widget.count}");
  }

  @override
  Widget build(BuildContext context) {
    print("4. build - Vẽ giao diện");
    return Scaffold(
      body: Center(
        child: Text("Count: ${widget.count}"),
      ),
    );
  }

  @override
  void deactivate() {
    print("5. deactivate - Tạm dừng");
    super.deactivate();
  }

  @override
  void dispose() {
    print("6. dispose - Hủy, dọn dẹp bộ nhớ");
    super.dispose();
  }
}

```

### 5. Thuộc tính `mounted`

Có một thuộc tính đặc biệt bạn cần biết là **`mounted`** (boolean).

* `true`: State đang nằm trong cây Widget.
* `false`: State đã bị dispose.

**Mẹo:** Khi gọi API bất đồng bộ (Async), trước khi gọi `setState` cập nhật kết quả, hãy luôn kiểm tra `mounted` để tránh crash app nếu người dùng đã thoát màn hình trước khi API trả về.

```dart
void _fetchData() async {
  await Future.delayed(Duration(seconds: 3)); // Giả lập gọi API
  
  // Kiểm tra xem widget còn sống không
  if (mounted) { 
    setState(() {
      _data = "New Data";
    });
  }
}

```
