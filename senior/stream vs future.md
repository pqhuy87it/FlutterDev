# Streams vs. Futures — Xử lý Bất đồng bộ trong Flutter

## 1. Bản chất cốt lõi

Cách đơn giản nhất để hiểu: **Future là 1 giá trị trong tương lai, Stream là nhiều giá trị theo thời gian**.

```
Future<User>         →  Hỏi 1 câu, nhận 1 câu trả lời
                        "Cho tôi thông tin user" → User

Stream<ChatMessage>  →  Mở kênh, nhận liên tục
                        "Lắng nghe tin nhắn" → msg1 → msg2 → msg3 → ...
```

Tương tự trong đời thực:

```
Future  =  Gọi điện hỏi "Bây giờ mấy độ?" → nhận 1 câu trả lời → xong
Stream  =  Bật app thời tiết → nó cập nhật liên tục mỗi 10 phút → chạy mãi
```

---

## 2. Future — Chi tiết

### Lifecycle của 1 Future

```
Created → Pending → Completed (value) 
                  → Completed (error)
```

Chỉ có **1 kết quả duy nhất**, sau khi complete thì Future đó kết thúc vĩnh viễn.

### Các pattern quan trọng

**a) Tuần tự vs Song song**

```dart
// TUẦN TỰ — tổng 5 giây (2s + 3s)
final user = await getUser();       // 2s
final posts = await getPosts();     // 3s

// SONG SONG — tổng 3 giây (max của 2 cái)
final (user, posts) = await (getUser(), getPosts()).wait;
```

**b) Timeout — không đợi vô hạn**

```dart
try {
  final user = await getUser().timeout(
    Duration(seconds: 5),
    onTimeout: () => throw TimeoutException('getUser quá chậm'),
  );
} on TimeoutException {
  // Handle: hiện cached data hoặc thông báo lỗi
}
```

**c) Chuyển đổi kết quả**

```dart
// .then — chain tiếp
final name = await getUser().then((user) => user.name);

// .whenComplete — luôn chạy dù success hay error (giống finally)
await getUser()
    .then((user) => saveToCache(user))
    .whenComplete(() => hideLoading());

// .catchError — bắt lỗi inline
final user = await getUser().catchError(
  (e) => fallbackUser,
  test: (e) => e is SocketException, // Chỉ catch lỗi mạng
);
```

**d) Future.delayed — hẹn giờ**

```dart
// Đợi 2 giây rồi mới chạy
final result = await Future.delayed(
  Duration(seconds: 2),
  () => 'Hello sau 2 giây',
);
```

**e) Future.value / Future.error — tạo Future đã hoàn thành**

```dart
// Dùng khi cần trả Future nhưng đã có data sẵn (ví dụ: cache hit)
Future<User> getUser(String id) {
  final cached = _cache[id];
  if (cached != null) return Future.value(cached); // Không cần async
  return _remote.fetchUser(id);
}
```

---

## 3. Stream — Chi tiết

### Lifecycle của 1 Stream

```
Created → Listening → data → data → data → ... → Done
                    → error (có thể tiếp tục hoặc dừng)
                    → Done (stream đóng)
```

Stream emit **nhiều event** theo thời gian: data events, error events, và done event.

### 2 loại Stream

```dart
// SINGLE-SUBSCRIPTION — chỉ 1 người nghe
// Ví dụ: đọc file, HTTP response body
final stream = File('data.txt').openRead();
stream.listen(print);       // OK
stream.listen(print);       // ❌ ERROR — đã có người nghe rồi

// BROADCAST — nhiều người nghe
// Ví dụ: WebSocket, event bus, UI events
final controller = StreamController<int>.broadcast();
controller.stream.listen(print);  // Listener 1 ✅
controller.stream.listen(print);  // Listener 2 ✅

// Chuyển single → broadcast
final broadcast = singleStream.asBroadcastStream();
```

### Tạo Stream

**a) StreamController — cách phổ biến nhất**

```dart
class LocationService {
  final _controller = StreamController<LatLng>.broadcast();
  Timer? _timer;

  Stream<LatLng> get locationStream => _controller.stream;

  void startTracking() {
    _timer = Timer.periodic(Duration(seconds: 5), (_) async {
      final position = await _getGPSPosition();
      _controller.add(LatLng(position.lat, position.lng)); // Emit data
    });
  }

  void reportError(Object error) {
    _controller.addError(error); // Emit error
  }

  void dispose() {
    _timer?.cancel();
    _controller.close(); // Emit done, đóng stream
  }
}
```

