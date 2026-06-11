# StatefulWidget Lifecycle — Giải thích chi tiết

## 1. Tổng quan: Widget, Element, State — Ba thực thể

Trước khi đi vào lifecycle, cần hiểu rõ mối quan hệ giữa 3 object được tạo khi Flutter gặp một `StatefulWidget`:

```
StatefulWidget (immutable, cấu hình)
    │
    ├── createElement() → StatefulElement (quản lý vị trí trong tree)
    │
    └── createState() → State<T> (mutable, giữ dữ liệu thay đổi)
```

**StatefulWidget** bản thân nó là **immutable** — mỗi lần rebuild, Flutter tạo một widget instance mới. Nhưng **State object** được tạo một lần duy nhất và **tồn tại xuyên suốt** nhiều lần rebuild. Đây là lý do state được tách ra thành class riêng — nếu state nằm trong widget thì mỗi lần rebuild sẽ mất hết dữ liệu.

**StatefulElement** là cầu nối. Nó giữ reference tới cả widget hiện tại lẫn state object. Khi widget mới được tạo (do rebuild), element so sánh widget cũ và mới — nếu cùng `runtimeType` và `key`, element giữ nguyên state, chỉ cập nhật widget reference.

---

## 2. Full Lifecycle Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                  STATEFULWIDGET LIFECYCLE                       │
│                                                                 │
│  ┌──────────────────┐                                           │
│  │  createState()   │  Framework gọi đúng 1 lần                 │
│  └────────┬─────────┘  State object được tạo                    │
│           │             mounted = false                         │
│           ▼                                                     │
│  ┌──────────────────┐                                           │
│  │   initState()    │  Gọi đúng 1 lần, sau createState          │
│  └────────┬─────────┘  mounted = true (ngay trước khi gọi)      │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────────────┐                                   │
│  │ didChangeDependencies()  │  Gọi ngay sau initState           │
│  └────────┬─────────────────┘  + mỗi khi InheritedWidget        │
│           │                     dependency thay đổi             │
│           ▼                                                     │
│  ┌──────────────────┐                                           │
│  │     build()      │◄─────────── setState() trigger            │
│  └────────┬─────────┘◄─────────── didChangeDependencies()       │
│           │           ◄─────────── didUpdateWidget()            │
│           │                                                     │
│           ▼                                                     │
│     [Widget hiển thị trên màn hình]                             │
│           │                                                      │
│           │  Parent rebuild với widget mới                       │
│           ▼  (cùng runtimeType + key)                           │
│  ┌──────────────────────┐                                       │
│  │  didUpdateWidget()   │  Nhận oldWidget để so sánh            │
│  └────────┬─────────────┘  Framework tự gọi build() sau đó     │
│           │                                                      │
│           │  (Quay lại build)                                    │
│           │                                                      │
│     ══════╪══════════════════════════════════                    │
│           │  Widget bị remove khỏi tree                         │
│           ▼                                                      │
│  ┌──────────────────┐                                           │
│  │   deactivate()   │  State bị tách khỏi tree                 │
│  └────────┬─────────┘  Có thể được reinsert (hiếm)             │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────┐                                           │
│  │    dispose()     │  Dọn dẹp tài nguyên                      │
│  └────────┬─────────┘  mounted = false                          │
│           │              KHÔNG BAO GIỜ gọi setState sau đây     │
│           ▼                                                      │
│      [State bị GC]                                               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Chi tiết từng giai đoạn

