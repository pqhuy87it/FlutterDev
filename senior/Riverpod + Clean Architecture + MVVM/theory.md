Huy, đây là một combo rất phổ biến và mạnh mẽ trong Flutter. Mình sẽ hướng dẫn chi tiết từ cấu trúc thư mục đến cách các layer kết nối với nhau.Mình đã tạo một guide đầy đủ cho Huy. Đây là tóm tắt những điểm cốt lõi:

**Luồng dữ liệu chính:**
Widget → ViewModel (Notifier) → UseCase → Repository (abstract) → RepositoryImpl → DataSource → API/DB

# Flutter: Riverpod + Clean Architecture + MVVM

## 1. Tổng quan kiến trúc

```
┌──────────────────────────────────────────────────┐
│                 PRESENTATION                     │
│  View (Widget) ←→ ViewModel (Notifier/Provider)  │
│         ↓ depends on                             │
├──────────────────────────────────────────────────┤
│                   DOMAIN                         │
│    UseCase ←→ Entity ←→ Repository (abstract)    │
│         ↑ implements                             │
├──────────────────────────────────────────────────┤
│                    DATA                          │
│  RepositoryImpl → DataSource (Remote / Local)    │
│                → Model (DTO) → Entity mapping    │
└──────────────────────────────────────────────────┘
```

**Quy tắc phụ thuộc (Dependency Rule):**
- Presentation → Domain ← Data
- Domain KHÔNG phụ thuộc vào bất kỳ layer nào khác
- Data implements các abstract class của Domain

---

## 2. Cấu trúc thư mục

```
lib/
├── core/                          # Shared utilities
│   ├── error/
│   │   ├── failures.dart          # Failure classes (domain-level errors)
│   │   └── exceptions.dart        # Exception classes (data-level errors)
│   ├── network/
│   │   ├── api_client.dart        # Dio/http setup
│   │   └── network_info.dart
│   ├── usecases/
│   │   └── usecase.dart           # Base UseCase abstract class
│   └── utils/
│       └── typedefs.dart          # FutureEither, etc.
│
├── features/
│   └── auth/                      # Feature module
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── auth_remote_datasource.dart
│       │   │   └── auth_local_datasource.dart
│       │   ├── models/
│       │   │   └── user_model.dart          # DTO + toEntity/fromJson
│       │   └── repositories/
│       │       └── auth_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user.dart                # Pure Dart class
│       │   ├── repositories/
│       │   │   └── auth_repository.dart     # Abstract class
│       │   └── usecases/
│       │       ├── login_usecase.dart
│       │       └── get_current_user_usecase.dart
│       │
│       └── presentation/
│           ├── providers/
│           │   ├── auth_providers.dart       # Riverpod providers (DI wiring)
│           │   └── login_viewmodel.dart      # Notifier (ViewModel)
│           ├── pages/
│           │   └── login_page.dart
│           └── widgets/
│               └── login_form.dart
│
├── app.dart
└── main.dart
```

---

## 3. Domain Layer (Lõi - không phụ thuộc gì)

### 3.1 Entity

```dart
// features/auth/domain/entities/user.dart

class User {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
  });
}
```

### 3.2 Repository (Abstract)

```dart
// features/auth/domain/repositories/auth_repository.dart

import 'package:fpdart/fpdart.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> logout();
}
```

### 3.3 UseCase

```dart
// core/usecases/usecase.dart

import 'package:fpdart/fpdart.dart';

/// UseCase có params
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// UseCase không params
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}
```

```dart
// features/auth/domain/usecases/login_usecase.dart

class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    return _repository.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}
```

### 3.4 Failure (Domain-level error)

```dart
// core/error/failures.dart

sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
```

---

## 4. Data Layer

### 4.1 Model (DTO)

```dart
// features/auth/data/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
  });

  /// JSON → Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'display_name': displayName,
    'avatar_url': avatarUrl,
  };

  /// Model → Entity (Domain layer)
  User toEntity() => User(
    id: id,
    email: email,
    displayName: displayName,
    avatarUrl: avatarUrl,
  );

  /// Entity → Model (để cache)
  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    email: user.email,
    displayName: user.displayName,
    avatarUrl: user.avatarUrl,
  );
}
```

### 4.2 DataSource

```dart
// features/auth/data/datasources/auth_remote_datasource.dart

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error');
    }
  }
}
```

### 4.3 Repository Implementation

```dart
// features/auth/data/repositories/auth_repository_impl.dart

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await _remoteDataSource.login(email, password);

      // Cache user locally
      await _localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity()); // DTO → Entity
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Try remote first
      final userModel = await _remoteDataSource.getCurrentUser();
      await _localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException {
      // Fallback to cache
      try {
        final cached = await _localDataSource.getCachedUser();
        return Right(cached.toEntity());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
```

---

## 5. Presentation Layer (MVVM + Riverpod)

### 5.1 Providers — Dependency Injection Wiring

```dart
// features/auth/presentation/providers/auth_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

// ===== Data layer providers =====

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  // Thêm interceptors: token, logging, etc.
  return dio;
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) {
  return AuthLocalDataSourceImpl();
}

// ===== Domain layer providers =====

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  );
}

@riverpod
LoginUseCase loginUseCase(Ref ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
}
```

### 5.2 ViewModel (AsyncNotifier)

