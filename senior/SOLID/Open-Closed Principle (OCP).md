# Open/Closed Principle (OCP) trong Flutter/Dart

> *"Software entities (classes, modules, functions) should be open for extension, but closed for modification."*
> — Bertrand Meyer, 1988

Nói đơn giản: **khi cần thêm tính năng mới, bạn nên mở rộng code hiện tại (extend) thay vì sửa đổi nó (modify)**. Code đã hoạt động đúng → đừng mở ra sửa, hãy viết thêm bên cạnh.

---

## 1. Tại sao OCP quan trọng?

Mỗi lần sửa code đang chạy đúng, bạn tạo ra rủi ro:

- **Regression**: tính năng cũ bị break.
- **Ripple effect**: một thay đổi nhỏ lan tỏa khắp codebase.
- **Merge conflict**: nhiều dev cùng sửa một file.
- **Test lại toàn bộ**: phải re-test mọi thứ liên quan đến đoạn code đã sửa.

OCP giải quyết bằng cách thiết kế code sao cho **thêm tính năng = thêm code mới**, không phải sửa code cũ.

---

## 2. Vi phạm OCP kinh điển — if/else & switch ngày càng phình

```dart
// ❌ Mỗi lần thêm payment method → sửa class này
class PaymentService {
  Future<PaymentResult> processPayment(String method, double amount) async {
    if (method == 'credit_card') {
      // 30 dòng xử lý credit card
      final response = await _stripeApi.charge(amount);
      return PaymentResult(success: response.ok);
      
    } else if (method == 'paypal') {
      // 30 dòng xử lý PayPal
      final token = await _paypalApi.getToken();
      final response = await _paypalApi.execute(token, amount);
      return PaymentResult(success: response.status == 'COMPLETED');
      
    } else if (method == 'momo') {
      // Thêm MoMo → SỬA class đang chạy đúng ❌
      final response = await _momoApi.pay(amount);
      return PaymentResult(success: response.resultCode == 0);
      
    } else if (method == 'vnpay') {
      // Thêm VNPay → lại SỬA tiếp ❌
      // ...
    }
    
    throw UnsupportedError('Unknown method: $method');
  }
}
```

**Hậu quả:**

- Mỗi payment method mới → mở `PaymentService` ra sửa.
- File ngày càng dài, if/else ngày càng sâu.
- Test phải cover toàn bộ method cũ + mới mỗi lần thay đổi.
- Nhiều dev thêm payment method cùng lúc → conflict.
- Một lỗi typo trong block MoMo có thể ảnh hưởng credit card.

---

## 3. Áp dụng OCP — Strategy Pattern

```dart
// ✅ Abstraction — ĐÓNG cho modification
abstract class PaymentProcessor {
  Future<PaymentResult> process(double amount);
}

// ✅ Mỗi method là class riêng — MỞ cho extension
class CreditCardProcessor implements PaymentProcessor {
  final StripeApi _api;
  CreditCardProcessor(this._api);

  @override
  Future<PaymentResult> process(double amount) async {
    final response = await _api.charge(amount);
    return PaymentResult(success: response.ok);
  }
}

class PayPalProcessor implements PaymentProcessor {
  final PayPalApi _api;
  PayPalProcessor(this._api);

  @override
  Future<PaymentResult> process(double amount) async {
    final token = await _api.getToken();
    final response = await _api.execute(token, amount);
    return PaymentResult(success: response.status == 'COMPLETED');
  }
}

// Thêm MoMo → tạo file MỚI, không sửa gì cả ✅
class MoMoProcessor implements PaymentProcessor {
  final MoMoApi _api;
  MoMoProcessor(this._api);

  @override
  Future<PaymentResult> process(double amount) async {
    final response = await _api.pay(amount);
    return PaymentResult(success: response.resultCode == 0);
  }
}
```

Service trở nên đơn giản và **không bao giờ cần sửa**:

```dart
class PaymentService {
  final Map<String, PaymentProcessor> _processors;

  PaymentService(this._processors);

  Future<PaymentResult> processPayment(String method, double amount) {
    final processor = _processors[method];
    if (processor == null) throw UnsupportedError('Unknown: $method');
    return processor.process(amount);
  }
}
```

