# CustomPainter & Canvas API — Deep Dive cho Senior Flutter Developer

CustomPainter là nơi bạn **vẽ trực tiếp lên Canvas** — bypass hoàn toàn widget tree cho phần visual. Đây là công cụ để xây chart, custom shape, particle effect, waveform, signature pad... những thứ mà compose widget không thể hoặc không nên làm.

---

## 1. Rendering Pipeline — CustomPainter nằm ở đâu

Nhắc lại pipeline:

```
Widget Tree → Element Tree → RenderObject Tree
                                    │
                              performLayout()  ← tính size + position
                                    │
                                 paint()       ← vẽ lên canvas
                                    │
                               compositing     ← ghép layers → GPU
```

Khi bạn dùng `CustomPaint` widget, Flutter tạo `RenderCustomPaint` — một RenderObject mà trong method `paint()` nó gọi `CustomPainter.paint()` của bạn. Tức là bạn đang **hook trực tiếp vào paint phase** của rendering pipeline.

Điều này có nghĩa: CustomPainter **không tham gia layout**. Nó không tự quyết size — size do parent constraint hoặc `CustomPaint(size: ...)` quyết định. Nó chỉ nhận một Canvas với size đã biết và vẽ lên đó.

---

## 2. Anatomy của CustomPainter

```dart
class ChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final double animationProgress; // 0.0 → 1.0

  ChartPainter({
    required this.dataPoints,
    required this.lineColor,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // size = kích thước vùng vẽ, do parent quyết
    // canvas = "tấm vải" để vẽ lên
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    // Flutter gọi hàm này để hỏi: "có cần vẽ lại không?"
    return oldDelegate.dataPoints != dataPoints
        || oldDelegate.lineColor != lineColor
        || oldDelegate.animationProgress != animationProgress;
  }
}
```

Sử dụng:

```dart
CustomPaint(
  size: const Size(double.infinity, 200),
  painter: ChartPainter(
    dataPoints: data,
    lineColor: Colors.blue,
    animationProgress: _controller.value,
  ),
)
```

---

## 3. Canvas API — Bộ công cụ vẽ

Canvas cung cấp primitive drawing operations. Mọi thứ bạn thấy trên màn hình Flutter cuối cùng đều được vẽ bằng những operation này (qua Skia/Impeller engine).

### Paint object — "cọ vẽ"

```dart
final paint = Paint()
  ..color = Colors.blue
  ..strokeWidth = 2.0
  ..style = PaintingStyle.stroke  // stroke = viền, fill = tô đặc
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..isAntiAlias = true;           // khử răng cưa, mặc định true
```

`Paint` là object nặng — senior developer tạo một lần và reuse, không tạo mới trong mỗi lần `paint()` nếu config không đổi. Tuy nhiên, tạo `Paint` trong `paint()` method vẫn acceptable vì Dart GC handle lightweight objects tốt — đừng premature optimize chỗ này trừ khi profiler chỉ ra vấn đề.

### Các primitive cơ bản

```dart
@override
void paint(Canvas canvas, Size size) {
  final paint = Paint()..color = Colors.blue;

  // === HÌNH HỌC CƠ BẢN ===

  // Đường thẳng
  canvas.drawLine(
    const Offset(0, 0),
    Offset(size.width, size.height),
    paint,
  );

  // Hình chữ nhật
  canvas.drawRect(
    Rect.fromLTWH(10, 10, 100, 60),
    paint,
  );

  // Hình chữ nhật bo góc
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 10, 100, 60),
      const Radius.circular(12),
    ),
    paint,
  );

  // Hình tròn
  canvas.drawCircle(
    Offset(size.width / 2, size.height / 2), // center
    50,                                        // radius
    paint,
  );

  // Arc (cung tròn) — dùng cho pie chart, progress indicator
  canvas.drawArc(
    Rect.fromCircle(center: const Offset(100, 100), radius: 80),
    -pi / 2,       // startAngle (12 giờ)
    pi * 1.5,      // sweepAngle (270°)
    false,          // useCenter: true = hình quạt, false = cung
    paint..style = PaintingStyle.stroke..strokeWidth = 8,
  );
}
```

