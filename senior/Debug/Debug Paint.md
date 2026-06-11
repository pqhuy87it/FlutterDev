## Debug Paint trong Flutter — Hướng dẫn chi tiết

### 1. Debug Paint là gì

Debug Paint là tính năng hiển thị trực quan các đường viền, padding, margin, alignment và các thông tin layout trực tiếp lên giao diện app đang chạy. Giúp bạn nhìn thấy chính xác mỗi widget chiếm bao nhiêu không gian, padding ở đâu, overflow xảy ra chỗ nào.

---

### 2. Các cách bật Debug Paint

#### Cách 1: Từ Android Studio

```
1. Chạy app debug mode
2. View → Tool Windows → Flutter Inspector
3. Trên toolbar Inspector, click biểu tượng "Toggle Debug Paint"
   (biểu tượng hình ô vuông có đường gạch chéo)
```

#### Cách 2: Từ VS Code

```
1. Chạy app debug mode
2. Cmd+Shift+P → "Dart: Toggle Debug Painting"
```

#### Cách 3: Từ code

```dart
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = true;
  runApp(const MyApp());
}
```

#### Cách 4: Từ DevTools browser

```
1. Mở Flutter DevTools
2. Tab Flutter Inspector
3. Click biểu tượng "Toggle Debug Paint" trên toolbar
```

#### Cách 5: Từ terminal đang chạy flutter run

```
# Khi app đang chạy, gõ phím 'p' trong terminal
# → Toggle debug paint ON/OFF
```

---

### 3. Đọc hiểu Debug Paint overlay

Khi bật `debugPaintSizeEnabled = true`, mỗi RenderObject hiển thị visual overlay:

#### 3.1 Đường viền xanh dương (Cyan border)

Viền bao quanh mỗi RenderBox, cho thấy kích thước thực tế của widget:

```
┌─────────────────────────────────┐  ← cyan border = kích thước RenderBox
│                                 │
│         Widget content          │
│                                 │
└─────────────────────────────────┘

// Ví dụ: Container(width: 200, height: 100)
// → Hiện hình chữ nhật viền cyan 200x100
```

#### 3.2 Mũi tên hai chiều (Dark cyan arrows)

Hiển thị bên trong mỗi box, chỉ hướng mà widget có thể mở rộng:

```
┌──────────────────────────────┐
│        ←───────────→         │  ← mũi tên ngang: widget expand theo chiều ngang
│             ↕                │  ← mũi tên dọc: widget expand theo chiều dọc
└──────────────────────────────┘

// Container không giới hạn size → mũi tên cả 2 chiều
// Container(width: 100) → chỉ có mũi tên dọc (ngang đã fix)
// SizedBox(width: 50, height: 50) → không có mũi tên (fix cả 2 chiều)
```

#### 3.3 Vùng tô xanh nhạt (Light blue area)

Hiển thị **padding** bên trong widget:

```
┌──────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │  ← padding top (xanh nhạt)
│ ░░ ┌──────────────────────────┐ ░░░ │
│ ░░ │                          │ ░░░ │  ← padding left/right
│ ░░ │      Content area        │ ░░░ │
│ ░░ │                          │ ░░░ │
│ ░░ └──────────────────────────┘ ░░░ │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │  ← padding bottom
└──────────────────────────────────────┘

// Padding(padding: EdgeInsets.all(16))
// → 4 vùng xanh nhạt rộng 16px quanh content
```

#### 3.4 Đường gạch vàng/cam (Yellow/orange dashed lines)

Hiển thị **margin** hoặc khoảng trống giữa các widget trong Flex (Row/Column):

```
┌─ Column ─────────────────────────────┐
│  ┌─ child 0 ──────────────────────┐  │
│  │          Widget A              │  │
│  └────────────────────────────────┘  │
│  ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌  │  ← dashed line = spacing
│  ┌─ child 1 ──────────────────────┐  │
│  │          Widget B              │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

#### 3.5 Đường chéo (Diagonal hatching)

Hiển thị vùng trống không có widget nào chiếm:

```
┌─ Row ─────────────────────────────────────┐
│ ┌─ Text ──┐  ╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱  │
│ │ "Hello" │  ╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲  │  ← vùng trống (hatching)
│ └─────────┘  ╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱  │
└───────────────────────────────────────────┘

