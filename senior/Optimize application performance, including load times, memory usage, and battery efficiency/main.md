# Optimize Application Performance trong Flutter

Đây là một trong những trách nhiệm cốt lõi của Senior Flutter Developer, bao gồm 3 trụ cột chính: **Load Times**, **Memory Usage**, và **Battery Efficiency**. Mình sẽ đi sâu từng phần.

---

## 1. Load Times (Thời gian tải)

### App Startup Time

Có 2 loại khởi động cần quan tâm:

**Cold start** là khi app được khởi động từ đầu, hệ điều hành phải load toàn bộ Dart VM, framework, rồi mới chạy `main()`. Senior cần tối ưu bằng cách giảm thiểu logic nặng trong `main()` và `initState()` của màn hình đầu tiên. Kỹ thuật phổ biến là **lazy initialization** — chỉ khởi tạo service/dependency khi thực sự cần, thay vì load hết trong `main()`.

```dart
// ❌ Bad: Load tất cả trong main
void main() async {
  await Firebase.initializeApp();
  await HiveDB.init();
  await AnalyticsService.init();
  await RemoteConfig.fetchAll();
  runApp(MyApp());
}

// ✅ Good: Chỉ load những gì cần thiết ngay lập tức
void main() async {
  await Firebase.initializeApp();
  runApp(MyApp()); // Các service khác lazy load sau
}
```

**Warm start** là khi app đã ở background và được resume lại — ít tốn kém hơn nhưng vẫn cần đảm bảo state được restore đúng cách.

### Rendering Performance

Mục tiêu là giữ **60fps** (hoặc 120fps trên thiết bị hỗ trợ), nghĩa là mỗi frame chỉ có khoảng **16ms** để build và paint.

**Tránh rebuild không cần thiết** — đây là vấn đề phổ biến nhất. Khi `setState()` được gọi ở widget cha, toàn bộ subtree bên dưới sẽ rebuild. Senior cần biết cách tách widget tree hợp lý:

```dart
// ❌ Bad: Cả page rebuild khi chỉ counter thay đổi
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpensiveHeader(),    // Rebuild vô ích
        ExpensiveList(),      // Rebuild vô ích
        Text('$counter'),
        ElevatedButton(
          onPressed: () => setState(() => counter++),
          child: Text('Increment'),
        ),
      ],
    );
  }
}

// ✅ Good: Tách counter thành widget riêng
class CounterWidget extends StatefulWidget { /* ... */ }
// Hoặc dùng ValueNotifier + ValueListenableBuilder
// Hoặc dùng state management (Bloc, Riverpod...) với selective rebuild
```

**`const` constructor** là vũ khí mạnh mà nhiều dev bỏ qua. Widget có `const` constructor sẽ được Flutter bỏ qua trong quá trình rebuild vì framework biết nó không thay đổi:

```dart
// Flutter sẽ skip rebuild widget này hoàn toàn
const SizedBox(height: 16),
const Divider(),
const MyStaticHeader(),
```

**`RepaintBoundary`** giúp isolate vùng cần repaint. Khi một phần UI thay đổi liên tục (animation, progress bar), đặt nó trong `RepaintBoundary` để Flutter không phải repaint cả layer tree:

```dart
RepaintBoundary(
  child: MyAnimatedWidget(), // Chỉ vùng này repaint
)
```

### Image & Asset Loading

Hình ảnh thường là bottleneck lớn nhất về load time:

```dart
// Cache và resize image đúng cách
CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: 300,  // Decode ở size cần hiển thị, không phải full resolution
  placeholder: (_, __) => Shimmer(), // Skeleton loading
)
```

Senior cần hiểu rằng một ảnh 4000x3000px dù hiển thị ở 300x200 vẫn chiếm bộ nhớ theo kích thước gốc nếu không resize khi decode. Tham số `cacheWidth`/`cacheHeight` trong `Image` widget hoặc `memCacheWidth` trong `CachedNetworkImage` giải quyết vấn đề này.

---

## 2. Memory Usage (Quản lý bộ nhớ)

### Memory Leak — kẻ thù thầm lặng

Dart có Garbage Collector (GC), nhưng GC chỉ thu hồi được object không còn reference nào trỏ tới. Memory leak xảy ra khi object đáng lẽ phải được giải phóng nhưng vẫn bị giữ reference.

**Nguyên nhân phổ biến nhất:**

Stream subscription không cancel:

```dart
class _MyState extends State<MyWidget> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = myStream.listen((data) => setState(() {}));
  }

  // ❌ Quên dispose → Stream giữ reference tới State
  // → State giữ reference tới BuildContext → cả widget tree bị giữ

  // ✅ Luôn cancel
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
```

Tương tự với `AnimationController`, `TextEditingController`, `ScrollController`, `FocusNode` — tất cả đều cần dispose.

**Closure giữ reference ẩn** là trường hợp khó phát hiện hơn:

```dart
// ❌ Closure capture `this` (State object)
Timer.periodic(Duration(seconds: 5), (timer) {
  setState(() => _refresh()); // Nếu widget đã unmount → leak
});
```

### Công cụ phát hiện

