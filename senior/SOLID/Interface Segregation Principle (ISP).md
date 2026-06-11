# Interface Segregation Principle (ISP) trong Flutter/Dart

> *"Clients should not be forced to depend on interfaces they do not use."*
> — Robert C. Martin

Trong Dart, **abstract class** và **mixin** đóng vai trò tương đương interface. ISP yêu cầu tách chúng thành những đơn vị nhỏ, chuyên biệt — mỗi consumer chỉ depend vào đúng khả năng mà nó cần.

---

## 1. Vấn đề khi vi phạm ISP

```dart
// ❌ Fat interface — ôm đồm mọi thứ
abstract class Repository {
  Future<List<Product>> fetchProducts();
  Future<void> addProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<void> uploadImage(File file);
  Future<void> syncWithRemote();
  Stream<List<Product>> watchProducts();
  Future<void> clearCache();
  Future<void> exportToCsv();
}
```

Một màn hình chỉ cần **hiển thị danh sách** vẫn bị ép phụ thuộc vào `uploadImage`, `exportToCsv`, `clearCache`…

```dart
// Widget chỉ cần đọc data, nhưng depend vào toàn bộ Repository
class ProductListPage extends StatelessWidget {
  final Repository repository; // ❌ biết quá nhiều

  // Trong test phải mock 8 methods, dù chỉ dùng 1-2
}
```

**Hậu quả thực tế:**

- **Test phình to**: mock/stub 8 methods chỉ để test 1 use case.
- **Ripple effect**: thêm `exportToPdf()` vào `Repository` → mọi class implement đều phải sửa, kể cả những chỗ không liên quan.
- **Khó tái sử dụng**: không thể dùng lại phần "read-only" ở module khác mà không kéo theo cả write logic.
- **Vi phạm Liskov**: class implement throw `UnimplementedError` cho method không cần → crash runtime.

---

## 2. Áp dụng ISP — Tách abstract class

```dart
// ✅ Mỗi interface một trách nhiệm rõ ràng
abstract class ProductReader {
  Future<List<Product>> fetchProducts();
}

abstract class ProductWriter {
  Future<void> addProduct(Product product);
  Future<void> deleteProduct(String id);
}

abstract class ProductWatcher {
  Stream<List<Product>> watchProducts();
}

abstract class ImageUploader {
  Future<void> uploadImage(File file);
}

abstract class Syncable {
  Future<void> syncWithRemote();
}

abstract class CacheManageable {
  Future<void> clearCache();
}

abstract class Exportable {
  Future<void> exportToCsv();
}
```

Consumer chỉ depend vào đúng thứ mình cần:

```dart
class ProductListPage extends StatelessWidget {
  final ProductReader reader;      // ✅ chỉ biết đọc
  final ProductWatcher watcher;    // ✅ chỉ biết watch

  const ProductListPage({
    required this.reader,
    required this.watcher,
  });
}
```

---

## 3. Dart `implements` — Đa kế thừa interface

Dart cho phép một class implement nhiều abstract class cùng lúc, đây là vũ khí chính để áp dụng ISP:

```dart
class ProductRepositoryImpl
    implements ProductReader, ProductWriter, ProductWatcher, 
               ImageUploader, Syncable, CacheManageable, Exportable {
  
  @override
  Future<List<Product>> fetchProducts() async {
    // Firestore / API call
  }

  @override
  Future<void> addProduct(Product product) async { /* ... */ }

  @override
  Future<void> deleteProduct(String id) async { /* ... */ }

  @override
  Stream<List<Product>> watchProducts() { /* ... */ }

  @override
  Future<void> uploadImage(File file) async { /* ... */ }

  @override
  Future<void> syncWithRemote() async { /* ... */ }

  @override
  Future<void> clearCache() async { /* ... */ }

  @override
  Future<void> exportToCsv() async { /* ... */ }
}
```

> **Class implement có thể "béo" — điều quan trọng là mỗi consumer chỉ nhìn thấy interface nhỏ mà nó cần.**

---

## 4. Mixin — Công cụ ISP đặc trưng của Dart

Mixin là cơ chế rất phù hợp để tách capability ra thành các đơn vị nhỏ **kèm theo implementation**:

```dart
mixin Trackable {
  void trackEvent(String name, [Map<String, dynamic>? props]) {
    AnalyticsService.instance.log(name, props ?? {});
  }
}

mixin Loggable {
  void logInfo(String message) => debugPrint('[INFO] $message');
  void logError(String message, [Object? error]) =>
      debugPrint('[ERROR] $message: $error');
}

mixin Cacheable<T> {
  final Map<String, T> _cache = {};

  T? getFromCache(String key) => _cache[key];
  void putInCache(String key, T value) => _cache[key] = value;
  void invalidateCache() => _cache.clear();
}
```

