# Token Refresh Race Condition — Deep Dive

## 1. Bối cảnh vấn đề

Trong hệ thống auth hiện đại, bạn có 2 token:

- **Access Token**: ngắn hạn (15 phút–1 giờ), gửi kèm mọi request
- **Refresh Token**: dài hạn (7–30 ngày), dùng để lấy access token mới khi hết hạn

Khi access token hết hạn, server trả **401 Unauthorized**. App phải tự động gọi `/refresh` để lấy token mới rồi retry request gốc — **user không biết gì hết**.

---

## 2. Vấn đề xảy ra khi nào?

Hình dung scenario thực tế: user mở **Home Screen**, app đồng thời fire 4 request:

```
Timeline:
────────────────────────────────────────────────►

t=0ms   GET /profile          ──► 401
t=5ms   GET /notifications    ──► 401
t=10ms  GET /feed             ──► 401
t=15ms  GET /balance          ──► 401
```

Access token vừa expire. Cả 4 request đều nhận 401 **gần như cùng lúc**.

### Nếu KHÔNG có lock mechanism:

```
t=0ms   /profile nhận 401       → gọi POST /refresh (lần 1)
t=5ms   /notifications nhận 401 → gọi POST /refresh (lần 2)
t=10ms  /feed nhận 401          → gọi POST /refresh (lần 3)
t=15ms  /balance nhận 401       → gọi POST /refresh (lần 4)
```

**Hậu quả nghiêm trọng:**

```dart
// Giả sử refresh token có cơ chế rotation (mỗi lần dùng sẽ bị invalidate)
// Đây là best practice bảo mật phổ biến (OAuth 2.0 Refresh Token Rotation)

POST /refresh (lần 1) → ✅ thành công
  // Server invalidate refreshToken cũ, trả về cặp token mới

POST /refresh (lần 2) → ❌ 403 Forbidden
  // refreshToken cũ đã bị invalidate bởi lần 1
  // Server detect reuse → có thể revoke TOÀN BỘ session (security measure)

POST /refresh (lần 3) → ❌ 403
POST /refresh (lần 4) → ❌ 403
```

**Kết quả**: User bị **logout bất ngờ**, mặc dù session hoàn toàn hợp lệ. Hoặc nhẹ hơn (nếu server không rotate refresh token): lãng phí 3 network calls thừa, potential rate limit hit.

---

## 3. Giải pháp: Lock Mechanism với Completer

`Completer` trong Dart hoạt động như một **"promise" mà bạn tự kiểm soát khi nào resolve**. Nó là công cụ lý tưởng để implement lock pattern.

### Cách Completer hoạt động:

```dart
// Completer = một Future mà bạn complete thủ công
final completer = Completer<String>();

// Ai đó await nó → sẽ đợi cho đến khi complete
final result = await completer.future; // đang chờ...

// Ở chỗ khác, bạn complete nó
completer.complete('done'); // → tất cả awaiter đều nhận 'done'
```

### Full Implementation với giải thích từng bước:

```dart
class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  
  // Đây chính là "lock" — null nghĩa là không ai đang refresh
  Completer<String>? _refreshCompleter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    try {
      final newToken = await _getOrRefreshToken();
      
      // Retry request gốc với token mới
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      final response = await _dio.fetch(opts);
      handler.resolve(response);
    } catch (e) {
      handler.reject(err);
    }
  }

  Future<String> _getOrRefreshToken() async {
    // ========== BƯỚC KIỂM TRA LOCK ==========
    // Nếu đã có ai đang refresh → ĐỪNG refresh nữa, chờ kết quả
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future; // chờ chung kết quả
    }

    // ========== BƯỚC TẠO LOCK ==========
    // Mình là người đầu tiên → tạo lock, bắt đầu refresh
    _refreshCompleter = Completer<String>();

    try {
      // ========== BƯỚC REFRESH ==========
      // Chỉ DUY NHẤT request này thực sự gọi /refresh
      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': _tokenStorage.refreshToken,
      });

      final newAccessToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];
      
      _tokenStorage.saveTokens(
        access: newAccessToken,
        refresh: newRefreshToken,
      );

      // ========== BƯỚC BROADCAST ==========
      // Complete → TẤT CẢ request đang chờ đều nhận token mới
      _refreshCompleter!.complete(newAccessToken);
      return newAccessToken;
      
    } catch (e) {
      // Nếu refresh fail → tất cả request đang chờ đều nhận error
      _refreshCompleter!.completeError(e);
      _tokenStorage.clear();
      // Navigate to login...
      rethrow;
    } finally {
      // ========== BƯỚC GIẢI LOCK ==========
      // Reset lock → lần 401 tiếp theo sẽ trigger refresh mới
      _refreshCompleter = null;
    }
  }
}
```

### Minh hoạ flow khi có lock:

