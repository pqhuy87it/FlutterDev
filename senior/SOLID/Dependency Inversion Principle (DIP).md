# Dependency Inversion Principle (DIP) trong Flutter/Dart

> *"High-level modules should not depend on low-level modules. Both should depend on abstractions."*
> *"Abstractions should not depend on details. Details should depend on abstractions."*
> — Robert C. Martin

Nói đơn giản: **tầng business logic không được biết đến chi tiết cụ thể của database, API, hay framework** — cả hai cùng phụ thuộc vào một abstraction (interface) ở giữa.

---

## 1. Hiểu đúng hai vế của DIP

### Vế 1: High-level không depend vào Low-level

```
High-level module = Policy/Business logic (WHAT to do)
Low-level module  = Implementation detail (HOW to do)
```

| High-level (What) | Low-level (How) |
|---|---|
| "Lấy danh sách sản phẩm" | Firestore query, REST API, SQLite |
| "Xác thực người dùng" | Firebase Auth, OAuth, Biometric |
| "Gửi thông báo" | FCM, OneSignal, Local Notification |
| "Lưu trữ dữ liệu" | SharedPreferences, Hive, SecureStorage |
| "Theo dõi analytics" | Firebase Analytics, Mixpanel, Amplitude |

### Vế 2: Abstraction không depend vào Detail

Abstraction (interface) được định nghĩa bởi **nhu cầu của high-level**, không phải bởi khả năng của low-level.

```
❌ Sai:  Viết interface dựa trên API của Firestore
✅ Đúng: Viết interface dựa trên nhu cầu của business logic,
         rồi Firestore implement interface đó
```

---

## 2. Vi phạm DIP kinh điển

```dart
// ❌ High-level (Cubit) depend TRỰC TIẾP vào low-level (Firestore)

class ProductListCubit extends Cubit<ProductListState> {
  // Depend trực tiếp vào Firestore — low-level detail
  final FirebaseFirestore _firestore;

  ProductListCubit(this._firestore) : super(const ProductListState());

  Future<void> loadProducts() async {
    emit(state.copyWith(isLoading: true));
    try {
      // Business logic BIẾT chi tiết Firestore:
      // - collection name
      // - query syntax
      // - snapshot structure
      // - document parsing
      final snapshot = await _firestore
          .collection('products')           // ❌ biết collection name
          .where('active', isEqualTo: true) // ❌ biết field name
          .orderBy('created_at', descending: true) // ❌ biết sort syntax
          .limit(20)
          .get();

      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['product_name'] as String,     // ❌ biết field mapping
          price: (data['price_cents'] as int) / 100, // ❌ biết data format
          category: data['cat'] as String,
        );
      }).toList();

      emit(state.copyWith(products: products, isLoading: false));
    } on FirebaseException catch (e) {
      // ❌ Biết cả exception type của Firestore
      emit(state.copyWith(error: e.message, isLoading: false));
    }
  }
}
```

**Hậu quả:**

```
ProductListCubit ──depends on──► FirebaseFirestore (concrete)
       │
       │  Đổi sang REST API? → SỬA Cubit
       │  Đổi sang Supabase? → SỬA Cubit
       │  Test offline?       → Phải mock Firestore (phức tạp)
       │  Dùng lại logic?     → Không thể, gắn chặt Firestore
```

- **Không test được dễ dàng**: phải dùng `fake_cloud_firestore` hoặc mock phức tạp.
- **Không thể swap**: đổi backend = rewrite Cubit.
- **Business logic bị "ô nhiễm"**: Cubit biết quá nhiều chi tiết database.
- **Vi phạm SRP**: Cubit vừa quản lý state vừa biết Firestore query syntax.

---

## 3. Áp dụng DIP — Đảo ngược mũi tên phụ thuộc

### Bước 1: Định nghĩa Abstraction từ góc nhìn High-level

```dart
// Abstraction — được định nghĩa bởi NHU CẦU của business logic
// KHÔNG phải bởi khả năng của Firestore/API

abstract class ProductRepository {
  /// Lấy danh sách sản phẩm đang active, sắp xếp mới nhất.
  Future<List<Product>> getActiveProducts({int limit = 20});

  /// Tìm sản phẩm theo ID. Trả null nếu không tìm thấy.
  Future<Product?> findById(String id);

  /// Theo dõi thay đổi realtime.
  Stream<List<Product>> watchActiveProducts();
}
```