```dart
// features/auth/presentation/providers/login_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_viewmodel.g.dart';

/// State cho LoginViewModel
class LoginState {
  final String email;
  final String password;
  final bool isPasswordVisible;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }

  bool get isValid => email.isNotEmpty && password.length >= 6;
}

/// ViewModel - xử lý logic presentation + gọi UseCase
@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginState build() => const LoginState();

  void onEmailChanged(String value) {
    state = state.copyWith(email: value.trim());
  }

  void onPasswordChanged(String value) {
    state = state.copyWith(password: value);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }
}

/// Tách riêng action login thành AsyncNotifier
/// để Widget listen trạng thái loading/error/data
@riverpod
class LoginAction extends _$LoginAction {
  @override
  FutureOr<User?> build() => null; // idle state

  Future<void> login() async {
    final formState = ref.read(loginViewModelProvider);
    if (!formState.isValid) return;

    state = const AsyncLoading();

    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(
      LoginParams(email: formState.email, password: formState.password),
    );

    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (user) => AsyncData(user),
    );
  }
}
```

### 5.3 View (Widget)

```dart
// features/auth/presentation/pages/login_page.dart

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(loginViewModelProvider);
    final loginAction = ref.watch(loginActionProvider);

    // ===== Side-effect handling =====
    ref.listen(loginActionProvider, (prev, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) {
            context.go('/home'); // Navigate on success
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    // ===== UI =====
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Email field
            TextField(
              onChanged: ref.read(loginViewModelProvider.notifier).onEmailChanged,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Password field
            TextField(
              onChanged: ref.read(loginViewModelProvider.notifier).onPasswordChanged,
              obscureText: !formState.isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    formState.isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: ref
                      .read(loginViewModelProvider.notifier)
                      .togglePasswordVisibility,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Login button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: formState.isValid && !loginAction.isLoading
                    ? () => ref.read(loginActionProvider.notifier).login()
                    : null,
                child: loginAction.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 6. Tổng kết vai trò từng thành phần

```
┌──────────────────────────────────────────────────────────────────┐
│ THÀNH PHẦN           │ VAI TRÒ                                   │
├──────────────────────┼───────────────────────────────────────────┤
│ Entity               │ Business object thuần (domain)            │
│ Model (DTO)          │ Serialize/deserialize + mapping Entity    │
│ DataSource           │ Giao tiếp API/DB trực tiếp                │
│ Repository (abstract)│ Contract ở domain layer                   │
│ Repository (impl)    │ Orchestrate datasources, map errors       │
│ UseCase              │ 1 business action, gọi repository         │
│ ViewModel (Notifier) │ Quản lý UI state + gọi UseCase            │
│ Provider             │ DI container (Riverpod wiring)            │
│ View (Widget)        │ Render UI, watch provider, dispatch action│
└──────────────────────┴───────────────────────────────────────────┘
```

---

## 7. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  dio: ^5.4.0
  fpdart: ^1.1.0           # Either, Option (functional error handling)
  go_router: ^14.0.0        # Routing
  shared_preferences: ^2.2.0
  freezed_annotation: ^2.4.0 # Optional: immutable state classes

dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
  freezed: ^2.5.0            # Optional
  json_serializable: ^6.7.0
  mockito: ^5.4.0
  mocktail: ^1.0.0
```

---

## 8. Tips thực chiến

### 8.1 Khi nào cần UseCase?
- Feature nhỏ, logic đơn giản → ViewModel gọi thẳng Repository cũng OK
- Feature phức tạp, logic cần reuse → Luôn qua UseCase
- Quy tắc: "Nếu 2 ViewModel cùng cần 1 business logic → tách UseCase"

### 8.2 State management pattern
- **Form state** (email, password, toggles) → Notifier (sync)
- **Async action** (login, fetch) → AsyncNotifier riêng
- **Global state** (current user, theme) → Provider ở core/

### 8.3 Error handling flow
```
DataSource throws Exception
    → RepositoryImpl catches → returns Left(Failure)
        → UseCase passes through Either
            → ViewModel receives → AsyncError
                → View shows SnackBar/Dialog
```

### 8.4 Testing pyramid
- **Unit test**: UseCase (mock Repository), ViewModel (mock UseCase)
- **Widget test**: Page (override Provider với mock)
- **Integration test**: Full flow với fake DataSource

**3 quyết định thiết kế quan trọng:**

1. **Riverpod đóng vai trò DI container** — thay vì dùng GetIt hay injectable, tất cả dependency được wire qua `@riverpod` functions trong file `auth_providers.dart`. Mỗi layer (DataSource → Repository → UseCase → ViewModel) đều là một provider.

2. **Tách ViewModel thành 2 loại Notifier** — `LoginViewModel` (sync Notifier) quản lý form state thuần như email, password, toggle. `LoginAction` (AsyncNotifier) xử lý async action và expose trạng thái loading/error/data để Widget listen.

3. **Error handling bằng `Either` (fpdart)** — Exception chỉ tồn tại ở Data layer. Từ Repository trở lên, mọi error đều là `Left(Failure)` — type-safe, dễ test, không bao giờ throw.

Nếu Huy cần mình đi sâu hơn vào phần nào (ví dụ cách test ViewModel, cách tổ chức routing với go_router, hay cách dùng `freezed` cho state classes), cứ nói nhé.