**b) async\* generator — khi logic tuần tự**

```dart
Stream<int> countDown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(Duration(seconds: 1));
    yield i; // Emit từng giá trị
  }
  // Stream tự done khi hết vòng lặp
}

// Delegate sang stream khác
Stream<int> countDownWithBonus(int from) async* {
  yield* countDown(from);    // yield* = forward toàn bộ stream con
  yield -1;                  // Bonus value sau khi stream con xong
}
```

**c) Stream.fromFuture / Stream.periodic**

```dart
// Chuyển Future → Stream (1 event rồi done)
final stream = Stream.fromFuture(getUser());

// Emit định kỳ
final ticker = Stream.periodic(
  Duration(seconds: 1),
  (count) => count, // 0, 1, 2, 3, ...
);
```

### Lắng nghe Stream

**a) listen — cách cơ bản**

```dart
final subscription = stream.listen(
  (data) => print('Data: $data'),       // onData
  onError: (error) => print('Error: $error'), // onError
  onDone: () => print('Stream closed'),       // onDone
  cancelOnError: false, // true = tự cancel khi gặp error
);

// Pause / Resume
subscription.pause();
subscription.resume();

// QUAN TRỌNG: phải cancel khi không cần nữa
subscription.cancel();
```

**b) await for — đọc tuần tự**

```dart
Future<void> processMessages() async {
  await for (final message in messageStream) {
    // Xử lý từng message một, đợi xong mới lấy cái tiếp
    await saveToDatabase(message);
    updateUI(message);
  }
  // Chạy đến đây khi stream done
  print('Đã xử lý hết');
}
```

### Stream Transformations — sức mạnh thực sự

```dart
final rawSearchStream = searchController.stream;

final results = rawSearchStream
    .distinct()                              // Bỏ query trùng liên tiếp
    .debounceTime(Duration(milliseconds: 300)) // Đợi user ngừng gõ
    .where((query) => query.length >= 2)     // Bỏ query quá ngắn
    .switchMap((query) =>                    // Cancel search cũ, chạy search mới
        Stream.fromFuture(searchApi(query))
            .startWith(SearchState.loading)  // Emit loading trước
    )
    .onErrorResume((error, _) =>             // Lỗi → emit error state, không kill stream
        Stream.value(SearchState.error(error))
    );
```

Giải thích flow:

```
User gõ: "f" → "fl" → "flu" → "flutter"
                                   │
distinct():         bỏ nếu trùng cái trước
                                   │
debounce(300ms):    đợi 300ms không gõ thêm
                                   │  
where(len >= 2):   "f" bị loại, "flutter" OK
                                   │
switchMap():        cancel search "fl" nếu đang chạy
                    bắt đầu search "flutter"
                                   │
                    emit Loading → emit Results
```

---

## 4. So sánh trực tiếp

### Cùng 1 feature — 2 cách implement

**Lấy danh sách sản phẩm 1 lần:**

```dart
// Future — gọi 1 lần, nhận 1 lần
class ProductRepo {
  Future<List<Product>> getProducts() async {
    final response = await dio.get('/products');
    return (response.data as List)
        .map((e) => Product.fromJson(e))
        .toList();
  }
}

// Sử dụng
final products = await repo.getProducts();
emit(ProductsLoaded(products));
```

**Lắng nghe sản phẩm thay đổi real-time:**

```dart
// Stream — nhận liên tục khi data thay đổi
class ProductRepo {
  Stream<List<Product>> watchProducts() {
    return firestore
        .collection('products')
        .snapshots()                    // Firestore trả Stream
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromJson(doc.data()))
            .toList());
  }
}

// Sử dụng
_subscription = repo.watchProducts().listen(
  (products) => emit(ProductsLoaded(products)),
);
```

### Cùng 1 feature — kết hợp cả 2

```dart
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  StreamSubscription? _messagesSub;

  Future<void> _onOpenChat(OpenChat event, Emitter emit) async {
    // Future: lấy lịch sử chat 1 lần
    final history = await chatRepo.getChatHistory(event.roomId);
    emit(ChatLoaded(messages: history));

    // Stream: lắng nghe tin nhắn mới real-time
    _messagesSub?.cancel();
    _messagesSub = chatRepo.watchNewMessages(event.roomId).listen(
      (newMsg) => add(NewMessageArrived(newMsg)),
      onError: (e) => add(ChatError(e)),
    );
  }

  Future<void> _onSendMessage(SendMessage event, Emitter emit) async {
    // Future: gửi tin nhắn 1 lần
    await chatRepo.sendMessage(event.roomId, event.text);
    // Không cần update UI ở đây
    // → Stream ở trên sẽ tự nhận tin nhắn mới và update
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    return super.close();
  }
}
```