Đăng ký trong DI:

```dart
// Thêm payment method = thêm 1 dòng ở đây + 1 class mới
// KHÔNG sửa PaymentService, KHÔNG sửa các processor cũ
getIt.registerSingleton<PaymentService>(
  PaymentService({
    'credit_card': CreditCardProcessor(getIt()),
    'paypal': PayPalProcessor(getIt()),
    'momo': MoMoProcessor(getIt()),        // ← chỉ thêm, không sửa
    'vnpay': VNPayProcessor(getIt()),      // ← chỉ thêm, không sửa
  }),
);
```

---

## 4. Các kỹ thuật đạt OCP trong Dart/Flutter

### 4a. Strategy Pattern (đã thấy ở trên)

Tách behavior thành interface + nhiều implementation. Consumer depend vào interface → thêm behavior mới = thêm class mới.

### 4b. Decorator Pattern — Mở rộng behavior mà không sửa class gốc

```dart
abstract class ApiClient {
  Future<Response> request(String path);
}

class BaseApiClient implements ApiClient {
  @override
  Future<Response> request(String path) async {
    return await http.get(Uri.parse('$baseUrl$path'));
  }
}

// Thêm logging — không sửa BaseApiClient ✅
class LoggingApiClient implements ApiClient {
  final ApiClient _inner;
  LoggingApiClient(this._inner);

  @override
  Future<Response> request(String path) async {
    debugPrint('[API] → $path');
    final stopwatch = Stopwatch()..start();
    final response = await _inner.request(path);
    debugPrint('[API] ← $path (${stopwatch.elapsedMilliseconds}ms)');
    return response;
  }
}

// Thêm retry — không sửa BaseApiClient, không sửa LoggingApiClient ✅
class RetryApiClient implements ApiClient {
  final ApiClient _inner;
  final int maxRetries;
  RetryApiClient(this._inner, {this.maxRetries = 3});

  @override
  Future<Response> request(String path) async {
    for (var i = 0; i <= maxRetries; i++) {
      try {
        return await _inner.request(path);
      } catch (e) {
        if (i == maxRetries) rethrow;
        await Future.delayed(Duration(seconds: i + 1));
      }
    }
    throw StateError('Unreachable');
  }
}

// Thêm caching — tạo file MỚI, không sửa gì cũ ✅
class CachingApiClient implements ApiClient {
  final ApiClient _inner;
  final Map<String, _CacheEntry> _cache = {};

  CachingApiClient(this._inner);

  @override
  Future<Response> request(String path) async {
    final cached = _cache[path];
    if (cached != null && !cached.isExpired) return cached.response;
    
    final response = await _inner.request(path);
    _cache[path] = _CacheEntry(response);
    return response;
  }
}
```

Compose linh hoạt — **thứ tự decorator thay đổi hành vi**:

```dart
// Cache → Retry → Log → Base
final client = CachingApiClient(
  RetryApiClient(
    LoggingApiClient(
      BaseApiClient(),
    ),
  ),
);
```

### 4c. Mixin — Mở rộng capability mà không sửa class

```dart
mixin Trackable on StatefulWidget {
  String get trackingName;
}

mixin TrackableState<T extends Trackable> on State<T> {
  @override
  void initState() {
    super.initState();
    Analytics.trackScreenView(widget.trackingName);
  }
}

// Thêm tracking cho BẤT KỲ widget nào — không sửa widget gốc ✅
class ProductDetailPage extends StatefulWidget with Trackable {
  @override
  String get trackingName => 'product_detail';

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TrackableState {
  @override
  Widget build(BuildContext context) {
    // tracking đã tự chạy qua mixin, không cần sửa gì ở đây
    return Scaffold(/* ... */);
  }
}
```

### 4d. Extension Methods — Mở rộng type có sẵn mà không sửa source

```dart
// Thêm capability cho DateTime — không sửa DateTime class ✅
extension DateTimeFormatting on DateTime {
  String get vietnameseDate => '$day/$month/$year';
  
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

// Thêm capability cho BuildContext — không sửa Flutter framework ✅
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<T?> pushRoute<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

// Sử dụng
Text(order.createdAt.timeAgo);
context.showSnackBar('Đã lưu thành công');
```

