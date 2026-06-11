Chào bạn, điều hướng (Navigation) là xương sống của mọi ứng dụng mobile. Trong Flutter, cơ chế này hoạt động dựa trên mô hình **Ngăn xếp (Stack)**: màn hình mới đè lên màn hình cũ, và khi tắt màn hình trên cùng, màn hình cũ sẽ hiện ra.

Dưới đây là 3 phương pháp điều hướng chính trong Flutter, đi từ cơ bản đến nâng cao:

---

### 1. Điều hướng cơ bản (Basic Navigation)

Đây là cách đơn giản nhất, thường dùng cho các app nhỏ hoặc khi bạn muốn điều hướng nhanh mà không cần thiết lập cấu hình đường dẫn trước.

* **Cơ chế:** Bạn tạo trực tiếp một `Route` (thường là `MaterialPageRoute`) và đẩy nó vào ngăn xếp.
* **Hàm chính:**
* `Navigator.push()`: Thêm màn hình mới vào stack.
* `Navigator.pop()`: Xóa màn hình hiện tại khỏi stack (quay lại).



**Ví dụ:**

```dart
// Ở Màn hình A
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScreenB()),
    );
  },
  child: const Text('Đi tới màn hình B'),
)

// Ở Màn hình B
ElevatedButton(
  onPressed: () {
    Navigator.pop(context); // Quay lại A
  },
  child: const Text('Quay lại'),
)

```

* **Ưu điểm:** Nhanh, dễ hiểu, linh hoạt (truyền dữ liệu trực tiếp qua Constructor).
* **Nhược điểm:** Code bị lặp lại nếu dùng nhiều nơi, khó quản lý Deep link.

---

### 2. Điều hướng bằng tên (Named Routes - Navigator 1.0)

Thay vì hard-code class màn hình (`ScreenB`), bạn đặt tên cho mỗi màn hình (ví dụ: `'/home'`, `'/settings'`) và khai báo chúng ở `MaterialApp`.

* **Cơ chế:** Định nghĩa bản đồ (Map) các route ngay từ đầu.
* **Hàm chính:** `Navigator.pushNamed()`.

**Cấu hình:**

```dart
MaterialApp(
  // Màn hình đầu tiên chạy
  initialRoute: '/',
  routes: {
    '/': (context) => const HomeScreen(),
    '/detail': (context) => const DetailScreen(),
    '/settings': (context) => const SettingsScreen(),
  },
);

```

**Sử dụng:**

```dart
// Chuyển màn hình
Navigator.pushNamed(context, '/detail');

// Chuyển màn hình và xóa hết các màn hình cũ (Ví dụ: Logout xong về Login)
Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

```

* **Ưu điểm:** Code gọn gàng, tập trung quản lý route tại một chỗ.
* **Nhược điểm:**
* Truyền tham số (arguments) phức tạp hơn (phải dùng `ModalRoute.of(context)`).
* Không hỗ trợ tốt cho Web (URL trên trình duyệt không cập nhật đẹp).



---

### 3. Điều hướng nâng cao (Router API / Navigator 2.0) - Khuyên dùng: GoRouter

Đây là chuẩn mực hiện đại ("Industry Standard") cho các ứng dụng Flutter quy mô vừa và lớn, đặc biệt quan trọng nếu bạn làm **Flutter Web** hoặc cần xử lý **Deep Linking** (mở app từ link web).

Vì Navigator 2.0 thuần rất khó viết, cộng đồng (và cả Google) khuyên dùng thư viện **`go_router`**.

* **Cơ chế:** Dựa trên trạng thái (Declarative) và URL path.
* **Cài đặt:** Thêm `go_router` vào `pubspec.yaml`.

**Cấu hình:**

```dart
// 1. Tạo config
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/detail/:id', // Hỗ trợ tham số trên URL
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailScreen(id: id!);
      },
    ),
  ],
);

// 2. Gắn vào MaterialApp
MaterialApp.router(
  routerConfig: _router,
);

```

**Sử dụng:**

```dart
// Điều hướng bằng context extension
context.go('/detail/123'); // Thay thế stack (tốt cho BottomNav)
context.push('/detail/123'); // Đẩy vào stack (có nút Back)

```

* **Ưu điểm:**
* Hỗ trợ Web URL hoàn hảo.
* Hỗ trợ Deep Link tự động.
* Hỗ trợ Redirect (ví dụ: chưa login thì tự đá về trang Login).
* Truyền tham số dễ dàng.



---

### 4. Cách truyền và nhận dữ liệu giữa các màn hình

#### A. Truyền dữ liệu đi (Pass Data)

* **Cách cơ bản:** Truyền qua Constructor.
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (context) => DetailScreen(data: "Hello"),
));

```


* **Cách Named Route:** Truyền qua `arguments`.
```dart
Navigator.pushNamed(context, '/detail', arguments: "Hello");
// Ở màn hình đích:
final args = ModalRoute.of(context)!.settings.arguments as String;

```



#### B. Nhận dữ liệu trả về (Return Data)

Dùng `await` để đợi kết quả khi màn hình kia `pop`.

```dart
// Màn hình A: Đợi kết quả
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SelectionScreen()),
);
print(result); // In ra "Đã chọn món A"

// Màn hình B (SelectionScreen): Trả dữ liệu khi đóng
Navigator.pop(context, "Đã chọn món A");

```

---

### Tổng kết: Khi nào dùng cái nào?

| Phương pháp | Độ khó | Phù hợp với |
| --- | --- | --- |
| **Navigator.push** | Dễ | App nhỏ, làm demo, chuyển màn hình cục bộ ít quan trọng. |
| **Named Routes** | Trung bình | App vừa, không cần Deep Link, ít tham số phức tạp. |
| **GoRouter** | Khó hơn chút | **Dự án thực tế**, App lớn, Flutter Web, cần quản lý Auth Redirect, Deep Link. |

**Lời khuyên:** Nếu bạn đang học để đi làm hoặc xây dựng dự án nghiêm túc, hãy bắt đầu làm quen với **`go_router`** ngay từ bây giờ.

Bạn có muốn tôi viết một ví dụ chi tiết về cách thiết lập `GoRouter` với BottomNavigationBar không?
