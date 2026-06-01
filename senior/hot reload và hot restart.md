Chào bạn, **Hot Reload** và **Hot Restart** là hai tính năng "vũ khí tối thượng" của Flutter giúp việc phát triển ứng dụng nhanh gấp nhiều lần so với Android/iOS thuần. Tuy nhiên, hiểu sai về chúng sẽ khiến bạn gặp lỗi logic (bug) mà không biết tại sao.

Dưới đây là bảng phân tích chi tiết sự khác biệt.

---

### 1. Hot Reload (Nạp lại nóng)

Đây là tính năng bạn dùng thường xuyên nhất (90% thời gian).

* **Cơ chế:** Flutter tiêm (inject) các file source code đã thay đổi vào máy ảo Dart (Dart VM) đang chạy. Sau đó, Flutter framework sẽ tự động xây dựng lại (rebuild) Widget Tree để phản ánh các thay đổi đó.
* **Điểm mấu chốt:** Nó **GIỮ NGUYÊN TRẠNG THÁI (STATE)** của ứng dụng.
* **Tốc độ:** Cực nhanh (dưới 1 giây - Sub-second).
* **Phím tắt:** Bấm `r` (viết thường) tại terminal hoặc icon tia sét ⚡️ trên IDE.

**Ví dụ:**
Bạn đang điền dở một Form đăng nhập (đã nhập username, password), nhưng thấy cái nút "Login" màu xấu quá. Bạn sửa code màu nút sang màu đỏ và bấm *Hot Reload*.
=> **Kết quả:** Màu nút đổi thành đỏ, nhưng chữ username/password bạn vừa nhập **vẫn còn nguyên**. Bạn không cần nhập lại.

**Nó làm gì?**

1. Chạy lại hàm `build()` của các widget bị thay đổi.
2. Cập nhật giao diện ngay lập tức.

**Nó KHÔNG làm gì?**

1. Không chạy lại hàm `main()`.
2. Không chạy lại hàm `initState()` (Hàm khởi tạo chỉ chạy 1 lần lúc widget được sinh ra).

---

### 2. Hot Restart (Khởi động lại nóng)

Đây là tính năng "mạnh tay" hơn, dùng khi Hot Reload không đủ đô.

* **Cơ chế:** Nó biên dịch lại code Dart, dừng app hiện tại, và khởi động lại app từ đầu trên thiết bị. Tuy nhiên, nó không kill process của app (không tắt hẳn app) nên vẫn nhanh hơn việc tắt đi bật lại (Cold build).
* **Điểm mấu chốt:** Nó **XÓA SẠCH TRẠNG THÁI (STATE)**. App trở về trạng thái sơ khai như lúc mới mở.
* **Tốc độ:** Nhanh (vài giây), nhưng chậm hơn Hot Reload.
* **Phím tắt:** Bấm `R` (viết hoa) tại terminal hoặc icon mũi tên xanh 🔄 trên IDE.

**Ví dụ:**
Bạn thay đổi logic chuyển trang trong hàm `main()`, hoặc bạn thêm một biến `Global`. Bạn bấm *Hot Restart*.
=> **Kết quả:** App chớp một cái, quay về màn hình đầu tiên (Splash screen/Login). Username/password bạn nhập lúc nãy **mất hết**.

**Nó làm gì?**

1. Chạy lại từ hàm `main()`.
2. Chạy lại tất cả các hàm `initState()`.
3. Khởi tạo lại các biến Static, Global.

---

### 3. Bảng so sánh tóm tắt

| Đặc điểm | Hot Reload (⚡️) | Hot Restart (🔄) |
| --- | --- | --- |
| **Phạm vi** | Cập nhật hàm `build()` và thay đổi nhỏ. | Khởi động lại toàn bộ logic Dart. |
| **Dữ liệu (State)** | **Được bảo toàn** (Giữ nguyên biến, data đang có). | **Bị Reset** về mặc định (Mất hết data tạm). |
| **Hàm `main()**` | Không chạy lại. | Chạy lại từ đầu. |
| **Hàm `initState()**` | Không chạy lại. | Chạy lại từ đầu. |
| **Tốc độ** | Rất nhanh (< 1s). | Nhanh (~ 3-5s). |
| **Khi nào dùng?** | Sửa UI, sửa logic trong hàm build. | Sửa logic khởi tạo, thêm thư viện, sửa Global var. |

---

### 4. Khi nào Hot Reload KHÔNG hoạt động?

Có những trường hợp bạn bấm Hot Reload nhưng code không ăn, lúc này bắt buộc phải dùng **Hot Restart**:

1. **Thay đổi `initState()`:** Vì Hot Reload không chạy lại hàm này, nên nếu bạn sửa code trong `initState`, bạn phải Hot Restart mới thấy tác dụng.
2. **Thay đổi biến `static` hoặc `global`:** Các biến này chỉ khởi tạo 1 lần khi app chạy.
3. **Thay đổi Enum hoặc Generic Type:** Nếu bạn đổi class thành enum, hoặc thay đổi kiểu dữ liệu Generic, Hot Reload thường sẽ thất bại.
4. **Thêm tài nguyên (Assets/Fonts):** Nếu bạn vừa thêm ảnh vào `pubspec.yaml`, đôi khi Hot Restart là chưa đủ mà phải tắt app chạy lại (Stop & Run).

### Tổng kết

* Dùng **Hot Reload** liên tục để chỉnh sửa giao diện (UI).
* Dùng **Hot Restart** khi thay đổi logic khởi tạo app hoặc thấy app hoạt động "kỳ lạ" sau nhiều lần Hot Reload.
* Dùng **Stop & Run (Cold build)** khi cài thêm thư viện mới hoặc sửa file cấu hình Native (Android/iOS).