### Path — Vẽ hình dạng tùy ý

Path là công cụ mạnh nhất — cho phép vẽ bất kỳ shape nào:

```dart
@override
void paint(Canvas canvas, Size size) {
  final path = Path();
  final paint = Paint()
    ..color = Colors.blue.withValues(alpha: 0.3)
    ..style = PaintingStyle.fill;

  // Di chuyển "bút" tới điểm bắt đầu
  path.moveTo(0, size.height * 0.6);

  // Vẽ curve mượt qua các điểm (Bézier bậc 3)
  path.cubicTo(
    size.width * 0.25, size.height * 0.2,  // control point 1
    size.width * 0.75, size.height * 0.9,  // control point 2
    size.width, size.height * 0.4,          // end point
  );

  // Đóng path về bottom-right → bottom-left → start
  path.lineTo(size.width, size.height);
  path.lineTo(0, size.height);
  path.close();

  canvas.drawPath(path, paint);
}
```

**Path operations** — combine nhiều shape:

```dart
final path1 = Path()..addOval(Rect.fromCircle(center: Offset(100, 100), radius: 60));
final path2 = Path()..addOval(Rect.fromCircle(center: Offset(150, 100), radius: 60));

// Các phép toán hình học
final union = Path.combine(PathOperation.union, path1, path2);
final intersect = Path.combine(PathOperation.intersect, path1, path2);
final difference = Path.combine(PathOperation.difference, path1, path2);
final xor = Path.combine(PathOperation.xor, path1, path2);

canvas.drawPath(union, paint);
```

Rất hữu ích cho custom shape phức tạp, vùng clip không quy tắc, hoặc venn diagram.

### Canvas transform

```dart
@override
void paint(Canvas canvas, Size size) {
  // Save trạng thái hiện tại
  canvas.save();

  // Dịch gốc tọa độ về center
  canvas.translate(size.width / 2, size.height / 2);

  // Xoay 45°
  canvas.rotate(pi / 4);

  // Scale
  canvas.scale(1.5, 1.0); // scale x 1.5, y giữ nguyên

  // Vẽ ở tọa độ đã transform
  canvas.drawRect(
    const Rect.fromLTWH(-25, -25, 50, 50),
    Paint()..color = Colors.red,
  );

  // Restore về trạng thái trước save
  canvas.restore();

  // Vẽ tiếp ở tọa độ gốc — không bị ảnh hưởng bởi transform trên
  canvas.drawCircle(Offset.zero, 10, Paint()..color = Colors.green);
}
```

`save()`/`restore()` hoạt động như stack — mỗi `save` push state, `restore` pop. Cực kỳ quan trọng khi vẽ nhiều element có transform riêng. Quên `restore()` là bug rất khó debug — mọi thứ vẽ sau đó bị transform sai.

### Clip — Cắt vùng vẽ

```dart
canvas.save();

// Chỉ cho phép vẽ trong vùng tròn này
canvas.clipRRect(
  RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, size.width, size.height),
    const Radius.circular(20),
  ),
);

// Mọi thứ vẽ sau đây bị crop theo vùng clip
canvas.drawImage(image, Offset.zero, Paint());

canvas.restore();
```

### Text trên Canvas

```dart
void _drawText(Canvas canvas, String text, Offset position) {
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(color: Colors.black, fontSize: 14),
    ),
    textDirection: TextDirection.ltr,
  );

  textPainter.layout(maxWidth: 200);
  textPainter.paint(canvas, position);
}
```

`TextPainter` phải gọi `layout()` trước `paint()` — nếu quên sẽ crash. Và sau khi `layout()`, bạn có `textPainter.width` và `textPainter.height` để căn chỉnh vị trí.