Class chỉ "mixin" đúng capability cần thiết:

```dart
class ProductRepository 
    with Trackable, Loggable, Cacheable<List<Product>>
    implements ProductReader, ProductWriter {
  
  @override
  Future<List<Product>> fetchProducts() async {
    // Tận dụng Cacheable
    final cached = getFromCache('products');
    if (cached != null) return cached;

    logInfo('Fetching products from API');
    final products = await _api.getProducts();
    putInCache('products', products);
    trackEvent('products_fetched', {'count': products.length});
    return products;
  }

  @override
  Future<void> addProduct(Product product) async {
    await _api.createProduct(product);
    invalidateCache();
    trackEvent('product_added');
  }
}
```

### Khi nào dùng abstract class vs mixin?

| Tiêu chí | `abstract class` | `mixin` |
|---|---|---|
| Mục đích | Định nghĩa **contract** (chỉ signature) | Cung cấp **reusable behavior** (có body) |
| Ví dụ | `ProductReader`, `Syncable` | `Trackable`, `Cacheable`, `Loggable` |
| Implement | Consumer phải tự viết logic | Tự động có logic khi `with` |
| Constraint | `implements` | `with` (có thể kết hợp `on` để ràng buộc) |

---

## 5. Ví dụ thực tế trong Flutter Architecture

### 5a. Networking Layer

```dart
// ❌ Fat interface
abstract class HttpClient {
  Future<Response> get(String path);
  Future<Response> post(String path, {dynamic body});
  Future<Response> put(String path, {dynamic body});
  Future<Response> delete(String path);
  Future<Response> upload(String path, File file);
  Future<void> download(String url, String savePath);
  void addInterceptor(Interceptor interceptor);
  void setBaseUrl(String url);
  void setTimeout(Duration duration);
}

// ✅ Tách theo capability
abstract class Fetchable {
  Future<Response> get(String path);
}

abstract class Submittable {
  Future<Response> post(String path, {dynamic body});
  Future<Response> put(String path, {dynamic body});
  Future<Response> delete(String path);
}

abstract class FileTransferable {
  Future<Response> upload(String path, File file);
  Future<void> download(String url, String savePath);
}

abstract class HttpConfigurable {
  void addInterceptor(Interceptor interceptor);
  void setBaseUrl(String url);
  void setTimeout(Duration duration);
}
```

```dart
// Bloc chỉ cần đọc data
class ProductListBloc {
  final Fetchable _client; // ✅ minimal dependency

  ProductListBloc(this._client);

  Future<List<Product>> loadProducts() async {
    final response = await _client.get('/products');
    return (response.data as List).map(Product.fromJson).toList();
  }
}
```

### 5b. Authentication — Tách theo từng phase

```dart
// ❌ Một interface cho toàn bộ auth flow
abstract class AuthService {
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> verifyEmail(String code);
  Future<void> refreshToken();
  Future<User?> getCurrentUser();
  Stream<User?> watchAuthState();
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<void> deleteAccount();
  Future<void> linkProvider(AuthProvider provider);
}

// ✅ Tách theo concern
abstract class SignInCapable {
  Future<User> signIn(String email, String password);
}

abstract class SignUpCapable {
  Future<User> signUp(String email, String password, String name);
}

abstract class SignOutCapable {
  Future<void> signOut();
}

abstract class AuthStateObservable {
  Future<User?> getCurrentUser();
  Stream<User?> watchAuthState();
}

abstract class PasswordResettable {
  Future<void> resetPassword(String email);
}

abstract class TokenRefreshable {
  Future<void> refreshToken();
}

abstract class AccountManageable {
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<void> deleteAccount();
  Future<void> linkProvider(AuthProvider provider);
}
```

```dart
// LoginPage chỉ cần sign in + theo dõi auth state
class LoginCubit extends Cubit<LoginState> {
  final SignInCapable _auth;
  final AuthStateObservable _authState;

  LoginCubit(this._auth, this._authState) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      await _auth.signIn(email, password);
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}

// SettingsPage cần những thứ khác hoàn toàn
class SettingsCubit extends Cubit<SettingsState> {
  final SignOutCapable _signOut;
  final AccountManageable _account;

  SettingsCubit(this._signOut, this._account) : super(SettingsInitial());
}
```

### 5c. State Management — BLoC event handling

