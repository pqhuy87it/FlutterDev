# Analytics Batching & Offline Queuing — Deep Dive

## 1. Tại sao cần Batching & Offline Queuing?

### Nếu KHÔNG có — naive approach:

```dart
// ❌ Mỗi event gửi ngay 1 HTTP request
class NaiveAnalytics {
  void track(String event, Map<String, dynamic> props) {
    _dio.post('/analytics/event', data: {
      'event': event,
      'properties': props,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

Vấn đề trong production:

```
User mở app, trong 10 giây đầu tiên:
─────────────────────────────────────────
t=0ms     track('app_open')              → HTTP request #1
t=50ms    track('screen_view', 'home')   → HTTP request #2
t=200ms   track('feed_loaded')           → HTTP request #3
t=500ms   track('banner_impression')     → HTTP request #4
t=800ms   track('notification_seen')     → HTTP request #5
t=1200ms  track('product_impression')    → HTTP request #6
t=1500ms  track('product_impression')    → HTTP request #7
t=2000ms  track('scroll_depth', 25%)     → HTTP request #8
...

→ 30-50 requests/phút trong active session
→ Nhân với 100K DAU = hàng triệu requests/phút tới analytics server
```

**Hậu quả trên device:**

```
1. Battery drain    — radio module bật/tắt liên tục (mỗi request đánh thức radio)
2. Bandwidth waste  — mỗi request tốn ~500 bytes HTTP overhead cho ~100 bytes payload
3. Thread pressure  — mỗi request chiếm 1 isolate/connection slot
4. Data loss        — user vào tunnel, mất mạng → events biến mất
5. Server cost      — backend phải handle millions of tiny requests thay vì bulk inserts
```

### Với Batching + Offline Queuing:

```
30 events trong 30 giây
    → gom lại thành 1 batch
    → 1 HTTP request duy nhất
    → Nếu fail → lưu SQLite → retry sau
    → Tiết kiệm ~95% requests
```

---

## 2. Kiến trúc tổng thể

```
┌─────────────────────────────────────────────────────┐
│                   App Code                          │
│  track('purchase', { amount: 99 })                  │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│              AnalyticsEngine                        │
│                                                     │
│  ┌─────────┐    ┌──────────┐    ┌────────────────┐  │
│  │ In-Memory│───►│  Flush   │───►│  HTTP Sender   │  │
│  │  Buffer  │    │ Strategy │    │  (batch POST)  │  │
│  └─────────┘    └────┬─────┘    └───────┬────────┘  │
│                      │                  │            │
│                      │            ┌─────▼────────┐   │
│                      │            │   Success?   │   │
│                      │            └──┬────────┬──┘   │
│                      │            Yes│        │No    │
│                      │               ▼        ▼      │
│                      │           ┌──────┐ ┌───────┐  │
│                      │           │Delete│ │Offline│  │
│                      │           │from  │ │Queue  │  │
│                      │           │queue │ │(SQLite│  │
│                      │           └──────┘ │/Drift)│  │
│                      │                    └───┬───┘  │
│                      │                        │      │
│                      │           ┌────────────▼───┐  │
│                      │           │  RetryManager  │  │
│                      │           │  (connectivity │  │
│                      │           │   + backoff)   │  │
│                      │           └────────────────┘  │
└─────────────────────────────────────────────────────┘
```

---

## 3. Implementation chi tiết

### 3.1 Event Model — Type-safe, serializable

```dart
class AnalyticsEvent {
  final String id;         // UUID — để deduplicate
  final String name;
  final Map<String, dynamic> properties;
  final DateTime timestamp;
  final int retryCount;

  AnalyticsEvent({
    String? id,
    required this.name,
    this.properties = const {},
    DateTime? timestamp,
    this.retryCount = 0,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'properties': properties,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) =>
    AnalyticsEvent(
      id: json['id'],
      name: json['name'],
      properties: Map<String, dynamic>.from(json['properties']),
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retry_count'] ?? 0,
    );
}
```

### 3.2 In-Memory Buffer + Flush Strategy

```dart
class AnalyticsEngine {
  final List<AnalyticsEvent> _buffer = [];
  final AnalyticsSender _sender;
  final OfflineQueue _offlineQueue;
  Timer? _flushTimer;

