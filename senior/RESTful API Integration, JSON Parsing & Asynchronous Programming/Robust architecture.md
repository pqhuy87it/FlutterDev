# Kiến trúc Robust trong Flutter — Giải thích chi tiết

"Robust" nghĩa là **chịu được mọi điều kiện bất thường mà vẫn hoạt động đúng hoặc fail một cách có kiểm soát**. Không phải chỉ chạy đúng khi mọi thứ thuận lợi, mà chạy đúng khi mọi thứ đi sai.

---

## 1. Robust nghĩa là gì cụ thể?

Hãy so sánh 2 cách tiếp cận:

**App không robust (fragile):**
- Mất mạng → crash hoặc trắng màn hình
- API trả JSON thiếu field → crash
- User bấm nút 10 lần liên tục → gửi 10 request trùng
- Token hết hạn → mọi thứ dừng, user phải login lại manual
- Parse JSON 5MB → UI đứng 3 giây

**App robust:**
- Mất mạng → hiện cached data + thông báo offline + tự retry khi có mạng
- API trả JSON thiếu field → dùng default value, log warning, app vẫn chạy
- User bấm nút 10 lần → debounce, chỉ gửi 1 request
- Token hết hạn → tự refresh, queue request lại, user không biết gì
- Parse JSON 5MB → chạy trên isolate, UI vẫn mượt 60fps

Cùng một feature, cùng một logic, nhưng kiến trúc robust **lường trước và xử lý mọi edge case**.

---

## 2. Các trụ cột của kiến trúc Robust

### 2.1. Separation of Concerns — Tách trách nhiệm rõ ràng

Đây là nền tảng. Nếu code dồn hết vào 1 chỗ, bạn không thể xử lý edge case ở đúng tầng.

```
┌─────────────────────────────────────────────┐
│  UI Layer (Widget)                          │
│  → Chỉ render, không biết API là gì        │
├─────────────────────────────────────────────┤
│  State Management (BLoC / Riverpod)         │
│  → Điều phối logic, handle loading/error    │
├─────────────────────────────────────────────┤
│  Domain Layer (UseCase / Entity)            │
│  → Business rules, không phụ thuộc Flutter  │
├─────────────────────────────────────────────┤
│  Data Layer (Repository)                    │
│  → Quyết định lấy từ cache hay remote      │
├─────────────────────────────────────────────┤
│  Data Source (Remote / Local)               │
│  → Gọi API, đọc DB, parse JSON             │
└─────────────────────────────────────────────┘
```

Tại sao điều này tạo ra robustness?

```dart
class UserRepository {
  final UserRemoteDataSource _remote;
  final UserLocalDataSource _local;
  final NetworkChecker _network;

  Future<Either<Failure, User>> getUser(String id) async {
    // Tầng Repository quyết định: có mạng → gọi API, không → lấy cache
    if (await _network.isConnected) {
      try {
        final model = await _remote.getUser(id);
        await _local.cacheUser(model); // Cache lại
        return Right(model.toEntity());
      } on DioException catch (e) {
        // API lỗi → fallback cache
        final cached = await _local.getUser(id);
        if (cached != null) return Right(cached.toEntity());
        return Left(_mapError(e));
      }
    } else {
      // Offline → dùng cache
      final cached = await _local.getUser(id);
      if (cached != null) return Right(cached.toEntity());
      return Left(NetworkFailure());
    }
  }
}
```

Nếu bạn nhét logic này vào Widget hay BLoC, nó sẽ lộn xộn và không reuse được. Tách ra thì **mỗi tầng chỉ lo 1 việc**, và robustness được xây dựng ở đúng chỗ.

---

### 2.2. Fail Gracefully — Lỗi có kiểm soát

Nguyên tắc: **app không bao giờ crash trước mặt user**. Mọi lỗi đều được catch và chuyển thành trạng thái UI có ý nghĩa.

```dart
// FRAGILE — crash nếu bất kỳ thứ gì sai
class UserBloc {
  Future<void> loadUser() async {
    final response = await dio.get('/user/123'); // Crash nếu mất mạng
    final user = UserModel.fromJson(response.data); // Crash nếu JSON sai
    emit(UserLoaded(user)); // Không có loading, không có error state
  }
}
```