// Row có 1 child Text nhỏ → phần còn lại hiển thị hatching
```

---

### 4. Các Debug Flag chi tiết

#### 4.1 `debugPaintSizeEnabled` — Kích thước và layout

```dart
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = true;
  runApp(const MyApp());
}
```

Hiển thị: viền cyan, mũi tên hướng expand, padding area, free space hatching. Đây là flag phổ biến nhất, dùng để debug layout chung.

**Ví dụ thực tế — debug overflow:**

```dart
// Trước khi bật Debug Paint, app hiện "RenderFlex overflowed by 24 pixels"
// Bật debugPaintSizeEnabled → nhìn thấy:

Row(
  children: [
    // Debug Paint cho thấy: ảnh chiếm 80px + text dài 340px = 420px
    // Nhưng Row chỉ rộng 390px → overflow 30px
    Image.network(logoUrl, width: 80),     // ← viền cyan 80px
    Text('dポイント交換サービス very long'),    // ← viền cyan 340px, TRÀN!
  ],
)

// Fix: wrap Text trong Expanded hoặc Flexible
Row(
  children: [
    Image.network(logoUrl, width: 80),
    Expanded(child: Text('dポイント交換サービス very long')),
  ],
)
```

#### 4.2 `debugPaintBaselinesEnabled` — Baseline text

```dart
debugPaintBaselinesEnabled = true;
```

Hiển thị đường baseline của text:

```
         alphabetic baseline (xanh lá)
              ↓
──────────────────────────── green line
    dポイント   100pt
──────────────────────────── yellow line
              ↑
         ideographic baseline (vàng)
```

**Khi nào dùng:** Debug text alignment trong Row, đặc biệt khi trộn font size khác nhau hoặc trộn tiếng Nhật với số:

```dart
// Text không thẳng hàng nhau
Row(
  crossAxisAlignment: CrossAxisAlignment.baseline,
  textBaseline: TextBaseline.alphabetic,
  children: [
    Text('dポイント', style: TextStyle(fontSize: 16)),
    Text('100', style: TextStyle(fontSize: 24)),
    Text('pt', style: TextStyle(fontSize: 12)),
  ],
)
// Bật debugPaintBaselinesEnabled → thấy baseline có thẳng hàng không
```

#### 4.3 `debugPaintPointersEnabled` — Vùng chạm

```dart
debugPaintPointersEnabled = true;
```

Khi tap vào app, hiển thị vùng tô màu xanh nhạt tại nơi touch event xảy ra:

```
                    ┌─────────┐
                    │ ████████│  ← vùng touch highlight
                    │ ████████│    khi user tap
                    └─────────┘
```

**Khi nào dùng:** Debug button không nhận touch. Có thể do widget khác đè lên phía trên (Stack), hoặc GestureDetector bị conflict, hoặc `HitTestBehavior` sai.

```dart
// Tap vào nút exchange nhưng không có phản hồi
// Bật debugPaintPointersEnabled → tap → không thấy highlight trên nút
// → Có widget trong suốt đè lên phía trên

Stack(
  children: [
    ExchangeButton(),           // nút bị che
    Positioned.fill(
      child: Container(         // ← container trong suốt nhưng nhận touch
        color: Colors.transparent, // hấp thụ touch event
      ),
    ),
  ],
)