### 3.1 — createState()

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}
```

Framework gọi method này khi `StatefulElement` được tạo (tức là khi widget được mount vào tree lần đầu). Đây là **factory method** — công việc duy nhất là tạo và return State object. Không nên đặt logic nào ở đây ngoài việc return instance.

**Điểm quan trọng**: `createState()` có thể được gọi **nhiều hơn một lần** trong đời sống của một StatefulWidget. Ví dụ khi widget cùng type được dùng ở nhiều vị trí trong tree, hoặc khi widget bị remove rồi insert lại với key khác. Mỗi lần gọi tạo ra một State object **độc lập**.

Tại thời điểm `createState()`, State object **chưa có context**, chưa có widget reference. Truy cập `widget` hay `context` ở đây sẽ không có giá trị hợp lệ.

### 3.2 — initState()

```dart
@override
void initState() {
  super.initState(); // BẮT BUỘC gọi đầu tiên

  // Khởi tạo dữ liệu chỉ cần làm 1 lần
  _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  _scrollController = ScrollController();

  _subscription = myStream.listen((data) {
    setState(() => _data = data);
  });
  
  _tabController = TabController(length: 3, vsync: this);
}
```

Framework gọi **đúng một lần** ngay sau khi State được insert vào tree. Tại thời điểm này:

- `mounted` đã là `true`
- `widget` đã có giá trị (có thể truy cập `widget.someProperty`)
- `context` đã hợp lệ — **nhưng** chưa có InheritedWidget dependency nào được thiết lập

**Được làm** trong initState: khởi tạo controller (Animation, Scroll, Text, Tab...), subscribe stream, đọc dữ liệu từ `widget` property, thiết lập giá trị ban đầu cho state variable, đăng ký listener.

**KHÔNG được làm** trong initState:

```dart
@override
void initState() {
  super.initState();

  // ❌ KHÔNG dùng context.dependOnInheritedWidgetOfExactType
  // (đây là mechanism bên dưới của Theme.of, MediaQuery.of, Provider.watch...)
  final theme = Theme.of(context);         // ❌ Sẽ gây assertion error
  final size = MediaQuery.of(context).size; // ❌

  // ❌ KHÔNG gọi showDialog, Navigator.push... 
  // (tree chưa build xong)
  showDialog(...); // ❌
}
```

Lý do kỹ thuật: `initState` được gọi **trong quá trình mount**, trước khi element được đăng ký vào inheritance chain. Khi bạn gọi `Theme.of(context)`, framework gọi `context.dependOnInheritedWidgetOfExactType<T>()`, method này đăng ký element hiện tại như **subscriber** của InheritedWidget đó. Flutter yêu cầu việc đăng ký này xảy ra **ngoài** `initState` — cụ thể trong `didChangeDependencies` hoặc `build`.

`super.initState()` phải gọi **đầu tiên** — nó thực hiện assertion check và setup nội bộ.

### 3.3 — didChangeDependencies()

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  
  // ✅ AN TOÀN truy cập InheritedWidget ở đây
  final theme = Theme.of(context);
  final locale = Localizations.localeOf(context);
  final mediaQuery = MediaQuery.of(context);
  
  // Ví dụ: fetch data dựa trên locale
  if (_lastLocale != locale) {
    _lastLocale = locale;
    _fetchLocalizedContent(locale);
  }
}
```

Được gọi trong hai trường hợp:

**Lần đầu tiên**: Ngay sau `initState()`, trước `build()` lần đầu. Đây là nơi sớm nhất có thể truy cập InheritedWidget an toàn.

**Các lần sau**: Mỗi khi một InheritedWidget mà State này **phụ thuộc** thay đổi. "Phụ thuộc" ở đây nghĩa là State đã gọi `context.dependOnInheritedWidgetOfExactType<T>()` (trực tiếp hoặc gián tiếp qua `Theme.of`, `MediaQuery.of`, `Provider.watch`...).

Cơ chế bên dưới hoạt động như sau: khi bạn gọi `Theme.of(context)` trong `build()`, framework ghi nhận rằng element này **depend on** `_InheritedTheme`. Khi theme thay đổi (ví dụ user switch dark mode), `_InheritedTheme` notify tất cả dependent — framework gọi `didChangeDependencies()` trên từng dependent, rồi schedule rebuild.