```dart
// ❌ Một Bloc xử lý mọi thứ
abstract class ProductEvent {}
class LoadProducts extends ProductEvent {}
class AddProduct extends ProductEvent { /* ... */ }
class DeleteProduct extends ProductEvent { /* ... */ }
class SearchProducts extends ProductEvent { /* ... */ }
class FilterByCategory extends ProductEvent { /* ... */ }
class ExportProducts extends ProductEvent { /* ... */ }
class SyncProducts extends ProductEvent { /* ... */ }

// Bloc này phụ thuộc vào mọi thứ → fat dependency

// ✅ Tách Bloc theo feature / use case
class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final ProductReader _reader;       // chỉ cần đọc
  final ProductWatcher _watcher;     // chỉ cần watch
  // ...
}

class ProductManagementBloc extends Bloc<ProductMgmtEvent, ProductMgmtState> {
  final ProductWriter _writer;       // chỉ cần ghi
  final ImageUploader _uploader;     // chỉ cần upload
  // ...
}

class ProductExportBloc extends Bloc<ExportEvent, ExportState> {
  final Exportable _exporter;        // chỉ cần export
  // ...
}
```

---

## 6. ISP trong DI (Dependency Injection) với `get_it` / `injectable`

```dart
final getIt = GetIt.instance;

void setupDependencies() {
  // Đăng ký concrete class một lần
  final repo = ProductRepositoryImpl(
    api: getIt<ApiClient>(),
    db: getIt<LocalDatabase>(),
  );

  // Expose nhiều interface khác nhau từ cùng một instance
  getIt.registerSingleton<ProductReader>(repo);
  getIt.registerSingleton<ProductWriter>(repo);
  getIt.registerSingleton<ProductWatcher>(repo);
  getIt.registerSingleton<ImageUploader>(repo);
  getIt.registerSingleton<Syncable>(repo);
  getIt.registerSingleton<CacheManageable>(repo);
  getIt.registerSingleton<Exportable>(repo);
}
```

Mỗi Bloc/Cubit chỉ resolve đúng interface mình cần:

```dart
class ProductListBloc {
  ProductListBloc() : _reader = getIt<ProductReader>();  // ✅
}
```

---

## 7. ISP giúp testing dễ hơn đáng kể

**Trước (fat interface):**

```dart
// Phải mock 8 methods dù test chỉ dùng 1
class MockRepository extends Mock implements Repository {}

test('should load products', () {
  final mock = MockRepository();
  // Phải stub fetchProducts, nhưng Mock vẫn "biết" 7 methods khác
  when(() => mock.fetchProducts()).thenAnswer((_) async => mockProducts);
  // ...
});
```

**Sau (ISP):**

```dart
// Mock cực nhỏ, rõ ràng
class MockProductReader extends Mock implements ProductReader {}

test('should load products', () {
  final mock = MockProductReader();
  when(() => mock.fetchProducts()).thenAnswer((_) async => mockProducts);
  
  final bloc = ProductListBloc(reader: mock);
  // Test chỉ biết đến ProductReader — không có noise
});
```

Lợi ích: test **tự document** — nhìn vào mock là biết ngay dependency thực sự của class.

---

## 8. Dấu hiệu nhận biết vi phạm ISP

| Dấu hiệu | Ý nghĩa |
|---|---|
| `throw UnimplementedError()` trong method override | Class bị ép implement thứ không cần |
| Abstract class có **7+ methods** | Có thể đang ôm nhiều concern |
| Mock trong test phải stub **5+ methods** dù chỉ test 1 flow | Fat interface |
| Sửa 1 method → rebuild nhiều feature không liên quan | Coupling quá chặt |
| Tên interface quá chung: `Service`, `Manager`, `Helper` | Thiếu chuyên biệt hóa |
| Một Widget/Bloc nhận dependency mà chỉ dùng 20% API của nó | Depend quá rộng |

---

## 9. ISP vs SRP — Khác nhau ở đâu?

Hai nguyên tắc hay bị nhầm vì đều nói về "tách nhỏ":

| | SRP | ISP |
|---|---|---|
| **Góc nhìn** | Từ phía **implementation** (class) | Từ phía **consumer** (client) |
| **Câu hỏi** | "Class này có quá nhiều lý do để thay đổi không?" | "Consumer có bị ép phụ thuộc vào thứ không dùng không?" |
| **Ví dụ** | Tách `UserRepository` ra khỏi `AuthService` | Tách `ProductReader` khỏi `ProductWriter` |

Một class có thể **tuân thủ SRP** (chỉ quản lý Product) nhưng **vi phạm ISP** (expose cả read, write, export, sync qua một interface duy nhất).

---

## 10. Tóm tắt

ISP trong Flutter/Dart xoay quanh ba trụ cột:

- **Tách abstract class** thành các interface nhỏ, mỗi cái đại diện cho một capability cụ thể.
- **Dùng `implements` để compose** — class concrete implement nhiều interface, nhưng mỗi consumer chỉ nhìn thấy phần mình cần.
- **Tận dụng `mixin`** cho reusable behavior kèm implementation, kết hợp với abstract class cho pure contract.

Kết quả: code dễ test, dễ refactor, giảm ripple effect khi thay đổi, và mỗi component chỉ biết đúng mức tối thiểu cần thiết — đúng tinh thần **Principle of Least Knowledge**.
