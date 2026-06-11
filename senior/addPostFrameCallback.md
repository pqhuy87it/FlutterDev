# addPostFrameCallback — Giải thích chi tiết

## 1. Bản chất: Frame Rendering Pipeline

Để hiểu `addPostFrameCallback`, trước hết cần hiểu Flutter render một frame như thế nào. Mỗi frame (mục tiêu 16ms ở 60fps) trải qua một pipeline cố định:

```
┌─────────────────────────────────────────────────────────────┐
│                   FLUTTER FRAME PIPELINE                     │
│                                                              │
│  ① Transient Callbacks (Animations)                          │
│     │  - Ticker callbacks (AnimationController)              │
│     │  - Mỗi frame, animation cập nhật giá trị mới          │
│     ▼                                                        │
│  ② Build Phase                                               │
│     │  - Rebuild dirty widgets (setState đã mark dirty)      │
│     │  - Widget tree → Element tree cập nhật                 │
│     ▼                                                        │
│  ③ Layout Phase                                              │
│     │  - RenderObject.performLayout()                        │
│     │  - Tính toán size, position của mọi render object      │
│     ▼                                                        │
│  ④ Compositing Phase                                         │
│     │  - Tạo Layer tree từ render tree                       │
│     ▼                                                        │
│  ⑤ Paint Phase                                               │
│     │  - RenderObject.paint() → vẽ lên canvas                │
│     │  - Gửi layer tree cho Raster thread                    │
│     ▼                                                        │
│  ⑥ POST-FRAME CALLBACKS  ← ← ← addPostFrameCallback        │
│     │  - Frame ĐÃ RENDER XONG                               │
│     │  - Widget tree, layout, paint đều đã hoàn tất          │
│     │  - RenderObject đã có size/position chính xác          │
│     ▼                                                        │
│  Frame hoàn thành → chờ VSync tiếp theo                      │
└─────────────────────────────────────────────────────────────┘
```

`addPostFrameCallback` đăng ký một callback sẽ được gọi **sau khi frame hiện tại (hoặc frame tiếp theo) đã hoàn thành toàn bộ pipeline** — tức là sau Build, Layout, và Paint. Callback này chỉ chạy **đúng một lần** rồi tự động bị loại bỏ.

---

## 2. API Signature

```dart
void addPostFrameCallback(FrameCallback callback, {String debugLabel = 'callback'});

// Trong đó:
typedef FrameCallback = void Function(Duration timeStamp);
// timeStamp: thời điểm frame bắt đầu (từ lúc engine khởi động)
```

Cách gọi:

```dart
WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
  // Code ở đây chạy SAU KHI frame đã render xong
});
```

---

## 3. Tại sao cần dùng trong initState

`initState()` được gọi **trước** khi widget được build và layout lần đầu. Tại thời điểm `initState()` chạy, widget tree chưa hoàn chỉnh, render object chưa tồn tại hoặc chưa có size/position. Nhiều thao tác không thể thực hiện ở thời điểm này:

```dart
@override
void initState() {
  super.initState();

  // ❌ CRASH — RenderBox chưa được layout, chưa có size
  final size = context.size;

  // ❌ CRASH hoặc SAI — Scaffold chưa tồn tại trong tree
  ScaffoldMessenger.of(context).showSnackBar(...);

  // ❌ KHÔNG HOẠT ĐỘNG — Navigator chưa sẵn sàng hoàn toàn
  Navigator.of(context).push(...);

  // ❌ ScrollController chưa attach vào ScrollView
  _scrollController.jumpTo(100);
}
```

Tất cả đều fail vì **frame đầu tiên chưa chạy**. `addPostFrameCallback` giải quyết bằng cách trì hoãn code đến sau khi frame đầu tiên hoàn tất:

```dart
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // ✅ Frame đã render → mọi thứ đã sẵn sàng
    final size = context.size;                          // Có giá trị
    ScaffoldMessenger.of(context).showSnackBar(...);    // Hoạt động
    Navigator.of(context).push(...);                     // Hoạt động
    _scrollController.jumpTo(100);                       // Hoạt động
  });
}
```

---

## 4. Thời điểm thực thi chính xác

Có một chi tiết quan trọng: callback không nhất thiết chạy trong frame hiện tại. Nó phụ thuộc vào **lúc nào bạn đăng ký**:

```
Nếu đăng ký TRƯỚC hoặc TRONG frame đang chạy:
  → Callback chạy cuối frame ĐÓ

Nếu đăng ký KHI KHÔNG CÓ frame nào đang chạy
  (ví dụ: trong initState, trong Future callback):
  → Callback chạy cuối frame TIẾP THEO được schedule
```

Trong trường hợp `initState`, widget vừa được tạo nên Flutter chắc chắn sẽ schedule một frame để build/layout/paint widget này. Callback sẽ chạy cuối frame đó — tức là ngay sau khi widget xuất hiện trên màn hình lần đầu.

Để minh hoạ rõ hơn thứ tự thực thi:

```dart
class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    print('1. initState');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('5. postFrameCallback'); // Cuối cùng, sau khi frame xong
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('2. didChangeDependencies');
  }

  @override
  Widget build(BuildContext context) {
    print('3. build');
    return SizedBox();
  }

  // (Layout + Paint xảy ra ở RenderObject level, không có print ở đây)
  // Nhưng logic thứ tự:
  // 4. layout + paint
  // 5. postFrameCallback
}

// Output:
// 1. initState
// 2. didChangeDependencies
// 3. build
// (4. layout + paint — internal)
// 5. postFrameCallback
```

---

## 5. Các use case thực tế

### 5.1 — Đọc size/position sau layout

Đây là use case phổ biến nhất. Khi cần biết kích thước thực tế của widget sau khi layout (ví dụ: để quyết định hiển thị tooltip ở vị trí nào, hay để kiểm tra text có bị overflow không):

```dart
final GlobalKey _key = GlobalKey();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;
    final Size size = box.size;
    final Offset position = box.localToGlobal(Offset.zero);

    print('Widget size: $size');
    print('Widget position on screen: $position');
  });
}
```

### 5.2 — Auto-scroll đến vị trí cụ thể

Khi mở một màn hình chat và muốn scroll xuống message cuối cùng. Tại `initState`, `ScrollController` chưa attach vào `ListView` nên không thể scroll:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  });
}
```

### 5.3 — Show dialog/snackbar/bottom sheet ngay khi mở màn hình

Ví dụ: mở màn hình Settings và ngay lập tức show dialog yêu cầu user update app:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (needsUpdate) {
      showDialog(
        context: context,
        builder: (_) => UpdateDialog(),
      );
    }
  });
}
```

`showDialog` cần `context` đã hoàn chỉnh với `Overlay` ancestor. Trong `initState` thuần, điều này có thể fail.

### 5.4 — Trigger logic phụ thuộc vào InheritedWidget

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Provider/Bloc/InheritedWidget đã sẵn sàng
    final user = context.read<AuthBloc>().state.user;
    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  });
}
```

Mặc dù `context.read` (không listen) có thể dùng trong `initState` với một số state management, nhưng navigation sau đó cần tree đã ổn định. `addPostFrameCallback` đảm bảo điều này.

### 5.5 — Defer heavy work để first frame render nhanh

Như đã đề cập ở bài Cold Start, đây là kỹ thuật tối ưu startup:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Critical only
  runApp(MyApp());

  // Sau khi first frame render → init phần còn lại
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Analytics.init();
    await RemoteConfig.fetch();
    await PrefetchService.warmCache();
  });
}
```

User nhìn thấy UI ngay lập tức, các service phụ init phía sau mà không block first frame.

---

## 6. addPostFrameCallback vs các cơ chế tương tự

### So với `Future.microtask` / `Future.delayed`

```dart
// Chạy trong microtask queue — TRƯỚC frame tiếp theo
Future.microtask(() {
  // Widget tree có thể CHƯA layout xong
  // context.size có thể chưa có
});

// Chạy sau 0ms — tương tự microtask, KHÔNG đảm bảo frame đã xong
Future.delayed(Duration.zero, () {
  // Không đảm bảo layout đã hoàn tất
});

// Chạy SAU KHI frame hoàn tất — đảm bảo layout + paint xong
WidgetsBinding.instance.addPostFrameCallback((_) {
  // context.size CÓ giá trị chính xác
});
```

Sự khác biệt cốt lõi: `Future.microtask` và `Future.delayed(Duration.zero)` chạy trong **event loop** của Dart, không liên quan đến frame pipeline. Chúng có thể chạy trước, trong, hoặc giữa các phase của frame. `addPostFrameCallback` được tích hợp vào **frame scheduling** của Flutter engine, đảm bảo chạy đúng thời điểm sau paint.

```
Event Loop vs Frame Pipeline:

Dart Event Loop:
  ┌─ Microtask Queue ─── xử lý hết ──┐
  │                                     │
  └─ Event Queue ─── lấy 1 event ──────┘
       ↑
       │ Frame callback cũng là một event
       │ nhưng được schedule bởi VSync signal

Frame Pipeline (chạy BÊN TRONG một event loop iteration):
  Transient → Build → Layout → Paint → PostFrame
```

### So với `addPersistentFrameCallback`

```dart
// Chạy MỖI frame, mãi mãi — dùng cho animation engine
WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
  // Chạy 60 lần/giây, KHÔNG TỰ DỪNG
});

// Chạy ĐÚNG MỘT LẦN rồi tự loại bỏ
WidgetsBinding.instance.addPostFrameCallback((_) {
  // Chạy 1 lần duy nhất
});
```

`addPersistentFrameCallback` là nền tảng của hệ thống animation — `Ticker` sử dụng nó bên dưới. Hầu như không bao giờ cần gọi trực tiếp trong app code.

### So với `SchedulerBinding.addTimingsCallback`