Interface này **không biết** Firestore tồn tại — nó chỉ mô tả **business cần gì**.

### Bước 2: Low-level implement Abstraction

```dart
// Low-level — Firestore implementation
class FirestoreProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore;
  final ProductMapper _mapper;

  FirestoreProductRepository(this._firestore, this._mapper);

  @override
  Future<List<Product>> getActiveProducts({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('products')
        .where('active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => _mapper.fromFirestore(doc))
        .toList();
  }

  @override
  Future<Product?> findById(String id) async {
    final doc = await _firestore.collection('products').doc(id).get();
    return doc.exists ? _mapper.fromFirestore(doc) : null;
  }

  @override
  Stream<List<Product>> watchActiveProducts() {
    return _firestore
        .collection('products')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(_mapper.fromFirestore).toList());
  }
}
```

### Bước 3: High-level depend vào Abstraction

```dart
class ProductListCubit extends Cubit<ProductListState> {
  // ✅ Depend vào ABSTRACTION, không biết Firestore tồn tại
  final ProductRepository _repository;

  ProductListCubit(this._repository) : super(const ProductListState());

  Future<void> loadProducts() async {
    emit(state.copyWith(isLoading: true));
    try {
      final products = await _repository.getActiveProducts();
      emit(state.copyWith(products: products, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }
}
```

**Mũi tên phụ thuộc đã đảo ngược:**

```
TRƯỚC (vi phạm DIP):
  Cubit ──depends on──► Firestore

SAU (tuân thủ DIP):
  Cubit ──depends on──► ProductRepository (abstraction)
  FirestoreProductRepository ──implements──► ProductRepository (abstraction)

  Cả Cubit VÀ Firestore đều depend vào abstraction,
  không ai depend vào ai.
```

---

## 4. DIP trong toàn bộ Flutter Architecture — Clean Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER (Widgets, Cubits/Blocs)                 │
│  Depends on: Domain abstractions                            │
│  Knows: Flutter framework, UI logic                         │
│  Does NOT know: Database, API, 3rd-party SDKs               │
├─────────────────────────────────────────────────────────────┤
│  DOMAIN LAYER (Entities, Use Cases, Repository interfaces)  │  ← Trung tâm
│  Depends on: NOTHING (pure Dart)                            │
│  Knows: Business rules only                                 │
│  Does NOT know: Flutter, Firestore, HTTP, SharedPreferences │
├─────────────────────────────────────────────────────────────┤
│  DATA LAYER (Repository impl, API clients, DTOs, Mappers)   │
│  Depends on: Domain abstractions                            │
│  Knows: Firestore, Dio, Hive, API contract                  │
│  Does NOT know: Widgets, Cubits, UI state                   │
└─────────────────────────────────────────────────────────────┘

Mũi tên dependency:
  Presentation ──►  Domain  ◄── Data
                     ↑
              Abstraction lives here
```

**Domain layer KHÔNG import bất kỳ package nào** ngoài pure Dart. Đây chính là DIP ở level kiến trúc.

```yaml
# domain/pubspec.yaml — KHÔNG có dependency ngoài Dart
# (nếu dùng multi-package monorepo)
dependencies: {}

# data/pubspec.yaml
dependencies:
  domain:
    path: ../domain
  cloud_firestore: ^5.0.0
  dio: ^5.0.0
  hive: ^2.0.0

# presentation/pubspec.yaml
dependencies:
  domain:
    path: ../domain
  flutter_bloc: ^8.0.0
```

---

## 5. Ví dụ thực tế chi tiết

### 5a. Authentication — Nhiều provider, một abstraction

```dart
// ══════════════════════════════════════════
// DOMAIN LAYER — Abstraction
// ══════════════════════════════════════════

// Định nghĩa bởi nhu cầu business, không bởi Firebase/Google/Apple
abstract class AuthRepository {
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signInWithSocial(SocialProvider provider);
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
  Stream<AppUser?> watchAuthState();
}

enum SocialProvider { google, apple, facebook }