```
InheritedWidget thay đổi
    │
    ▼
Framework duyệt danh sách dependents
    │
    ▼
Gọi didChangeDependencies() trên mỗi dependent
    │
    ▼
Mark element dirty → schedule rebuild
    │
    ▼
build() được gọi trong frame tiếp theo
```

**Lưu ý quan trọng**: Method này có thể được gọi **nhiều lần** trong đời sống của State. Nếu đặt logic expensive (như API call) ở đây mà không guard, sẽ bị gọi lại mỗi khi dependency thay đổi:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  
  // ❌ Bad: fetch lại mỗi khi BẤT KỲ dependency nào thay đổi
  _fetchData();
  
  // ✅ Good: chỉ fetch khi dependency CỤ THỂ thay đổi
  final newLocale = Localizations.localeOf(context);
  if (_lastLocale != newLocale) {
    _lastLocale = newLocale;
    _fetchData(newLocale);
  }
}
```

### 3.4 — build()

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text(_title)),
    body: _isLoading
        ? const CircularProgressIndicator()
        : ListView.builder(
            itemCount: _items.length,
            itemBuilder: (ctx, i) => ListTile(title: Text(_items[i])),
          ),
  );
}
```

Đây là method **quan trọng nhất** và được gọi **thường xuyên nhất**. Framework gọi `build()` trong nhiều trường hợp:

- Sau `initState()` (qua `didChangeDependencies()`)
- Sau `setState()`
- Sau `didChangeDependencies()`
- Sau `didUpdateWidget()`
- Sau element bị reassemble (hot reload)

**Nguyên tắc vàng**: `build()` phải là **pure function** — chỉ đọc state và trả về widget tree. Tuyệt đối không có side effect:

```dart
@override
Widget build(BuildContext context) {
  // ❌ KHÔNG gọi setState trong build
  setState(() => _count++); // Infinite loop!
  
  // ❌ KHÔNG thực hiện IO/network call
  fetchData(); // Gọi lại mỗi frame!
  
  // ❌ KHÔNG tạo stream subscription
  myStream.listen(...); // Memory leak!
  
  // ✅ CHỈ đọc state và return widget
  return Text('$_count');
}
```

Framework có thể gọi `build()` **60 lần/giây** trong trường hợp animation. Bất kỳ side effect nào cũng bị nhân lên hàng chục lần.

`build()` nhận `BuildContext context` — đây chính là element. Tại thời điểm build, context đã hoàn chỉnh, có thể dùng `of(context)` cho mọi InheritedWidget. Tuy nhiên, render tree **chưa** được layout — `context.size` vẫn chưa có giá trị mới nhất (phải đợi đến sau layout phase).

### 3.5 — didUpdateWidget()

```dart
@override
void didUpdateWidget(covariant MyWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  // So sánh config cũ và mới
  if (widget.url != oldWidget.url) {
    // URL thay đổi → cần fetch data mới
    _fetchData(widget.url);
  }
  
  if (widget.duration != oldWidget.duration) {
    // Cập nhật animation controller
    _controller.duration = widget.duration;
  }
  
  if (widget.itemCount != oldWidget.itemCount) {
    // TabController không hỗ trợ thay đổi length
    // → phải tạo mới
    _tabController.dispose();
    _tabController = TabController(
      length: widget.itemCount,
      vsync: this,
    );
  }
}
```

Được gọi khi **parent rebuild** và tạo widget mới cùng `runtimeType` và `key` với widget cũ. Framework quyết định **giữ nguyên State** nhưng cập nhật widget reference.

Quy trình bên trong:

```
Parent gọi setState()
    │
    ▼
Parent.build() tạo widget mới: MyWidget(url: 'new_url')
    │
    ▼
Framework so sánh: canUpdate(oldWidget, newWidget)?
    │  → cùng runtimeType? ✓
    │  → cùng key? ✓ (hoặc cả hai null)
    │
    ▼
Element giữ nguyên, cập nhật widget reference
    │  state._widget = newWidget
    │
    ▼
Gọi state.didUpdateWidget(oldWidget)
    │
    ▼
Framework tự động mark dirty → build() sẽ được gọi
```

