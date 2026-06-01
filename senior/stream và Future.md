Chào bạn, sự khác biệt giữa **Future** và **Stream** là nền tảng cốt lõi của lập trình bất đồng bộ (Asynchronous) trong Dart và Flutter.

Hãy tưởng tượng đơn giản nhất:

* **Future**: Giống như bạn **chụp một bức ảnh**. Bạn bấm máy, chờ một chút (xử lý), và nhận được **một tấm ảnh duy nhất**. Sau đó quá trình kết thúc.
* **Stream**: Giống như bạn **quay một đoạn video**. Hình ảnh cứ liên tục xuất hiện nối tiếp nhau theo thời gian cho đến khi bạn bấm dừng.

Dưới đây là giải thích chi tiết về kỹ thuật và cách sử dụng.

---

### 1. Future (Tương lai - Đơn giá trị)

**Future** đại diện cho một giá trị (hoặc lỗi) sẽ có trong tương lai, nhưng **chỉ xảy ra đúng 1 lần**.

* **Cơ chế:**
1. Bắt đầu (Uncompleted).
2. Chờ đợi xử lý...
3. Kết thúc (Completed) -> Trả về **Dữ liệu** hoặc **Lỗi**.
4. Đóng lại ngay lập tức.


* **Cách dùng:**
* Dùng từ khóa `async` / `await` để lấy giá trị.
* Dùng `.then()` (cách cũ).


* **Ví dụ thực tế:**
* Gọi API lấy thông tin Profile (chỉ lấy 1 lần).
* Đọc nội dung một file text.
* Hiển thị hộp thoại (Dialog) và chờ người dùng chọn "Yes" hoặc "No".



**Code ví dụ:**

```dart
// Future: Chỉ trả về 1 số ngẫu nhiên sau 2 giây rồi dừng
Future<int> getRandomNumber() async {
  await Future.delayed(Duration(seconds: 2));
  return 100; // Xong nhiệm vụ
}

```

---

### 2. Stream (Luồng - Đa giá trị)

**Stream** đại diện cho một chuỗi các giá trị (hoặc lỗi) xuất hiện rải rác theo thời gian. Nó có thể phát ra 0, 1 hoặc n giá trị.

* **Cơ chế:**
1. Bắt đầu (Mở ống nước).
2. Có dữ liệu 1 -> Đẩy ra.
3. Nghỉ...
4. Có dữ liệu 2 -> Đẩy ra.
5. ...
6. Có lỗi -> Đẩy ra.
7. Kết thúc (Done) -> Đóng ống nước (Tùy chọn, stream có thể chạy mãi mãi).


* **Cách dùng:**
* Dùng `listen` để lắng nghe liên tục.
* Dùng `StreamBuilder` để vẽ UI cập nhật liên tục.
* Dùng từ khóa `async*` và `yield` để tạo stream.


* **Ví dụ thực tế:**
* Lắng nghe vị trí GPS khi di chuyển (cập nhật liên tục).
* Đếm ngược đồng hồ (Timer): 10, 9, 8...
* Chat Realtime (WebSocket): Tin nhắn tới liên tục.
* Sự kiện click chuột liên tiếp.



**Code ví dụ:**

```dart
// Stream: Trả về 1 số mỗi giây (1, 2, 3...)
Stream<int> countSeconds() async* {
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i; // Đẩy số i ra, nhưng hàm không dừng hẳn mà chạy tiếp vòng lặp
  }
}

```

---

### 3. Bảng so sánh chi tiết

| Đặc điểm | Future | Stream |
| --- | --- | --- |
| **Số lượng dữ liệu** | Duy nhất **1** giá trị (hoặc 1 lỗi). | **Nhiều** giá trị (vô hạn hoặc hữu hạn). |
| **Trạng thái** | Uncompleted -> Completed. | Active -> Data/Error... -> Done. |
| **Cách lấy dữ liệu** | `await` hoặc `.then()`. | `.listen()` hoặc `await for`. |
| **Widget tương ứng** | `FutureBuilder`. | `StreamBuilder`. |
| **Từ khóa tạo hàm** | `async` / `return`. | `async*` / `yield`. |
| **Ví dụ đời thường** | Giao hàng (Nhận gói hàng là xong). | Băng chuyền sân bay (Hành lý cứ trôi qua liên tục). |

---

### 4. Khi nào dùng cái nào?

Hãy tự hỏi: **"Dữ liệu này trả về một cục hay trả về lắt nhắt?"**

1. **Dùng Future khi:**
* Bạn gọi REST API (GET, POST).
* Bạn chụp ảnh từ Camera.
* Bạn đọc cài đặt (SharedPreferences).
* *Tóm lại:* Hành động dạng "Hỏi - Đáp" (Request - Response).


2. **Dùng Stream khi:**
* Bạn tải file lớn (cần xem % download: 10%... 50%... 100%).
* Bạn làm app Chat, Chứng khoán (giá nhảy liên tục).
* Bạn theo dõi trạng thái đăng nhập (Login/Logout) từ Firebase (`authStateChanges`).
* *Tóm lại:* Hành động dạng "Theo dõi - Cập nhật" (Subscribe - Update).



### Tóm tắt

* **Future** = Một món quà (Chờ -> Nhận -> Hết).
* **Stream** = Vòi nước (Mở -> Chảy liên tục -> Khóa).