// Entity — pure Dart, không biết Firebase User
class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
  });
}

// ══════════════════════════════════════════
// DATA LAYER — Implementation detail
// ══════════════════════════════════════════

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final UserMapper _mapper;

  FirebaseAuthRepository(this._auth, this._googleSignIn, this._mapper);

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapper.fromFirebase(credential.user!);
    } on FirebaseAuthException catch (e) {
      // ✅ Convert Firebase exception → domain exception
      throw _mapException(e);
    }
  }

  @override
  Future<AppUser> signInWithSocial(SocialProvider provider) async {
    final credential = switch (provider) {
      SocialProvider.google => await _signInWithGoogle(),
      SocialProvider.apple  => await _signInWithApple(),
      SocialProvider.facebook => await _signInWithFacebook(),
    };
    return _mapper.fromFirebase(credential.user!);
  }

  Future<UserCredential> _signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  @override
  Stream<AppUser?> watchAuthState() {
    return _auth.authStateChanges().map(
      (fbUser) => fbUser != null ? _mapper.fromFirebase(fbUser) : null,
    );
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<AppUser?> getCurrentUser() async {
    final fbUser = _auth.currentUser;
    return fbUser != null ? _mapper.fromFirebase(fbUser) : null;
  }

  AuthException _mapException(FirebaseAuthException e) => switch (e.code) {
    'user-not-found'    => const AuthException.userNotFound(),
    'wrong-password'    => const AuthException.wrongPassword(),
    'too-many-requests' => const AuthException.tooManyAttempts(),
    _                   => AuthException.unknown(e.message),
  };
}

// Mapper: convert Firebase type → Domain type
class UserMapper {
  AppUser fromFirebase(User fbUser) => AppUser(
    id: fbUser.uid,
    email: fbUser.email ?? '',
    displayName: fbUser.displayName,
    photoUrl: fbUser.photoURL,
    isEmailVerified: fbUser.emailVerified,
  );
}

// ══════════════════════════════════════════
// PRESENTATION LAYER — Depend on abstraction
// ══════════════════════════════════════════

class LoginCubit extends Cubit<LoginState> {
  // ✅ Không biết Firebase tồn tại
  final AuthRepository _auth;

  LoginCubit(this._auth) : super(const LoginState());

  Future<void> loginWithEmail() async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final user = await _auth.signInWithEmail(state.email, state.password);
      emit(state.copyWith(status: LoginStatus.success, user: user));
    } on AuthException catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, error: e));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final user = await _auth.signInWithSocial(SocialProvider.google);
      emit(state.copyWith(status: LoginStatus.success, user: user));
    } on AuthException catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, error: e));
    }
  }
}
```

**Swap backend hoàn toàn không ảnh hưởng Cubit:**

```dart
// Đổi sang Supabase → tạo class MỚI, Cubit KHÔNG SỬA
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return AppUser(
      id: response.user!.id,
      email: response.user!.email!,
    );
  }

  // ... implement còn lại
}
```

### 5b. Storage — Abstraction cho local persistence

```dart
// ══════════════════════════════════════════
// DOMAIN LAYER
// ══════════════════════════════════════════

abstract class KeyValueStorage {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<void> remove(String key);
  Future<void> clear();
}

// Use case level — abstraction cụ thể hơn cho từng concern
abstract class UserPreferences {
  Future<String> getLocale();
  Future<void> setLocale(String locale);
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
  Future<bool> isOnboardingComplete();
  Future<void> setOnboardingComplete();
}

// ══════════════════════════════════════════
// DATA LAYER
// ══════════════════════════════════════════

// Low-level: SharedPreferences implementation
class SharedPrefsStorage implements KeyValueStorage {
  final SharedPreferences _prefs;
  SharedPrefsStorage(this._prefs);

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);
  @override
  Future<void> setString(String key, String value) async =>
      _prefs.setString(key, value);
  @override
  Future<bool?> getBool(String key) async => _prefs.getBool(key);
  @override
  Future<void> setBool(String key, bool value) async =>
      _prefs.setBool(key, value);
  @override
  Future<void> remove(String key) async => _prefs.remove(key);
  @override
  Future<void> clear() async => _prefs.clear();
}