**Không cần gọi `setState()` bên trong `didUpdateWidget`** vì framework đã tự mark dirty. Gọi `setState` vẫn an toàn nhưng thừa.

`oldWidget` là tham số truyền vào — widget **trước khi** cập nhật. `widget` (property của State) đã là widget **mới** tại thời điểm `didUpdateWidget` được gọi. So sánh hai cái để biết gì đã thay đổi.

Use case phổ biến nhất: khi controller hoặc subscription phụ thuộc vào widget property. Ví dụ nếu `widget.streamSource` thay đổi, cần cancel subscription cũ và subscribe mới.

### 3.6 — setState()

```dart
void _onButtonPressed() {
  setState(() {
    _count++;
    _label = 'Count: $_count';
  });
}
```

Đây không phải lifecycle method mà là method **do developer gọi** để báo framework rằng state đã thay đổi. Bên trong, `setState()` thực hiện:

```dart
// Simplified internal implementation
void setState(VoidCallback fn) {
  assert(() {
    if (_debugLifecycleState == _StateLifecycle.defunct) {
      throw FlutterError('setState() called after dispose()');
    }
    if (_debugLifecycleState == _StateLifecycle.created && !mounted) {
      throw FlutterError('setState() called in constructor');
    }
    return true;
  }());
  
  final Object? result = fn(); // Chạy callback đồng bộ
  assert(() {
    if (result is Future) {
      throw FlutterError('setState() callback returned a Future');
    }
    return true;
  }());
  
  _element!.markNeedsBuild(); // Mark element dirty
}
```

Điểm quan trọng: `setState()` **không** trigger rebuild ngay lập tức. Nó chỉ mark element dirty. Framework gom tất cả dirty element và rebuild trong **frame tiếp theo**. Nghĩa là nếu gọi `setState()` 10 lần liên tiếp trong cùng một synchronous block, widget chỉ rebuild **1 lần**:

```dart
void _onDataReceived() {
  setState(() => _a = 1);
  setState(() => _b = 2);
  setState(() => _c = 3);
  // Widget chỉ rebuild 1 lần, không phải 3 lần
  // Vì cả 3 đều xảy ra trước frame tiếp theo
}
```

Callback truyền vào `setState()` phải là **synchronous**. Trả về Future sẽ gây assertion error trong debug mode:

```dart
// ❌ WRONG
setState(() async {
  _data = await fetchData(); // Assertion error!
});

// ✅ CORRECT
final data = await fetchData();
if (mounted) {
  setState(() {
    _data = data;
  });
}
```

Thực ra việc thay đổi state bên ngoài `setState()` callback cũng hoạt động — callback chỉ là convention để code rõ ràng hơn. Hai cách viết dưới đây tương đương về mặt kỹ thuật:

```dart
// Cách 1: Thay đổi trong callback
setState(() {
  _count++;
});

// Cách 2: Thay đổi trước, gọi setState rỗng
_count++;
setState(() {});

// Cả hai đều: thay đổi state → markNeedsBuild
// Nhưng cách 1 ĐƯỢC KHUYẾN KHÍCH vì ý đồ rõ ràng
```

### 3.7 — deactivate()

```dart
@override
void deactivate() {
  // State bị tách khỏi tree
  // Nhưng CÓ THỂ được reinsert trong cùng frame
  
  // Ví dụ: huỷ đăng ký khỏi ancestor notification
  super.deactivate();
}
```

Được gọi khi element bị **remove khỏi tree**. Có hai kịch bản:

**Kịch bản 1 — Vĩnh viễn**: Widget bị remove và không quay lại. `deactivate()` được gọi, sau đó `dispose()` được gọi cuối frame.

**Kịch bản 2 — Tạm thời (GlobalKey move)**: Khi một widget có `GlobalKey` được move từ vị trí A sang vị trí B trong cùng một frame. Framework remove element ở A (gọi `deactivate`), rồi insert lại ở B (gọi `activate`). State được **giữ nguyên hoàn toàn**.