---

## 5. OCP trong thực tế Flutter Architecture

### 5a. Theming System

```dart
// ❌ Vi phạm — mỗi lần thêm theme → sửa function
ThemeData getTheme(String name) {
  switch (name) {
    case 'light': return ThemeData.light();
    case 'dark': return ThemeData.dark();
    case 'ocean': // sửa function ❌
      return ThemeData(primarySwatch: Colors.blue);
    case 'forest': // sửa tiếp ❌
      return ThemeData(primarySwatch: Colors.green);
    default: return ThemeData.light();
  }
}

// ✅ Tuân thủ OCP
abstract class AppTheme {
  String get name;
  ThemeData get themeData;
}

class LightTheme implements AppTheme {
  @override String get name => 'light';
  @override ThemeData get themeData => ThemeData.light();
}

class DarkTheme implements AppTheme {
  @override String get name => 'dark';
  @override ThemeData get themeData => ThemeData.dark();
}

// Thêm theme = tạo class MỚI ✅
class OceanTheme implements AppTheme {
  @override String get name => 'ocean';
  @override ThemeData get themeData => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
  );
}

class ThemeManager {
  final List<AppTheme> _themes;
  ThemeManager(this._themes);

  // ĐÓNG — không bao giờ cần sửa method này
  ThemeData getTheme(String name) {
    return _themes
        .firstWhere((t) => t.name == name, orElse: () => LightTheme())
        .themeData;
  }
}
```

### 5b. Form Validation

```dart
// ❌ Vi phạm — mỗi loại validation mới → sửa method
String? validate(String field, String? value) {
  if (field == 'email') {
    if (value == null || value.isEmpty) return 'Required';
    if (!value.contains('@')) return 'Invalid email';
    return null;
  } else if (field == 'phone') {
    // ...sửa ❌
  } else if (field == 'vietnamese_id') {
    // ...sửa tiếp ❌
  }
}

// ✅ Tuân thủ OCP — Validator là composable unit
abstract class Validator {
  String? validate(String? value);
}

class RequiredValidator implements Validator {
  final String message;
  RequiredValidator([this.message = 'Trường này là bắt buộc']);

  @override
  String? validate(String? value) =>
      (value == null || value.trim().isEmpty) ? message : null;
}

class EmailValidator implements Validator {
  @override
  String? validate(String? value) {
    if (value == null || value.isEmpty) return null; // let Required handle
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(value) ? null : 'Email không hợp lệ';
  }
}

class MinLengthValidator implements Validator {
  final int minLength;
  MinLengthValidator(this.minLength);

  @override
  String? validate(String? value) =>
      (value != null && value.length < minLength)
          ? 'Tối thiểu $minLength ký tự'
          : null;
}

class RegexValidator implements Validator {
  final RegExp regex;
  final String message;
  RegexValidator(this.regex, this.message);

  @override
  String? validate(String? value) =>
      (value != null && !regex.hasMatch(value)) ? message : null;
}

// Thêm validator mới = tạo class MỚI ✅
class VietnamesePhoneValidator implements Validator {
  @override
  String? validate(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^(0|\+84)(3|5|7|8|9)\d{8}$');
    return regex.hasMatch(value) ? null : 'Số điện thoại không hợp lệ';
  }
}
```

Compose validators — **không sửa validator nào cả**:

```dart
class CompositeValidator implements Validator {
  final List<Validator> _validators;
  CompositeValidator(this._validators);

  @override
  String? validate(String? value) {
    for (final validator in _validators) {
      final error = validator.validate(value);
      if (error != null) return error;
    }
    return null;
  }
}

// Sử dụng
TextFormField(
  validator: CompositeValidator([
    RequiredValidator(),
    EmailValidator(),
  ]).validate,
);

TextFormField(
  validator: CompositeValidator([
    RequiredValidator(),
    MinLengthValidator(8),
    RegexValidator(
      RegExp(r'[A-Z]'),
      'Cần ít nhất 1 chữ hoa',
    ),
    RegexValidator(
      RegExp(r'[0-9]'),
      'Cần ít nhất 1 chữ số',
    ),
  ]).validate,
);
```