// Low-level: Hive implementation (swap mà không sửa gì ở trên)
class HiveStorage implements KeyValueStorage {
  final Box _box;
  HiveStorage(this._box);

  @override
  Future<String?> getString(String key) async => _box.get(key) as String?;
  @override
  Future<void> setString(String key, String value) async =>
      _box.put(key, value);
  // ...
}

// Higher-level implementation dùng low-level abstraction
class UserPreferencesImpl implements UserPreferences {
  final KeyValueStorage _storage; // ✅ depend on abstraction

  UserPreferencesImpl(this._storage);

  @override
  Future<String> getLocale() async =>
      await _storage.getString('locale') ?? 'vi';

  @override
  Future<void> setLocale(String locale) =>
      _storage.setString('locale', locale);

  @override
  Future<ThemeMode> getThemeMode() async {
    final value = await _storage.getString('theme_mode');
    return switch (value) {
      'dark'   => ThemeMode.dark,
      'light'  => ThemeMode.light,
      _        => ThemeMode.system,
    };
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) =>
      _storage.setString('theme_mode', mode.name);

  @override
  Future<bool> isOnboardingComplete() async =>
      await _storage.getBool('onboarding_complete') ?? false;

  @override
  Future<void> setOnboardingComplete() =>
      _storage.setBool('onboarding_complete', true);
}
```

### 5c. Networking — Abstraction multi-layer

```dart
// ══════════════════════════════════════════
// LAYER 1: HTTP Abstraction — không biết Dio/http tồn tại
// ══════════════════════════════════════════

abstract class HttpClient {
  Future<HttpResponse> get(String path, {Map<String, dynamic>? queryParams});
  Future<HttpResponse> post(String path, {dynamic body});
  Future<HttpResponse> put(String path, {dynamic body});
  Future<HttpResponse> delete(String path);
}

class HttpResponse {
  final int statusCode;
  final dynamic data;
  final Map<String, String> headers;

  const HttpResponse({
    required this.statusCode,
    required this.data,
    this.headers = const {},
  });
}

// ══════════════════════════════════════════
// LAYER 2: Dio implementation
// ══════════════════════════════════════════

class DioHttpClient implements HttpClient {
  final Dio _dio;
  DioHttpClient(this._dio);

  @override
  Future<HttpResponse> get(String path, {Map<String, dynamic>? queryParams}) async {
    final response = await _dio.get(path, queryParameters: queryParams);
    return HttpResponse(
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  }

  @override
  Future<HttpResponse> post(String path, {dynamic body}) async {
    final response = await _dio.post(path, data: body);
    return HttpResponse(statusCode: response.statusCode ?? 0, data: response.data);
  }

  // put, delete tương tự...
}

// ══════════════════════════════════════════
// LAYER 3: Feature-specific API client dùng HttpClient abstraction
// ══════════════════════════════════════════

class OrderApiClient {
  final HttpClient _http; // ✅ không biết Dio

  OrderApiClient(this._http);

  Future<List<OrderDto>> fetchOrders({int page = 0}) async {
    final response = await _http.get(
      '/orders',
      queryParams: {'page': page, 'limit': 20},
    );
    return (response.data as List)
        .map((e) => OrderDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderDto> createOrder(CreateOrderRequest request) async {
    final response = await _http.post('/orders', body: request.toJson());
    return OrderDto.fromJson(response.data as Map<String, dynamic>);
  }
}
```

**Đổi từ Dio sang http package:**

```dart
// Tạo class MỚI, không sửa OrderApiClient, không sửa Cubit
class StandardHttpClient implements HttpClient {
  final http.Client _client;
  final String _baseUrl;

  StandardHttpClient(this._client, this._baseUrl);

  @override
  Future<HttpResponse> get(String path, {Map<String, dynamic>? queryParams}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);
    final response = await _client.get(uri);
    return HttpResponse(
      statusCode: response.statusCode,
      data: jsonDecode(response.body),
    );
  }
  // ...
}
```

---

## 6. DIP trong Dependency Injection — Nơi mọi thứ kết nối

DIP nói **what** (depend on abstraction), DI nói **how** (inject implementation vào).

### 6a. get_it — Service Locator

```dart
final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Low-level: concrete implementations ──
  final prefs = await SharedPreferences.getInstance();
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  
  // ── Layer 1: Infrastructure ──
  getIt.registerSingleton<KeyValueStorage>(SharedPrefsStorage(prefs));
  getIt.registerSingleton<HttpClient>(DioHttpClient(dio));