// Fix: thêm IgnorePointer
Stack(
  children: [
    ExchangeButton(),
    Positioned.fill(
      child: IgnorePointer(     // ← bỏ qua touch, truyền xuống dưới
        child: Container(),
      ),
    ),
  ],
)
```

#### 4.4 `debugPaintLayerBordersEnabled` — Layer boundaries

```dart
debugPaintLayerBordersEnabled = true;
```

Hiển thị viền cam quanh mỗi compositing layer:

```
┌─ Layer 0 (root) ─────────────────────────┐
│  ┌─ Layer 1 (RepaintBoundary) ────────┐  │  ← viền cam
│  │                                    │  │
│  │  ListView content                  │  │
│  │                                    │  │
│  └────────────────────────────────────┘  │
│  ┌─ Layer 2 (RepaintBoundary) ────────┐  │  ← viền cam
│  │  AnimatedWidget                    │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
```

**Khi nào dùng:** Kiểm tra RepaintBoundary có thực sự tạo layer riêng không. Kết hợp với `debugRepaintRainbowEnabled` để tối ưu paint performance.

#### 4.5 `debugRepaintRainbowEnabled` — Rainbow repaint

```dart
debugRepaintRainbowEnabled = true;
```

Mỗi lần RenderObject repaint, viền đổi sang màu khác trong cầu vồng (đỏ → cam → vàng → lục → lam → chàm → tím → đỏ...). Viền đổi màu liên tục = repaint liên tục.

```
Frame 1: ┌─ đỏ ──────────────────────┐
Frame 2: ┌─ cam ──────────────────────┐
Frame 3: ┌─ vàng ─────────────────────┐
Frame 4: ┌─ lục ──────────────────────┐
...

// Widget tĩnh: viền giữ nguyên màu (không repaint)
// Widget animation: viền đổi màu liên tục (repaint mỗi frame)
// Vùng LỚN đổi màu liên tục → cần thêm RepaintBoundary
```

**Thực hành với point exchange screen:**

```dart
// Bật rainbow
debugRepaintRainbowEnabled = true;

// Quan sát:
// 1. Scroll danh sách → viền ListView đổi màu (bình thường)
// 2. Nhưng Header phía trên CŨNG đổi màu → repaint thừa!
// 3. Fix:
Scaffold(
  appBar: AppBar(title: Text('ポイント交換')),  // repaint thừa
  body: RepaintBoundary(                       // ← thêm boundary
    child: ListView.builder(
      itemBuilder: (context, index) {
        return PointExchangeCard(model: exchanges[index]);
      },
    ),
  ),
)
// Sau fix: scroll → chỉ ListView đổi màu, AppBar giữ nguyên
```

#### 4.6 `debugCheckElevationsEnabled` — Material elevation

```dart
debugCheckElevationsEnabled = true;
```

Highlight vùng mà Material widgets có elevation chồng lên nhau không đúng:

```
// Card(elevation: 2) nằm trong Card(elevation: 4)
// → Viền đỏ cảnh báo child elevation < parent elevation
// Material Design spec: child nên có elevation >= parent
```

---

### 5. Bật nhiều flag cùng lúc

```dart
import 'package:flutter/rendering.dart';

void main() {
  // Bật theo nhu cầu, không nên bật tất cả cùng lúc vì rối mắt
  
  // Combo 1: Debug layout
  debugPaintSizeEnabled = true;
  debugPaintBaselinesEnabled = true;
  
  // Combo 2: Debug performance  
  debugRepaintRainbowEnabled = true;
  debugPaintLayerBordersEnabled = true;
  
  // Combo 3: Debug touch
  debugPaintPointersEnabled = true;
  
  runApp(const MyApp());
}
```

Hoặc dùng helper class để toggle dễ hơn:

```dart
class DebugPaintConfig {
  static void enableLayoutDebug() {
    debugPaintSizeEnabled = true;
    debugPaintBaselinesEnabled = true;
  }
  
  static void enablePaintDebug() {
    debugRepaintRainbowEnabled = true;
    debugPaintLayerBordersEnabled = true;
  }
  
  static void enableTouchDebug() {
    debugPaintPointersEnabled = true;
  }
  
  static void disableAll() {
    debugPaintSizeEnabled = false;
    debugPaintBaselinesEnabled = false;
    debugRepaintRainbowEnabled = false;
    debugPaintLayerBordersEnabled = false;
    debugPaintPointersEnabled = false;
  }
}