---

## 4. shouldRepaint — Hiểu đúng và sâu

Đây là method mà **phần lớn developer hiểu sai**, dẫn đến hoặc repaint thừa (laggy) hoặc thiếu (UI stale).

### Cơ chế hoạt động

```
Widget rebuild (setState, Provider change...)
    │
    ▼
CustomPaint widget tạo ChartPainter mới
    │
    ▼
Flutter gọi newPainter.shouldRepaint(oldPainter)
    │
    ├── return true  → gọi paint() lại
    └── return false → SKIP paint(), giữ kết quả cũ
```

Tức là `shouldRepaint` là **gate** quyết định có gọi `paint()` hay không. Nó được gọi mỗi khi widget rebuild tạo painter mới — không phải mỗi frame.

### Sai lầm phổ biến

```dart
// ❌ LUÔN return true — mọi rebuild đều repaint
// Nếu parent rebuild vì lý do không liên quan, painter vẫn vẽ lại vô ích
@override
bool shouldRepaint(covariant MyPainter oldDelegate) => true;

// ❌ LUÔN return false — không bao giờ update
// Khi data thay đổi, UI không cập nhật → bug visual
@override
bool shouldRepaint(covariant MyPainter oldDelegate) => false;
```

### Cách đúng — So sánh chính xác data đã thay đổi

```dart
class LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double strokeWidth;
  final double progress; // animation 0.0 → 1.0

  LineChartPainter({
    required this.values,
    required this.color,
    this.strokeWidth = 2.0,
    this.progress = 1.0,
  });

  @override
  bool shouldRepaint(covariant LineChartPainter old) {
    // So sánh từng field có ảnh hưởng đến visual output
    return old.color != color
        || old.strokeWidth != strokeWidth
        || old.progress != progress
        || !listEquals(old.values, values); // deep compare cho List
  }
  // ...
}
```

Lưu ý: `listEquals` từ `package:flutter/foundation.dart` — so sánh element-by-element. Nếu dùng `old.values != values` với List, nó chỉ compare reference (identity), không compare content → list mới với cùng data vẫn trigger repaint vô ích, hoặc cùng list object bị mutate thì lại **không** trigger repaint.

### shouldRepaint trong context animation

Khi dùng với `AnimationController`:

```dart
class _ChartState extends State<Chart> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: LineChartPainter(
            values: widget.data,
            color: Colors.blue,
            progress: _ctrl.value, // thay đổi mỗi frame (60fps)
          ),
        );
      },
    );
  }
}
```

`AnimatedBuilder` rebuild mỗi frame → tạo `LineChartPainter` mới mỗi frame → `shouldRepaint` được gọi mỗi frame. Vì `progress` thay đổi liên tục, `shouldRepaint` return `true` mỗi frame → `paint()` chạy mỗi frame. Đây là expected behavior cho animation.

Nhưng nếu animation chạy mà **data không đổi** (ví dụ: parent rebuild vì keyboard appear), `shouldRepaint` return `false` → skip paint → tiết kiệm GPU work. Đây là giá trị thực sự của `shouldRepaint` đúng.

---

## 5. RepaintBoundary — Isolate repaint area

Đây là **optimization quan trọng nhất** khi dùng CustomPainter, và là thứ senior developer phải master.

### Vấn đề: Repaint cascade

Flutter rendering có khái niệm **repaint boundary** (ranh giới repaint). Khi một RenderObject cần repaint, Flutter tìm **ancestor repaint boundary gần nhất** và repaint toàn bộ subtree từ boundary đó trở xuống.

Mặc định, ranh giới này khá xa — thường là `Scaffold` hoặc `Navigator`. Nghĩa là:

```
Scaffold (repaint boundary mặc định)
├── AppBar
├── Body
│   ├── Text("Hello")
│   ├── CustomPaint(WaveformPainter)  ← repaint mỗi frame (animation)
│   └── ListView (100 items)          ← BỊ REPAINT THEO vì cùng boundary!
└── BottomNavigationBar               ← BỊ REPAINT THEO!
```

