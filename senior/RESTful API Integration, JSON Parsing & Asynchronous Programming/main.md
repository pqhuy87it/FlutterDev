# RESTful API Integration, JSON Parsing & Asynchronous Programming trong Flutter

Đây là 3 trụ cột cốt lõi khi Flutter app giao tiếp với backend. Ở level senior, bạn không chỉ "biết dùng" mà cần hiểu sâu về kiến trúc, edge cases, và cách thiết kế scalable.

---

## 1. RESTful API Integration

### Nền tảng lý thuyết

REST (Representational State Transfer) là kiến trúc dựa trên HTTP methods: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`. Senior cần hiểu rõ semantic của từng method, không phải chỉ dùng `POST` cho mọi thứ.

### Trong Flutter, có nhiều tầng cần nắm:

**a) HTTP Client layer**

`http` package đơn giản nhưng thiếu nhiều thứ. Senior thường dùng `dio` vì hỗ trợ interceptors, cancel tokens, form data, retry logic. Quan trọng hơn là bạn phải hiểu *tại sao* chọn cái nào.

```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com/v1',
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 15),
  headers: {'Content-Type': 'application/json'},
));
```

**b) Interceptors — đây là chỗ senior khác biệt junior**

```dart
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    // Gắn access token
    final token = authStore.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  },
  onError: (error, handler) async {
    if (error.response?.statusCode == 401) {
      // Token hết hạn → refresh token → retry request
      try {
        await authStore.refreshToken();
        final retryResponse = await dio.fetch(error.requestOptions);
        handler.resolve(retryResponse);
      } catch (e) {
        authStore.logout();
        handler.reject(error);
      }
    } else {
      handler.next(error);
    }
  },
));
```

Senior cần handle: token refresh race condition (nhiều request cùng lúc nhận 401), queue lại requests trong lúc refresh, retry logic với exponential backoff.

**c) API layer architecture**

Senior thiết kế theo lớp rõ ràng:

```
Data Source (Remote) → Repository → UseCase/BLoC → UI
```

```dart
// Abstract để dễ mock test
abstract class UserRemoteDataSource {
  Future<UserModel> getUser(String id);
  Future<void> updateUser(String id, UpdateUserRequest request);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio _dio;
  
  UserRemoteDataSourceImpl(this._dio);

  @override
  Future<UserModel> getUser(String id) async {
    final response = await _dio.get('/users/$id');
    return UserModel.fromJson(response.data);
  }
}
```

**d) Error handling tinh tế**

Senior không chỉ catch `DioException` mà phân loại rõ:

```dart
sealed class ApiFailure {
  const ApiFailure();
}

class NetworkFailure extends ApiFailure {} // Mất mạng
class ServerFailure extends ApiFailure {   // 5xx
  final int statusCode;
  final String? message;
  const ServerFailure(this.statusCode, this.message);
}
class UnauthorizedFailure extends ApiFailure {} // 401
class ValidationFailure extends ApiFailure {    // 422
  final Map<String, List<String>> fieldErrors;
  const ValidationFailure(this.fieldErrors);
}
class TimeoutFailure extends ApiFailure {} // Request timeout
```

Kết hợp với `Either` (từ `fpdart` hoặc `dartz`):

```dart
Future<Either<ApiFailure, User>> getUser(String id) async {
  try {
    final model = await remoteDataSource.getUser(id);
    return Right(model.toEntity());
  } on DioException catch (e) {
    return Left(_mapDioError(e));
  }
}
```

---

## 2. JSON Parsing

### Vấn đề thực tế

JSON parsing trong Dart không có reflection (vì tree shaking), nên không dùng được kiểu `Gson` hay `Jackson` như native. Đây là chỗ nhiều dev làm sai.

**a) Manual parsing — hiểu bản chất**

```dart
class UserModel {
  final String id;
  final String name;
  final String? email; // nullable field
  final DateTime createdAt;
  final List<AddressModel> addresses;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    required this.createdAt,
    required this.addresses,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'created_at': createdAt.toIso8601String(),
    'addresses': addresses.map((e) => e.toJson()).toList(),
  };
}
```

**b) Code generation — `json_serializable` + `freezed`**

Senior dùng code generation cho productivity, nhưng hiểu rõ output:

```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    String? email,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default([]) List<AddressModel> addresses,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

**c) Defensive parsing — điểm mấu chốt của senior**

API backend có thể trả về data bất ngờ. Senior luôn phòng thủ:

```dart
// Backend đôi khi trả "id" là int, đôi khi là String
id: json['id'].toString(),

// Field có thể là object hoặc null hoặc absent
email: json['email'] as String? ?? '',

// Nested object có thể null
address: json['address'] != null 
    ? AddressModel.fromJson(json['address']) 
    : null,
```

**d) Isolate cho JSON nặng**

Khi parse JSON lớn (vài MB), nó block UI thread. Senior biết dùng `compute`:

```dart
// Parse JSON trên isolate riêng
final users = await compute(_parseUsers, responseBody);

List<UserModel> _parseUsers(String body) {
  final List<dynamic> jsonList = jsonDecode(body);
  return jsonList.map((e) => UserModel.fromJson(e)).toList();
}
```

`dio` cũng có option `transformer` để tự decode trên background isolate.

---

## 3. Asynchronous Programming

Đây là phần **phức tạp nhất** và phân biệt senior rõ nhất.

**a) Future — hiểu execution model**

Dart là single-threaded với event loop. `Future` không phải multi-thread, nó chỉ schedule work trên event queue.

```dart
// Đây KHÔNG chạy song song — chạy tuần tự
final user = await getUser();
final posts = await getPosts();

// Đây MỚI chạy song song
final results = await Future.wait([getUser(), getPosts()]);
```

Senior hiểu khi nào dùng `Future.wait` vs tuần tự, và handle partial failure:

```dart
final results = await Future.wait(
  [getUser(), getPosts(), getNotifications()],
  eagerError: false, // Không fail ngay khi 1 cái lỗi
);
```

**b) Stream — reactive data flow**

```dart
// WebSocket, SSE, real-time data
Stream<ChatMessage> watchMessages(String roomId) {
  return _webSocket.stream
      .where((event) => event.roomId == roomId)
      .map((event) => ChatMessage.fromJson(event.data))
      .handleError((error) {
        logger.error('Stream error', error);
      });
}
```

Senior phân biệt rõ: single-subscription vs broadcast stream, khi nào dùng `StreamController`, và quan trọng nhất — **luôn cancel subscription** để tránh memory leak:

```dart
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  StreamSubscription? _messagesSub;

  void _onStartListening(/*...*/) {
    _messagesSub?.cancel(); // Cancel cái cũ trước
    _messagesSub = repo.watchMessages(roomId).listen(
      (msg) => add(NewMessageReceived(msg)),
      onError: (e) => add(MessageError(e)),
    );
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel(); // Cleanup
    return super.close();
  }
}
```

**c) Cancellation — thứ junior hay bỏ qua**

```dart
// User rời khỏi màn hình → cancel request đang pending
final cancelToken = CancelToken();

Future<void> loadData() async {
  try {
    final data = await dio.get('/heavy-data', cancelToken: cancelToken);
  } on DioException catch (e) {
    if (e.type == DioExceptionType.cancel) return; // Bỏ qua
    rethrow;
  }
}

@override
void dispose() {
  cancelToken.cancel('Widget disposed');
  super.dispose();
}
```

**d) Debounce, Throttle, và Retry**

```dart
// Search với debounce
final _searchSubject = StreamController<String>();

_searchSubject.stream
    .debounceTime(Duration(milliseconds: 300))
    .distinct() // Bỏ qua nếu query không đổi
    .switchMap((query) => Stream.fromFuture(searchApi(query)))
    .listen((results) => emit(SearchLoaded(results)));
```

**e) Concurrency control**

Senior biết giới hạn concurrent requests để không overwhelm server:

```dart
// Pool pattern: tối đa 3 request song song
Future<List<Result>> fetchAll(List<String> ids) async {
  final results = <Result>[];
  for (var chunk in ids.chunked(3)) {
    final batch = await Future.wait(
      chunk.map((id) => fetchOne(id)),
    );
    results.addAll(batch);
  }
  return results;
}
```

---

## Tổng kết — Mindset của Senior

Ở level senior, 3 mảng này không tách rời mà **đan xen chặt chẽ**: API call (REST) trả về JSON, được parse thành model, toàn bộ quá trình chạy asynchronous và cần handle error, cancellation, retry ở mọi tầng.

Senior tư duy theo hướng: nếu mạng chậm thì sao? Nếu API thay đổi format thì sao? Nếu user thoát app giữa chừng thì sao? Nếu 50 request cùng lúc thì sao? Nếu JSON 10MB thì sao? — Tất cả câu hỏi đó dẫn đến kiến trúc robust mà junior chưa nghĩ tới.