// Trong main.dart
void main() {
  DebugPaintConfig.enableLayoutDebug();
  runApp(const MyApp());
}
```

---

### 6. Debug Paint trong thực tế — Các scenario phổ biến

#### Scenario 1: Widget bị overflow nhưng không biết widget nào

```dart
// Error: "A RenderFlex overflowed by 42 pixels on the right"

// Bước 1: Bật debugPaintSizeEnabled = true
// Bước 2: Tìm widget có viền cyan VƯỢT ra ngoài parent

// Quan sát:
// ┌─ Row (390px) ─────────────────────────────────────────┐
// │ ┌─ Image(80px)─┐ ┌─ Text(352px) ───────────────────────┐  ← text VƯỢT!
// │ └──────────────┘ └─────────────────────────────────────┘
// └───────────────────────────────────────────────────────┘

// → Text chiếm 352px, Image 80px, tổng 432px > Row 390px
// Fix:
Row(
  children: [
    Image.network(url, width: 80),
    Expanded(                          // ← co text lại
      child: Text(
        'dポイント交換サービス',
        overflow: TextOverflow.ellipsis, // ← cắt text nếu dài
      ),
    ),
  ],
)
```

#### Scenario 2: Padding không đều, UI lệch

```dart
// Bật debugPaintSizeEnabled → thấy padding area (vùng xanh nhạt)

// Quan sát:
// ┌─ Card ──────────────────────────────────────────┐
// │ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   │  16px top
// │ ░░ ┌─ Content ──────────────────────────┐ ░░░░  │
// │ ░░ │                                    │ ░░░░  │  16px left, 24px right ← KHÔNG ĐỀU!
// │ ░░ └────────────────────────────────────┘ ░░░░  │
// │ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   │  16px bottom
// └─────────────────────────────────────────────────┘

// → Phát hiện padding right = 24px thay vì 16px
// Kiểm tra code:
Padding(
  padding: EdgeInsets.fromLTRB(16, 16, 24, 16), // ← right = 24, sai!
  child: content,
)
// Fix:
Padding(
  padding: EdgeInsets.all(16),
  child: content,
)
```

#### Scenario 3: ListView item có khoảng trống thừa

```dart
// Bật debugPaintSizeEnabled → scroll danh sách point exchange

// Quan sát mỗi item:
// ┌─ ListTile ──────────────────────────────────────┐
// │ ┌─ Row ──────────────────────────────────────┐  │
// │ │ ┌─ Image ─┐  ┌─ Column ─────────────────┐ │  │
// │ │ │  logo   │  │  "dポイント"               │ │  │
// │ │ │         │  │  "100pt = 1pt"            │ │  │
// │ │ └─────────┘  └──────────────────────────┘ │  │
// │ └────────────────────────────────────────────┘  │
// │ ╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱  │  ← hatching = vùng trống
// │ ╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲  │    item có chiều cao thừa
// └─────────────────────────────────────────────────┘

// → Item có khoảng trống phía dưới do SizedBox hoặc Container có height cố định
// Kiểm tra code:
Container(
  height: 120, // ← fix height quá lớn
  child: Row(...),
)
// Fix: bỏ height cố định, để content tự quyết định
Container(
  child: Row(...),
)
```

#### Scenario 4: RepaintBoundary có hiệu quả không

```dart
// Bước 1: Bật debugRepaintRainbowEnabled = true
// Bước 2: Bật debugPaintLayerBordersEnabled = true

// Quan sát khi scroll:
// ┌─ Layer 0 (cam border) ─────────────────────────┐
// │  AppBar: viền giữ nguyên màu ✅ (không repaint)│
// │  ┌─ Layer 1 (cam border) ───────────────────┐  │
// │  │  ListView: viền đổi màu liên tục         │  │  ← RepaintBoundary hoạt động
// │  │  (repaint khi scroll — bình thường)      │  │
// │  └──────────────────────────────────────────┘  │
// │  BottomNav: viền giữ nguyên màu ✅             │
// └────────────────────────────────────────────────┘