### 5c. Navigation / Routing

```dart
// ❌ Vi phạm — mỗi màn mới → sửa router
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/home': return MaterialPageRoute(builder: (_) => HomePage());
    case '/product': return MaterialPageRoute(builder: (_) => ProductPage());
    case '/cart': return MaterialPageRoute(builder: (_) => CartPage());
    // Thêm route → SỬA function này ❌
  }
}

// ✅ Tuân thủ OCP — Route registry
abstract class RouteFactory {
  String get path;
  Route<dynamic> build(RouteSettings settings);
}

class HomeRouteFactory implements RouteFactory {
  @override String get path => '/home';
  @override Route<dynamic> build(RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => const HomePage());
}

class ProductRouteFactory implements RouteFactory {
  @override String get path => '/product';
  @override Route<dynamic> build(RouteSettings settings) {
    final args = settings.arguments as ProductArgs;
    return MaterialPageRoute(builder: (_) => ProductPage(args: args));
  }
}

// Thêm route = tạo class MỚI ✅
class CartRouteFactory implements RouteFactory {
  @override String get path => '/cart';
  @override Route<dynamic> build(RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => const CartPage());
}

class AppRouter {
  final Map<String, RouteFactory> _routes;

  AppRouter(List<RouteFactory> factories)
      : _routes = {for (final f in factories) f.path: f};

  // ĐÓNG — method này không bao giờ cần sửa
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return _routes[settings.name]?.build(settings);
  }
}
```

### 5d. Middleware / Interceptor Chain

```dart
abstract class Middleware {
  Future<Response> handle(Request request, Next next);
}

typedef Next = Future<Response> Function(Request);

// Mỗi middleware là một class độc lập — thêm mới = tạo class MỚI ✅
class AuthMiddleware implements Middleware {
  final TokenStorage _tokenStorage;
  AuthMiddleware(this._tokenStorage);

  @override
  Future<Response> handle(Request request, Next next) async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return next(request);
  }
}

class RateLimitMiddleware implements Middleware {
  final _timestamps = <DateTime>[];
  final int maxRequests;
  final Duration window;

  RateLimitMiddleware({this.maxRequests = 60, this.window = const Duration(minutes: 1)});

  @override
  Future<Response> handle(Request request, Next next) async {
    _timestamps.removeWhere((t) => DateTime.now().difference(t) > window);
    if (_timestamps.length >= maxRequests) {
      throw RateLimitException('Vượt quá $maxRequests requests/$window');
    }
    _timestamps.add(DateTime.now());
    return next(request);
  }
}

// Pipeline ĐÓNG cho modification — chỉ cần config danh sách middleware
class MiddlewarePipeline {
  final List<Middleware> _middlewares;
  final ApiClient _client;

  MiddlewarePipeline(this._middlewares, this._client);

  Future<Response> execute(Request request) {
    Next chain = (req) => _client.send(req);
    
    // Xây chain từ cuối lên đầu
    for (final middleware in _middlewares.reversed) {
      final next = chain;
      chain = (req) => middleware.handle(req, next);
    }
    
    return chain(request);
  }
}

// Config — thêm middleware = thêm vào list, không sửa pipeline
final pipeline = MiddlewarePipeline([
  AuthMiddleware(getIt()),
  RateLimitMiddleware(),
  LoggingMiddleware(),    // ← thêm mới, không sửa gì cả ✅
  CacheMiddleware(),      // ← thêm mới, không sửa gì cả ✅
], getIt<ApiClient>());
```

### 5e. BLoC Event Handler mở rộng được