```
Timeline (4 requests cùng nhận 401):

Request A (đầu tiên):
  → Kiểm tra _refreshCompleter → null (chưa ai refresh)
  → Tạo Completer (lock)
  → Gọi POST /refresh
  → Đang chờ server...

Request B (đến trong lúc A đang refresh):
  → Kiểm tra _refreshCompleter → KHÔNG null (có ai đang refresh)
  → await _refreshCompleter.future  ← ĐỨNG ĐÂY CHỜ

Request C: → tương tự B, đứng chờ
Request D: → tương tự B, đứng chờ

Server trả về token mới cho Request A:
  → _refreshCompleter.complete(newToken)
  → Request B nhận newToken → retry với token mới
  → Request C nhận newToken → retry với token mới  
  → Request D nhận newToken → retry với token mới
  → _refreshCompleter = null (giải lock)

Kết quả: CHỈ 1 lần gọi /refresh, tất cả 4 requests đều retry thành công
```

---

## 4. Tại sao dùng QueuedInterceptor thay vì Interceptor?

Đây là chi tiết quan trọng mà nhiều dev bỏ qua:

```dart
// Dio có 2 loại interceptor:

// Interceptor (thường) — xử lý song song
// Nhiều request lỗi 401 sẽ chạy onError ĐỒNG THỜI
class AuthInterceptor extends Interceptor { }

// QueuedInterceptor — xử lý tuần tự
// Request tiếp theo chỉ vào onError SAU KHI request trước xử lý xong
class AuthInterceptor extends QueuedInterceptor { }
```

Với `QueuedInterceptor`, Dio tự động serialize các error handling. Tuy nhiên, **Completer pattern vẫn cần thiết** vì:

- Trong thực tế, race condition vẫn xảy ra ở edge cases (multiple Dio instances, platform channels)
- `QueuedInterceptor` chỉ queue interceptor execution — nếu bạn không cache kết quả refresh, nó vẫn gọi `/refresh` nhiều lần tuần tự
- Defense in depth: hai lớp bảo vệ tốt hơn một lớp

```dart
// Kể cả với QueuedInterceptor, nếu không có Completer:
// Request A: onError → refresh → OK → retry ✅
// Request B: onError → refresh LẦN 2 → có thể fail nếu token rotation ❌

// Với Completer + QueuedInterceptor:
// Request A: onError → refresh → complete → retry ✅
// Request B: onError → thấy completer đã complete → dùng token đã cache → retry ✅
```

---

## 5. Edge Cases cần xử lý thêm

**a) Token hết hạn ngay sau refresh (server clock skew):**

```dart
@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  if (err.response?.statusCode != 401) return handler.next(err);

  // Tránh infinite retry loop
  final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
  if (retryCount >= 1) {
    // Đã retry 1 lần mà vẫn 401 → token mới cũng invalid → logout
    _forceLogout();
    return handler.reject(err);
  }

  try {
    final newToken = await _getOrRefreshToken();
    final opts = err.requestOptions
      ..headers['Authorization'] = 'Bearer $newToken'
      ..extra['retryCount'] = retryCount + 1;
    final response = await _dio.fetch(opts);
    handler.resolve(response);
  } catch (e) {
    handler.reject(err);
  }
}
```

**b) Refresh token cũng hết hạn:**

```dart
} catch (e) {
  if (e is DioException && e.response?.statusCode == 403) {
    // Refresh token expired → phải re-authenticate
    _tokenStorage.clear();
    _navigationService.navigateToLogin();
  }
  _refreshCompleter!.completeError(e);
  rethrow;
}
```

**c) Kiểm tra token expiry TRƯỚC KHI gửi request** (proactive refresh):

```dart
@override
void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
  final token = _tokenStorage.accessToken;
  final expiry = _tokenStorage.accessTokenExpiry;

  if (expiry != null && expiry.isBefore(DateTime.now().add(Duration(seconds: 30)))) {
    // Token sắp hết hạn trong 30s → refresh proactively
    try {
      final newToken = await _getOrRefreshToken();
      options.headers['Authorization'] = 'Bearer $newToken';
    } catch (_) {
      // Nếu refresh fail, vẫn gửi token cũ → server sẽ 401 → retry flow
    }
  } else if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }

  handler.next(options);
}
```

---

## 6. Tóm tắt bằng sơ đồ logic

```
Request nhận 401
       │
       ▼
  _refreshCompleter != null ?
       │
   ┌───┴────┐
   │ YES    │ NO
   ▼        ▼
 await    Tạo Completer
 .future  Gọi /refresh
   │        │
   │    ┌───┴───┐
   │  Thành    Thất
   │  công     bại
   │    │        │
   │    ▼        ▼
   │ .complete  .completeError
   │ (token)    (error)
   │    │        │
   │    ▼        ▼
   │  Reset    Reset
   │  lock     lock + logout
   │    │
   ▼    ▼
 Retry request với token mới
```

Bản chất pattern này là **"first caller does the work, everyone else waits for the result"** — một dạng **coalescing** rất phổ biến trong system design, tương tự singleflight pattern trong Go hay request deduplication trong caching layer.
