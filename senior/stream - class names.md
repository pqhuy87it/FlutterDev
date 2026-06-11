Đây là danh sách các class liên quan đến Stream trong Dart/Flutter SDK, tổ chức theo nhóm chức năng:

## 1. Core (dart:async)

| Class | Mô tả |
|---|---|
| `Stream<T>` | Base class, nguồn phát event bất đồng bộ |
| `StreamController<T>` | Tạo và điều khiển Stream thủ công |
| `StreamSubscription<T>` | Đại diện cho 1 lượt listen, dùng để cancel/pause/resume |
| `StreamSink<T>` | Interface để add data/error vào Stream |
| `StreamConsumer<T>` | Interface nhận data từ Stream (ít dùng trực tiếp) |
| `StreamTransformer<S, T>` | Biến đổi Stream kiểu S thành Stream kiểu T |
| `StreamTransformerBase<S, T>` | Base class để tạo custom transformer |
| `StreamIterator<T>` | Duyệt Stream theo kiểu pull (thay vì push) |
| `StreamView<T>` | Wrapper bọc Stream, dùng để ẩn implementation |
| `EventSink<T>` | Interface add data/error/close (StreamController implement cái này) |
| `MultiStreamController<T>` | Controller cho multi-listener stream (Dart 3+) |

## 2. Broadcast & Multi-subscription

```dart
// Tạo broadcast controller
final controller = StreamController<int>.broadcast();

// Hoặc chuyển single → broadcast
final broadcast = singleStream.asBroadcastStream();
```

Không có class riêng — `StreamController` có named constructor `.broadcast()` và `Stream` có method `.asBroadcastStream()`.

## 3. Flutter Widgets (package:flutter)

| Class | Mô tả |
|---|---|
| `StreamBuilder<T>` | Widget rebuild khi Stream emit data mới |
| `StreamBuilderBase<T, S>` | Base class cho custom stream-aware widget |
| `AsyncSnapshot<T>` | Chứa trạng thái hiện tại của Stream/Future trong Builder |

```dart
StreamBuilder<User>(
  stream: userStream,
  builder: (context, snapshot) {
    // snapshot.connectionState: none, waiting, active, done
    // snapshot.data: giá trị mới nhất
    // snapshot.error: lỗi mới nhất
    // snapshot.hasData, snapshot.hasError
    
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) return ErrorWidget(snapshot.error!);
    if (!snapshot.hasData) return EmptyWidget();
    return UserProfile(snapshot.data!);
  },
)
```

## 4. dart:io — I/O Streams

| Class | Mô tả |
|---|---|
| `IOSink` | Ghi data ra stream (stdout, file) |
| `HttpClientResponse` | Implements `Stream<List<int>>` — đọc HTTP response body |
| `Socket` | Implements `Stream<Uint8List>` — TCP socket |
| `RawSocket` | Implements `Stream<RawSocketEvent>` — low-level socket |
| `WebSocket` | Implements `Stream<dynamic>` — WebSocket connection |
| `Stdin` | Implements `Stream<List<int>>` — đọc input từ terminal |
| `Process` | `stdout`, `stderr` là `Stream<List<int>>` |

```dart
// Đọc file lớn dưới dạng stream — không load toàn bộ vào RAM
final file = File('large_data.csv');
final lines = file.openRead()
    .transform(utf8.decoder)
    .transform(LineSplitter());

await for (final line in lines) {
  processLine(line);
}
```

## 5. dart:convert — Transform Streams

| Class | Mô tả |
|---|---|
| `StreamTransformer` | Base cho codec transform |
| `Utf8Decoder` | `StreamTransformer<List<int>, String>` |
| `Utf8Encoder` | `StreamTransformer<String, List<int>>` |
| `LineSplitter` | `StreamTransformer<String, String>` — tách theo dòng |
| `JsonDecoder` | Dùng kết hợp stream transform |

```dart
// Chain transformers trên stream
socket
    .transform(utf8.decoder)       // bytes → String
    .transform(LineSplitter())     // String → từng dòng
    .transform(jsonDecoder)        // dòng → JSON object
    .listen((json) => handle(json));
```

## 6. Animation & Scheduler (Flutter framework)

| Class | Mô tả |
|---|---|
| `AnimationController` | Không phải Stream nhưng có `addListener` pattern tương tự |
| `ChangeNotifier` | Cũng push-based notification, "stream-like" |

Flutter animation dùng `Ticker` thay vì Stream, nhưng concept tương tự.

## 7. RxDart (package bên ngoài, nhưng rất phổ biến)

| Class | Mô tả |
|---|---|
| `BehaviorSubject<T>` | StreamController + nhớ giá trị cuối |
| `ReplaySubject<T>` | StreamController + nhớ N giá trị gần nhất |
| `PublishSubject<T>` | StreamController broadcast đơn giản |
| `ValueStream<T>` | Stream có `.value` accessor |
| `ConnectableStream<T>` | Stream chỉ bắt đầu emit khi gọi `.connect()` |
| `CombineLatestStream<T, R>` | Ghép nhiều stream |
| `MergeStream<T>` | Trộn nhiều stream thành 1 |
| `ConcatStream<T>` | Nối stream tuần tự |
| `ZipStream<T, R>` | Ghép cặp event từ nhiều stream |
| `SwitchLatestStream<T>` | Stream of streams, chỉ lấy cái mới nhất |
| `RetryStream<T>` | Tự retry khi stream lỗi |
| `TimerStream<T>` | Emit 1 giá trị sau delay |
| `RangeStream` | Emit dãy số |
| `DeferStream<T>` | Tạo stream mới mỗi lần listen |
| `NeverStream` | Stream không bao giờ emit gì |
| `FromCallableStream<T>` | Chuyển function → Stream |

## 8. Các package phổ biến khác

| Package | Class | Mô tả |
|---|---|---|
| `bloc` | `BlocBase<S>` | Có `stream` getter trả về `Stream<State>` |
| `riverpod` | `StreamProvider<T>` | Provider bọc Stream |
| `riverpod` | `AsyncValue<T>` | Tương tự `AsyncSnapshot`, dùng cho Stream/Future |
| `firebase_core` | `FirebaseDatabase.ref().onValue` | Trả `Stream<DatabaseEvent>` |
| `cloud_firestore` | `Query.snapshots()` | Trả `Stream<QuerySnapshot>` |
| `connectivity_plus` | `Connectivity().onConnectivityChanged` | `Stream<ConnectivityResult>` |
| `geolocator` | `Geolocator.getPositionStream()` | `Stream<Position>` |
| `web_socket_channel` | `WebSocketChannel` | `.stream` là `Stream<dynamic>` |
| `sensors_plus` | `accelerometerEvents` | `Stream<AccelerometerEvent>` |

## 9. Tổng hợp mối quan hệ

```
                    StreamTransformer<S,T>
                           │
                           ▼
StreamController<T> ──► Stream<T> ──► StreamSubscription<T>
    │                     │
    │                     ├─► StreamBuilder<T> (Flutter Widget)
    │                     │
    │                     ├─► StreamIterator<T> (pull-based)
    │                     │
    │                     ├─► StreamView<T> (wrapper)
    │                     │
    │                     └─► asBroadcastStream()
    │
    ├─► .broadcast() constructor
    │
    └─► implements StreamSink<T>
                │
                └─► extends StreamConsumer<T>
```

Senior cần nắm chắc ít nhất: `Stream`, `StreamController`, `StreamSubscription`, `StreamBuilder`, `StreamTransformer`, và `BehaviorSubject` (RxDart). Các class còn lại biết để dùng khi cần, không cần nhớ hết.