```dart
// Nhận thông tin performance MỖI frame (build time, raster time)
SchedulerBinding.instance.addTimingsCallback((timings) {
  for (final timing in timings) {
    print('Build: ${timing.buildDuration}');
    print('Raster: ${timing.rasterDuration}');
  }
});
```

Đây là tool đo performance, không phải để chạy logic sau frame.

---

## 7. Khi nào KHÔNG nên dùng

### 7.1 — Gọi setState bên trong PostFrameCallback

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  setState(() {
    _isReady = true; // Trigger rebuild ngay sau frame vừa xong
  });
});
```

Về mặt kỹ thuật code này **hoạt động** và không crash. Nhưng cần hiểu hệ quả: `setState` mark widget dirty, Flutter schedule frame mới. Nghĩa là vừa render xong frame 1, lập tức trigger frame 2. User có thể thấy **1 frame nhấp nháy** — frame đầu render trạng thái cũ, frame sau render trạng thái mới.

Nếu bắt buộc phải dùng pattern này (ví dụ: cần size từ layout để quyết định UI), thì nên hiển thị loading/placeholder ở frame đầu để tránh nhấp nháy:

```dart
@override
Widget build(BuildContext context) {
  if (!_isReady) return const SizedBox.shrink(); // hoặc Shimmer
  return ActualContent();
}
```

### 7.2 — Logic không phụ thuộc vào frame

Nếu code không cần size, position, hay bất cứ gì từ render tree, dùng `addPostFrameCallback` là **overhead không cần thiết**:

```dart
// ❌ Không cần chờ frame — chỉ fetch data
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    fetchData(); // Không phụ thuộc layout
  });
}

// ✅ Gọi trực tiếp trong initState
@override
void initState() {
  super.initState();
  fetchData(); // Chạy ngay, không cần chờ frame
}
```

`fetchData()` là async I/O, không cần `context.size` hay `Navigator`, nên gọi thẳng trong `initState` là đủ. Dùng `addPostFrameCallback` chỉ trì hoãn vô ích thêm 1 frame (~16ms).

### 7.3 — Logic cần chạy MỖI lần rebuild

`addPostFrameCallback` chạy **một lần duy nhất**. Nếu cần code chạy sau mỗi lần widget rebuild (ví dụ: mỗi lần data thay đổi cần đo lại size), đặt nó trong `build` method hoặc dùng approach khác:

```dart
@override
Widget build(BuildContext context) {
  // Đăng ký lại mỗi lần build
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _measureAndAdjust();
  });
  return MyContent();
}
```

Cách này hoạt động nhưng hơi "thô". Alternative sạch hơn là dùng `LayoutBuilder` (biết size tại layout time) hoặc custom `RenderObject` với `performLayout` override.

### 7.4 — Thay thế cho didChangeDependencies khi có thể

Nếu chỉ cần access `InheritedWidget` data (Theme, MediaQuery, Provider), `didChangeDependencies` là nơi chính xác hơn:

```dart
// ✅ Đúng lifecycle method cho InheritedWidget access
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final theme = Theme.of(context); // Hoạt động ở đây
  final screenWidth = MediaQuery.of(context).size.width;
}
```

`didChangeDependencies` được gọi ngay sau `initState` và mỗi khi dependency thay đổi, vẫn là **trước** build nhưng `context` đã sẵn sàng cho `of(context)` lookups. Không cần `addPostFrameCallback` cho mục đích này.

---

## 8. Lưu ý quan trọng về mounted check

Vì `addPostFrameCallback` chạy **bất đồng bộ** (sau frame), có khả năng widget đã bị dispose trước khi callback chạy. Đặc biệt khi user navigate đi rất nhanh:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Widget có thể đã bị dispose tại thời điểm này!
    if (!mounted) return; // ← LUÔN check mounted

    setState(() => _isReady = true);
    Navigator.of(context).push(...);
  });
}
```

`mounted` check là **bắt buộc** trong mọi `addPostFrameCallback` có gọi `setState`, `Navigator`, `showDialog`, hoặc bất cứ gì dùng `context`. Bỏ qua check này sẽ gây crash với error `setState() called after dispose()`.

---

## 9. Tóm tắt quyết định

```
Cần access size/position sau layout?          → addPostFrameCallback ✅
Cần show dialog/snackbar ngay khi mở screen?  → addPostFrameCallback ✅
Cần scroll đến vị trí cụ thể lần đầu?        → addPostFrameCallback ✅
Cần defer non-critical init sau first frame?  → addPostFrameCallback ✅
Chỉ cần fetch data?                           → initState trực tiếp  ✅
Cần access InheritedWidget?                   → didChangeDependencies ✅
Cần biết size tại mọi lần build?              → LayoutBuilder         ✅
Cần chạy logic mỗi frame?                     → addPersistentFrameCallback ✅
```

Nguyên tắc đơn giản: nếu code cần **render tree đã hoàn chỉnh** (size, position, paint đã xong), dùng `addPostFrameCallback`. Nếu không, có lifecycle method phù hợp hơn.
