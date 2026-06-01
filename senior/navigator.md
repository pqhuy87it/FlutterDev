Chào bạn, **Navigator** trong Flutter là "người dẫn đường" hoặc "người điều phối giao thông" của ứng dụng.

Nếu `Scaffold` là khung xương của **một màn hình**, thì `Navigator` là cơ chế quản lý việc **chuyển đổi giữa các màn hình** đó.

Để hiểu Navigator, bạn cần nắm vững cấu trúc dữ liệu **STACK (Ngăn xếp)**. Hãy tưởng tượng Navigator quản lý các màn hình giống như một **chồng đĩa**:

* **Màn hình đang hiển thị** là cái đĩa nằm trên cùng.
* **Màn hình trước đó** nằm ngay bên dưới nó.

Dưới đây là giải thích chi tiết từ cơ bản đến nâng cao.

---

### 1. Cơ chế hoạt động (Stack: Last In, First Out)

Navigator hoạt động theo nguyên tắc: **Vào sau - Ra trước**.

1. **Push (Đẩy vào):** Khi bạn muốn sang màn hình mới, bạn đặt cái đĩa mới lên đỉnh chồng đĩa.
2. **Pop (Lấy ra):** Khi bạn bấm nút Back, bạn nhấc cái đĩa trên cùng ra vứt đi, màn hình bên dưới sẽ lộ ra.

```
   [ Màn hình C ]  <-- Đang xem (Push C)
   [ Màn hình B ]
   [ Màn hình A ]  <-- Màn hình Home (Root)

```

*Nếu `Pop` màn hình C -> Màn hình B hiện ra.*

---

### 2. Các lệnh Navigator cơ bản nhất

#### A. `Navigator.push()` (Đi tới)

Dùng để mở một màn hình mới chồng lên màn hình hiện tại.

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => SecondScreen()),
);

```

* `context`: Để Flutter biết vị trí hiện tại của bạn.
* `MaterialPageRoute`: Là lớp bao bọc widget màn hình, giúp tạo hiệu ứng trượt (slide) chuẩn Android/iOS.

#### B. `Navigator.pop()` (Quay lại)

Dùng để đóng màn hình hiện tại và quay về màn hình trước đó.

```dart
Navigator.pop(context);

```

#### C. `Navigator.canPop()` (Kiểm tra)

Kiểm tra xem có màn hình nào phía sau để quay lại không. Dùng để ẩn/hiện nút Back tùy chỉnh.

---

### 3. Các lệnh Navigator nâng cao (Rất quan trọng)

Đây là những lệnh bạn cần biết để xử lý các luồng như Đăng nhập, Đăng xuất.

#### A. `pushReplacement` (Tráo đổi)

* **Tác dụng:** Đóng màn hình hiện tại rồi mới mở màn hình mới. (Thay thế cái đĩa trên cùng bằng cái đĩa mới).
* **Dùng khi:** Từ màn hình **Splash Screen** sang **Home**. Bạn không muốn người dùng bấm Back ở Home mà lại quay về Splash.

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => HomeScreen()),
);

```

#### B. `pushAndRemoveUntil` (Xóa sạch lịch sử)

* **Tác dụng:** Xóa hết tất cả các màn hình cũ trong Stack, chỉ giữ lại màn hình mới nhất.
* **Dùng khi:** **Đăng xuất (Logout)**. Khi user đăng xuất, bạn đẩy họ về màn hình Login và xóa sạch lịch sử để họ không thể bấm Back quay lại màn hình cũ được nữa.

```dart
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => LoginScreen()),
  (Route<dynamic> route) => false, // false nghĩa là: Xóa hết, không giữ lại ai cả
);

```

---

### 4. Hai cách tổ chức Navigator

#### Cách 1: Anonymous Routes (Điều hướng trực tiếp)

Là cách nãy giờ chúng ta ví dụ (dùng `MaterialPageRoute`).

* **Ưu điểm:** Nhanh, linh hoạt, dễ truyền dữ liệu qua constructor.
* **Nhược điểm:** Code lặp lại nhiều nếu app lớn.

#### Cách 2: Named Routes (Điều hướng bằng tên)

Bạn đặt tên cho mỗi màn hình (`/home`, `/login`) trong `MaterialApp`.

**Bước 1: Khai báo ở main.dart**

```dart
MaterialApp(
  initialRoute: '/', // Màn hình đầu tiên
  routes: {
    '/': (context) => HomeScreen(),
    '/detail': (context) => DetailScreen(),
    '/login': (context) => LoginScreen(),
  },
);

```

**Bước 2: Gọi bằng tên**

```dart
Navigator.pushNamed(context, '/detail');
// Hoặc truyền tham số
Navigator.pushNamed(context, '/detail', arguments: 'Dữ liệu ID 123');

```

---

### 5. Truyền và nhận dữ liệu ngược chiều

Một tính năng cực hay của Navigator là `push` có thể trả về kết quả (Future).

**Ví dụ:** Màn hình A mở màn hình B để chọn Ngày. Khi chọn xong ở B, dữ liệu trả về A.

**Màn hình A (Nơi gọi):**

```dart
void _selectDate() async {
  // Dùng await để đợi người dùng chọn xong ở màn hình B
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DatePickerScreen()),
  );

  if (result != null) {
    print("Ngày đã chọn: $result");
  }
}

```

**Màn hình B (Nơi trả về):**

```dart
// Khi bấm nút "Lưu"
Navigator.pop(context, "20/11/2023"); // Truyền dữ liệu vào hàm pop

```

---

### 6. Navigator 1.0 vs Navigator 2.0 (Router)

Bạn sẽ nghe nói về Navigator 2.0 (hiện nay thường dùng qua thư viện **GoRouter**).

* **Navigator 1.0 (Imperative):** Là những gì tôi giải thích ở trên (`push`, `pop`). Dễ dùng, phù hợp 90% app mobile thông thường.
* **Navigator 2.0 (Declarative - Router):** Phức tạp hơn nhiều. Nó quản lý stack dựa trên Trạng thái (State) của App. Ví dụ: URL trên web thay đổi -> State thay đổi -> Màn hình thay đổi.
* *Lời khuyên:* Nếu bạn làm App Mobile đơn giản, hãy dùng **Navigator 1.0**. Nếu làm Web hoặc App có Deep Link phức tạp, hãy dùng thư viện **go_router** (đừng tự implement Navigator 2.0 thuần, rất khó).



### Tóm tắt

1. **Navigator** quản lý màn hình theo cơ chế **Ngăn xếp (Stack)**.
2. **`push`**: Thêm màn hình mới lên trên.
3. **`pop`**: Gỡ màn hình hiện tại ra, quay về trước.
4. **`pushReplacement`**: Thay thế màn hình (dùng cho Splash -> Login).
5. **`pushAndRemoveUntil`**: Xóa hết lịch sử (dùng cho Logout).
6. **`context`** là chìa khóa để Navigator biết nó đang ở đâu trong ứng dụng.