```dart
// ROBUST — mọi failure đều được handle
sealed class UserState {}
class UserInitial extends UserState {}
class UserLoading extends UserState {}
class UserLoaded extends UserState {
  final User user;
  UserLoaded(this.user);
}
class UserError extends UserState {
  final String message;
  final bool canRetry;
  final VoidCallback? onRetry;
  UserError(this.message, {this.canRetry = true, this.onRetry});
}
class UserOffline extends UserState {
  final User? cachedUser; // Vẫn có data cũ để hiển thị
  UserOffline(this.cachedUser);
}
```

UI tương ứng:

```dart
BlocBuilder<UserBloc, UserState>(
  builder: (context, state) => switch (state) {
    UserInitial()  => SizedBox.shrink(),
    UserLoading()  => ShimmerPlaceholder(), // Skeleton loading, không phải spinner
    UserLoaded(user: final u) => UserProfile(u),
    UserOffline(cachedUser: final u?) => Column(
      children: [
        OfflineBanner(),       // "Bạn đang offline"
        UserProfile(u),        // Vẫn hiện data cũ
      ],
    ),
    UserOffline() => NoDataOffline(),
    UserError(:final message, :final onRetry) => ErrorView(
      message: message,
      onRetry: onRetry,
    ),
  },
)
```

Điểm mấu chốt: **user luôn thấy một trạng thái có ý nghĩa**, không bao giờ trắng màn hình hay crash.

---

### 2.3. Defensive Programming — Không tin bất kỳ ai

Senior không tin backend, không tin network, không tin user input, không tin cả chính mình.

**Không tin Backend:**

```dart
factory ProductModel.fromJson(Map<String, dynamic> json) {
  return ProductModel(
    // Backend có thể trả id là int hoặc String
    id: json['id']?.toString() ?? '',
    
    // Giá có thể là int, double, hoặc String "19.99"
    price: _parsePrice(json['price']),
    
    // List có thể null, có thể chứa null items
    tags: (json['tags'] as List<dynamic>?)
        ?.whereType<String>() // Bỏ qua non-String items
        .toList() ?? [],
        
    // Field mới backend thêm → app cũ không crash
    // Field cũ backend xóa → có default value
    status: _parseStatus(json['status']),
  );
}

static double _parsePrice(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

static ProductStatus _parseStatus(dynamic value) {
  if (value is String) {
    return ProductStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProductStatus.unknown, // Enum mới backend thêm → không crash
    );
  }
  return ProductStatus.unknown;
}
```

**Không tin Network:**

```dart
class RobustApiClient {
  Future<Response> requestWithRetry(
    String path, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    var delay = initialDelay;
    
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await dio.get(path);
      } on DioException catch (e) {
        final isLastAttempt = attempt == maxRetries;
        final isRetryable = _isRetryable(e); // Chỉ retry 5xx, timeout
        
        if (isLastAttempt || !isRetryable) rethrow;
        
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff: 1s → 2s → 4s
      }
    }
    throw StateError('Unreachable');
  }

  bool _isRetryable(DioException e) {
    // 4xx → lỗi client, retry vô nghĩa
    // 5xx → lỗi server, có thể tạm thời
    // Timeout → mạng chậm, thử lại
    return e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.receiveTimeout ||
           (e.response?.statusCode ?? 0) >= 500;
  }
}
```

**Không tin User:**

```dart
class SearchBloc {
  CancelToken? _currentSearch;

  Future<void> search(String query) async {
    // User gõ liên tục → cancel request cũ
    _currentSearch?.cancel();
    _currentSearch = CancelToken();
    
    // User gửi query rỗng hoặc toàn whitespace
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(SearchInitial());
      return;
    }
    
    // User gửi query quá dài → cắt
    final safeQuery = trimmed.substring(0, min(trimmed.length, 200));
    
    emit(SearchLoading());
    
    try {
      final results = await repo.search(
        safeQuery, 
        cancelToken: _currentSearch,
      );
      emit(SearchLoaded(results));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return; // Đã cancel, bỏ qua
      emit(SearchError('Tìm kiếm thất bại'));
    }
  }
}
```