---

## 5. Memory Leak — Vấn đề lớn nhất với Stream

Đây là chỗ **senior khác biệt junior** rõ nhất:

```dart
// ❌ LEAK — StreamSubscription không bao giờ cancel
class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    stream.listen((data) => setState(() => _data = data));
    // Widget bị dispose → listener vẫn chạy → giữ reference → leak
  }
}

// ✅ ĐÚNG — luôn cancel
class _MyScreenState extends State<MyScreen> {
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = stream.listen((data) {
      if (mounted) setState(() => _data = data);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
```

**StreamController cũng phải close:**

```dart
// ❌ LEAK — controller không close → stream không bao giờ done
class SearchService {
  final _controller = StreamController<String>();
  // Nếu không gọi _controller.close() → leak
}

// ✅ ĐÚNG
class SearchService {
  final _controller = StreamController<String>();
  
  void dispose() {
    _controller.close();
  }
}
```

---

## 6. RxDart — Stream nâng cao

Dart built-in stream thiếu nhiều operator. RxDart bổ sung:

```dart
import 'package:rxdart/rxdart.dart';
```

**BehaviorSubject — Stream có nhớ giá trị cuối:**

```dart
// StreamController thường: listener mới không nhận được giá trị cũ
// BehaviorSubject: listener mới nhận ngay giá trị mới nhất

final subject = BehaviorSubject<User>.seeded(defaultUser);
subject.add(newUser);

// Listener đăng ký SAU khi add → vẫn nhận được newUser ngay lập tức
subject.listen((user) => print(user)); // In newUser ngay

// Đọc giá trị hiện tại mà không cần listen
final current = subject.value;
```

**CombineLatest — ghép nhiều stream:**

```dart
final combined = Rx.combineLatest3(
  selectedCategoryStream,   // Stream<Category>
  sortOrderStream,          // Stream<SortOrder>
  searchQueryStream,        // Stream<String>
  (category, sort, query) => ProductFilter(
    category: category,
    sort: sort,
    query: query,
  ),
);

// Mỗi khi BẤT KỲ stream nào thay đổi → emit ProductFilter mới
// UI tự rebuild với filter mới
```

**Các operator quan trọng khác:**

```dart
stream
    .debounceTime(Duration(ms: 300))  // Đợi ngừng emit
    .throttleTime(Duration(ms: 500))  // Tối đa 1 event mỗi 500ms
    .switchMap((val) => apiCall(val))  // Cancel cũ, chạy mới
    .exhaustMap((val) => apiCall(val)) // Bỏ qua mới nếu cũ chưa xong
    .distinctUnique()                  // Bỏ trùng (deep equality)
    .startWith(initialValue)           // Emit giá trị đầu tiên ngay
    .pairwise()                        // Emit [previous, current]
    .scan((acc, val, _) => acc + val, 0) // Tích lũy (như reduce)
```

---

## 7. Khi nào dùng cái nào?

| Tình huống | Dùng | Lý do |
|---|---|---|
| Gọi API lấy data 1 lần | **Future** | 1 request → 1 response |
| Gửi form, upload file | **Future** | Hành động 1 lần |
| Firestore real-time | **Stream** | Data thay đổi liên tục |
| WebSocket / SSE | **Stream** | Kết nối liên tục |
| Theo dõi connectivity | **Stream** | Trạng thái thay đổi bất kỳ lúc nào |
| Search khi user gõ | **Stream** | Cần debounce, switchMap |
| Timer / countdown | **Stream** | Emit giá trị định kỳ |
| Đọc GPS liên tục | **Stream** | Vị trí thay đổi liên tục |
| Authentication state | **Stream** | Login/logout xảy ra bất kỳ lúc nào |
| Lấy history + lắng nghe mới | **Cả hai** | Future cho quá khứ, Stream cho tương lai |

Nguyên tắc đơn giản: nếu data **chỉ cần 1 lần** → Future. Nếu data **có thể thay đổi và bạn cần biết khi nào nó đổi** → Stream.