  // ── Layer 2: Data sources & Repositories ──
  getIt.registerSingleton<ProductApiClient>(
    ProductApiClient(getIt<HttpClient>()), // ✅ inject abstraction
  );
  getIt.registerSingleton<ProductRepository>(
    FirestoreProductRepository(
      FirebaseFirestore.instance,
      ProductMapper(),
    ),
  );
  getIt.registerSingleton<AuthRepository>(
    FirebaseAuthRepository(
      FirebaseAuth.instance,
      GoogleSignIn(),
      UserMapper(),
    ),
  );
  getIt.registerSingleton<UserPreferences>(
    UserPreferencesImpl(getIt<KeyValueStorage>()), // ✅ inject abstraction
  );

  // ── Layer 3: Cubits — depend on abstractions ──
  getIt.registerFactory<ProductListCubit>(
    () => ProductListCubit(getIt<ProductRepository>()), // ✅
  );
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(getIt<AuthRepository>()), // ✅
  );
}
```

### 6b. injectable + get_it — Code generation

```dart
// Annotation-based DI — tự generate registration code
@module
abstract class InfrastructureModule {
  @preResolve
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  KeyValueStorage storage(SharedPreferences prefs) => SharedPrefsStorage(prefs);

  @singleton
  HttpClient httpClient() => DioHttpClient(
    Dio(BaseOptions(baseUrl: const String.fromEnvironment('API_URL'))),
  );
}

@Singleton(as: ProductRepository)  // ✅ register AS abstraction
class FirestoreProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore;
  final ProductMapper _mapper;

  @factoryMethod
  FirestoreProductRepository(this._firestore, this._mapper);

  // ...
}

@Singleton(as: AuthRepository)  // ✅ register AS abstraction
class FirebaseAuthRepository implements AuthRepository {
  // ...
}

@injectable
class ProductListCubit extends Cubit<ProductListState> {
  // get_it tự inject ProductRepository abstraction
  ProductListCubit(ProductRepository repository)
      : _repository = repository,
        super(const ProductListState());
}
```

### 6c. Provider / Riverpod — Flutter-native DI

```dart
// Riverpod — declare dependency graph declaratively

// Low-level providers
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://api.example.com'));
});

final httpClientProvider = Provider<HttpClient>((ref) {
  return DioHttpClient(ref.read(dioProvider)); // ✅
});

// Repository providers — abstraction type
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirestoreProductRepository(
    FirebaseFirestore.instance,
    ProductMapper(),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    FirebaseAuth.instance,
    GoogleSignIn(),
    UserMapper(),
  );
});