```dart
// Frame N: widget ở subtree A
Column(
  children: [
    SubtreeA(child: MyWidget(key: myGlobalKey)),  // ← ở đây
    SubtreeB(),
  ],
)

// Frame N+1: widget move sang subtree B
Column(
  children: [
    SubtreeA(),
    SubtreeB(child: MyWidget(key: myGlobalKey)),  // ← giờ ở đây
  ],
)

// Sequence: deactivate() → activate() → didUpdateWidget() → build()
// State object GIỐNG NHAU, không bị tạo mới
```

Tại thời điểm `deactivate()`, `context` vẫn hợp lệ nhưng widget có thể đã không còn trong tree. Không nên dựa vào ancestor lookup ở đây.

Trong thực tế, rất ít khi cần override `deactivate()`. Hầu hết cleanup nên đặt trong `dispose()`.

### 3.8 — activate()

```dart
@override
void activate() {
  super.activate();
  // State được reinsert vào tree (sau deactivate)
  // Chỉ xảy ra với GlobalKey move
}
```

Được gọi khi element bị deactivate trước đó được **reinsert** vào tree. Chỉ xảy ra trong kịch bản GlobalKey move. Rất hiếm khi cần override.

### 3.9 — dispose()

```dart
@override
void dispose() {
  // Giải phóng TẤT CẢ resources
  _animationController.dispose();
  _scrollController.dispose();
  _textEditingController.dispose();
  _focusNode.dispose();
  _tabController.dispose();
  _subscription.cancel();
  _timer?.cancel();

  super.dispose(); // BẮT BUỘC gọi CUỐI CÙNG
}
```

Gọi **đúng một lần** khi State bị remove **vĩnh viễn** khỏi tree. Sau `dispose()`:

- `mounted` trở thành `false`
- Gọi `setState()` sẽ throw error
- `context` không còn hợp lệ
- State object trở thành **defunct** — không bao giờ được dùng lại

`super.dispose()` phải gọi **cuối cùng** (ngược với `super.initState()` gọi đầu tiên). Lý do: base class `dispose()` thực hiện assertion và cleanup nội bộ, sau đó State được đánh dấu defunct. Nếu gọi `super.dispose()` trước rồi mới dispose controller, controller.dispose() có thể gặp vấn đề vì state đã defunct.

**Checklist dispose — mọi thứ tạo trong initState phải có counterpart trong dispose**:

```
initState                    →    dispose
─────────────────────────────────────────────
AnimationController(...)     →    .dispose()
ScrollController()           →    .dispose()
TextEditingController()      →    .dispose()
FocusNode()                  →    .dispose()
TabController(...)           →    .dispose()
stream.listen(...)           →    subscription.cancel()
Timer.periodic(...)          →    timer.cancel()
WidgetsBinding.addObserver   →    WidgetsBinding.removeObserver
```

### 3.10 — reassemble()

```dart
@override
void reassemble() {
  super.reassemble();
  // Chỉ được gọi trong DEVELOPMENT (hot reload)
  // Không bao giờ gọi trong release build
}
```

Đây là method đặc biệt chỉ dành cho development. Framework gọi khi **hot reload** xảy ra. Mục đích là cho phép State reinitialize lại những gì cần thiết khi code thay đổi. Trong production, method này không tồn tại trong call flow.

---

## 4. Bổ sung: WidgetsBindingObserver — App Lifecycle

Ngoài widget lifecycle, State có thể observe **app-level lifecycle** bằng cách mixin `WidgetsBindingObserver`:

```dart
class _MyState extends State<MyWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        // App mất focus (ví dụ: incoming call overlay)
        break;
      case AppLifecycleState.paused:
        // App hoàn toàn ở background
        _pauseVideo();
        break;
      case AppLifecycleState.resumed:
        // App quay lại foreground
        _resumeVideo();
        _refreshData();
        break;
      case AppLifecycleState.detached:
        // App sắp bị kill
        break;
      case AppLifecycleState.hidden:
        // App bị ẩn (transitioning)
        break;
    }
  }

  @override
  void didChangeMetrics() {
    // Screen size thay đổi (rotate, keyboard show/hide)
  }

  @override
  void didChangePlatformBrightness() {
    // System theme thay đổi (light ↔ dark)
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // System language thay đổi
  }

  @override
  Future<bool> didPopRoute() async {
    // System back button pressed (Android)
    return false; // false = để framework xử lý mặc định
  }
}
```

---

## 5. Tình huống thực tế — Thứ tự gọi lifecycle

### Tình huống 1: Widget mount lần đầu

```
createState()
initState()
didChangeDependencies()
build()
```

### Tình huống 2: setState() được gọi

```
build()    ← chỉ build, không có lifecycle method nào khác
```

### Tình huống 3: Parent rebuild, truyền props mới

```
didUpdateWidget(oldWidget)
build()
```

### Tình huống 4: InheritedWidget (Theme, MediaQuery...) thay đổi

```
didChangeDependencies()
build()
```

### Tình huống 5: Widget bị remove khỏi tree

```
deactivate()
dispose()
```

### Tình huống 6: GlobalKey move widget sang vị trí khác

```
deactivate()     ← remove khỏi vị trí cũ
activate()       ← insert vào vị trí mới
didUpdateWidget() ← có thể được gọi nếu widget config thay đổi
build()
```

### Tình huống 7: Hot reload (development only)

```
reassemble()
didUpdateWidget()   ← vì widget object mới được tạo
build()
```

### Tình huống 8: Navigate tới screen mới rồi pop về

```
── Push screen B lên trên A ──
Không có lifecycle nào trên A! A vẫn mounted, chỉ bị obscured.

── Pop screen B, quay lại A ──
Không có lifecycle nào trên A! A vẫn trong tree, chỉ lại được visible.

→ Nếu cần biết khi screen "quay lại", dùng:
   - RouteAware mixin
   - Navigator.push().then((result) => ...)
   - hoặc WidgetsBindingObserver cho app-level
```

Đây là điểm thường gây nhầm lẫn: **push/pop Navigator không trigger bất kỳ State lifecycle method nào** trên screen bên dưới. Screen A vẫn mounted hoàn toàn, chỉ là bị screen B che phủ. Nếu cần react khi user quay lại, phải dùng cơ chế riêng:

```dart
// Cách 1: Dùng return value từ Navigator
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => ScreenB()),
);
// Code ở đây chạy khi ScreenB pop
_refreshData(result);

// Cách 2: Dùng RouteAware
class _MyState extends State<MyScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Screen phía trên vừa pop → screen này lại visible
    _refreshData();
  }

  @override
  void didPushNext() {
    // Screen mới vừa push lên trên → screen này bị obscured
    _pauseExpensiveWork();
  }
}
```

---

## 6. Quy tắc vàng cho Senior

**Mỗi lifecycle method có đúng một mục đích**:

```
createState()           → Chỉ tạo State instance, không có logic
initState()             → One-time setup: controllers, subscriptions, initial state
didChangeDependencies() → React khi InheritedWidget dependency thay đổi
build()                 → Pure function: đọc state → return widget tree
didUpdateWidget()       → React khi parent truyền props mới
deactivate()            → Hiếm dùng, chỉ cho GlobalKey scenarios
dispose()               → Giải phóng MỌI resource đã tạo
```

**Nguyên tắc symmetry**: mọi thứ khởi tạo trong `initState` phải được dọn dẹp trong `dispose`. Mọi thứ subscribe trong `didChangeDependencies` phải được unsubscribe khi thay đổi hoặc dispose. Vi phạm nguyên tắc này là nguồn gốc phổ biến nhất của memory leak trong Flutter app.
