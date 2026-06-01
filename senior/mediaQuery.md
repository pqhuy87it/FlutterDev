Chào bạn, **MediaQuery** là một trong những công cụ quan trọng nhất để làm **Responsive Design** (Thiết kế đáp ứng) trong Flutter.

Nếu ví ứng dụng của bạn là một người khách bước vào căn phòng, thì **`MediaQuery`** chính là người cung cấp thông tin về căn phòng đó: "Phòng này rộng bao nhiêu? Có đang bật đèn tối không? Có cái cột nhà (tai thỏ) nào chắn đường không?".

Dưới đây là giải thích chi tiết từ cơ bản đến nâng cao.

---

### 1. MediaQuery là gì?

`MediaQuery` cung cấp thông tin về kích thước, hướng màn hình, và các thiết lập hệ thống (như cỡ chữ, chế độ tối/sáng) của thiết bị hiện tại.

Cú pháp cơ bản nhất:

```dart
MediaQueryData data = MediaQuery.of(context);

```

Tuy nhiên, từ Flutter 3.10 trở đi, Google khuyến khích dùng các phương thức cụ thể hơn để tối ưu hiệu năng (sẽ giải thích ở mục 4).

---

### 2. Các thuộc tính quan trọng nhất

#### A. `size` (Kích thước màn hình)

Dùng để lấy chiều rộng và chiều cao của toàn bộ màn hình thiết bị.

```dart
final size = MediaQuery.of(context).size;
final width = size.width;
final height = size.height;

// Ví dụ: Tạo một Container rộng bằng 50% màn hình
Container(
  width: width * 0.5,
  color: Colors.red,
)

```

#### B. `orientation` (Hướng màn hình)

Kiểm tra xem điện thoại đang để dọc (Portrait) hay ngang (Landscape).

```dart
var orientation = MediaQuery.of(context).orientation;

if (orientation == Orientation.portrait) {
  // Đang dọc -> Xếp cột
  return Column(...);
} else {
  // Đang ngang -> Xếp hàng
  return Row(...);
}

```

#### C. `padding` (Vùng an toàn / Tai thỏ)

Rất quan trọng với các điện thoại có "Tai thỏ" (Notch) hoặc thanh điều hướng ảo phía dưới (Home Indicator trên iPhone X trở lên).

* `padding.top`: Chiều cao của thanh trạng thái (status bar) hoặc tai thỏ.
* `padding.bottom`: Chiều cao của vùng vuốt home phía dưới.

*Mẹo: Widget `SafeArea` thực chất sử dụng chính thuộc tính này để tự động tránh tai thỏ.*

#### D. `viewInsets` (Bàn phím ảo)

Thuộc tính này cho biết phần màn hình bị che khuất bởi bàn phím ảo.

* Khi bàn phím ẩn: `viewInsets.bottom = 0`.
* Khi bàn phím hiện: `viewInsets.bottom > 0` (bằng chiều cao bàn phím).

```dart
final bottomInset = MediaQuery.of(context).viewInsets.bottom;
if (bottomInset > 0) {
  print("Bàn phím đang mở!");
}

```

#### E. `textScaleFactor` (Cỡ chữ hệ thống)

Người dùng có thể chỉnh cỡ chữ to lên trong Cài đặt của điện thoại (dành cho người già/kém thị lực). Bạn dùng cái này để tính toán xem giao diện có bị vỡ khi chữ to lên không.

---

### 3. Ví dụ thực tế: Responsive đơn giản

```dart
class ResponsiveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final size = MediaQuery.of(context).size;
    
    // Logic: Nếu màn hình rộng hơn 600px (Tablet) thì dùng bố cục 2 cột
    bool isTablet = size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text("MediaQuery Demo")),
      body: isTablet 
          ? Row( // Tablet: Chia đôi màn hình
              children: [
                Expanded(child: Container(color: Colors.red)),
                Expanded(child: Container(color: Colors.blue)),
              ],
            )
          : Column( // Mobile: Xếp chồng lên nhau
              children: [
                Expanded(child: Container(color: Colors.red)),
                Expanded(child: Container(color: Colors.blue)),
              ],
            ),
    );
  }
}

```

---

### 4. Tối ưu hiệu năng (Quan trọng - Flutter 3.10+) 🚀

Trước đây, khi bạn gọi `MediaQuery.of(context)`, widget của bạn sẽ lắng nghe **mọi thay đổi** của MediaQueryData.

* *Vấn đề:* Nếu bàn phím hiện lên -> `viewInsets` thay đổi -> Widget `build` lại. Nhưng nếu widget của bạn chỉ cần quan tâm đến `size` (kích thước), việc nó rebuild khi bàn phím hiện lên là **lãng phí**.

**Giải pháp mới:** Hãy dùng các hàm trích xuất cụ thể (`.sizeOf`, `.orientationOf`, ...). Nó giúp widget chỉ rebuild khi đúng thuộc tính đó thay đổi.

| Cách cũ (Nên hạn chế) | Cách mới (Khuyên dùng) |
| --- | --- |
| `MediaQuery.of(context).size` | `MediaQuery.sizeOf(context)` |
| `MediaQuery.of(context).orientation` | `MediaQuery.orientationOf(context)` |
| `MediaQuery.of(context).padding` | `MediaQuery.paddingOf(context)` |
| `MediaQuery.of(context).platformBrightness` | `MediaQuery.platformBrightnessOf(context)` |

**Ví dụ tối ưu:**

```dart
@override
Widget build(BuildContext context) {
  // Chỉ rebuild khi KÍCH THƯỚC thay đổi.
  // Không rebuild khi bật tắt Dark Mode hay bật bàn phím.
  final width = MediaQuery.sizeOf(context).width; 

  return Container(width: width * 0.8);
}

```

### 5. Phân biệt MediaQuery vs LayoutBuilder

Rất nhiều bạn nhầm lẫn hai cái này.

* **MediaQuery**: Đo kích thước của **toàn màn hình thiết bị**.
* *Dùng khi:* Muốn quyết định giao diện tổng thể (Mobile vs Tablet), kiểm tra bàn phím, tai thỏ.


* **LayoutBuilder**: Đo kích thước của **Widget cha** chứa nó.
* *Dùng khi:* Muốn một widget con tự điều chỉnh dựa trên không gian mà widget cha cho phép (ví dụ: một Card trong danh sách).



### Tổng kết

1. Dùng **MediaQuery** để lấy thông tin màn hình (Rộng, Cao, Dọc, Ngang).
2. Ưu tiên dùng **`MediaQuery.sizeOf(context)`** thay vì `.of(context).size` để app mượt hơn.
3. Dùng nó để xử lý **Responsive** (chia layout Mobile/Tablet).
4. Dùng `viewInsets.bottom` để xử lý khi bàn phím che mất nội dung.