Khi `WaveformPainter` cần repaint mỗi frame (animation), **toàn bộ Scaffold** repaint — bao gồm ListView 100 items, AppBar, BottomNav... tất cả đều vẽ lại dù không thay đổi gì. Đây là nguyên nhân phổ biến nhất gây jank khi dùng CustomPainter.

### Giải pháp: RepaintBoundary

```dart
// ✅ Isolate vùng repaint
RepaintBoundary(
  child: CustomPaint(
    painter: WaveformPainter(progress: _ctrl.value),
    size: const Size(double.infinity, 100),
  ),
)
```

`RepaintBoundary` tạo một **Layer riêng** trong compositing tree. Khi painter cần repaint, Flutter chỉ repaint layer đó — không ảnh hưởng đến phần còn lại của tree.

```
Scaffold (repaint boundary)
├── AppBar                            ← KHÔNG repaint
├── Body
│   ├── Text("Hello")                 ← KHÔNG repaint
│   ├── RepaintBoundary               ← ranh giới mới
│   │   └── CustomPaint(Waveform)     ← chỉ vùng này repaint
│   └── ListView (100 items)          ← KHÔNG repaint
└── BottomNavigationBar               ← KHÔNG repaint
```

### Khi nào nên dùng RepaintBoundary

**Nên dùng:**
- CustomPainter có animation (repaint mỗi frame)
- Vùng UI thay đổi với tần suất khác phần còn lại (real-time chart, waveform, progress indicator phức tạp)
- Canvas vẽ phức tạp (nhiều path, nhiều draw call) mà content xung quanh static

**Không nên dùng tràn lan:**
- Mỗi RepaintBoundary tạo thêm Layer → tốn memory (mỗi layer = bitmap cache)
- Quá nhiều layer → compositing overhead tăng
- Static UI không cần RepaintBoundary — Flutter đã optimize tốt rồi

### Kiểm tra bằng DevTools

Flutter DevTools → Performance overlay → bật "Repaint Rainbow". Mỗi khi một area repaint, border của nó đổi màu. Nếu bạn thấy toàn bộ screen đổi màu liên tục khi chỉ có một animation nhỏ → đó là signal cần `RepaintBoundary`.

Hoặc programmatically:

```dart
import 'package:flutter/rendering.dart';

// Bật highlight repaint areas
debugRepaintRainbowEnabled = true;
```

---

## 6. Ví dụ thực tế — Animated Line Chart đầy đủ

Kết hợp tất cả: Canvas API, shouldRepaint đúng, RepaintBoundary, animation:

```dart
class AnimatedLineChart extends StatefulWidget {
  final List<double> data;
  final Color lineColor;
  final Color gradientColor;

  const AnimatedLineChart({
    required this.data,
    this.lineColor = Colors.blue,
    this.gradientColor = Colors.blue,
  });

  @override
  State<AnimatedLineChart> createState() => _AnimatedLineChartState();
}

class _AnimatedLineChartState extends State<AnimatedLineChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void didUpdateWidget(AnimatedLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.data, widget.data)) {
      _ctrl.forward(from: 0); // re-animate khi data thay đổi
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary isolate animation repaint
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _LineChartPainter(
              data: widget.data,
              lineColor: widget.lineColor,
              gradientColor: widget.gradientColor,
              progress: CurvedAnimation(
                parent: _ctrl,
                curve: Curves.easeOutCubic,
              ).value,
            ),
          );
        },
      ),
    );
  }
}
```