// Cubit/Notifier — depend on abstraction via ref
final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  return ProductListNotifier(
    ref.read(productRepositoryProvider), // ✅ abstraction
  );
});
```

---

## 7. DIP trong Testing — Lợi ích lớn nhất

### 7a. Unit test dễ dàng nhờ abstraction

```dart
// Mock ABSTRACTION, không mock Firestore/Dio
class MockProductRepository extends Mock implements ProductRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('ProductListCubit', () {
    late MockProductRepository mockRepo;
    late ProductListCubit cubit;

    setUp(() {
      mockRepo = MockProductRepository();
      cubit = ProductListCubit(mockRepo); // ✅ inject mock
    });

    blocTest<ProductListCubit, ProductListState>(
      'loads products successfully',
      build: () {
        when(() => mockRepo.getActiveProducts())
            .thenAnswer((_) async => [
              const Product(id: '1', name: 'iPhone', price: 999, category: 'electronics'),
            ]);
        return cubit;
      },
      act: (c) => c.loadProducts(),
      expect: () => [
        isA<ProductListState>().having((s) => s.isLoading, 'loading', true),
        isA<ProductListState>().having(
          (s) => s.products.length, 'count', 1,
        ),
      ],
    );

    blocTest<ProductListCubit, ProductListState>(
      'handles error gracefully',
      build: () {
        when(() => mockRepo.getActiveProducts())
            .thenThrow(const NetworkException('No internet'));
        return cubit;
      },
      act: (c) => c.loadProducts(),
      expect: () => [
        isA<ProductListState>().having((s) => s.isLoading, 'loading', true),
        isA<ProductListState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });
}
```

### 7b. Swap implementation cho từng môi trường

```dart
// Production
Future<void> configureProd() async {
  getIt.registerSingleton<ProductRepository>(
    FirestoreProductRepository(FirebaseFirestore.instance, ProductMapper()),
  );
  getIt.registerSingleton<AuthRepository>(
    FirebaseAuthRepository(FirebaseAuth.instance, GoogleSignIn(), UserMapper()),
  );
  getIt.registerSingleton<AnalyticsTracker>(
    FirebaseAnalyticsTracker(FirebaseAnalytics.instance),
  );
}

// Staging — dùng REST API thay Firestore
Future<void> configureStaging() async {
  getIt.registerSingleton<ProductRepository>(
    RestProductRepository(getIt<HttpClient>(), ProductMapper()),
  );
  getIt.registerSingleton<AuthRepository>(
    // Vẫn dùng Firebase Auth nhưng trỏ sang staging project
    FirebaseAuthRepository(FirebaseAuth.instance, GoogleSignIn(), UserMapper()),
  );
  getIt.registerSingleton<AnalyticsTracker>(
    ConsoleAnalyticsTracker(), // chỉ print, không gửi event thật
  );
}

// Integration test — in-memory
Future<void> configureTest() async {
  getIt.registerSingleton<ProductRepository>(
    InMemoryProductRepository(), // fake data, instant response
  );
  getIt.registerSingleton<AuthRepository>(
    FakeAuthRepository(), // luôn sign in thành công
  );
  getIt.registerSingleton<AnalyticsTracker>(
    NoOpAnalyticsTracker(), // không làm gì
  );
}

// main.dart
void main() async {
  const env = String.fromEnvironment('ENV', defaultValue: 'prod');
  switch (env) {
    case 'prod':    await configureProd();
    case 'staging': await configureStaging();
    case 'test':    await configureTest();
  }
  runApp(const MyApp());
}
```

---

## 8. DIP cho Platform-specific Code

```dart
// ══════════════════════════════════════════
// Abstraction — pure Dart
// ══════════════════════════════════════════

abstract class BiometricAuth {
  Future<bool> isAvailable();
  Future<bool> authenticate(String reason);
}

abstract class DeviceInfo {
  Future<String> getDeviceId();
  Future<String> getOsVersion();
  Future<int> getAvailableStorageMb();
}

abstract class PermissionHandler {
  Future<PermissionStatus> requestCamera();
  Future<PermissionStatus> requestLocation();
  Future<PermissionStatus> requestNotification();
  Future<void> openSettings();
}

enum PermissionStatus { granted, denied, permanentlyDenied }

// ══════════════════════════════════════════
// Implementation — biết platform detail
// ══════════════════════════════════════════

class LocalAuthBiometric implements BiometricAuth {
  final LocalAuthentication _localAuth;
  LocalAuthBiometric(this._localAuth);

  @override
  Future<bool> isAvailable() => _localAuth.canCheckBiometrics;

  @override
  Future<bool> authenticate(String reason) => _localAuth.authenticate(
    localizedReason: reason,
    options: const AuthenticationOptions(biometricOnly: true),
  );
}

class FlutterPermissionHandler implements PermissionHandler {
  @override
  Future<PermissionStatus> requestCamera() async {
    final status = await Permission.camera.request();
    return _mapStatus(status);
  }

  @override
  Future<PermissionStatus> requestLocation() async {
    final status = await Permission.location.request();
    return _mapStatus(status);
  }

  @override
  Future<void> openSettings() => openAppSettings();

  PermissionStatus _mapStatus(permission_handler.PermissionStatus status) {
    if (status.isGranted) return PermissionStatus.granted;
    if (status.isPermanentlyDenied) return PermissionStatus.permanentlyDenied;
    return PermissionStatus.denied;
  }
}
```

**Cubit/UseCase dùng abstraction — không import bất kỳ platform package nào:**

```dart
class CameraFeatureCubit extends Cubit<CameraState> {
  final PermissionHandler _permissions; // ✅ abstraction
  final BiometricAuth _biometric;       // ✅ abstraction

  CameraFeatureCubit(this._permissions, this._biometric)
      : super(const CameraState());

  Future<void> openCamera() async {
    // Verify identity trước khi mở camera nhạy cảm
    final authed = await _biometric.authenticate('Xác thực để mở camera');
    if (!authed) {
      emit(state.copyWith(error: 'Xác thực thất bại'));
      return;
    }

    final status = await _permissions.requestCamera();
    switch (status) {
      case PermissionStatus.granted:
        emit(state.copyWith(cameraReady: true));
      case PermissionStatus.denied:
        emit(state.copyWith(error: 'Cần quyền Camera'));
      case PermissionStatus.permanentlyDenied:
        emit(state.copyWith(showSettingsPrompt: true));
    }
  }
}
```

---

## 9. Abstraction Ownership — Ai sở hữu interface?

Đây là điểm **nhiều người hiểu sai** nhất về DIP:

```
❌ SAI: Data layer định nghĩa interface, Presentation layer dùng

  data/
    ├── firestore_product_repo.dart
    └── product_repository.dart      ← interface ở đây = DATA sở hữu

  presentation/
    └── product_cubit.dart           ← depend vào data layer


✅ ĐÚNG: Domain layer sở hữu interface, Data layer implement

  domain/
    ├── product.dart                 ← entity
    └── product_repository.dart      ← interface ở đây = DOMAIN sở hữu

  data/
    └── firestore_product_repo.dart  ← implement interface từ domain

  presentation/
    └── product_cubit.dart           ← depend vào domain layer
```

**Tại sao điều này quan trọng?**

Nếu interface nằm trong data layer, khi bạn tách module:

```yaml
# presentation package phải depend vào data package → NGƯỢC
presentation:
  dependencies:
    data: ^1.0.0  # ❌ high-level depend vào low-level PACKAGE
```

Khi interface nằm trong domain layer:

```yaml
# Cả hai cùng depend vào domain → ĐÚNG DIP
presentation:
  dependencies:
    domain: ^1.0.0  # ✅

data:
  dependencies:
    domain: ^1.0.0  # ✅
```

---

## 10. Anti-patterns thường gặp

### 10a. Leaky Abstraction — Interface lộ chi tiết implementation

```dart
// ❌ Interface lộ Firestore detail
abstract class ProductRepository {
  // DocumentSnapshot là Firestore type → lộ implementation
  Future<List<Product>> getProducts({DocumentSnapshot? startAfter});

  // Query là Firestore type
  Future<List<Product>> query(Query query);
}

// ✅ Interface chỉ dùng domain type
abstract class ProductRepository {
  Future<List<Product>> getProducts({String? cursor});
  Future<List<Product>> search(ProductFilter filter);
}
```

### 10b. Interface mirroring — Copy 1:1 implementation

```dart
// ❌ Interface chỉ là copy của Firestore API → vô nghĩa
abstract class Database {
  Future<DocumentSnapshot> getDocument(String collection, String id);
  Future<QuerySnapshot> query(String collection, Map<String, dynamic> where);
  Future<void> setDocument(String collection, String id, Map<String, dynamic> data);
}

// ✅ Interface phản ánh business need
abstract class ProductRepository {
  Future<Product?> findById(String id);
  Future<List<Product>> getActiveProducts();
  Future<void> save(Product product);
}
```

### 10c. Quá nhiều layer abstraction — Abstraction sandwich

```dart
// ❌ Quá mức — 5 layer cho 1 operation đơn giản
abstract class DataSource { ... }
abstract class Repository { ... }
abstract class UseCase { ... }
abstract class ViewModel { ... }
abstract class Presenter { ... }

class GetProductsRemoteDataSourceImpl implements DataSource { ... }
class ProductRepositoryImpl implements Repository { ... }
class GetProductsUseCaseImpl implements UseCase { ... }
class ProductViewModelImpl implements ViewModel { ... }
class ProductPresenterImpl implements Presenter { ... }

// ✅ Thực dụng — chỉ abstract ở boundary thật sự cần swap
// Abstraction ở Repository level là đủ cho hầu hết case
abstract class ProductRepository { ... }
class FirestoreProductRepository implements ProductRepository { ... }
class ProductListCubit { ... } // dùng trực tiếp, không cần UseCase wrapper
```

**Quy tắc: chỉ tạo abstraction khi bạn thực sự cần swap implementation** — giữa các môi trường (prod/staging/test), giữa các data source, hoặc khi business logic cần tách khỏi framework.

### 10d. Constructor explosion — Quá nhiều dependency

```dart
// ❌ Dấu hiệu vi phạm SRP (quá nhiều concern), không phải lỗi DIP
class SuperCubit extends Cubit<SuperState> {
  SuperCubit(
    this._productRepo,
    this._orderRepo,
    this._userRepo,
    this._analytics,
    this._logger,
    this._navigator,
    this._formatter,
    this._validator,
    this._cache,
  );
  // 9 dependencies → class này đang làm quá nhiều việc
}

// ✅ Tách Cubit theo concern (SRP), mỗi cái ít dependency
class ProductListCubit extends Cubit<ProductListState> {
  ProductListCubit(this._repository, this._analytics);
  // 2 dependencies → rõ ràng, dễ test
}
```

---

## 11. Checklist kiểm tra DIP

```
┌──────────────────────────────────────────────────────────────┐
│  1. Cubit/Bloc có import package nào ngoài Dart + BLoC?      │
│     → Nếu import firebase, dio, hive → vi phạm DIP           │
│                                                              │
│  2. Domain layer có import Flutter package không?            │
│     → Nếu có → vi phạm DIP                                   │
│                                                              │
│  3. Interface có chứa type từ 3rd-party library không?       │
│     → DocumentSnapshot, Response, Box → leaky abstraction    │
│                                                              │
│  4. Interface nằm ở đâu trong project structure?             │
│     → Nằm trong data/ → sai ownership                        │
│     → Nằm trong domain/ → đúng                               │
│                                                              │
│  5. Có thể swap implementation mà KHÔNG sửa Cubit không?     │
│     → Nếu không → thiếu abstraction layer                    │
│                                                              │
│  6. Unit test có cần Firestore emulator / real API không?    │
│     → Nếu có → high-level depend trực tiếp vào low-level     │
│                                                              │
│  7. Interface có phản ánh business need hay mirror library?  │
│     → Nếu giống 1:1 Firestore API → abstraction vô nghĩa     │
└──────────────────────────────────────────────────────────────┘
```

---

## 12. DIP kết hợp các nguyên tắc SOLID khác

| Kết hợp | Cách hoạt động |
|---|---|
| **DIP + SRP** | Mỗi abstraction đại diện cho 1 responsibility → interface nhỏ, rõ ràng |
| **DIP + OCP** | Depend on abstraction → thêm implementation mới không sửa consumer |
| **DIP + LSP** | Mọi implementation phải thay thế được cho abstraction mà không break |
| **DIP + ISP** | Tách interface nhỏ → mỗi consumer chỉ depend vào đúng abstraction cần |

Thực tế, DIP là **nền tảng** để các nguyên tắc còn lại hoạt động — không có abstraction layer thì không có polymorphism, không có extension point, không có substitutability.

---

## 13. Tóm tắt

DIP trong Flutter/Dart xoay quanh một ý tưởng: **business logic không được biết chi tiết implementation**.

- **High-level (Cubit/UseCase)** depend vào **abstraction (Repository interface)**, không depend vào Firestore/Dio/Hive.
- **Low-level (FirestoreRepo, DioClient)** implement abstraction — mũi tên dependency hướng **ngược** lên domain.
- **Interface thuộc về domain layer** — được thiết kế dựa trên business need, không phải library API.
- **DI container** (get_it, Riverpod, Provider) là cơ chế **kết nối** abstraction với implementation tại runtime.
- **Chỉ abstract ở boundary thực sự cần** — nơi bạn cần swap (test, multi-environment, multi-datasource). Đừng tạo abstraction cho mọi class.

Kiểm tra đơn giản nhất: **xóa toàn bộ folder `data/` khỏi project — `domain/` và `presentation/` có compile được không?** Nếu có → DIP đúng. Nếu không → đâu đó đang depend vào implementation detail.