  // ===== FLUSH THRESHOLDS =====
  static const _maxBufferSize = 20;           // gom đủ 20 events → flush
  static const _flushInterval = Duration(seconds: 30); // hoặc 30s → flush
  static const _maxBatchPayload = 50;         // server chấp nhận tối đa 50/batch

  void track(AnalyticsEvent event) {
    _buffer.add(event);

    // Condition 1: buffer đầy → flush ngay
    if (_buffer.length >= _maxBufferSize) {
      _flush();
    } else {
      // Condition 2: chưa đầy → đặt timer, flush sau 30s
      _flushTimer ??= Timer(_flushInterval, _flush);
    }
  }

  Future<void> _flush() async {
    _flushTimer?.cancel();
    _flushTimer = null;

    if (_buffer.isEmpty) return;

    // Lấy events ra khỏi buffer (clear ngay để không block track() mới)
    final batch = List<AnalyticsEvent>.from(_buffer);
    _buffer.clear();

    // Chia batch nếu quá lớn
    final chunks = _chunkList(batch, _maxBatchPayload);
    for (final chunk in chunks) {
      await _sendOrQueue(chunk);
    }
  }

  Future<void> _sendOrQueue(List<AnalyticsEvent> batch) async {
    try {
      await _sender.sendBatch(batch);
    } catch (e) {
      // Gửi fail → đẩy vào offline queue
      await _offlineQueue.enqueue(batch);
    }
  }

  List<List<T>> _chunkList<T>(List<T> list, int size) =>
    [for (var i = 0; i < list.length; i += size) list.sublist(i, min(i + size, list.length))];
}
```

### 3.3 Flush khi app về background / bị kill

Đây là điểm **dễ mất data nhất** — user đóng app, buffer chưa flush:

```dart
class AnalyticsEngine with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // App đang bị tắt → flush ngay lập tức
        _emergencyFlush();
        break;
      case AppLifecycleState.resumed:
        // App trở lại → retry offline queue
        _offlineQueue.retryPending();
        break;
      default:
        break;
    }
  }

  Future<void> _emergencyFlush() async {
    if (_buffer.isEmpty) return;
    final batch = List<AnalyticsEvent>.from(_buffer);
    _buffer.clear();

    // Khi paused, network có thể unreliable → lưu thẳng vào disk
    // Sẽ retry khi app resume hoặc lần mở sau
    await _offlineQueue.enqueue(batch);
  }
}
```

---

### 3.4 Offline Queue — Persistent Storage

Đây là lớp **đảm bảo zero data loss**. Dùng SQLite (qua Drift/sqflite) thay vì SharedPreferences vì cần ACID transactions cho batch operations:

```dart
// Drift table definition
class PendingEvents extends Table {
  TextColumn get id => text()();              // event UUID
  TextColumn get payload => text()();          // JSON string
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class OfflineQueue {
  final AppDatabase _db;
  final AnalyticsSender _sender;
  final ConnectivityService _connectivity;
  Timer? _retryTimer;

  /// Lưu batch vào SQLite khi gửi fail
  Future<void> enqueue(List<AnalyticsEvent> events) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.pendingEvents,
        events.map((e) => PendingEventsCompanion.insert(
          id: e.id,
          payload: jsonEncode(e.toJson()),
          createdAt: DateTime.now(),
        )),
        mode: InsertMode.insertOrIgnore, // deduplicate by ID
      );
    });

    _scheduleRetry();
  }

  /// Retry pending events
  Future<void> retryPending() async {
    final hasConnection = await _connectivity.hasInternet;
    if (!hasConnection) {
      _scheduleRetry();
      return;
    }

    // Lấy batch từ DB, ưu tiên events cũ nhất
    final pending = await (_db.select(_db.pendingEvents)
      ..where((e) =>
        e.nextRetryAt.isNull() | e.nextRetryAt.isSmallerOrEqualValue(DateTime.now()))
      ..orderBy([(e) => OrderingTerm.asc(e.createdAt)])
      ..limit(50)
    ).get();

    if (pending.isEmpty) return;

    final events = pending
        .map((row) => AnalyticsEvent.fromJson(jsonDecode(row.payload)))
        .toList();

    try {
      await _sender.sendBatch(events);
      // Gửi thành công → xoá khỏi DB
      await (_db.delete(_db.pendingEvents)
        ..where((e) => e.id.isIn(pending.map((p) => p.id)))
      ).go();

      // Còn pending nữa không? Tiếp tục retry
      await retryPending();
    } catch (e) {
      // Vẫn fail → tăng retry count, schedule next attempt
      await _incrementRetryCount(pending);
      _scheduleRetry();
    }
  }

  /// Exponential backoff per event
  Future<void> _incrementRetryCount(List<PendingEvent> events) async {
    for (final event in events) {
      final newCount = event.retryCount + 1;

      if (newCount > 5) {
        // Quá 5 lần → drop event (hoặc move to dead letter)
        await (_db.delete(_db.pendingEvents)
          ..where((e) => e.id.equals(event.id))
        ).go();
        continue;
      }

      // Backoff: 1min, 2min, 4min, 8min, 16min
      final nextRetry = DateTime.now().add(
        Duration(minutes: pow(2, newCount).toInt()),
      );

      await (_db.update(_db.pendingEvents)
        ..where((e) => e.id.equals(event.id))
      ).write(PendingEventsCompanion(
        retryCount: Value(newCount),
        nextRetryAt: Value(nextRetry),
      ));
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(minutes: 1), retryPending);
  }

  /// Cleanup: xoá events quá cũ (> 7 ngày)
  Future<void> pruneStaleEvents() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    await (_db.delete(_db.pendingEvents)
      ..where((e) => e.createdAt.isSmallerThanValue(cutoff))
    ).go();
  }
}
```

---

### 3.5 HTTP Sender — Batch API Call

```dart
class AnalyticsSender {
  final Dio _dio;