Senior cần thành thạo **DevTools Memory tab**: theo dõi heap size theo thời gian, nếu thấy heap tăng liên tục mà không giảm sau GC thì gần như chắc chắn có leak. Dùng **Heap Snapshot** để tìm xem object nào đang chiếm nhiều bộ nhớ và ai đang giữ reference tới nó (retaining path).

### ListView & Lazy Loading

Với danh sách lớn, sự khác biệt giữa `ListView()` và `ListView.builder()` là rất lớn:

```dart
// ❌ Render TẤT CẢ 10,000 items cùng lúc vào bộ nhớ
ListView(
  children: items.map((i) => ItemWidget(i)).toList(),
)

// ✅ Chỉ render items đang hiển thị trên viewport + buffer
ListView.builder(
  itemCount: items.length,
  itemBuilder: (ctx, i) => ItemWidget(items[i]),
)
```

`ListView.builder` chỉ tạo widget cho các item visible trên màn hình (cộng thêm một vùng buffer nhỏ). Khi user scroll, widget cũ bị dispose và widget mới được tạo. Đây là cơ chế **viewport-based rendering**.

### Isolate cho heavy computation

Dart là single-threaded trên main isolate. Bất kỳ tính toán nào tốn hơn vài ms đều có thể gây **jank** (frame drop). Senior cần biết khi nào dùng `compute()` hoặc tạo isolate riêng:

```dart
// ❌ Parse JSON lớn trên main isolate → UI freeze
final data = jsonDecode(hugeJsonString);

// ✅ Chạy trên isolate riêng
final data = await compute(jsonDecode, hugeJsonString);
```

Các use case phổ biến: parse JSON lớn, xử lý ảnh, mã hóa/giải mã, tính toán thuật toán phức tạp.

---

## 3. Battery Efficiency (Tối ưu pin)

Đây là phần thường bị bỏ qua nhất nhưng ảnh hưởng trực tiếp đến trải nghiệm người dùng, đặc biệt trên mobile.

### Giảm thiểu network calls

Mỗi request mạng đều đánh thức radio antenna — một trong những component tốn pin nhất trên điện thoại:

**Batching requests**: Thay vì gọi 5 API riêng lẻ khi mở màn hình, gom thành 1 request hoặc dùng GraphQL để lấy đúng data cần.

**Caching strategy**: Implement caching nhiều tầng — memory cache (nhanh nhất), disk cache (bền hơn), và stale-while-revalidate pattern (hiển thị cache cũ ngay lập tức, đồng thời fetch data mới phía sau):

```dart
// Stale-while-revalidate
Future<Data> getData() async {
  final cached = await localCache.get('key');
  if (cached != null) {
    _refreshInBackground(); // Fetch mới nhưng không block UI
    return cached;
  }
  return await fetchFromApi();
}
```

### Animation & GPU Usage

Animation chạy liên tục sẽ giữ GPU active, tốn pin đáng kể:

```dart
// ❌ Animation chạy mãi dù widget không visible
_controller = AnimationController(vsync: this)..repeat();

// ✅ Dùng VisibilityDetector hoặc TickerMode để pause khi off-screen
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    _controller.stop(); // App xuống background → stop animation
  } else if (state == AppLifecycleState.resumed) {
    _controller.repeat();
  }
}
```

### Location & Sensors

Nếu app dùng GPS, accelerometer, gyroscope, cần tuân thủ nguyên tắc: **request ở accuracy thấp nhất chấp nhận được**, và **stop listen ngay khi không cần**:

```dart
// ❌ High accuracy liên tục
Geolocator.getPositionStream(
  locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
);

// ✅ Chỉ dùng accuracy vừa đủ, và dispose khi không cần
Geolocator.getPositionStream(
  locationSettings: LocationSettings(
    accuracy: LocationAccuracy.medium,
    distanceFilter: 50, // Chỉ update khi di chuyển 50m
  ),
);
```

### Background Processing

Với các task chạy nền (sync data, push notification handling), dùng `workmanager` hoặc platform channel tới native background service thay vì giữ Dart isolate chạy liên tục. Hệ điều hành sẽ schedule task hiệu quả hơn về mặt pin.

---

## Công cụ đo lường — Senior phải dùng thành thạo

Tất cả tối ưu trên đều vô nghĩa nếu không đo lường. Các công cụ quan trọng:

**Flutter DevTools** cung cấp Performance tab (timeline, frame rendering), Memory tab (heap, allocation), và Network tab. **Profile mode** (`flutter run --profile`) cho kết quả sát thực tế hơn debug mode vì dùng AOT compilation như release build nhưng vẫn giữ được DevTools connection. Ngoài ra, **`flutter run --trace-skia`** giúp phân tích GPU workload, và trên production thì dùng **Firebase Performance Monitoring** hoặc **Sentry** để theo dõi real-user metrics.

Nguyên tắc vàng: **Đo trước, tối ưu sau**. Không bao giờ tối ưu dựa trên phỏng đoán — luôn dùng profiler để xác định bottleneck thực sự, rồi mới áp dụng kỹ thuật phù hợp.
