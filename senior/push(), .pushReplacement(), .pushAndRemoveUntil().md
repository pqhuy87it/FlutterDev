# Navigator Stack Operations trong Flutter

Để hiểu rõ ba method này, trước hết cần nắm vững bản chất: **Navigator quản lý một stack (LIFO) các Route objects**. Mỗi method thao tác trên stack theo cách khác nhau.

---

## 1. `Navigator.push()`

**Bản chất:** Đẩy một Route mới lên đỉnh stack. Route cũ vẫn nằm bên dưới, **không bị dispose**.## Tóm tắt sự khác biệt cốt lõi

**`push()`** — Stack: `[A] → [A, B]`. Route A vẫn sống trong memory, `dispose()` của A chưa được gọi. User nhấn back sẽ quay về A. Method này trả về `Future<T>`, cho phép nhận result khi B bị pop.

**`pushReplacement()`** — Stack: `[A, B] → [A, C]`. Route B bị **dispose ngay** sau khi animation hoàn tất, C thế chỗ B. Back từ C sẽ về A chứ không về B. Param `result` cho phép gửi data ngược về A như thể B đã pop bình thường.

**`pushAndRemoveUntil()`** — Stack: `[A, B, C, D] → [A, E]` (nếu predicate giữ A). Đây là "nuclear option" — push route mới, đồng thời **dispose hàng loạt** route theo predicate. Predicate `(route) => false` xoá sạch toàn bộ stack.

## Điểm cần lưu ý cho senior level

**Memory & Lifecycle:** `push()` giữ route cũ trong memory (State object, widget tree, controller, stream subscription... tất cả vẫn active). Với deep navigation stack, đây là nguồn memory leak tiềm ẩn nếu các screen giữ resource nặng mà không release trong `deactivate()`.

**Animation behavior:** `pushReplacement()` và `pushAndRemoveUntil()` vẫn chạy **enter animation** của route mới, nhưng route bị remove không chạy exit animation (chúng bị dispose "âm thầm" phía sau). Đây là lý do UX mượt hơn so với việc pop nhiều lần rồi push.

**Predicate power trong `pushAndRemoveUntil()`:** `ModalRoute.withName('/dashboard')` chỉ hoạt động đúng khi route được push bằng named route. Nếu dùng anonymous route (MaterialPageRoute trực tiếp), hãy dùng `route.isFirst` hoặc custom predicate check `route.settings.name`.

**Với Go_Router / Declarative Navigation:** Trong thực tế production hiện nay, các pattern trên thường được abstract qua `go_router` hoặc `auto_route`, nơi stack manipulation được handle declaratively. Tuy nhiên, hiểu imperative Navigator vẫn quan trọng vì nó là nền tảng mà mọi routing package xây dựng bên trên.

