Chào bạn, **Flutter DevTools** giống như một "cỗ máy X-quang" dành cho ứng dụng của bạn. Nó cho phép bạn nhìn xuyên qua giao diện để thấy code chạy thế nào, mạng mẽo ra sao, và tại sao app lại bị giật lag.

Nếu lập trình Flutter mà không biết dùng DevTools thì giống như lái xe ban đêm mà không bật đèn vậy. Dưới đây là hướng dẫn chi tiết cách sử dụng các công cụ quan trọng nhất trong bộ DevTools.

---

### 1. Cách mở DevTools

Trước hết, ứng dụng của bạn **phải đang chạy** (ở chế độ Debug hoặc Profile).

* **Trên VS Code:**
* Mở Command Palette (`Cmd + Shift + P` trên Mac hoặc `Ctrl + Shift + P` trên Win).
* Gõ `DevTools` và chọn **"Dart: Open DevTools"**.
* Chọn **"Open DevTools in Web Browser"** (Khuyên dùng vì rộng rãi hơn).


* **Trên Android Studio:**
* Tìm biểu tượng cái tuốc nơ vít và cờ lê (hoặc icon Flutter màu xanh) ở thanh công cụ Run/Debug.


* **Qua đường dẫn:**
* Khi chạy app (`flutter run`), ở Terminal sẽ hiện ra một đường link kiểu `http://127.0.0.1:9100/...`. Copy link đó dán vào Chrome.



---

### 2. Các công cụ cốt lõi (The Big 4)

DevTools có nhiều tab, nhưng 4 tab sau đây là quan trọng nhất:

#### A. Flutter Inspector (Soi giao diện)

Đây là tab bạn sẽ dùng 80% thời gian. Nó giúp bạn hiểu tại sao UI lại hiển thị (hoặc không hiển thị) như vậy.

* **Tính năng "Select Widget Mode" (Nút tròn đồng tâm 🎯):**
* Bấm nút này trên DevTools.
* Bấm vào bất kỳ thành phần nào trên màn hình điện thoại/giả lập.
* DevTools sẽ nhảy ngay đến dòng code tạo ra widget đó.


* **Layout Explorer (Cứu tinh cho Row/Column):**
* Khi bạn bấm vào một `Row`, `Column` hoặc `Flex`, tab này sẽ hiện ra mô hình trực quan.
* Bạn có thể click chuột để chỉnh `mainAxisAlignment`, `crossAxisAlignment` và thấy kết quả thay đổi ngay lập tức trên app mà không cần sửa code.
* Nó giúp sửa lỗi `RenderFlex overflowed` (tràn màn hình) cực nhanh.



#### B. Performance View (Soi độ mượt)

Dùng tab này khi bạn thấy app bị khựng, giật (Jank) khi cuộn danh sách hoặc chạy animation.

* **Biểu đồ Frame (UI/Raster):**
* Mỗi thanh dọc là một khung hình (Frame).
* **Màu xanh:** Tốt (Vẽ nhanh dưới 16ms -> đạt 60fps).
* **Màu đỏ:** Xấu (Vẽ chậm -> gây giật lag).


* **CPU Flame Chart:**
* Khi chọn một thanh màu đỏ, biểu đồ bên dưới sẽ cho biết hàm nào đang chạy lâu nhất.
* Giúp bạn phát hiện ra việc lỡ tay tính toán nặng trong hàm `build()`.



#### C. Network View (Soi API)

Thay vì phải `print` log ra console để xem API trả về gì, hãy dùng tab này.

* Nó liệt kê tất cả các request HTTP (GET, POST...).
* Bấm vào một dòng để xem chi tiết:
* **Headers:** Xem token gửi đi đúng chưa.
* **Response:** Xem JSON trả về có đúng cấu trúc không.
* **Status:** Kiểm tra xem là 200 (OK) hay 404/500 (Lỗi).



#### D. Memory View (Soi bộ nhớ)

Dùng khi app chạy lâu bị crash hoặc càng dùng càng chậm.

* **Heap:** Tổng dung lượng RAM app đang chiếm.
* **Leak Detection:** Giúp phát hiện rò rỉ bộ nhớ (ví dụ: quên `dispose` Controller hoặc Stream).
* **Nút cái thùng rác (GC):** Bấm để ép dọn dẹp bộ nhớ thủ công xem RAM có giảm xuống không.

---

### 3. Quy trình Debug thực tế với DevTools

Hãy áp dụng quy trình này vào công việc hàng ngày của bạn:

**Tình huống 1: "Tại sao cái nút này lệch sang trái?"**

1. Mở **Inspector**.
2. Bật chế độ **Select Widget**.
3. Bấm vào cái nút trên màn hình.
4. Nhìn vào cây Widget Tree, xem cha nó là ai, Padding bao nhiêu.
5. Mở **Layout Explorer** để chỉnh thử alignment.

**Tình huống 2: "Tại sao cuộn danh sách bị giật?"**

1. Chuyển sang chế độ chạy **Profile Mode** (`flutter run --profile`). *Lưu ý: Debug mode luôn giật, đừng đo ở đó.*
2. Mở tab **Performance**.
3. Bấm nút **Record** (Ghi âm).
4. Cuộn danh sách trên điện thoại.
5. Bấm **Stop**.
6. Tìm các thanh màu đỏ, xem hàm nào chiếm nhiều thời gian nhất (ví dụ: load ảnh quá to, tính toán logic trong item builder).

**Tình huống 3: "Tại sao API báo lỗi mà không biết lỗi gì?"**

1. Mở tab **Network**.
2. Bấm nút gọi API trên app.
3. Tìm dòng request vừa gửi (thường có màu đỏ nếu lỗi).
4. Tab vào xem **Response Body** để đọc thông báo lỗi từ Server.

### Tóm tắt

* **Inspector:** Sửa giao diện (UI).
* **Performance:** Sửa giật lag (FPS).
* **Network:** Sửa lỗi API/Server.
* **Memory:** Sửa lỗi tràn RAM/Crash.

DevTools là công cụ mạnh nhất bạn có. Hãy tập thói quen mở nó lên ngay khi bắt đầu code, đừng đợi đến lúc có lỗi mới mở!