// Nếu KHÔNG có RepaintBoundary:
// ┌─ Layer 0 (cam border) ────────────────────────┐
// │  AppBar: viền ĐỔI MÀU ❌ (repaint thừa)       │
// │  ListView: viền đổi màu (bình thường)         │
// │  BottomNav: viền ĐỔI MÀU ❌ (repaint thừa)    │
// └───────────────────────────────────────────────┘
```

#### Scenario 5: Text baseline lệch trong Row

```dart
// Bật debugPaintBaselinesEnabled = true

// Quan sát exchange rate display:
// ─────── green (alphabetic baseline) ────────
//     1000   →   100  pt
// ─────── yellow (ideographic baseline) ──────

// Nếu baseline không thẳng hàng:
//                    ─── green ───
//     1000   →         100  pt
//              ─── green ───

// → crossAxisAlignment chưa đúng:
Row(
  crossAxisAlignment: CrossAxisAlignment.center, // ← baseline lệch
  children: [
    Text('1000', style: TextStyle(fontSize: 24)),
    Text(' → ', style: TextStyle(fontSize: 16)),
    Text('100', style: TextStyle(fontSize: 24)),
    Text(' pt', style: TextStyle(fontSize: 12)),
  ],
)

// Fix:
Row(
  crossAxisAlignment: CrossAxisAlignment.baseline,
  textBaseline: TextBaseline.alphabetic,
  children: [
    Text('1000', style: TextStyle(fontSize: 24)),
    Text(' → ', style: TextStyle(fontSize: 16)),
    Text('100', style: TextStyle(fontSize: 24)),
    Text(' pt', style: TextStyle(fontSize: 12)),
  ],
)
```

#### Scenario 6: Touch target quá nhỏ

```dart
// Bật debugPaintPointersEnabled = true
// Tap vào nút nhỏ → thấy touch highlight nhưng button không phản hồi

// Quan sát: touch point nằm NGOÀI viền cyan của button
// → Button quá nhỏ, user tap trúng padding area bên ngoài

// Material guideline: touch target tối thiểu 48x48
// Kiểm tra:
IconButton(
  icon: Icon(Icons.favorite, size: 16),  // ← icon nhỏ
  onPressed: () {},
  // IconButton mặc định có constraints 48x48 → OK
)

// Nhưng nếu custom button:
GestureDetector(
  onTap: () {},
  child: Icon(Icons.favorite, size: 16), // ← touch target chỉ 16x16!
)

// Fix:
GestureDetector(
  onTap: () {},
  child: SizedBox(
    width: 48,
    height: 48,
    child: Center(
      child: Icon(Icons.favorite, size: 16),
    ),
  ),
)
```

---

### 7. Debug Paint với DevTools Layout Explorer

Kết hợp Debug Paint với Layout Explorer cho hiệu quả cao nhất:

```
Bước 1: Bật debugPaintSizeEnabled → nhìn tổng quan layout trên app
Bước 2: Thấy widget nào lạ → dùng Select Widget Mode trong DevTools
        → tap vào widget đó trên app
Bước 3: DevTools hiển thị widget trong tree
        → click vào parent Flex widget
Bước 4: Layout Explorer hiện lên → thấy chi tiết flex factor,
        alignment, constraints
Bước 5: Thay đổi trực tiếp trong Layout Explorer → app cập nhật realtime
Bước 6: Tìm được config đúng → cập nhật vào code
```

---

### 8. Lưu ý quan trọng

**Debug Paint chỉ hoạt động ở debug mode.** Tất cả các flag `debug*` bị strip khỏi release build nên không ảnh hưởng performance production.

**Không nên bật nhiều flag cùng lúc** vì overlay chồng lên nhau rất khó đọc. Bật từng flag theo vấn đề đang debug.

**Debug Paint thay đổi visual nhưng KHÔNG thay đổi layout.** Overlay được vẽ thêm lên trên, không ảnh hưởng kích thước hay vị trí widget.

**Khi toggle từ DevTools hoặc terminal (phím 'p'), app tự hot reload.** Không cần restart. Nhưng khi set trong code (`debugPaintSizeEnabled = true`), cần hot restart vì flag được đọc lúc khởi tạo rendering pipeline.
