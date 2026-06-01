Chào bạn, **Stack** là một trong những Widget thú vị và hữu ích nhất để tạo ra các giao diện đẹp mắt trong Flutter.

Nếu `Row` giúp bạn xếp các widget nằm ngang (trục X), `Column` xếp nằm dọc (trục Y), thì **`Stack`** giúp bạn xếp các widget **chồng lên nhau** (trục Z - chiều sâu).

Hãy tưởng tượng `Stack` giống như việc bạn dùng **Photoshop** hoặc xếp các tờ giấy lên bàn:

* Tờ giấy đặt xuống trước sẽ nằm ở dưới cùng (nền).
* Tờ giấy đặt xuống sau sẽ nằm đè lên trên.

Dưới đây là giải thích chi tiết và cách sử dụng:

---

### 1. Cơ chế hoạt động của Stack

Quy tắc quan trọng nhất của Stack là **thứ tự vẽ (Paint Order)**:

1. Widget nào nằm đầu tiên trong danh sách `children` sẽ được vẽ trước (nằm dưới cùng).
2. Widget nào nằm cuối cùng sẽ được vẽ sau (nằm trên cùng).

```dart
Stack(
  children: [
    WidgetA(), // Được vẽ đầu tiên -> Nằm dưới đáy (Background)
    WidgetB(), // Được vẽ đè lên WidgetA
    WidgetC(), // Được vẽ cuối cùng -> Nằm trên đỉnh (Top)
  ],
)

```

---

### 2. Hai loại Widget con trong Stack

Trong một `Stack`, các widget con được chia làm 2 loại dựa trên cách chúng được bao bọc:

#### A. Non-positioned (Không định vị)

Là những widget bình thường (như `Container`, `Text`, `Image`) thả trực tiếp vào Stack.

* **Vị trí:** Chúng sẽ tuân theo thuộc tính `alignment` của Stack (Mặc định là góc trên-trái `topStart`).
* **Kích thước:** Chúng tự quyết định kích thước hoặc bị ép theo Stack.

#### B. Positioned (Được định vị)

Là những widget được bọc bên trong widget **`Positioned`** hoặc **`Align`**.

* **Vị trí:** Bạn có thể neo nó vào bất kỳ đâu: `top`, `bottom`, `left`, `right`.
* **Kích thước:** Nếu bạn set cả `left` và `right`, widget sẽ bị kéo giãn ra chiều ngang.

---

### 3. Ví dụ thực tế: Banner quảng cáo & Avatar

#### Ví dụ 1: Chữ đè lên Ảnh (Banner)

```dart
Stack(
  alignment: Alignment.center, // 1. Căn giữa tất cả các con không định vị
  children: [
    // Lớp 1: Ảnh nền
    Image.network(
      'https://picsum.photos/300/200',
      width: 300,
      height: 200,
      fit: BoxFit.cover,
    ),
    
    // Lớp 2: Lớp phủ màu đen mờ (để chữ dễ đọc hơn)
    Container(
      width: 300,
      height: 200,
      color: Colors.black.withOpacity(0.3),
    ),

    // Lớp 3: Text nằm giữa (Do alignment của Stack)
    const Text(
      "Hello Flutter",
      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    ),

    // Lớp 4: Nút yêu thích ở góc phải trên (Dùng Positioned)
    const Positioned(
      top: 10,
      right: 10,
      child: Icon(Icons.favorite, color: Colors.red),
    ),
  ],
)

```

#### Ví dụ 2: Avatar có chấm xanh Online (Notification Badge)

```dart
Stack(
  clipBehavior: Clip.none, // Quan trọng: Cho phép chấm đỏ tràn ra ngoài avatar nếu cần
  children: [
    // 1. Avatar hình tròn
    const CircleAvatar(
      radius: 40,
      backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
    ),

    // 2. Chấm xanh trạng thái
    Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2), // Viền trắng cho nổi
        ),
      ),
    ),
  ],
)

```

---

### 4. Các thuộc tính quan trọng cần nhớ

1. **`alignment`**:
* Quyết định vị trí của các widget *không dùng Positioned*.
* Ví dụ: `Alignment.center`, `Alignment.bottomRight`.


2. **`fit` (StackFit)**:
* `StackFit.loose` (Mặc định): Widget con được phép nhỏ hơn Stack.
* `StackFit.expand`: Ép tất cả các widget con (không phải Positioned) phải phình to ra bằng kích thước của Stack. (Thường dùng khi muốn ảnh nền chiếm hết khung).


3. **`clipBehavior`**:
* Mặc định là `Clip.hardEdge` (Cắt bỏ phần thừa).
* Nếu bạn muốn làm hiệu ứng một widget con nằm "thò" ra ngoài Stack (ví dụ nút X ở góc banner), hãy set `clipBehavior: Clip.none`.



---

### 5. Khi nào dùng Stack?

* **Overlay:** Hiển thị chữ trên ảnh, icon trên nút.
* **Badge:** Hiển thị số lượng tin nhắn chưa đọc trên icon chuông.
* **Background:** Tạo các hình khối trang trí background phức tạp.
* **Loading:** Hiển thị vòng quay `CircularProgressIndicator` đè lên toàn bộ màn hình khi đang gọi API.

### Tóm lại

* **Row/Column**: Xếp gạch (Trục X, Y).
* **Stack**: Xếp bánh kếp (Trục Z).
* Dùng **`Positioned`** để ghim vị trí chính xác (top, right, bottom, left) bên trong Stack.