```dart
class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color gradientColor;
  final double progress; // 0.0 → 1.0

  _LineChartPainter({
    required this.data,
    required this.lineColor,
    required this.gradientColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final drawableWidth = size.width;
    final drawableHeight = size.height;
    final maxVal = data.reduce(max);
    final minVal = data.reduce(min);
    final range = maxVal - minVal;
    if (range == 0) return;

    // Padding cho chart
    const padding = EdgeInsets.fromLTRB(40, 16, 16, 32);
    final chartRect = Rect.fromLTWH(
      padding.left,
      padding.top,
      drawableWidth - padding.horizontal,
      drawableHeight - padding.vertical,
    );

    _drawGridLines(canvas, chartRect, minVal, maxVal);
    _drawLine(canvas, chartRect, minVal, range);
    _drawGradient(canvas, chartRect, minVal, range);
    _drawDataPoints(canvas, chartRect, minVal, range);
  }

  /// Tính toạ độ X, Y cho mỗi data point
  Offset _pointAt(int index, Rect chartRect, double minVal, double range) {
    final x = chartRect.left + (index / (data.length - 1)) * chartRect.width;
    final normalized = (data[index] - minVal) / range;
    final y = chartRect.bottom - normalized * chartRect.height;
    return Offset(x, y);
  }

  /// Grid ngang + label trục Y
  void _drawGridLines(Canvas canvas, Rect rect, double minVal, double maxVal) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    const gridCount = 4;
    for (int i = 0; i <= gridCount; i++) {
      final y = rect.top + (rect.height / gridCount) * i;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridPaint);

      // Label giá trị
      final value = maxVal - ((maxVal - minVal) / gridCount) * i;
      final tp = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(0),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(rect.left - tp.width - 6, y - tp.height / 2));
    }
  }

  /// Đường line chính với animation
  void _drawLine(Canvas canvas, Rect chartRect, double minVal, double range) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final visibleCount = (data.length * progress).ceil().clamp(0, data.length);

    for (int i = 0; i < visibleCount; i++) {
      final point = _pointAt(i, chartRect, minVal, range);

      // Point cuối cùng: interpolate giữa prev và current theo progress
      if (i == visibleCount - 1 && i > 0 && progress < 1.0) {
        final prev = _pointAt(i - 1, chartRect, minVal, range);
        final fraction = (data.length * progress) - (visibleCount - 1);
        final interpolated = Offset.lerp(prev, point, fraction.clamp(0, 1))!;
        path.lineTo(interpolated.dx, interpolated.dy);
      } else if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  /// Gradient fill dưới đường line
  void _drawGradient(Canvas canvas, Rect chartRect, double minVal, double range) {
    final fillPath = Path();
    final visibleCount = (data.length * progress).ceil().clamp(0, data.length);
    if (visibleCount == 0) return;

    final firstPoint = _pointAt(0, chartRect, minVal, range);
    fillPath.moveTo(firstPoint.dx, chartRect.bottom);
    fillPath.lineTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < visibleCount; i++) {
      final point = _pointAt(i, chartRect, minVal, range);
      fillPath.lineTo(point.dx, point.dy);
    }

    final lastX = _pointAt(visibleCount - 1, chartRect, minVal, range).dx;
    fillPath.lineTo(lastX, chartRect.bottom);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        gradientColor.withValues(alpha: 0.3),
        gradientColor.withValues(alpha: 0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(chartRect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
  }

  /// Dot ở mỗi data point
  void _drawDataPoints(Canvas canvas, Rect chartRect, double minVal, double range) {
    final dotPaint = Paint()..color = lineColor;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final visibleCount = (data.length * progress).ceil().clamp(0, data.length);

    for (int i = 0; i < visibleCount; i++) {
      final point = _pointAt(i, chartRect, minVal, range);
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 4, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) {
    return old.progress != progress
        || old.lineColor != lineColor
        || old.gradientColor != gradientColor
        || !listEquals(old.data, data);
  }
}
```

---

## 7. Advanced — shouldRepaint vs shouldRebuildSemantics

Ít người biết `CustomPainter` còn có `shouldRebuildSemantics`:

```dart
@override
SemanticsBuilderCallback? get semanticsBuilder {
  return (Size size) {
    return [
      CustomPainterSemantics(
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        properties: const SemanticsProperties(
          label: 'Line chart showing revenue data',
          textDirection: TextDirection.ltr,
        ),
      ),
    ];
  };
}

@override
bool shouldRebuildSemantics(covariant _LineChartPainter old) {
  // Chỉ rebuild semantics khi data thay đổi — không cần khi animation progress đổi
  return !listEquals(old.data, data);
}
```

Tách `shouldRepaint` (visual) và `shouldRebuildSemantics` (accessibility) — paint có thể thay đổi mỗi frame (animation) nhưng semantics chỉ đổi khi data thực sự đổi. Đây là optimization cho accessibility mà hầu như không ai làm nhưng rất impactful cho screen reader performance.

---

## 8. Advanced — CustomPainter với `repaint` Listenable

Cách khác để trigger repaint mà **không cần rebuild widget**:

```dart
class WaveformPainter extends CustomPainter {
  final Animation<double> animation;
  final List<double> samples;

  WaveformPainter({required this.animation, required this.samples})
      : super(repaint: animation);
  //         ^^^^^^^^^^^^^^^^
  //   Khi animation thay đổi → repaint TRỰC TIẾP
  //   KHÔNG đi qua widget rebuild → KHÔNG gọi shouldRepaint

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    // vẽ waveform...
  }

  @override
  bool shouldRepaint(covariant WaveformPainter old) {
    // Chỉ cần check data thay đổi — animation được handle qua repaint listenable
    return !listEquals(old.samples, samples);
  }
}
```

Sử dụng:

```dart
// Không cần AnimatedBuilder!
CustomPaint(
  painter: WaveformPainter(
    animation: _controller,
    samples: _audioSamples,
  ),
)
```

So sánh 2 approach:

**AnimatedBuilder approach:** animation tick → rebuild widget → tạo painter mới → `shouldRepaint()` → `paint()`. Mỗi frame đi qua widget layer, tạo object mới, chạy shouldRepaint.

**repaint Listenable approach:** animation tick → `markNeedsPaint()` trực tiếp trên RenderObject → `paint()`. Bypass hoàn toàn widget rebuild. Không tạo painter mới, không gọi shouldRepaint. Nhanh hơn — đặc biệt quan trọng khi paint chạy 60fps.

Tuy nhiên trade-off: khi dùng `repaint` listenable, `shouldRepaint` không được gọi mỗi frame nữa (vì không có painter mới để so sánh). Nó chỉ được gọi khi widget rebuild tạo painter mới (ví dụ khi `samples` thay đổi). Đây là behavior đúng nhưng cần hiểu rõ.

---

## 9. Chiến lược performance tổng thể

Tóm tắt decision framework khi dùng CustomPainter:

**shouldRepaint** — so sánh chính xác field nào thay đổi, dùng `listEquals` cho collection, tách data change khỏi animation change.

**repaint Listenable** — dùng cho animation-driven painter để bypass widget rebuild. Ưu tiên approach này cho 60fps animation thay vì AnimatedBuilder + shouldRepaint.

**RepaintBoundary** — wrap mọi CustomPaint có animation. Kiểm tra bằng `debugRepaintRainbowEnabled` hoặc DevTools Performance overlay. Không dùng quá nhiều — mỗi boundary tạo thêm layer (bitmap buffer).

**Canvas optimization** — reuse `Path` object khi có thể (cache path, chỉ rebuild khi data đổi). Giảm `canvas.save()`/`restore()` không cần thiết. Dùng `canvas.clipRect` sớm để skip draw call ngoài visible area.

Bạn muốn mình đi sâu thêm vào phần nào — ví dụ `Sliver` + CustomPainter kết hợp, particle system trên Canvas, hay cách vẽ custom shape cho hit testing (non-rectangular touch target)?