---

### 2.4. Resource Management — Không leak bất cứ thứ gì

Memory leak là kẻ giết app thầm lặng. Robust architecture đảm bảo mọi resource được cleanup:

```dart
class ChatScreen extends StatefulWidget { /*...*/ }

class _ChatScreenState extends State<ChatScreen> {
  late final StreamSubscription _messageSub;
  late final StreamSubscription _typingSub;
  late final Timer _heartbeat;
  final _scrollController = ScrollController();
  final _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _messageSub = chatRepo.messages(roomId).listen(_onMessage);
    _typingSub = chatRepo.typingStatus(roomId).listen(_onTyping);
    _heartbeat = Timer.periodic(
      Duration(seconds: 30), 
      (_) => chatRepo.sendHeartbeat(roomId),
    );
  }

  @override
  void dispose() {
    // Cleanup EVERYTHING — bỏ sót 1 cái = memory leak
    _messageSub.cancel();
    _typingSub.cancel();
    _heartbeat.cancel();
    _scrollController.dispose();
    _cancelToken.cancel('Screen disposed');
    super.dispose();
  }
}
```

Senior thường tạo pattern tự động để tránh quên:

```dart
mixin AutoDisposeMixin<T extends StatefulWidget> on State<T> {
  final _subscriptions = <StreamSubscription>[];
  final _controllers = <ChangeNotifier>[];

  void autoDispose(StreamSubscription sub) => _subscriptions.add(sub);
  void autoDisposeController(ChangeNotifier c) => _controllers.add(c);

  @override
  void dispose() {
    for (final sub in _subscriptions) sub.cancel();
    for (final c in _controllers) c.dispose();
    super.dispose();
  }
}
```

---

### 2.5. Testability — Robust code phải test được

Nếu không test được, bạn không biết nó có robust hay không:

```dart
// Dễ test vì mọi dependency đều inject được
test('should return cached user when API fails', () async {
  // Arrange
  when(mockNetwork.isConnected).thenAnswer((_) async => true);
  when(mockRemote.getUser('1')).thenThrow(
    DioException(type: DioExceptionType.connectionTimeout, /*...*/),
  );
  when(mockLocal.getUser('1')).thenAnswer(
    (_) async => cachedUserModel,
  );

  // Act
  final result = await repository.getUser('1');

  // Assert
  expect(result, Right(expectedUser));
  verify(mockLocal.getUser('1')).called(1); // Đã fallback sang cache
});

test('should cancel previous search when new query arrives', () async {
  // Test cancellation logic
  bloc.search('flutter');
  await Future.delayed(Duration(milliseconds: 50));
  bloc.search('flutter dev'); // Cancel cái trước

  // Chỉ có kết quả của "flutter dev"
  expect(bloc.state, isA<SearchLoaded>());
});
```

---

## 3. Tổng kết bằng 1 mental model

Hãy tưởng tượng app là một **tòa nhà**:

| Yếu tố | Fragile | Robust |
|---|---|---|
| Mất điện (mất mạng) | Cả tòa nhà tối đen | Máy phát điện tự bật (cache) |
| Động đất (API thay đổi) | Sập tòa nhà | Khung chịu lực uốn cong nhưng không gãy (defensive parsing) |
| Cháy tầng 3 (1 feature lỗi) | Lửa lan toàn bộ | Cửa chống cháy ngăn lại (error boundary, isolated layers) |
| Quá tải thang máy (quá nhiều request) | Thang máy hỏng | Hệ thống xếp hàng, giới hạn tải (debounce, throttle, queue) |
| Người dùng rời đi (dispose) | Đèn quạt vẫn chạy, tốn điện | Tự tắt hết khi không ai ở (cleanup resources) |

Robust architecture không phải viết nhiều code hơn — mà là viết code **đúng chỗ**, **lường trước failure**, và **fail một cách có kiểm soát** thay vì crash không kiểm soát.
