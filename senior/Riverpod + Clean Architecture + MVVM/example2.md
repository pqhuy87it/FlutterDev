Hiểu, `fpdart` khá functional và không phải ai cũng thích. Mình sẽ thay `Either<AuthFailure, T>` bằng một sealed class `Result<T>` đơn giản tự viết. Vì thay đổi xuyên suốt toàn bộ file nên mình cần rewrite:Đã thay toàn bộ `fpdart Either` bằng `Result<T>` tự viết. Tóm tắt thay đổi:

**Thêm `core/result.dart`** — chỉ ~30 dòng code:

```dart
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> { final T value; }
class Failure<T> extends Result<T> { final AuthFailure error; }
```

**Cách dùng so sánh:**

```dart
// fpdart (CŨ)
Either<AuthFailure, User> result = ...;
result.fold(
  (failure) => handleError(failure),
  (user) => handleSuccess(user),
);

// Result<T> (MỚI) — cùng ý nghĩa, dễ đọc hơn
Result<User> result = ...;
result.when(
  failure: (failure) => handleError(failure),
  success: (user) => handleSuccess(user),
);

// Hoặc check đơn giản
if (result.isFailure) return Failure(result.failure!);
```

```Dart
// ============================================================================
// CẤU TRÚC THƯ MỤC
// ============================================================================
//
// lib/
// ├── core/
// │   └── result.dart                     ← Result<T> thay fpdart Either
// │
// └── features/auth/
//     ├── data/
//     │   ├── datasources/
//     │   │   ├── auth_remote_datasource.dart
//     │   │   └── auth_local_datasource.dart
//     │   └── repositories/
//     │       ├── auth_repository_impl.dart
//     │       └── rate_limit_repository_impl.dart
//     │
//     ├── domain/
//     │   ├── entities/
//     │   │   └── login_result.dart
//     │   ├── repositories/
//     │   │   ├── auth_repository.dart
//     │   │   └── rate_limit_repository.dart
//     │   ├── usecases/
//     │   │   ├── login_usecase.dart
//     │   │   ├── check_sms_code_usecase.dart
//     │   │   ├── login_after_sms_usecase.dart
//     │   │   ├── login_and_update_phone_usecase.dart
//     │   │   ├── send_password_reset_usecase.dart
//     │   │   ├── check_rate_limit_usecase.dart
//     │   │   └── conditional_sign_out_usecase.dart
//     │   └── failures/
//     │       └── auth_failures.dart
//     │
//     └── presentation/
//         ├── providers/
//         │   ├── auth_providers.dart
//         │   └── after_login_handler.dart
//         ├── viewmodels/
//         │   ├── login_viewmodel.dart
//         │   ├── sms_auth_viewmodel.dart
//         │   ├── password_reset_viewmodel.dart
//         │   └── update_phone_viewmodel.dart
//         └── pages/
//             ├── login_page.dart
//             ├── sms_auth_page.dart
//             ├── password_reset_page.dart
//             └── update_phone_page.dart


// ============================================================================
// ██████╗ ██████╗ ██████╗ ███████╗
// ██╔════╝██╔═══██╗██╔══██╗██╔════╝
// ██║     ██║   ██║██████╔╝█████╗
// ██║     ██║   ██║██╔══██╗██╔══╝
// ╚██████╗╚██████╔╝██║  ██║███████╗
//  ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
// ============================================================================


// ============================================================================
// FILE: core/result.dart
// ============================================================================

/// Thay thế fpdart Either — đơn giản, dễ hiểu
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// Lấy data nếu Success, throw nếu Failure
  T get data => (this as Success<T>).value;

  /// Lấy failure nếu Failure, null nếu Success
  AuthFailure? get failure =>
      this is Failure<T> ? (this as Failure<T>).error : null;

  /// Pattern matching — dùng giống .fold() của fpdart
  R when<R>({
    required R Function(T value) success,
    required R Function(AuthFailure failure) failure,
  }) {
    return switch (this) {
      Success(:final value) => success(value),
      Failure(:final error) => failure(error),
    };
  }

  /// Chỉ xử lý success, trả fallback khi failure
  T getOrElse(T fallback) {
    return switch (this) {
      Success(:final value) => value,
      Failure() => fallback,
    };
  }
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final AuthFailure error;
  const Failure(this.error);
}


// ============================================================================
// ██████╗  ██████╗ ███╗   ███╗ █████╗ ██╗███╗   ██╗
// ██╔══██╗██╔═══██╗████╗ ████║██╔══██╗██║████╗  ██║
// ██║  ██║██║   ██║██╔████╔██║███████║██║██╔██╗ ██║
// ██║  ██║██║   ██║██║╚██╔╝██║██╔══██║██║██║╚██╗██║
// ██████╔╝╚██████╔╝██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
// ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
// ============================================================================


// ============================================================================
// FILE: domain/failures/auth_failures.dart
// ============================================================================

sealed class AuthFailure {
  final String message;
  const AuthFailure(this.message);
}

class ServerFailure extends AuthFailure {
  const ServerFailure(super.message);
}

class OfflineFailure extends AuthFailure {
  const OfflineFailure([super.message = 'インターネットに接続されていません。']);
}

class ValidationFailure extends AuthFailure {
  const ValidationFailure(super.message);
}

class RateLimitFailure extends AuthFailure {
  final String? code;
  const RateLimitFailure(super.message, {this.code});
}

class CloudFlareFailure extends AuthFailure {
  final String code;
  const CloudFlareFailure(super.message, {required this.code});
}

class UserPausedFailure extends AuthFailure {
  const UserPausedFailure(super.message);
}

class UserBlacklistedFailure extends AuthFailure {
  const UserBlacklistedFailure(super.message);
}

class FirstWinLoginFailure extends AuthFailure {
  final String title;
  const FirstWinLoginFailure(super.message, {required this.title});
}

class RequireSmsAuthFailure extends AuthFailure {
  final String email;
  final String password;
  final String tel;
  const RequireSmsAuthFailure({
    required this.email,
    required this.password,
    required this.tel,
  }) : super('SMS認証が必要です');
}

class RequireUpdatePhoneFailure extends AuthFailure {
  final String email;
  final String password;
  final String oldTel;
  const RequireUpdatePhoneFailure({
    required this.email,
    required this.password,
    required this.oldTel,
    String message = '新しい電話番号を登録してください。',
  }) : super(message);
}

class SmsVerificationFailure extends AuthFailure {
  const SmsVerificationFailure(super.message);
}

class PasswordResetFailure extends AuthFailure {
  const PasswordResetFailure(super.message);
}

class PhoneAlreadyExistsFailure extends AuthFailure {
  const PhoneAlreadyExistsFailure([super.message = 'この電話番号は使用できません']);
}


// ============================================================================
// FILE: domain/entities/login_result.dart
// ============================================================================

sealed class LoginResult {
  const LoginResult();
}

class LoginSuccess extends LoginResult {
  const LoginSuccess();
}

class LoginRequiresSmsAuth extends LoginResult {
  final String email;
  final String password;
  final String tel;
  const LoginRequiresSmsAuth({
    required this.email,
    required this.password,
    required this.tel,
  });
}

class LoginRequiresPhoneUpdate extends LoginResult {
  final String email;
  final String password;
  final String oldTel;
  final String message;
  const LoginRequiresPhoneUpdate({
    required this.email,
    required this.password,
    required this.oldTel,
    this.message = '新しい電話番号を登録してください。',
  });
}


// ============================================================================
// FILE: domain/repositories/auth_repository.dart
// ============================================================================

abstract class AuthRepository {
  Future<Result<LoginResult>> login({
    required String email,
    required String password,
  });

  Future<Result<void>> loginAndUpdatePhone({
    required String email,
    required String password,
    required String tel,
  });

  Future<Result<void>> loginAfterSmsAuth({
    required String email,
    required String password,
  });

  Future<Result<bool>> checkSmsCode({
    required String code,
    required String tel,
  });

  Future<Result<bool>> sendSmsCode({required String tel});

  Future<Result<bool>> sendPasswordResetEmail({required String email});

  Future<Result<bool>> isEmailAlreadyExist({required String email});

  Future<Result<bool>> isTelAlreadyExist({required String tel});

  Future<Result<String?>> performAfterLoginTasks();

  Future<void> conditionalSignOut({bool? enableTwoStepVerification});

  Future<void> saveCredential({
    required String email,
    required String password,
  });
}


// ============================================================================
// FILE: domain/repositories/rate_limit_repository.dart
// ============================================================================

abstract class RateLimitRepository {
  Future<Result<void>> checkLoginRateLimit();
  Future<Result<void>> checkRegisterRateLimit();
}


// ============================================================================
// FILE: domain/usecases/login_usecase.dart
// ============================================================================

class LoginUseCase {
  final AuthRepository _authRepo;
  final RateLimitRepository _rateLimitRepo;

  const LoginUseCase(this._authRepo, this._rateLimitRepo);

  Future<Result<LoginResult>> call({
    required String email,
    required String password,
  }) async {
    // Step 1: Rate limit check
    final rateLimitResult = await _rateLimitRepo.checkLoginRateLimit();
    if (rateLimitResult.isFailure) {
      return Failure(rateLimitResult.failure!);
    }

    // Step 2-4: Login + user status + 2FA
    final loginResult = await _authRepo.login(
      email: email,
      password: password,
    );

    // Step 5: Save credential nếu thành công
    if (loginResult.isSuccess) {
      await _authRepo.saveCredential(email: email, password: password);
    }

    return loginResult;
  }
}


// ============================================================================
// FILE: domain/usecases/check_sms_code_usecase.dart
// ============================================================================

class CheckSmsCodeUseCase {
  final AuthRepository _repository;

  const CheckSmsCodeUseCase(this._repository);

  Future<Result<bool>> call({
    required String code,
    required String tel,
  }) {
    return _repository.checkSmsCode(code: code, tel: tel);
  }
}


// ============================================================================
// FILE: domain/usecases/login_after_sms_usecase.dart
// ============================================================================

class LoginAfterSmsUseCase {
  final AuthRepository _repository;

  const LoginAfterSmsUseCase(this._repository);

  Future<Result<void>> call({
    required String email,
    required String password,
  }) {
    return _repository.loginAfterSmsAuth(
      email: email,
      password: password,
    );
  }
}


// ============================================================================
// FILE: domain/usecases/send_password_reset_usecase.dart
// ============================================================================

class SendPasswordResetUseCase {
  final AuthRepository _repository;

  const SendPasswordResetUseCase(this._repository);

  Future<Result<bool>> call({required String email}) async {
    // 1. Check email exist
    final existResult = await _repository.isEmailAlreadyExist(email: email);
    if (existResult.isFailure) return Failure(existResult.failure!);

    if (!existResult.data) {
      return const Failure(
        PasswordResetFailure('ご入力のメールアドレスは登録されていません。'),
      );
    }

    // 2. Send reset email
    return _repository.sendPasswordResetEmail(email: email);
  }
}


// ============================================================================
// FILE: domain/usecases/login_and_update_phone_usecase.dart
// ============================================================================

class LoginAndUpdatePhoneUseCase {
  final AuthRepository _repository;

  const LoginAndUpdatePhoneUseCase(this._repository);

  /// Kiểm tra phone trùng → gửi SMS code
  Future<Result<bool>> validateAndSendCode({
    required String newTel,
    required String oldTel,
  }) async {
    // Check duplicate (nếu số mới == số cũ thì skip)
    if (newTel != oldTel) {
      final existResult = await _repository.isTelAlreadyExist(tel: newTel);
      if (existResult.isFailure) return Failure(existResult.failure!);
      if (existResult.data) {
        return const Failure(PhoneAlreadyExistsFailure());
      }
    }

    return _repository.sendSmsCode(tel: newTel);
  }

  /// Sau khi SMS verified → login + update phone
  Future<Result<void>> executeLoginAndUpdate({
    required String email,
    required String password,
    required String tel,
  }) {
    return _repository.loginAndUpdatePhone(
      email: email,
      password: password,
      tel: tel,
    );
  }
}


// ============================================================================
// FILE: domain/usecases/conditional_sign_out_usecase.dart
// ============================================================================

class ConditionalSignOutUseCase {
  final AuthRepository _repository;

  const ConditionalSignOutUseCase(this._repository);

  Future<void> call({bool? enableTwoStepVerification}) {
    return _repository.conditionalSignOut(
      enableTwoStepVerification: enableTwoStepVerification,
    );
  }
}


// ============================================================================
// FILE: domain/usecases/check_rate_limit_usecase.dart
// ============================================================================

class CheckRegisterRateLimitUseCase {
  final RateLimitRepository _repository;

  const CheckRegisterRateLimitUseCase(this._repository);

  Future<Result<void>> call() {
    return _repository.checkRegisterRateLimit();
  }
}


// ============================================================================
// ██████╗  █████╗ ████████╗ █████╗
// ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
// ██║  ██║███████║   ██║   ███████║
// ██║  ██║██╔══██║   ██║   ██╔══██║
// ██████╔╝██║  ██║   ██║   ██║  ██║
// ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝
// ============================================================================


// ============================================================================
// FILE: data/datasources/auth_remote_datasource.dart
// ============================================================================

import 'dart:io';
import 'package:api_client/constants/firestore/user_status.dart';
import 'package:api_client/dependent/cloud_firestore.dart';
import 'package:api_client/dependent/firebase_auth.dart';
import 'package:api_client/firebase_functions_client.dart';
import 'package:api_client/firestore_collection_names.dart';
import 'package:api_client/request/functions/check_code/check_code_request.dart';
import 'package:api_client/request/functions/is_email_already_exist/is_email_already_exist_request.dart';
import 'package:api_client/request/functions/is_tel_already_exist/is_tel_already_exist_request.dart';
import 'package:api_client/request/functions/send_code/send_code_request.dart';
import 'package:api_client/request/functions/set_two_step_verification/set_two_step_verification_request.dart';
import 'package:api_client/response/firestore/users/users_document_data.dart';

abstract class AuthRemoteDataSource {
  Future<bool> signIn({required String email, required String password});
  Future<void> signOut({bool isRemoveToken = false});
  String? get currentUserUid;

  Future<UsersDocumentData> getUserDocument(String uid);
  Future<bool> getTwoStepVerification();
  Future<bool> setTwoStepVerification(bool value);

  Future<bool> checkSmsCode({required String code, required String tel});
  Future<bool> sendSmsCode({required String tel});

  Future<bool> isEmailAlreadyExist({required String email});
  Future<bool> isTelAlreadyExist({required String tel});
  Future<void> sendResetPasswordEmail({required String email});

  Future<void> updateUserPhone({required String tel});
  Future<void> registerYomsubiUser();
  Future<String?> registerPushToken();
  Future<void> lockForHighBalanceHolder();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthService _authService;
  final FirebaseFunctionsClient _functionsClient;

  AuthRemoteDataSourceImpl(this._authService, this._functionsClient);

  @override
  Future<bool> signIn({required String email, required String password}) {
    return _authService.signIn(email: email, password: password);
  }

  @override
  Future<void> signOut({bool isRemoveToken = false}) {
    return _authService.signOut(isRemoveToken: isRemoveToken);
  }

  @override
  String? get currentUserUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<UsersDocumentData> getUserDocument(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection(FirestoreCollectionNames.users)
        .doc(uid)
        .get(const GetOptions(source: Source.server));
    if (!doc.exists) throw Exception('ユーザーデータが存在しません');
    return UsersDocumentData.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<bool> getTwoStepVerification() async {
    final userData = await _functionsClient.getUserData();
    return userData.when(
      success: (data1) async {
        final result = await _functionsClient.getUser();
        return result.when(
          success: (data2) {
            return (data2.customClaims?.TWO_STEP_VERIFICATION ?? false) &&
                (data1.user?.telVerified ?? false);
          },
          failure: (error) => throw error,
        );
      },
      failure: (error) => throw error,
    );
  }

  @override
  Future<bool> setTwoStepVerification(bool value) async {
    await _functionsClient.updateUserProperties({
      'user': {'telVerified': value},
    }, notificationOff: true);
    final result = await _functionsClient.setTwoStepVerification(
      SetTwoStepVerificationRequest(
        uid: currentUserUid ?? '',
        twoStepVerification: value,
      ),
    );
    return result.when(
      success: (data) => data,
      failure: (error) => throw error,
    );
  }

  @override
  Future<bool> checkSmsCode({required String code, required String tel}) async {
    final result = await _functionsClient.checkCode(
      CheckCodeRequest(code: code, tel: tel),
    );
    return result.when(
      success: (data) => data.success == true,
      failure: (error) => throw error,
    );
  }

  @override
  Future<bool> sendSmsCode({required String tel}) async {
    await _functionsClient.sendCode(SendCodeRequest(tel: tel));
    return true;
  }

  @override
  Future<bool> isEmailAlreadyExist({required String email}) async {
    final result = await _functionsClient.isEmailAlreadyExist(
      IsEmailAlreadyExistRequest(email: email),
    );
    return result.when(
      success: (data) => data.exist,
      failure: (error) => throw error,
    );
  }

  @override
  Future<bool> isTelAlreadyExist({required String tel}) async {
    final result = await _functionsClient.isTelAlreadyExist(
      IsTelAlreadyExistRequest(tel: tel),
    );
    return result.when(
      success: (data) => data.exist,
      failure: (error) => throw error,
    );
  }

  @override
  Future<void> sendResetPasswordEmail({required String email}) async {
    final result = await YomsubiApiClient.instance.sendResetFirebasePwMail(
      email: email,
    );
    result.when(
      success: (data) {
        if (!data.result) throw Exception('メール送信に失敗しました');
      },
      failure: (error) => throw error,
    );
  }

  @override
  Future<void> updateUserPhone({required String tel}) async {
    await _functionsClient.updateUserProperties({
      'user': {'tel': tel},
    });
  }

  @override
  Future<void> registerYomsubiUser() async {
    await YomsubiApiClient.instance.addUser();
  }

  @override
  Future<String?> registerPushToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    await ApiClient.instance.updateUserMessagingToken(token: token);
    return token;
  }

  @override
  Future<void> lockForHighBalanceHolder() async {
    await AccountLockUtil().lockForHighBalanceHolder();
  }
}


// ============================================================================
// FILE: data/datasources/auth_local_datasource.dart
// ============================================================================

import 'dart:io';

abstract class AuthLocalDataSource {
  Future<void> saveCredential({
    required String email,
    required String password,
  });
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> saveCredential({
    required String email,
    required String password,
  }) async {
    if (Platform.isIOS) {
      await CredentialService.save(username: email, password: password);
    }
  }
}


// ============================================================================
// FILE: data/repositories/auth_repository_impl.dart
// ============================================================================

import 'package:api_client/constants/firestore/user_status.dart';
import 'package:api_client/constants/network_error_codes.dart';
import 'package:api_client/exception/api_exception_handler.dart';
import 'package:api_client/exception/db_failure_exception.dart';
import 'package:yomsubi_api_client/response/rate_limit_exception.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  // ===== Helper =====

  Future<String?> _performAfterLogin() async {
    await _remote.registerYomsubiUser();
    try {
      return await _remote.registerPushToken();
    } catch (e) {
      debugPrint('FCM token error: $e');
      return null;
    }
  }

  // ===== Login =====

  @override
  Future<Result<LoginResult>> login({
    required String email,
    required String password,
  }) async {
    try {
      final success = await _remote.signIn(email: email, password: password);
      if (!success) {
        return const Failure(ServerFailure('ログインに失敗しました'));
      }

      final uid = _remote.currentUserUid;
      if (uid == null) {
        return const Failure(ServerFailure('ユーザー情報の取得に失敗しました'));
      }

      final userDoc = await _remote.getUserDocument(uid);

      // Status check
      if (userDoc.status == UserStatus.pause) {
        await _remote.signOut(isRemoveToken: false);
        return const Failure(
          UserPausedFailure(AppStrings.userStatusPauseMessage),
        );
      }
      if (userDoc.status == UserStatus.blacklist) {
        await _remote.signOut(isRemoveToken: false);
        return const Failure(
          UserBlacklistedFailure(AppStrings.userStatusBlacklistMessage),
        );
      }

      // 2FA check
      final enable2FA = await _remote.getTwoStepVerification();
      final hasTel = userDoc.tel != null && userDoc.tel!.isNotEmpty;

      if (enable2FA && hasTel) {
        await _remote.signOut(isRemoveToken: false);
        await _remote.sendSmsCode(tel: userDoc.tel!);
        return Success(LoginRequiresSmsAuth(
          email: email,
          password: password,
          tel: userDoc.tel!,
        ));
      } else if (!enable2FA && hasTel) {
        await _remote.signOut(isRemoveToken: false);
        return Success(LoginRequiresPhoneUpdate(
          email: email,
          password: password,
          oldTel: userDoc.tel!,
        ));
      } else {
        await _performAfterLogin();
        return const Success(LoginSuccess());
      }
    } on DbFailureException {
      await _remote.signOut(isRemoveToken: false);
      return const Failure(ServerFailure('ユーザーデータが存在しません'));
    } on RateLimitException {
      await _remote.signOut(isRemoveToken: false);
      return const Failure(RateLimitFailure(
        'ただいまアクセスが集中しております。\nしばらく時間をおいてから再度お試しください。',
      ));
    } on CloudFlareException catch (e) {
      await _remote.signOut(isRemoveToken: false);
      return Failure(CloudFlareFailure(
        'システムエラーが発生しました。\n\nしばらく時間をおいてから再度お試しください。',
        code: e.code,
      ));
    } catch (e) {
      final error = ApiExceptionHandler.getError(e);
      final isOffline = NetworkErrorCodes.isNetworkError(
        error.code?.toString(),
      );
      if (isOffline) return Failure(OfflineFailure(error.getMessage()));
      return Failure(ServerFailure(error.getMessage()));
    }
  }

  // ===== Login after SMS auth =====

  @override
  Future<Result<void>> loginAfterSmsAuth({
    required String email,
    required String password,
  }) async {
    try {
      final success = await _remote.signIn(email: email, password: password);
      if (!success) {
        return const Failure(
          ServerFailure('ログインに失敗しました。\nはじめからやり直してください。'),
        );
      }
      await Future.delayed(const Duration(seconds: 1));
      await _performAfterLogin();
      await _remote.lockForHighBalanceHolder();
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure(
        ApiExceptionHandler.getError(e).getMessage(),
      ));
    }
  }

  // ===== Login + update phone =====

  @override
  Future<Result<void>> loginAndUpdatePhone({
    required String email,
    required String password,
    required String tel,
  }) async {
    try {
      final success = await _remote.signIn(email: email, password: password);
      if (!success) throw Exception('ログインに失敗しました。');

      await Future.delayed(const Duration(seconds: 1));
      await _remote.updateUserPhone(tel: tel);
      await _remote.setTwoStepVerification(true);
      await _performAfterLogin();
      await _remote.lockForHighBalanceHolder();
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure(
        ApiExceptionHandler.getError(e).getMessage(),
      ));
    }
  }

  // ===== SMS =====

  @override
  Future<Result<bool>> checkSmsCode({
    required String code,
    required String tel,
  }) async {
    try {
      final result = await _remote.checkSmsCode(code: code, tel: tel);
      if (!result) return const Failure(SmsVerificationFailure('認証に失敗しました'));
      return const Success(true);
    } catch (e) {
      final error = ApiExceptionHandler.getError(e);
      final isOffline = NetworkErrorCodes.isNetworkError(
        error.code?.toString(),
      );
      if (isOffline) return Failure(OfflineFailure(error.getMessageDetails()));
      return Failure(SmsVerificationFailure(error.getMessageDetails()));
    }
  }

  @override
  Future<Result<bool>> sendSmsCode({required String tel}) async {
    try {
      await _remote.sendSmsCode(tel: tel);
      return const Success(true);
    } catch (e) {
      return Failure(ServerFailure(
        ApiExceptionHandler.getError(e).getMessage(),
      ));
    }
  }

  // ===== Password reset =====

  @override
  Future<Result<bool>> sendPasswordResetEmail({required String email}) async {
    try {
      await _remote.sendResetPasswordEmail(email: email);
      return const Success(true);
    } catch (e) {
      return Failure(PasswordResetFailure(
        ApiExceptionHandler.getError(e).getMessage(),
      ));
    }
  }

  @override
  Future<Result<bool>> isEmailAlreadyExist({required String email}) async {
    try {
      final exists = await _remote.isEmailAlreadyExist(email: email);
      return Success(exists);
    } catch (e) {
      return Failure(ServerFailure(
        ApiExceptionHandler.getError(e).getMessage(),
      ));
    }
  }

  // ===== Phone =====

  @override
  Future<Result<bool>> isTelAlreadyExist({required String tel}) async {
    try {
      final exists = await _remote.isTelAlreadyExist(tel: tel);
      return Success(exists);
    } catch (e) {
      return Failure(ServerFailure(
        ApiExceptionHandler.getError(e).getMessage(),
      ));
    }
  }

  // ===== After login tasks =====

  @override
  Future<Result<String?>> performAfterLoginTasks() async {
    try {
      final token = await _performAfterLogin();
      return Success(token);
    } catch (e) {
      return Failure(ServerFailure(e.toString()));
    }
  }

  // ===== Sign out =====

  @override
  Future<void> conditionalSignOut({bool? enableTwoStepVerification}) async {
    final currentUser = _remote.currentUserUid;
    if (currentUser != null &&
        (enableTwoStepVerification == null || enableTwoStepVerification)) {
      await _remote.signOut(isRemoveToken: false);
    }
  }

  @override
  Future<void> saveCredential({
    required String email,
    required String password,
  }) async {
    await _local.saveCredential(email: email, password: password);
  }
}


// ============================================================================
// FILE: data/repositories/rate_limit_repository_impl.dart
// ============================================================================

import 'package:yomsubi_api_client/rate_limit_api_client.dart';
import 'package:yomsubi_api_client/response/rate_limit_exception.dart';

class RateLimitRepositoryImpl implements RateLimitRepository {
  @override
  Future<Result<void>> checkLoginRateLimit() async {
    try {
      await RateLimitApiClient.instance.checkRateLimitLogin();
      return const Success(null);
    } on RateLimitException {
      return const Failure(RateLimitFailure(
        'ただいまアクセスが集中しております。\nしばらく時間をおいてから再度お試しください。',
      ));
    } on CloudFlareException catch (e) {
      return Failure(CloudFlareFailure(
        'システムエラーが発生しました。\n\nしばらく時間をおいてから再度お試しください。',
        code: e.code,
      ));
    } catch (e) {
      return Failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> checkRegisterRateLimit() async {
    try {
      await RateLimitApiClient.instance.checkRateLimitRegister();
      return const Success(null);
    } on RateLimitException {
      return const Failure(RateLimitFailure(
        'ただいまアクセスが集中しております。\nしばらく時間をおいてから再度お試しください。',
      ));
    } on CloudFlareException catch (e) {
      return Failure(CloudFlareFailure(
        'システムエラーが発生しました。\n\nしばらく時間をおいてから再度お試しください。',
        code: e.code,
      ));
    } catch (e) {
      return Failure(ServerFailure(e.toString()));
    }
  }
}


// ============================================================================
// ██████╗ ██████╗ ███████╗███████╗███████╗███╗   ██╗████████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
// ██╔══██╗██╔══██╗██╔════╝██╔════╝██╔════╝████╗  ██║╚══██╔══╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
// ██████╔╝██████╔╝█████╗  ███████╗█████╗  ██╔██╗ ██║   ██║   ███████║   ██║   ██║██║   ██║██╔██╗ ██║
// ██╔═══╝ ██╔══██╗██╔══╝  ╚════██║██╔══╝  ██║╚██╗██║   ██║   ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
// ██║     ██║  ██║███████╗███████║███████╗██║ ╚████║   ██║   ██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
// ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
// ============================================================================


// ============================================================================
// FILE: presentation/providers/auth_providers.dart
// ============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

// ===== Data Layer =====

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl(
    AuthService.instance,
    FirebaseFunctionsClient.instance,
  );
}

@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) {
  return AuthLocalDataSourceImpl();
}

// ===== Repositories =====

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  );
}

@riverpod
RateLimitRepository rateLimitRepository(Ref ref) {
  return RateLimitRepositoryImpl();
}

// ===== Use Cases =====

@riverpod
LoginUseCase loginUseCase(Ref ref) {
  return LoginUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(rateLimitRepositoryProvider),
  );
}

@riverpod
CheckSmsCodeUseCase checkSmsCodeUseCase(Ref ref) {
  return CheckSmsCodeUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
LoginAfterSmsUseCase loginAfterSmsUseCase(Ref ref) {
  return LoginAfterSmsUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
SendPasswordResetUseCase sendPasswordResetUseCase(Ref ref) {
  return SendPasswordResetUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
LoginAndUpdatePhoneUseCase loginAndUpdatePhoneUseCase(Ref ref) {
  return LoginAndUpdatePhoneUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
ConditionalSignOutUseCase conditionalSignOutUseCase(Ref ref) {
  return ConditionalSignOutUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
CheckRegisterRateLimitUseCase checkRegisterRateLimitUseCase(Ref ref) {
  return CheckRegisterRateLimitUseCase(ref.watch(rateLimitRepositoryProvider));
}

// ===== After Login Handler =====

@riverpod
AfterLoginHandler afterLoginHandler(Ref ref) {
  return AfterLoginHandler(ref);
}


// ============================================================================
// FILE: presentation/providers/after_login_handler.dart
// ============================================================================

/// Xử lý Riverpod state-side sau login thành công.
/// Dùng chung cho LoginViewModel, SmsAuthViewModel, UpdatePhoneViewModel.
///
/// Phần API-side (registerYomsubiUser, registerPushToken)
/// đã được xử lý trong AuthRepositoryImpl._performAfterLogin()
class AfterLoginHandler {
  final Ref _ref;

  const AfterLoginHandler(this._ref);

  void execute({bool isFromRegister = false}) {
    try {
      _ref
          .read(sharedPreferencesProvider)
          .setString(
            SharedPreferencesKey.lastFcmTokenFetchDate,
            DateTime.now().toIso8601String(),
          );
    } catch (_) {}
    _ref.read(realLoggedIn.notifier).setState(true);
    eventBus.fire(LoginEvent(isFromRegister: isFromRegister));
    TTPFirebaseAnalytics.login();
  }
}


// ============================================================================
// FILE: presentation/viewmodels/login_viewmodel.dart
// ============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_viewmodel.g.dart';

// ---------- States ----------

sealed class LoginActionState {
  const LoginActionState();
}

class LoginIdle extends LoginActionState {
  const LoginIdle();
}

class LoginLoading extends LoginActionState {
  const LoginLoading();
}

class LoginSuccessState extends LoginActionState {
  const LoginSuccessState();
}

class LoginNeedsSmsAuth extends LoginActionState {
  final String email;
  final String password;
  final String tel;
  const LoginNeedsSmsAuth({
    required this.email,
    required this.password,
    required this.tel,
  });
}

class LoginNeedsPhoneUpdate extends LoginActionState {
  final String email;
  final String password;
  final String oldTel;
  final String message;
  const LoginNeedsPhoneUpdate({
    required this.email,
    required this.password,
    required this.oldTel,
    required this.message,
  });
}

class LoginErrorState extends LoginActionState {
  final String message;
  final bool isOffline;
  const LoginErrorState(this.message, {this.isOffline = false});
}

class LoginBlacklistedState extends LoginActionState {
  final String message;
  const LoginBlacklistedState(this.message);
}

class LoginFirstWinErrorState extends LoginActionState {
  final String title;
  final String message;
  const LoginFirstWinErrorState({required this.title, required this.message});
}

// ---------- ViewModel ----------

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginActionState build() => const LoginIdle();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (state is LoginLoading) return;

    state = const LoginLoading();

    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(email: email, password: password);

    state = result.when(
      success: (loginResult) {
        if (loginResult is LoginSuccess) {
          ref.read(afterLoginHandlerProvider).execute();
        }
        return switch (loginResult) {
          LoginSuccess() => const LoginSuccessState(),
          LoginRequiresSmsAuth(:final email, :final password, :final tel) =>
            LoginNeedsSmsAuth(email: email, password: password, tel: tel),
          LoginRequiresPhoneUpdate(
            :final email,
            :final password,
            :final oldTel,
            :final message,
          ) =>
            LoginNeedsPhoneUpdate(
              email: email,
              password: password,
              oldTel: oldTel,
              message: message,
            ),
        };
      },
      failure: (error) => _mapFailureToState(error),
    );
  }

  void reset() {
    state = const LoginIdle();
  }

  LoginActionState _mapFailureToState(AuthFailure failure) {
    return switch (failure) {
      OfflineFailure(:final message) =>
        LoginErrorState(message, isOffline: true),
      UserPausedFailure(:final message) =>
        LoginErrorState(message),
      UserBlacklistedFailure(:final message) =>
        LoginBlacklistedState(message),
      FirstWinLoginFailure(:final title, :final message) =>
        LoginFirstWinErrorState(title: title, message: message),
      RateLimitFailure(:final message) =>
        LoginErrorState(message),
      CloudFlareFailure(:final message, :final code) =>
        LoginErrorState('$message\nエラーコード：$code'),
      _ => LoginErrorState(failure.message),
    };
  }
}


// ============================================================================
// FILE: presentation/viewmodels/sms_auth_viewmodel.dart
// ============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sms_auth_viewmodel.g.dart';

sealed class SmsAuthState {
  const SmsAuthState();
}

class SmsAuthIdle extends SmsAuthState {
  const SmsAuthIdle();
}

class SmsAuthLoading extends SmsAuthState {
  const SmsAuthLoading();
}

class SmsAuthSuccess extends SmsAuthState {
  const SmsAuthSuccess();
}

class SmsAuthError extends SmsAuthState {
  final String message;
  final bool isOffline;
  const SmsAuthError(this.message, {this.isOffline = false});
}

@riverpod
class SmsAuthViewModel extends _$SmsAuthViewModel {
  @override
  SmsAuthState build() => const SmsAuthIdle();

  Future<void> verifyAndLogin({
    required String code,
    required String tel,
    required String email,
    required String password,
  }) async {
    state = const SmsAuthLoading();

    // Step 1: Check code
    final checkCodeUC = ref.read(checkSmsCodeUseCaseProvider);
    final codeResult = await checkCodeUC(code: code, tel: tel);

    if (codeResult.isFailure) {
      final f = codeResult.failure!;
      state = SmsAuthError(f.message, isOffline: f is OfflineFailure);
      return;
    }

    if (!codeResult.data) {
      state = const SmsAuthError('認証に失敗しました');
      return;
    }

    // Step 2: Login
    final loginAfterSmsUC = ref.read(loginAfterSmsUseCaseProvider);
    final loginResult = await loginAfterSmsUC(
      email: email,
      password: password,
    );

    state = loginResult.when(
      success: (_) {
        ref.read(afterLoginHandlerProvider).execute();
        return const SmsAuthSuccess();
      },
      failure: (f) => SmsAuthError(
        f.message,
        isOffline: f is OfflineFailure,
      ),
    );
  }
}


// ============================================================================
// FILE: presentation/viewmodels/password_reset_viewmodel.dart
// ============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'password_reset_viewmodel.g.dart';

sealed class PasswordResetState {
  const PasswordResetState();
}

class PasswordResetIdle extends PasswordResetState {
  const PasswordResetIdle();
}

class PasswordResetLoading extends PasswordResetState {
  const PasswordResetLoading();
}

class PasswordResetSuccess extends PasswordResetState {
  final String email;
  const PasswordResetSuccess(this.email);
}

class PasswordResetError extends PasswordResetState {
  final String message;
  const PasswordResetError(this.message);
}

@riverpod
class PasswordResetViewModel extends _$PasswordResetViewModel {
  @override
  PasswordResetState build() => const PasswordResetIdle();

  Future<void> sendResetEmail({required String email}) async {
    state = const PasswordResetLoading();

    final useCase = ref.read(sendPasswordResetUseCaseProvider);
    final result = await useCase(email: email);

    state = result.when(
      success: (_) => PasswordResetSuccess(email),
      failure: (f) => PasswordResetError(f.message),
    );
  }
}


// ============================================================================
// FILE: presentation/viewmodels/update_phone_viewmodel.dart
// ============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_phone_viewmodel.g.dart';

sealed class UpdatePhoneState {
  const UpdatePhoneState();
}

class UpdatePhoneIdle extends UpdatePhoneState {
  const UpdatePhoneIdle();
}

class UpdatePhoneLoading extends UpdatePhoneState {
  const UpdatePhoneLoading();
}

class UpdatePhoneCodeSent extends UpdatePhoneState {
  final String tel;
  const UpdatePhoneCodeSent(this.tel);
}

class UpdatePhoneSuccess extends UpdatePhoneState {
  const UpdatePhoneSuccess();
}

class UpdatePhoneError extends UpdatePhoneState {
  final String message;
  const UpdatePhoneError(this.message);
}

@riverpod
class UpdatePhoneViewModel extends _$UpdatePhoneViewModel {
  @override
  UpdatePhoneState build() => const UpdatePhoneIdle();

  Future<void> validateAndSendCode({
    required String newTel,
    required String oldTel,
  }) async {
    state = const UpdatePhoneLoading();

    final useCase = ref.read(loginAndUpdatePhoneUseCaseProvider);
    final result = await useCase.validateAndSendCode(
      newTel: newTel,
      oldTel: oldTel,
    );

    state = result.when(
      success: (_) => UpdatePhoneCodeSent(newTel),
      failure: (f) => UpdatePhoneError(f.message),
    );
  }

  Future<void> executeLoginAndUpdate({
    required String email,
    required String password,
    required String tel,
  }) async {
    state = const UpdatePhoneLoading();

    final useCase = ref.read(loginAndUpdatePhoneUseCaseProvider);
    final result = await useCase.executeLoginAndUpdate(
      email: email,
      password: password,
      tel: tel,
    );

    state = result.when(
      success: (_) {
        ref.read(afterLoginHandlerProvider).execute();
        return const UpdatePhoneSuccess();
      },
      failure: (f) => UpdatePhoneError(f.message),
    );
  }
}


// ============================================================================
// FILE: presentation/pages/login_page.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.email, this.isLogEventAtInit = true});

  final String? email;
  final bool isLogEventAtInit;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with WidgetsBindingObserver {
  final _fbKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isLogEventAtInit) {
      TTPFirebaseAnalytics.logEvent(
        eventName: FirebaseEventName.view_custom_event,
        eventValues: {
          FirebaseParameterName.screen_name.value: "login_top",
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.paused ||
        appState == AppLifecycleState.resumed) {
      // Chỉ sign out nếu user chưa thực sự login thành công
      final loginState = ref.read(loginViewModelProvider);
      if (loginState is! LoginSuccessState) {
        ref.read(conditionalSignOutUseCaseProvider)();
      }
    }
  }

  // ===== Event Handlers =====

  Future<void> _onLoginPressed() async {
    AppUtil.hideKeyboard(context);
    if (Platform.isIOS) {
      TextInput.finishAutofillContext(shouldSave: false);
    }

    TTPFirebaseAnalytics.logEvent(
      eventName: FirebaseEventName.tap_custom_event,
      eventValues: {
        FirebaseParameterName.function_name.value: "login_button",
      },
    );

    final canProceed = await _checkAppUpdate();
    if (!canProceed) return;

    _fbKey.currentState?.save();
    if (!(_fbKey.currentState?.validate() ?? false)) return;

    final data = _fbKey.currentState!.value;
    await ref.read(loginViewModelProvider.notifier).login(
      email: data['email'],
      password: data['password'],
    );
  }

  Future<bool> _checkAppUpdate() async {
    try {
      await TermsAgreeService.instance.checkAppUpdateWithLatest(
        context: context,
        ref: ref,
      );
      if (TermsAgreeService.instance.showingDialog) {
        await TermsAgreeService.instance.queueDialog.onComplete;
      }
      return true;
    } catch (e) {
      if (mounted) _showOfflineDialog();
      return false;
    }
  }

  void _showOfflineDialog() {
    CommonDialog.showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ErrorMessageDialogBox(
        error: AppStrings.offlineMessage,
        onTap: () {},
      ),
    );
  }

  // ===== Build =====

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);

    // ★ Side-effect handling
    ref.listen(loginViewModelProvider, (prev, next) {
      switch (next) {
        case LoginSuccessState():
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
        case LoginNeedsSmsAuth(:final email, :final password, :final tel):
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SmsAuthPage(
                email: email,
                password: password,
                tel: tel,
              ),
            ),
          );
          ref.read(loginViewModelProvider.notifier).reset();
        case LoginNeedsPhoneUpdate(
            :final email,
            :final password,
            :final oldTel,
            :final message,
          ):
          CommonDialog.showDialog(
            context: context,
            builder: (_) => BasicDialogBox(
              message: message,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UpdatePhonePage(
                      email: email,
                      password: password,
                      oldTel: oldTel,
                    ),
                  ),
                );
              },
            ),
          );
          ref.read(loginViewModelProvider.notifier).reset();
        case LoginBlacklistedState(:final message):
          _showBlacklistDialog(message);
          ref.read(loginViewModelProvider.notifier).reset();
        case LoginFirstWinErrorState(:final title, :final message):
          CommonDialog.showDialog(
            context: context,
            builder: (_) => TitleMessageDialogBox(
              title: title,
              message: message,
              onTap: () {},
            ),
          );
          ref.read(loginViewModelProvider.notifier).reset();
        case LoginErrorState(:final message, :final isOffline):
          if (isOffline) {
            _showOfflineDialog();
            ref.read(loginViewModelProvider.notifier).reset();
          }
        default:
          break;
      }
    });

    final isLoading = loginState is LoginLoading;
    final errorMessage = loginState is LoginErrorState && !loginState.isOffline
        ? loginState.message
        : null;

    return Scaffold(
      body: PopScope(
        canPop: false,
        child: GestureDetector(
          onTap: () {
            AppUtil.hideKeyboard(context);
            _fbKey.currentState?.validate();
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  color: RSA.instance.primaryColor,
                  child: Column(
                    children: [
                      const SizedBox(height: AppDimens.spacer46),
                      Image(
                        image: Assets.images.loginLogo.provider(),
                        height: AppDimens.spacer60,
                      ),
                      const SizedBox(height: AppDimens.spacer30),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.spacer20),

                // Form
                FormBuilder(
                  autovalidateMode: AutovalidateMode.disabled,
                  key: _fbKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.horizontalMargin21,
                    ),
                    child: Column(
                      children: [
                        AutofillGroup(
                          onDisposeAction: AutofillContextAction.cancel,
                          child: Column(
                            children: [
                              WidgetWithLabel(
                                label: "メールアドレス",
                                widget: TextFieldRound(
                                  'email', null,
                                  ValidatorConstants.emailLogin(),
                                  null, null, null, "メールアドレス",
                                  initialValue: widget.email,
                                  autofillHints: const [AutofillHints.email],
                                ),
                              ),
                              const SizedBox(height: AppDimens.spacer18),
                              WidgetWithLabel(
                                label: "パスワード",
                                widget: PasswordTextFieldRound2(
                                  'password', null,
                                  ValidatorConstants.userPassword(_fbKey, ''),
                                  null, null, null, "パスワード",
                                  autofillHints: const [AutofillHints.password],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimens.spacer37),

                        // Inline error
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(
                                color: ColorName.textError,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Login button / loading
                        SizedBox(
                          height: AppDimens.spacer52,
                          child: isLoading
                              ? const CustomCircularProgressIndicator()
                              : SizedBox(
                                  width: double.infinity,
                                  child: ButtonPrimaryRoundCommon(
                                    title: "ログイン",
                                    onPressed: _onLoginPressed,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom links
                _buildBottomLinks(isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomLinks(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.horizontalMargin21,
        vertical: AppDimens.verticalMargin29,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: isLoading ? null : () async {
              TTPFirebaseAnalytics.logEvent(
                eventName: FirebaseEventName.tap_custom_event,
                eventValues: {
                  FirebaseParameterName.function_name.value:
                      "password_forget_button",
                },
              );
              final ok = await _checkAppUpdate();
              if (!ok) return;
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PasswordResetPage(),
                  ),
                );
              }
            },
            child: const Text(
              'パスワードをお忘れの方',
              style: TextStyle(
                fontSize: 16,
                color: ColorName.ttpColorButtonText,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.spacer30),
          SizedBox(
            width: double.infinity,
            child: ButtonPrimaryRound(
              title: "新規登録（初めての方）",
              textColor: RSA.instance.primaryColor,
              borderColor: RSA.instance.primaryColor,
              titleBold: FontWeight.bold,
              onPressed: () async {
                // ... registration logic giữ nguyên
              },
            ),
          ),
          const SizedBox(height: AppDimens.spacer30),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OnBoardingScreen(
                    contents: Tutorial().contents,
                    backgroundImage: Assets.images.bgTutorial.provider(),
                    mainColor: RSA.instance.primaryColor,
                    isRegistered: false,
                  ),
                ),
              );
            },
            child: const Text(
              "このアプリの使い方",
              style: TextStyle(
                fontSize: 16,
                color: ColorName.ttpColorButtonText,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.spacer30),
          InkWell(
            onTap: () => TTPUrl.contact.launchBrowser(),
            child: const Text(
              "お問い合わせ",
              style: TextStyle(
                fontSize: AppDimens.textMedium,
                color: ColorName.ttpColorButtonText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBlacklistDialog(String message) {
    CommonDialog.showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusPrimary),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusPrimary),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.horizontalPrimaryPadding,
                    vertical: 40,
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: ColorName.ttpColorTextPrimary,
                      fontSize: AppDimens.textMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(height: AppDimens.spacer2),
                SizedBox(
                  height: AppDimens.spacer55,
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppDimens.radiusPrimary),
                      bottomRight: Radius.circular(AppDimens.radiusPrimary),
                    ),
                    onTap: () => Navigator.of(context).pop(),
                    child: Center(
                      child: Text(
                        "OK",
                        style: TextStyle(
                          fontSize: AppDimens.textLarge,
                          fontWeight: FontWeight.bold,
                          color: RSA.instance.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================================
// FILE: presentation/pages/sms_auth_page.dart
// ============================================================================

class SmsAuthPage extends ConsumerStatefulWidget {
  const SmsAuthPage({
    super.key,
    required this.email,
    required this.password,
    required this.tel,
  });

  final String email;
  final String password;
  final String tel;

  @override
  ConsumerState<SmsAuthPage> createState() => _SmsAuthPageState();
}

class _SmsAuthPageState extends ConsumerState<SmsAuthPage> {
  String code = '';

  @override
  Widget build(BuildContext context) {
    final smsState = ref.watch(smsAuthViewModelProvider);

    ref.listen(smsAuthViewModelProvider, (prev, next) {
      if (next is SmsAuthSuccess) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    });

    final errorMessage = smsState is SmsAuthError ? smsState.message : null;
    final isLoading = smsState is SmsAuthLoading;

    return RsaScaffoldCustomLeading(
      title: 'SMS認証ログイン',
      backgroundColor: Colors.white,
      showBottomDivider: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => AppUtil.hideKeyboard(context),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.horizontalMargin20,
              ),
              child: Column(
                children: [
                  AuthenticationPlainLabel(
                    title: 'SMSを確認してください',
                    bodyText:
                        'の電話番号にSMS（ショートメッセージ）\nを送信しました。\n記載された認証コードを入力してください。',
                    subTitle: PhoneUtil.getHyphenText(
                      PhoneUtil.convertToInternalNumber(widget.tel),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: AppDimens.verticalMargin20),
                    child: Text(
                      '※SMS認証は安心してお使いいただくために必要です。\n電話番号変更時にお手続きが必要となります。',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: AppDimens.textMedium),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppDimens.verticalMargin50,
                      bottom: AppDimens.verticalMargin30,
                    ),
                    child: AuthenticationField(
                      code: (v) => setState(() => code = v),
                    ),
                  ),

                  if (errorMessage != null) ...[
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        color: ColorName.ttpColorTextRed,
                        fontSize: AppDimens.textMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimens.spacer25),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ButtonPrimaryRoundCommon(
                      title: '認証する',
                      fillColor: code.length == 6
                          ? RSA.instance.primaryColor
                          : Colors.grey,
                      onPressed: code.length == 6 && !isLoading
                          ? () {
                              ref
                                  .read(smsAuthViewModelProvider.notifier)
                                  .verifyAndLogin(
                                    code: code,
                                    tel: widget.tel,
                                    email: widget.email,
                                    password: widget.password,
                                  );
                            }
                          : null,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppDimens.verticalMargin22,
                    ),
                    child: CountdownItem(
                      seconds: 10 * 60,
                      builder: (endCountDown) {
                        return GestureDetector(
                          onTap: endCountDown
                              ? () => Navigator.of(context).pop()
                              : null,
                          child: Text(
                            'コードを再送する',
                            style: TextStyle(
                              fontSize: AppDimens.textMedium,
                              color: endCountDown
                                  ? ColorName.ttpColorButtonText
                                  : ColorName.ttpColorTextInactive,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '※10分間はコードの再送ができません。',
                    style: TextStyle(
                      fontSize: AppDimens.textMedium,
                      color: ColorName.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================================
// FILE: presentation/pages/password_reset_page.dart
// ============================================================================

class PasswordResetPage extends ConsumerStatefulWidget {
  const PasswordResetPage({super.key});

  @override
  ConsumerState<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends ConsumerState<PasswordResetPage> {
  final _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    ref.listen(passwordResetViewModelProvider, (prev, next) {
      switch (next) {
        case PasswordResetSuccess(:final email):
          CommonDialog.showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AfterConfirmationDialogBox(
              title: '$email\nへメールを送信しました。',
              buttonText: "メールを確認する",
              backToListRoute: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          );
        case PasswordResetError(:final message):
          CommonDialog.showDialog(
            context: context,
            builder: (_) => BasicDialogBox(
              message: message,
              buttonText: message == AppStrings.emailNotRegisteredErrorMessage
                  ? "戻る"
                  : "OK",
              onTap: () {},
            ),
          );
        default:
          break;
      }
    });

    final isLoading = ref.watch(passwordResetViewModelProvider)
        is PasswordResetLoading;

    return RsaScaffoldCustomLeading(
      title: 'パスワードの再設定',
      showBottomDivider: true,
      body: GestureDetector(
        onTap: () => AppUtil.hideKeyboard(context),
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      "ご登録済みのメールアドレスに\nパスワードの再設定用URLを送付します。",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Text(
                    "メールアドレス",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 5),
                FormBuilder(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _fbKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.horizontalPrimaryPadding,
                      vertical: 5,
                    ),
                    child: FormBuilderTextField(
                      name: "email",
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(
                          15.0, 5.0, 15.0, 5.0,
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: ColorName.textFieldBorder,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: ColorName.textFieldBorder,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: ColorName.textFieldBorder,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        hintText: "example@mail.com",
                        filled: true,
                        fillColor: Colors.white,
                        hintStyle: const TextStyle(
                          color: ColorName.textFieldFill,
                        ),
                      ),
                      validator: FormBuilderValidators.compose(
                        ValidatorConstants.emailRegistration(_fbKey, ''),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    FlutterClipboard.copy(RSA.instance.adminMailDomain).then(
                      (value) => Fluttertoast.showToast(
                        msg: "${RSA.instance.adminMailDomain}をコピーしました。",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER_RIGHT,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black54,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      ),
                    );
                  },
                  child: Text(
                    "メールが届かない場合は、\n迷惑メールボックス、または \n「@${RSA.instance.adminMailDomain}」からの\n受信を許可されているかご確認ください。",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: ColorName.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.horizontalPrimaryPadding,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: isLoading
                        ? const Center(
                            child: CustomCircularProgressIndicator(),
                          )
                        : ButtonPrimaryRoundCommon(
                            title: "再設定メールを送信",
                            onPressed: () {
                              _fbKey.currentState!.save();
                              if (_fbKey.currentState!.validate()) {
                                AppUtil.hideKeyboard(context);
                                ref
                                    .read(passwordResetViewModelProvider
                                        .notifier)
                                    .sendResetEmail(
                                      email: _fbKey
                                          .currentState!.value['email'],
                                    );
                              }
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================================
// FILE: presentation/pages/update_phone_page.dart
// ============================================================================

class UpdatePhonePage extends ConsumerStatefulWidget {
  const UpdatePhonePage({
    super.key,
    required this.email,
    required this.password,
    required this.oldTel,
  });

  final String email;
  final String password;
  final String oldTel;

  @override
  ConsumerState<UpdatePhonePage> createState() => _UpdatePhonePageState();
}

class _UpdatePhonePageState extends ConsumerState<UpdatePhonePage> {
  final _fbKey = GlobalKey<FormBuilderState>();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmit() {
    AppUtil.hideKeyboard(context);
    TTPFirebaseAnalytics.logEvent(
      eventName: FirebaseEventName.tap_custom_event,
      eventValues: {
        FirebaseParameterName.function_name.value:
            "account_tel_change_button",
      },
    );

    _fbKey.currentState?.save();
    if (!(_fbKey.currentState?.validate() ?? false)) return;

    final data = _fbKey.currentState!.value;
    final intlTel = PhoneUtil.convertToCompleteNumber(
      data['homePhone'].toString(),
    );

    ref.read(updatePhoneViewModelProvider.notifier).validateAndSendCode(
      newTel: intlTel,
      oldTel: widget.oldTel,
    );
  }

  void _onSmsVerified(String tel) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(updatePhoneViewModelProvider.notifier).executeLoginAndUpdate(
        email: widget.email,
        password: widget.password,
        tel: tel,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final phoneState = ref.watch(updatePhoneViewModelProvider);
    final isLoading = phoneState is UpdatePhoneLoading;

    ref.listen(updatePhoneViewModelProvider, (prev, next) {
      switch (next) {
        case UpdatePhoneCodeSent(:final tel):
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => SmsCheckCodeScreen(
                title: '電話番号設定',
                tel: tel,
                description:
                    'の電話番号にSMS（ショートメッセージ）\nを送信しました。\n記載された認証コードを入力してください。',
                descriptionSub:
                    '※SMS認証は安心してお使いいただくために必要です。\n電話番号変更時にお手続きが必要となります。',
                onTapAuthenticationButton: () {},
                onSuccess: () => _onSmsVerified(tel),
              ),
            ),
          );
        case UpdatePhoneSuccess():
          CommonDialog.showDialog(
            context: context,
            builder: (_) => BasicDialogBox(
              message:
                  '電話番号の変更が完了しました。\n\n次回ログイン以降、変更後の電話番号で\nSMS認証を行ってください。',
              onTap: () {},
            ),
            callback: () async {
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                  (route) => false,
                );
              }
            },
          );
        case UpdatePhoneError(:final message):
          CommonDialog.showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => ErrorMessageDialogBox(
              error: message,
              onTap: () {},
            ),
          );
        default:
          break;
      }
    });

    return RsaScaffoldCustomLeading(
      title: '電話番号設定',
      showBottomDivider: true,
      body: GestureDetector(
        onTap: () => AppUtil.hideKeyboard(context),
        child: KeyboardActions(
          disableScroll: true,
          config: KeyboardActionsHelper.buildConfig(context, _focusNode),
          child: SingleChildScrollView(
            child: FormBuilder(
              autovalidateMode: AutovalidateMode.disabled,
              key: _fbKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.horizontalMargin16,
                      AppDimens.verticalMargin20,
                      0,
                      AppDimens.verticalMargin16,
                    ),
                    child: const Text(
                      '新しい電話番号の入力',
                      style: TextStyle(
                        color: Color(0xFF626264),
                        fontSize: AppDimens.textSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.horizontalMargin21,
                      AppDimens.verticalMargin40,
                      AppDimens.horizontalMargin21,
                      AppDimens.verticalMargin38,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '電話番号(携帯)',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FormBuilderTextField(
                          focusNode: _focusNode,
                          enableSuggestions: true,
                          name: 'homePhone',
                          style: userPropertyTextFieldStyle,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          initialValue: "",
                          decoration: userPropertyInputDecoration(
                            hintText: "ハイフンなし",
                            contentPadding: const EdgeInsets.fromLTRB(
                              AppDimens.spacer14,
                              AppDimens.spacer16,
                              AppDimens.spacer14,
                              AppDimens.spacer16,
                            ),
                          ),
                          validator: FormBuilderValidators.compose(
                            ValidatorConstants.mobileNumber(_fbKey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 44),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: isLoading
                        ? const Center(
                            child: CustomCircularProgressIndicator(),
                          )
                        : ButtonPrimaryRoundCommon(
                            title: "変更する",
                            onPressed: _onSubmit,
                          ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================================
// SỬ DỤNG Result<T> — SO SÁNH VỚI fpdart Either
// ============================================================================
//
// ┌────────────────────────────┬──────────────────────────────────────────┐
// │ fpdart Either              │ Result<T> (custom)                       │
// ├────────────────────────────┼──────────────────────────────────────────┤
// │ Either<AuthFailure, User>  │ Result<User>                             │
// │ Right(user)                │ Success(user)                            │
// │ Left(failure)              │ Failure(failure)                         │
// │ result.fold(onL, onR)      │ result.when(success: ..., failure: ...)  │
// │ result.isRight()           │ result.isSuccess                         │
// │ result.getOrElse((_) => x) │ result.getOrElse(x)                      │
// │ result.getRight().toNull() │ result.data (throws nếu Failure)         │
// │ result.getLeft().toNull()  │ result.failure (null nếu Success)        │
// └────────────────────────────┴──────────────────────────────────────────┘
//
// Ưu điểm Result<T>:
// - Không cần thêm dependency fpdart
// - API đơn giản, dễ đọc hơn Left/Right
// - Pattern matching với switch vẫn hoạt động tốt
// - Đủ dùng cho hầu hết use case trong Flutter app
```