```dart
// ❌ Vi phạm — thêm feature → sửa Bloc
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<LoadProducts>(_onLoad);
    on<AddProduct>(_onAdd);
    on<DeleteProduct>(_onDelete);
    // Thêm SearchProduct → sửa class ❌
    // Thêm FilterProduct → sửa class ❌
  }
}

// ✅ Tuân thủ OCP — Command pattern + handler registry
abstract class BlocCommand<E, S> {
  bool canHandle(E event);
  Future<void> execute(E event, Emitter<S> emit);
}

class LoadProductsCommand implements BlocCommand<ProductEvent, ProductState> {
  final ProductReader _reader;
  LoadProductsCommand(this._reader);

  @override
  bool canHandle(ProductEvent event) => event is LoadProducts;

  @override
  Future<void> execute(ProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _reader.fetchProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}

// Thêm command MỚI → tạo class MỚI ✅
class SearchProductsCommand implements BlocCommand<ProductEvent, ProductState> {
  final ProductSearchable _searcher;
  SearchProductsCommand(this._searcher);

  @override
  bool canHandle(ProductEvent event) => event is SearchProducts;

  @override
  Future<void> execute(ProductEvent event, Emitter<ProductState> emit) async {
    final e = event as SearchProducts;
    emit(ProductLoading());
    final results = await _searcher.search(e.query);
    emit(ProductLoaded(results));
  }
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final List<BlocCommand<ProductEvent, ProductState>> _commands;

  ProductBloc(this._commands) : super(ProductInitial()) {
    // ĐÓNG — handler này không bao giờ cần sửa
    on<ProductEvent>((event, emit) async {
      for (final command in _commands) {
        if (command.canHandle(event)) {
          await command.execute(event, emit);
          return;
        }
      }
    });
  }
}
```

---

## 6. OCP với Generics — Viết một lần, dùng cho mọi type

```dart
// Pagination logic — ĐÓNG, viết 1 lần, không sửa
class PaginatedFetcher<T> {
  final Future<List<T>> Function(int page, int limit) _fetcher;
  final int limit;
  
  int _currentPage = 0;
  bool _hasMore = true;
  final List<T> _items = [];

  PaginatedFetcher(this._fetcher, {this.limit = 20});

  List<T> get items => List.unmodifiable(_items);
  bool get hasMore => _hasMore;

  Future<void> loadNext() async {
    if (!_hasMore) return;
    final newItems = await _fetcher(_currentPage, limit);
    _items.addAll(newItems);
    _hasMore = newItems.length >= limit;
    _currentPage++;
  }

  void reset() {
    _items.clear();
    _currentPage = 0;
    _hasMore = true;
  }
}

// MỞ cho extension — dùng cho bất kỳ type nào mà không sửa PaginatedFetcher
final productPaginator = PaginatedFetcher<Product>(
  (page, limit) => api.getProducts(page: page, limit: limit),
);

final orderPaginator = PaginatedFetcher<Order>(
  (page, limit) => api.getOrders(page: page, limit: limit),
);

final userPaginator = PaginatedFetcher<User>(
  (page, limit) => api.getUsers(page: page, limit: limit),
);
```

---

## 7. OCP với Sealed Class (Dart 3) — Khi ĐÓNG có chủ đích

Dart 3 sealed class là ngoại lệ có ý thức đối với OCP — bạn **chủ đích đóng** tập hợp subtype:

```dart
// Đóng CÓ CHỦ ĐÍCH — exhaustive matching, compiler kiểm tra
sealed class PaymentState {}
class PaymentInitial extends PaymentState {}
class PaymentProcessing extends PaymentState {}
class PaymentSuccess extends PaymentState {
  final String transactionId;
  PaymentSuccess(this.transactionId);
}
class PaymentFailed extends PaymentState {
  final String error;
  PaymentFailed(this.error);
}

// Compiler đảm bảo handle hết mọi case
Widget buildUI(PaymentState state) => switch (state) {
  PaymentInitial()    => const CheckoutButton(),
  PaymentProcessing() => const CircularProgressIndicator(),
  PaymentSuccess(transactionId: var id) => SuccessView(id: id),
  PaymentFailed(error: var msg)         => ErrorView(message: msg),
  // Nếu thiếu case → compile error ✅
};
```

**Khi nào sealed class phù hợp hơn OCP thuần túy?**

| Dùng sealed class (đóng) | Dùng abstract class (mở) |
|---|---|
| Tập hợp state **cố định**, cần exhaustive check | Tập hợp behavior **mở rộng** không giới hạn |
| `PaymentState`, `AuthState`, `Result<T>` | `PaymentProcessor`, `Validator`, `Middleware` |
| Thêm subtype mới = thay đổi business logic | Thêm subtype mới = thêm tính năng |
| Compiler giúp tìm mọi chỗ cần update | Không chỗ nào cần update |