  Future<void> sendBatch(List<AnalyticsEvent> events) async {
    final response = await _dio.post(
      '/analytics/batch',
      data: {
        'events': events.map((e) => e.toJson()).toList(),
        'device': _deviceInfo(),
        'sent_at': DateTime.now().toIso8601String(),
      },
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        // Không gửi auth token cho analytics — giảm coupling
        // Analytics server dùng API key thay vì user token
        headers: {'X-API-Key': _config.analyticsApiKey},
      ),
    );

    // Server trả về partial failure
    if (response.data['failed_ids'] != null) {
      final failedIds = List<String>.from(response.data['failed_ids']);
      if (failedIds.isNotEmpty) {
        final failedEvents = events.where((e) => failedIds.contains(e.id)).toList();
        throw PartialBatchFailure(failedEvents);
      }
    }
  }

  Map<String, dynamic> _deviceInfo() => {
    'platform': Platform.operatingSystem,
    'os_version': _deviceData.osVersion,
    'app_version': _packageInfo.version,
    'locale': Platform.localeName,
  };
}
```

---

### 3.6 Connectivity-Aware Retry

```dart
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get onConnectivityChanged =>
    _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );

  Future<bool> get hasInternet async {
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) return false;
    // ConnectivityResult chỉ check WiFi/cellular có bật không
    // KHÔNG đảm bảo có internet thật → cần ping
    try {
      final response = await Dio().get(
        'https://clients3.google.com/generate_204',
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}

// Tích hợp vào OfflineQueue
class OfflineQueue {
  late final StreamSubscription _connectSub;

  void init() {
    _connectSub = _connectivity.onConnectivityChanged.listen((hasNet) {
      if (hasNet) retryPending(); // online trở lại → flush queue
    });
  }

  void dispose() => _connectSub.cancel();
}
```

---

## 4. Timing Diagram — Full Flow

### Happy path (có mạng):

```
track(A)  track(B)  track(C)  ... track(T)   ← 20 events
  │         │         │              │
  ▼         ▼         ▼              ▼
  ┌─────────────────────────────────────┐
  │         In-Memory Buffer            │
  │  [A, B, C, D, ... T]  (size=20)    │
  └────────────────┬────────────────────┘
                   │ buffer full → flush
                   ▼
  ┌─────────────────────────────────────┐
  │  POST /analytics/batch              │
  │  { events: [A..T], sent_at: ... }   │
  └────────────────┬────────────────────┘
                   │ 200 OK
                   ▼
                 Done ✅
```

### Offline → Online:

```
track(A)  track(B)  ...  track(T)
  │         │              │
  ▼         ▼              ▼
  ┌──────────────────────────────┐
  │     In-Memory Buffer (20)    │
  └──────────┬───────────────────┘
             │ flush
             ▼
  ┌──────────────────────────────┐
  │  POST /analytics/batch       │
  │  → ❌ SocketException        │
  └──────────┬───────────────────┘
             │ fail
             ▼
  ┌──────────────────────────────┐
  │  SQLite: INSERT 20 events    │──── retry timer: 1min
  └──────────────────────────────┘
             │
     ... 5 phút, user vẫn offline, events tích luỹ ...
             │
  ┌──────────────────────────────┐
  │  SQLite: 80 events pending   │
  └──────────┬───────────────────┘
             │ ConnectivityChanged: ONLINE
             ▼
  ┌──────────────────────────────┐
  │  retryPending()              │
  │  SELECT 50 events (batch 1)  │
  │  POST /analytics/batch → ✅  │
  │  DELETE 50 from SQLite       │
  │                              │
  │  SELECT 30 events (batch 2)  │
  │  POST /analytics/batch → ✅  │
  │  DELETE 30 from SQLite       │
  │                              │
  │  Queue empty ✅               │
  └──────────────────────────────┘
```

### App bị kill:

```
track(A) track(B) track(C)
  │        │        │
  ▼        ▼        ▼
  ┌─────────────────────────┐
  │  Buffer: [A, B, C]      │ ← chưa đủ 20, chưa hết 30s
  └──────────┬──────────────┘
             │ AppLifecycleState.paused (user swipe kill)
             ▼
  ┌─────────────────────────┐
  │  emergencyFlush()        │
  │  → SQLite: INSERT [A,B,C]│ ← lưu disk ngay, KHÔNG gửi network
  └─────────────────────────┘
             │
     ... App bị terminate ...
             │
     ... Ngày hôm sau, user mở app ...
             │
  ┌─────────────────────────┐
  │  App init                │
  │  → retryPending()        │
  │  → SELECT [A,B,C]        │
  │  → POST /batch → ✅      │
  │  → DELETE from SQLite    │
  └─────────────────────────┘

→ Zero data loss ✅
```

---

## 5. Advanced: Priority Queue

Không phải mọi events đều quan trọng như nhau. Revenue events KHÔNG được mất, impression events mất cũng chấp nhận được:

```dart
enum EventPriority {
  critical,   // purchase, signup, payment_failed
  high,       // add_to_cart, begin_checkout
  normal,     // screen_view, button_click
  low,        // scroll_depth, impression, hover
}

class PrioritizedAnalyticsEngine extends AnalyticsEngine {
  @override
  Future<void> _emergencyFlush() async {
    final batch = List<AnalyticsEvent>.from(_buffer);
    _buffer.clear();

    // Khi app đang bị kill, thời gian hạn chế
    // Chỉ persist critical + high priority
    final important = batch.where(
      (e) => e.priority == EventPriority.critical ||
             e.priority == EventPriority.high
    ).toList();

    await _offlineQueue.enqueue(important);
    // low/normal events bị drop — chấp nhận được
  }
}

// Offline queue cũng ưu tiên critical events khi retry
class OfflineQueue {
  Future<void> retryPending() async {
    final pending = await (_db.select(_db.pendingEvents)
      ..orderBy([
        // Critical events retry trước
        (e) => OrderingTerm.asc(e.priority),
        (e) => OrderingTerm.asc(e.createdAt),
      ])
      ..limit(50)
    ).get();
    // ...
  }
}
```

---

## 6. Advanced: Backpressure — Bảo vệ khi event quá nhiều

```dart
class AnalyticsEngine {
  static const _maxQueuedEvents = 1000;

  void track(AnalyticsEvent event) {
    // Nếu buffer + offline queue quá lớn → drop low priority
    if (_totalPending > _maxQueuedEvents) {
      if (event.priority == EventPriority.low) return; // drop
      if (event.priority == EventPriority.normal) {
        // Sample: chỉ giữ 10%
        if (Random().nextInt(10) != 0) return;
      }
    }

    _buffer.add(event);
    _checkFlush();
  }

  int get _totalPending => _buffer.length + _offlineQueue.pendingCount;
}
```

Tại sao cần? Hình dung user scroll một RecyclerView với 500 items, mỗi item fire `impression` event. Nếu không có backpressure, buffer sẽ chiếm hàng MB RAM.

---

## 7. Testing Strategy

```dart
// Unit test cho flush logic
void main() {
  late AnalyticsEngine engine;
  late MockSender mockSender;
  late MockOfflineQueue mockQueue;

  setUp(() {
    mockSender = MockSender();
    mockQueue = MockOfflineQueue();
    engine = AnalyticsEngine(sender: mockSender, offlineQueue: mockQueue);
  });

  test('flushes when buffer reaches max size', () async {
    // Track 20 events (max buffer size)
    for (var i = 0; i < 20; i++) {
      engine.track(AnalyticsEvent(name: 'event_$i'));
    }

    // Sender should be called once with 20 events
    verify(() => mockSender.sendBatch(any(that: hasLength(20)))).called(1);
  });

  test('queues to offline when send fails', () async {
    when(() => mockSender.sendBatch(any()))
        .thenThrow(DioException(requestOptions: RequestOptions()));

    for (var i = 0; i < 20; i++) {
      engine.track(AnalyticsEvent(name: 'event_$i'));
    }

    // Should save to offline queue
    verify(() => mockQueue.enqueue(any(that: hasLength(20)))).called(1);
  });

  test('emergency flush on app pause saves to disk', () async {
    for (var i = 0; i < 5; i++) {
      engine.track(AnalyticsEvent(name: 'event_$i'));
    }

    // Simulate app going to background
    engine.didChangeAppLifecycleState(AppLifecycleState.paused);

    // Should save to offline queue (NOT try to send)
    verify(() => mockQueue.enqueue(any(that: hasLength(5)))).called(1);
    verifyNever(() => mockSender.sendBatch(any()));
  });

  test('drops low priority events under backpressure', () {
    // Fill up to max
    engine.simulatePendingCount(1000);

    engine.track(AnalyticsEvent(
      name: 'impression',
      priority: EventPriority.low,
    ));

    expect(engine.bufferSize, 0); // dropped

    engine.track(AnalyticsEvent(
      name: 'purchase',
      priority: EventPriority.critical,
    ));

    expect(engine.bufferSize, 1); // kept
  });
}
```

---

## 8. Tổng kết

```
Layer              Vai trò                    Bảo vệ khỏi
───────────────────────────────────────────────────────────
In-Memory Buffer   Gom events, giảm requests  Battery drain, bandwidth
Flush Strategy     Trigger gửi đúng lúc       Latency vs efficiency tradeoff
Offline Queue      Persist khi fail/offline    Data loss khi mất mạng
Emergency Flush    Persist khi app bị kill     Data loss khi user đóng app
Retry Manager      Gửi lại với backoff        Transient server failures
Priority Queue     Ưu tiên events quan trọng  Resource constraints
Backpressure       Drop events khi quá tải    Memory overflow, CPU spike
Deduplication      Event ID check             Duplicate data từ retry
Pruning            Xoá events > 7 ngày        Disk space trên device
```

Mindset senior ở đây: analytics có vẻ "không quan trọng" so với core features, nhưng **data quality quyết định business decisions**. Mất purchase events → revenue attribution sai → marketing budget allocate sai → mất tiền thật. Batching + offline queuing đảm bảo data đến server **đầy đủ, đúng thứ tự, không trùng lặp**, dù network conditions thế nào.
