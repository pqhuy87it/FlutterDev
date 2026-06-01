Chào bạn, nếu ví việc viết code là "xây nhà", thì **Flutter Inspector** chính là chiếc "máy quét X-quang" hay "bản đồ quy hoạch" giúp bạn nhìn thấu cấu trúc bên trong ngôi nhà đó.

Khi ứng dụng chạy lên bị lệch bố cục, nút bấm sai màu, hay xuất hiện các vạch vàng đen (Overflow) đáng ghét, **Flutter Inspector** là công cụ đầu tiên bạn cần mở lên.

Dưới đây là hướng dẫn chi tiết cách sử dụng.

---

### 1. Flutter Inspector là gì?

Nó là một công cụ trực quan (Visual tool) nằm trong bộ **Dart DevTools**. Nó giúp bạn:

* Xem cây phân cấp Widget (Widget Tree) đang hiển thị trên màn hình.
* "Soi" từng thuộc tính của Widget (kích thước, padding, margin, màu sắc...).
* Sửa lỗi giao diện (Layout) trực tiếp mà không cần sửa code rồi chạy lại ngay.

---

### 2. Cách mở Flutter Inspector

Trước tiên, bạn phải chạy ứng dụng (Debug mode) trên máy ảo hoặc máy thật.

* **Trong VS Code:**
1. Bấm tổ hợp phím `Ctrl + Shift + P` (hoặc `Cmd + Shift + P` trên Mac).
2. Gõ `Dart: Open DevTools`.
3. Chọn **Open DevTools in Web Browser** (Khuyên dùng vì rộng rãi dễ nhìn).
4. Khi trình duyệt mở ra, chọn tab **"Flutter Inspector"**.


* **Trong Android Studio / IntelliJ:**
* Nó thường nằm ở thanh công cụ bên phải, tab tên là **Flutter Inspector**.



---

### 3. Các tính năng "Thần thánh" (Cần phải biết)

Giao diện Inspector chia làm 3 phần chính mà bạn sẽ dùng hàng ngày:

#### A. Select Widget Mode (Chế độ "Chỉ đâu trúng đó") 🔍

Đây là nút quan trọng nhất! Biểu tượng thường là một cái kính lúp hoặc ô vuông có con trỏ chuột.

* **Cách dùng:** Bấm vào nút này để kích hoạt. Sau đó, trên màn hình điện thoại/máy ảo, bạn bấm vào bất kỳ widget nào (ví dụ: cái nút màu đỏ).
* **Tác dụng:**
* Inspector sẽ tự động nhảy đến đúng vị trí của widget đó trong **Widget Tree**.
* Trong IDE (VS Code/Android Studio), con trỏ soạn thảo code cũng sẽ nhảy đến đúng dòng code tạo ra widget đó.
* *Cực tiện khi bạn tiếp nhận dự án của người khác mà không biết cái nút đó nằm ở file nào.*



#### B. Layout Explorer (Cứu tinh lỗi Overflow) 🛠️

Khi bạn chọn một Widget dạng `Row`, `Column`, hoặc `Flex`, tab **Layout Explorer** sẽ hiện ra.

* **Tác dụng:** Nó mô phỏng trực quan cách các widget con được sắp xếp.
* **Sửa lỗi nóng:** Bạn có thể click chuột vào các thuộc tính như `MainAxisAlignment` (start, center, end...) hay `CrossAxisAlignment` để thay đổi bố cục ngay lập tức trên màn hình.
* **Ví dụ:** Dòng chữ bị tràn lề (vạch vàng đen)? Vào Layout Explorer chỉnh thử `flex` xem có hết không. Nếu hết, bạn mới quay lại code để sửa thật.

#### C. Widget Details Tree (Soi thuộc tính) 📋

Nằm ở bên phải hoặc dưới cùng. Khi bạn chọn một widget, nó hiện tất cả thông số:

* `renderObject`: Kích thước thật (width, height) trên màn hình là bao nhiêu pixel.
* `constraints`: Widget cha cho phép widget này to tối đa/tối thiểu bao nhiêu.
* Các tham số bạn truyền vào (text, color, padding...).

---

### 4. Các nút chức năng trên thanh công cụ

Trên thanh công cụ của Inspector có một hàng nút nhỏ nhưng có võ:

1. **Select Widget Mode (🔍):** Đã giải thích ở trên.
2. **Refresh Tree (🔄):** Nếu cây widget chưa cập nhật kịp so với màn hình, bấm nút này để tải lại.
3. **Slow Animations (🐢 - Con rùa):**
* Làm chậm tất cả chuyển động của App lại 5-10 lần.
* *Dùng khi:* Bạn muốn soi kỹ xem hiệu ứng chuyển trang có bị giật không, hay animation phức tạp chạy có đúng quỹ đạo không.


4. **Show Guidelines (📏):**
* Vẽ các đường kẻ khung, padding, margin lên màn hình điện thoại.
* *Dùng khi:* Bạn thắc mắc "Tại sao 2 cái nút này không thẳng hàng?" hoặc "Cái Padding này rộng bao nhiêu?".


5. **Show Baselines:** Kẻ dòng để soi việc căn chỉnh chữ (Text alignment).
6. **Highlight Repaints (🌈):**
* Hiển thị các viền cầu vồng nhấp nháy mỗi khi một widget bị vẽ lại (rebuild).
* *Dùng khi:* Tối ưu hiệu năng. Nếu một widget tĩnh mà cứ nhấp nháy liên tục -> Bạn đang code thừa, làm nó bị rebuild không cần thiết.



---

### 5. Quy trình Debug giao diện chuẩn bằng Inspector

Ví dụ: Bạn thấy một dòng chữ bị lệch sang trái, trong khi bạn muốn nó ở giữa.

1. Mở **Flutter Inspector**.
2. Bấm nút **Select Widget Mode** (🔍).
3. Bấm vào dòng chữ bị lệch trên điện thoại.
4. Nhìn vào **Widget Tree**: Xem cha của nó là ai? (Ví dụ là `Column`).
5. Bấm vào `Column` đó trên cây.
6. Chuyển sang tab **Layout Explorer**.
7. Thử bấm vào các nút căn giữa (`Center`) của `CrossAxisAlignment`.
8. Thấy trên điện thoại nó nhảy vào giữa đúng ý rồi -> Nhớ thuộc tính đó.
9. Quay về code, thêm `crossAxisAlignment: CrossAxisAlignment.center` vào `Column`.
10. **Hot Reload** và xong!

### Tóm lại

**Flutter Inspector** không chỉ để "nhìn", mà là công cụ để **hiểu** cách Flutter dựng hình và **thử nghiệm** sửa lỗi nhanh. Đừng code mù mờ, hãy bật "đèn X-quang" lên!