---

## 8. Anti-patterns thường gặp

### 8a. "OCP" nhưng vẫn dùng type checking

```dart
// ❌ Có interface nhưng vẫn check type → giả OCP
void processNotification(Notification notification) {
  if (notification is PushNotification) {
    showPushBanner(notification);
  } else if (notification is EmailNotification) {
    sendEmail(notification);
  } else if (notification is SmsNotification) {
    // Thêm → sửa function ❌
  }
}

// ✅ Thực sự OCP — polymorphism
abstract class Notification {
  Future<void> send();
}

class PushNotification implements Notification {
  @override
  Future<void> send() async => showPushBanner();
}

class EmailNotification implements Notification {
  @override
  Future<void> send() async => sendEmail();
}

// Thêm SMS → tạo class MỚI, function dưới không sửa ✅
class SmsNotification implements Notification {
  @override
  Future<void> send() async => sendSms();
}

// ĐÓNG vĩnh viễn
void processNotification(Notification notification) {
  notification.send(); // polymorphism xử lý hết
}
```

### 8b. Over-engineering — Mọi thứ đều phải abstract

```dart
// ❌ Quá mức — đoạn code chỉ có 1 variant và không có kế hoạch mở rộng
abstract class DateFormatter {
  String format(DateTime date);
}

class VietnameseDateFormatter implements DateFormatter {
  @override
  String format(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

// ✅ Đơn giản — extension đủ rồi
extension DateFormatting on DateTime {
  String get vietnameseDate => '$day/$month/$year';
}
```

**Quy tắc thực dụng:**
- **Lần đầu**: viết trực tiếp, đơn giản.
- **Lần thứ hai** cần variant tương tự: bắt đầu nghĩ đến abstraction.
- **Lần thứ ba**: refactor thành OCP-compliant.

Đây chính là **Rule of Three** — đừng abstract hóa quá sớm.

---

## 9. Dấu hiệu vi phạm OCP

| Dấu hiệu | Ý nghĩa |
|---|---|
| `if/else` hoặc `switch` trên type/string ngày càng dài | Thiếu polymorphism |
| Thêm feature mới → sửa 3+ file cũ | Thiếu abstraction layer |
| Commit message: "Add X support to Y, Z, W" | X nên là class riêng |
| Merge conflict thường xuyên trong cùng 1 file | Nhiều concern dồn vào 1 chỗ |
| Test cũ bị fail khi thêm feature mới | Code cũ bị sửa thay vì mở rộng |
| Phải hiểu toàn bộ function 200 dòng để thêm 1 case | Thiếu tách biệt |

---

## 10. OCP kết hợp các nguyên tắc SOLID khác

| Kết hợp | Cách hoạt động |
|---|---|
| **OCP + SRP** | Mỗi extension (class mới) chỉ có một trách nhiệm → dễ thêm, dễ test |
| **OCP + LSP** | Subtype mới phải thay thế được cho abstraction mà không break code cũ |
| **OCP + ISP** | Interface nhỏ → dễ tạo implementation mới → dễ extend |
| **OCP + DIP** | Depend vào abstraction → swap implementation tự do → extension không cần sửa consumer |

---

## 11. Tóm tắt

OCP trong Flutter/Dart xoay quanh triết lý: **thêm tính năng = thêm code mới, không sửa code cũ**.

Bốn kỹ thuật chính để đạt OCP:

- **Strategy Pattern**: tách behavior thành interface + implementations → thêm behavior = thêm class.
- **Decorator Pattern**: wrap behavior lên nhau → thêm capability mà không sửa class gốc.
- **Mixin**: inject behavior vào class có sẵn mà không sửa source.
- **Extension Methods**: mở rộng type có sẵn (kể cả framework type) mà không sửa type đó.

Nguyên tắc thực dụng: **OCP không phải "mọi thứ phải abstract từ đầu"**. Nó là mindset thiết kế — khi bạn thấy pattern lặp lại (variant thứ 3), đó là lúc refactor để đóng cho modification và mở cho extension. Đừng abstract quá sớm, nhưng cũng đừng để switch/if-else phình ra không kiểm soát.
