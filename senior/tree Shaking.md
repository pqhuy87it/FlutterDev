Chào bạn, **Tree Shaking** (Rung cây) là một thuật ngữ thú vị và là một trong những cơ chế quan trọng nhất giúp ứng dụng Flutter của bạn trở nên nhỏ gọn và nhanh nhẹn khi đến tay người dùng.

Hãy tưởng tượng ứng dụng của bạn là một **cây táo xum xuê**.

* **Thân cây:** Là hàm `main()`, nơi bắt đầu mọi thứ.
* **Cành và Lá:** Là các hàm (functions), lớp (classes), và thư viện (libraries) mà bạn viết hoặc import vào.
* **Quả Táo (Live Code):** Là những đoạn code thực sự được sử dụng khi app chạy.
* **Lá khô/Cành chết (Dead Code):** Là những đoạn code bạn viết hoặc import thư viện về nhưng **không bao giờ dùng đến**.

**Tree Shaking** chính là hành động cầm thân cây và **rung thật mạnh**. Những gì dính chặt vào cây (được sử dụng) sẽ ở lại, còn lá khô (code thừa) sẽ rụng xuống và bị người làm vườn (Trình biên dịch) quét đi.

Dưới đây là giải thích chi tiết về cơ chế này trong Flutter:

---

### 1. Bản chất kỹ thuật: Dead Code Elimination

Trong khoa học máy tính, Tree Shaking thực chất là kỹ thuật **Dead Code Elimination** (Loại bỏ mã chết).

Khi bạn build ứng dụng ở chế độ **Release** (`flutter build apk/ios`), trình biên dịch Dart sẽ thực hiện quy trình sau:

1. **Bắt đầu từ `main()`:** Nó coi hàm `main()` là gốc.
2. **Duyệt đồ thị (Trace Graph):** Nó đi theo từng dòng code.
* Nếu `main()` gọi hàm A -> Đánh dấu A là "Sống".
* Nếu hàm A gọi Class B -> Đánh dấu B là "Sống".


3. **Loại bỏ phần thừa:** Sau khi duyệt xong, tất cả những hàm, biến, class nào không được đánh dấu "Sống" sẽ bị **xóa bỏ hoàn toàn** khỏi file nhị phân (binary file) cuối cùng.

---

### 2. Ví dụ thực tế dễ hiểu

Giả sử bạn import thư viện `material.dart`. Thư viện này khổng lồ, chứa hàng trăm Widget: `Button`, `Slider`, `Switch`, `Calendar`, `Table`...

Nhưng trong màn hình của bạn, bạn chỉ dùng đúng 1 cái **`Text`** và 1 cái **`ElevatedButton`**.

* **Nếu không có Tree Shaking:** Ứng dụng của bạn sẽ phải gánh toàn bộ code của `Slider`, `Switch`, `Table`... dù không bao giờ dùng tới. App sẽ nặng thêm cả chục MB vô nghĩa.
* **Nhờ có Tree Shaking:** Trình biên dịch thấy bạn không gọi `Slider`, nó sẽ cắt bỏ toàn bộ code cấu tạo nên `Slider` khỏi file cài đặt.

```dart
// Ví dụ minh họa
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// Hàm này được viết nhưng KHÔNG BAO GIỜ được gọi
void hamVoDung() {
  print("Tôi là lá khô, tôi sẽ bị Tree Shaking loại bỏ!");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Chỉ dùng Text, không dùng Slider hay Switch
      home: Text("Hello World"), 
    );
  }
}

```

=> Kết quả: Hàm `hamVoDung` và code của các widget không dùng sẽ biến mất khỏi bản Release.

---

### 3. Điều kiện để Tree Shaking hoạt động

Tree Shaking **KHÔNG** hoạt động mọi lúc. Bạn cần nhớ:

1. **Chỉ chạy ở Release Mode:**
* Ở **Debug Mode** (JIT compiler), Tree Shaking bị tắt. Tại sao? Vì Flutter cần giữ lại mọi đoạn code để phục vụ tính năng **Hot Reload**. Nếu xóa code thừa đi, lỡ tí nữa bạn sửa code và gọi đến hàm đó thì sao?
* Đó là lý do file APK bản Debug thường nặng gấp 3-4 lần bản Release.


2. **Dựa vào AOT (Ahead-of-Time):**
* Tree Shaking hoạt động hiệu quả nhất nhờ cơ chế biên dịch AOT của Dart. Vì Dart là ngôn ngữ định kiểu tĩnh (Statically Typed), trình biên dịch biết chính xác hàm nào gọi hàm nào ngay từ lúc build.



---

### 4. Tại sao Flutter không hỗ trợ Reflection (dart:mirrors)?

Đây là một kiến thức nâng cao liên quan mật thiết đến Tree Shaking.

**Reflection** là khả năng code tự kiểm tra và gọi chính nó thông qua **String** (Chuỗi ký tự) lúc đang chạy (Runtime).
Ví dụ: `goiHamTheoTen("hamA")`.

* Nếu cho phép Reflection, trình biên dịch sẽ bối rối: *"Lúc biên dịch tôi thấy `hamA` không được ai gọi trực tiếp cả, lẽ ra tôi nên xóa nó. Nhưng lỡ lúc chạy người dùng nhập chuỗi 'hamA' để gọi nó thì sao?"*
* Do đó, để bảo vệ khả năng Tree Shaking tối ưu nhất (giúp app nhỏ gọn nhất), Flutter **cấm hoàn toàn** việc sử dụng `dart:mirrors` và Reflection động.

### 5. Lợi ích của Tree Shaking

1. **Giảm dung lượng App:** Đây là lợi ích lớn nhất. Giúp app Flutter cạnh tranh được với Native về kích thước file tải về.
2. **Tăng tốc độ khởi động:** Ít code hơn nghĩa là CPU phải tải ít dữ liệu vào RAM hơn khi mở app.

### Tóm tắt

* **Tree Shaking** = Xóa code thừa khi đóng gói app.
* Chỉ hoạt động ở chế độ **Release**.
* Giúp app **nhẹ hơn** và **nhanh hơn**.
* Là lý do tại sao bạn có thể thoải mái import các thư viện lớn mà không sợ app bị phình to quá mức, miễn là bạn chỉ dùng những phần cần thiết.