```dart
// ============================================================
// 1. Navigator.push() — Thêm route mới lên đỉnh stack
// ============================================================
// Stack TRƯỚC: [Home]
// Stack SAU:   [Home, Detail]
// => Home vẫn tồn tại trong memory, KHÔNG bị dispose

// Cách 1: MaterialPageRoute (imperative)
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const DetailScreen()),
);

// Cách 2: Named route
Navigator.pushNamed(context, '/detail', arguments: {'id': 42});

// Cách 3: push() trả về Future<T> — nhận result khi pop()
final result = await Navigator.push<String>(
  context,
  MaterialPageRoute(builder: (_) => const SelectionScreen()),
);
// result có giá trị khi SelectionScreen gọi Navigator.pop(context, 'selected_value')

// USE CASE ĐIỂN HÌNH:
// - Home -> Detail (user cần quay lại Home)
// - List -> Item Detail
// - Bất kỳ flow nào cần preserve back navigation


// ============================================================
// 2. Navigator.pushReplacement() — Thay thế route hiện tại
// ============================================================
// Stack TRƯỚC: [Home, Login]
// Stack SAU:   [Home, Dashboard]
// => Login bị DISPOSE và thay bằng Dashboard
// => Nhấn back từ Dashboard sẽ về Home, KHÔNG về Login

// Cách 1: MaterialPageRoute
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const DashboardScreen()),
);

// Cách 2: Named route
Navigator.pushReplacementNamed(context, '/dashboard');

// Cách 3: Với result cho route bị replace
// Route bị thay thế (Login) nếu đang await push() ở route trước đó,
// sẽ nhận được `result` thông qua tham số này
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const DashboardScreen()),
  result: 'login_success', // gửi result cho route BÊN DƯỚI Login (tức Home)
);

// USE CASE ĐIỂN HÌNH:
// - Login -> Dashboard (không cho quay lại Login)
// - Splash -> Home
// - Onboarding step cuối -> Main app
// - Bất kỳ flow nào route hiện tại không còn ý nghĩa sau khi navigate


// ============================================================
// 3. Navigator.pushAndRemoveUntil() — Push mới + xoá nhiều route
// ============================================================
// Đây là method mạnh nhất: push route mới, đồng thời remove
// TẤT CẢ các route bên dưới cho đến khi predicate trả về true.

// --- Ví dụ A: Xoá toàn bộ stack (logout flow) ---
// Stack TRƯỚC: [Home, Settings, Profile, ConfirmLogout]
// Stack SAU:   [Login]
// => Tất cả route cũ bị dispose

Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const LoginScreen()),
  (Route<dynamic> route) => false, // predicate luôn false => xoá HẾT
);

// Named route equivalent
Navigator.pushNamedAndRemoveUntil(
  context,
  '/login',
  (route) => false,
);

// --- Ví dụ B: Xoá đến một route cụ thể ---
// Stack TRƯỚC: [Home, Category, SubCategory, Product, Cart, Checkout]
// Stack SAU:   [Home, OrderSuccess]
// => Giữ lại Home, xoá từ Category đến Checkout, push OrderSuccess

Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
  (route) => route.isFirst, // giữ lại route đầu tiên (Home)
);

// --- Ví dụ C: Xoá đến route có tên cụ thể ---
// Stack TRƯỚC: [Home, Dashboard, Settings, ChangePassword, Verify]
// Stack SAU:   [Home, Dashboard, PasswordChanged]

Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const PasswordChangedScreen()),
  ModalRoute.withName('/dashboard'), // giữ đến '/dashboard'
);

// USE CASE ĐIỂN HÌNH:
// - Logout: clear toàn bộ stack, đưa về Login
// - Checkout success: xoá cart/checkout flow, giữ Home
// - Deep reset: sau một flow phức tạp, quay về trạng thái sạch


// ============================================================
// BONUS: So sánh lifecycle & memory implications
// ============================================================

class _DetailScreenState extends State<DetailScreen> {
  @override
  void dispose() {
    // push():                GỌI khi pop() route này
    // pushReplacement():     GỌI NGAY khi route bị replace (animation xong)
    // pushAndRemoveUntil():  GỌI NGAY cho MỌI route bị remove
    debugPrint('DetailScreen disposed');
    super.dispose();
  }

  @override
  void deactivate() {
    // Gọi khi route bị remove khỏi tree (trước dispose)
    // Quan trọng: nếu dùng GlobalKey, widget có thể được
    // move sang tree khác thay vì bị dispose
    super.deactivate();
  }
}


// ============================================================
// PRODUCTION PATTERN: Auth Flow with pushAndRemoveUntil
// ============================================================

class AuthService {
  static void handleAuthStateChange(BuildContext context, bool isAuthenticated) {
    if (isAuthenticated) {
      // Login thành công: xoá toàn bộ auth flow
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } else {
      // Session expired / Logout: xoá toàn bộ, về login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}

// ============================================================
// PRODUCTION PATTERN: E-commerce Checkout Flow
// ============================================================

class CheckoutFlow {
  // Bước 1: Cart -> Shipping (push bình thường, user có thể quay lại)
  static void goToShipping(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShippingScreen()),
    );
  }

  // Bước 2: Shipping -> Payment (push, user có thể sửa shipping)
  static void goToPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentScreen()),
    );
  }

  // Bước 3: Payment thành công -> Order Success
  // Xoá toàn bộ checkout flow, giữ Home
  // User KHÔNG thể back về Payment/Shipping (tránh double charge)
  static void goToOrderSuccess(BuildContext context, String orderId) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(orderId: orderId),
      ),
      (route) => route.isFirst, // giữ lại Home
    );
  }
}
```

