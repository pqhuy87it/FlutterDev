# Benchmark với Stopwatch — Tại sao ngưỡng 4ms

## 1. Ngưỡng 4ms đến từ đâu — Frame Budget Analysis

### Frame budget cơ bản

Flutter target **60fps**, mỗi frame có budget **16.67ms**. Nhưng main isolate không dành toàn bộ 16.67ms cho code của bạn:

```
┌──────────────────── 16.67ms (1 frame @ 60fps) ────────────────────┐
│                                                                   │
│  ┌─────────┐ ┌─────────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌─────────┐   │
│  │Animation│ │  Build  │ │Layout│ │Paint │ │Compo-│ │Microtask│   │
│  │Callbacks│ │  Phase  │ │Phase │ │Phase │ │siting│ │+ Events │   │
│  │         │ │         │ │      │ │      │ │      │ │         │   │
│  │  ~1ms   │ │  ~2-4ms │ │~1-3ms│ │~1-2ms│ │~1ms  │ │  ~1-2ms │   │
│  └─────────┘ └─────────┘ └──────┘ └──────┘ └──────┘ └─────────┘   │
│                                                                   │
│  Tổng framework overhead: ~7-12ms                                 │
│  Còn lại cho YOUR CODE:   ~4-9ms                                  │
│                                                                   │
│  ⚠️ Nếu your code > 4ms → rủi ro cao frame vượt 16.67ms → JANK    │
└───────────────────────────────────────────────────────────────────┘
```

Chi tiết từng phase:

**Animation Callbacks** (~1ms): `Ticker` callback cập nhật `AnimationController.value`. Nếu screen có nhiều animation đồng thời, phase này có thể tốn hơn.

**Build Phase** (~2-4ms): Framework duyệt tất cả dirty element, gọi `build()` trên từng cái, diff widget tree cũ vs mới. Screen phức tạp với nhiều widget lồng nhau có thể tốn 3-5ms chỉ riêng build.

**Layout Phase** (~1-3ms): `RenderObject.performLayout()` chạy trên tất cả render object cần relayout. Tính toán size, position. Với danh sách dài hoặc layout phức tạp (intrinsic calculation, multi-pass layout) có thể tốn nhiều hơn.

**Paint Phase** (~1-2ms): `RenderObject.paint()` vẽ lên canvas. `CustomPaint` phức tạp, nhiều layer, shadow, gradient tốn thêm thời gian.

**Compositing** (~1ms): Merge tất cả layer thành scene gửi cho Raster thread.

**Microtask + Event Processing** (~1-2ms): Future callback, stream listener, gesture recognizer, platform channel message.

Tổng framework overhead dao động **7-12ms** tùy độ phức tạp của UI. Phần còn lại — khoảng **4-9ms** — là budget dành cho code của bạn (business logic chạy trong frame đó).

### Tại sao 4ms chứ không phải 9ms

Lấy **worst case** làm chuẩn: trên thiết bị yếu (low-end Android), framework overhead có thể lên tới 12ms, chỉ còn **~4ms** cho developer code. Nếu task chiếm > 4ms, trên thiết bị yếu sẽ gần như chắc chắn miss frame.

Ngoài ra cần tính **120fps devices** (iPad Pro, nhiều flagship Android). Ở 120fps, frame budget chỉ còn **8.33ms**:

```
                    60fps           120fps
Frame budget:       16.67ms         8.33ms
Framework overhead: ~7-12ms         ~5-8ms  (nhanh hơn nhờ hardware tốt)
Còn lại:           ~4-9ms          ~1-3ms

→ Ngưỡng an toàn cho 120fps: ~1-2ms
→ Ngưỡng an toàn cho 60fps:  ~4ms
→ 4ms là mức trung bình hợp lý cho cả hai target
```

### Thêm yếu tố GC

Dart Garbage Collector chạy trên main isolate. GC pause nhỏ thường ~0.5-2ms, nhưng nếu heap fragmented hoặc có nhiều object cần collect, pause có thể lên 3-5ms. GC có thể xảy ra **bất kỳ lúc nào** trong frame:

```
Frame thông thường (không GC):
[Animation 1ms][Build 3ms][Layout 2ms][YOUR CODE 4ms][Paint 2ms] = 12ms ✓

Frame khi GC xảy ra:
[Animation 1ms][Build 3ms][GC 2ms][Layout 2ms][YOUR CODE 4ms][Paint 2ms] = 14ms ✓

Frame khi GC nặng:
[Animation 1ms][Build 3ms][GC 4ms][Layout 2ms][YOUR CODE 4ms][Paint 2ms] = 16ms → JANK!
```

Code 4ms + GC pause 4ms đã chiếm 8ms budget. Cộng thêm framework overhead là vượt frame. Đây là lý do **4ms là ngưỡng mà rủi ro bắt đầu tăng đáng kể**, không phải ngưỡng chắc chắn jank.

---

## 2. Cách dùng Stopwatch để Benchmark

### Cơ bản

```dart
void _measureWork() {
  final stopwatch = Stopwatch()..start();
  
  // Code cần đo
  final result = jsonDecode(largeJsonString);
  
  stopwatch.stop();
  print('jsonDecode took: ${stopwatch.elapsedMilliseconds}ms');
  print('             or: ${stopwatch.elapsedMicroseconds}μs');
}
```

### Benchmark chính xác hơn — chạy nhiều lần

Một lần đo duy nhất không đáng tin vì có noise từ GC, OS scheduling, CPU throttling:

```dart
void _benchmarkJsonParsing(String jsonString) {
  final iterations = 100;
  final times = <int>[];
  
  // Warm-up: chạy vài lần để JIT (debug mode) hoặc
  // CPU cache ổn định
  for (int i = 0; i < 5; i++) {
    jsonDecode(jsonString);
  }
  
  // Benchmark thực
  for (int i = 0; i < iterations; i++) {
    final sw = Stopwatch()..start();
    jsonDecode(jsonString);
    sw.stop();
    times.add(sw.elapsedMicroseconds);
  }
  
  times.sort();
  final median = times[times.length ~/ 2];
  final p95 = times[(times.length * 0.95).floor()];
  final avg = times.reduce((a, b) => a + b) / times.length;
  
  print('=== JSON Parse Benchmark ===');
  print('Iterations: $iterations');
  print('Average:    ${(avg / 1000).toStringAsFixed(2)}ms');
  print('Median:     ${(median / 1000).toStringAsFixed(2)}ms');
  print('P95:        ${(p95 / 1000).toStringAsFixed(2)}ms');
  print('Min:        ${(times.first / 1000).toStringAsFixed(2)}ms');
  print('Max:        ${(times.last / 1000).toStringAsFixed(2)}ms');
  
  if (p95 > 4000) { // > 4ms ở P95
    print('⚠️  P95 > 4ms → NÊN dùng Isolate');
  } else {
    print('✅ P95 < 4ms → Chạy trên main isolate OK');
  }
}
```

Dùng **P95** (percentile 95) thay vì average vì average bị kéo thấp bởi các lần chạy nhanh. P95 cho biết "95% thời gian, task hoàn thành trong bao lâu" — phản ánh worst case thực tế mà user trải nghiệm tốt hơn.

### Benchmark trên đúng môi trường

Kết quả benchmark **khác nhau rất lớn** giữa debug mode và profile/release mode:

```dart
// Debug mode:  jsonDecode 50KB → ~15ms  (JIT, assertions, debug checks)
// Profile mode: jsonDecode 50KB → ~3ms   (AOT, no assertions)
// Release mode: jsonDecode 50KB → ~2ms   (AOT, full optimization)
```

**Luôn benchmark trên Profile mode**: `flutter run --profile`. Debug mode chậm gấp 3-10 lần so với release, không phản ánh thực tế. Profile mode dùng AOT compilation giống release nhưng vẫn cho phép DevTools connection.

Ngoài ra nên test trên **thiết bị yếu nhất** mà app hỗ trợ. Code chạy 2ms trên iPhone 15 Pro có thể tốn 8ms trên Samsung Galaxy A13.

---

## 3. Ví dụ thực tế — Đo các tác vụ phổ biến

```dart
class PerformanceBenchmark {
  
  /// Đo JSON parsing theo kích thước
  static Future<void> benchmarkJsonParsing() async {
    final sizes = {
      '1KB': _generateJson(10),
      '10KB': _generateJson(100),
      '100KB': _generateJson(1000),
      '500KB': _generateJson(5000),
      '1MB': _generateJson(10000),
    };

    print('╔══════════════════════════════════════╗');
    print('║     JSON Parsing Benchmark           ║');
    print('╠══════════════════════════════════════╣');

    for (final entry in sizes.entries) {
      final sw = Stopwatch()..start();
      jsonDecode(entry.value);
      sw.stop();

      final ms = sw.elapsedMicroseconds / 1000;
      final recommendation = ms > 4 ? '⚠️  USE ISOLATE' : '✅ Main OK';
      print('║ ${entry.key.padRight(6)} → '
            '${ms.toStringAsFixed(2).padLeft(8)}ms '
            '$recommendation');
    }
    print('╚══════════════════════════════════════╝');
  }

  /// Đo sort theo kích thước list
  static void benchmarkSorting() {
    final sizes = [100, 1000, 10000, 100000, 1000000];
    final random = Random(42);

    print('╔══════════════════════════════════════╗');
    print('║     List Sorting Benchmark           ║');
    print('╠══════════════════════════════════════╣');

    for (final size in sizes) {
      final list = List.generate(size, (_) => random.nextInt(1000000));

      final sw = Stopwatch()..start();
      list.sort();
      sw.stop();

      final ms = sw.elapsedMicroseconds / 1000;
      final recommendation = ms > 4 ? '⚠️  USE ISOLATE' : '✅ Main OK';
      final sizeStr = _formatNumber(size);
      print('║ ${sizeStr.padRight(10)} → '
            '${ms.toStringAsFixed(2).padLeft(8)}ms '
            '$recommendation');
    }
    print('╚══════════════════════════════════════╝');
  }

  /// Đo image resize
  static void benchmarkImageProcessing(Uint8List imageBytes) {
    final sw = Stopwatch()..start();
    
    // Decode image
    final codec = instantiateImageCodec(imageBytes);
    // ... resize logic
    
    sw.stop();
    final ms = sw.elapsedMicroseconds / 1000;
    print('Image processing: ${ms.toStringAsFixed(2)}ms');
    print(ms > 4 ? '⚠️  USE ISOLATE' : '✅ Main OK');
  }

  static String _generateJson(int items) {
    final list = List.generate(items, (i) => {
      'id': i,
      'name': 'User $i',
      'email': 'user$i@example.com',
      'age': 20 + (i % 50),
      'address': {
        'street': '${i * 100} Main St',
        'city': 'City $i',
        'country': 'Country ${i % 10}',
      },
    });
    return jsonEncode(list);
  }
}
```

Kết quả điển hình trên thiết bị mid-range (Profile mode):

```
╔══════════════════════════════════════╗
║     JSON Parsing Benchmark           ║
╠══════════════════════════════════════╣
║ 1KB   →     0.12ms ✅ Main OK        ║
║ 10KB  →     0.85ms ✅ Main OK        ║
║ 100KB →     3.20ms ✅ Main OK        ║
║ 500KB →     8.50ms ⚠️  USE ISOLATE   ║
║ 1MB   →    18.30ms ⚠️  USE ISOLATE   ║
╚══════════════════════════════════════╝

╔══════════════════════════════════════╗
║     List Sorting Benchmark           ║
╠══════════════════════════════════════╣
║ 100        →     0.02ms ✅ Main OK   ║
║ 1,000      →     0.25ms ✅ Main OK   ║
║ 10,000     →     3.10ms ✅ Main OK   ║
║ 100,000    →    35.00ms ⚠️  USE ISO  ║
║ 1,000,000  →   420.00ms ⚠️  USE ISO  ║
╚══════════════════════════════════════╝
```

---

## 4. Tích hợp Benchmark vào workflow

### Benchmark class có thể reuse

```dart
class TaskBenchmark {
  final String name;
  final int warmupRuns;
  final int benchmarkRuns;

  TaskBenchmark({
    required this.name,
    this.warmupRuns = 3,
    this.benchmarkRuns = 20,
  });

  /// Đo một task, trả về recommendation
  BenchmarkResult measure(void Function() task) {
    // Warm-up
    for (int i = 0; i < warmupRuns; i++) {
      task();
    }

    // Benchmark
    final times = <int>[];
    for (int i = 0; i < benchmarkRuns; i++) {
      final sw = Stopwatch()..start();
      task();
      sw.stop();
      times.add(sw.elapsedMicroseconds);
    }

    return BenchmarkResult(
      name: name,
      times: times,
    );
  }
}

class BenchmarkResult {
  final String name;
  final List<int> times;

  BenchmarkResult({required this.name, required this.times}) {
    times.sort();
  }

  double get averageMs => 
      times.reduce((a, b) => a + b) / times.length / 1000;
  double get medianMs => 
      times[times.length ~/ 2] / 1000;
  double get p95Ms => 
      times[(times.length * 0.95).floor()] / 1000;
  double get minMs => 
      times.first / 1000;
  double get maxMs => 
      times.last / 1000;

  /// Khuyến nghị dựa trên device tier
  String get recommendation {
    if (p95Ms <= 1) return '✅ Safe cho mọi device, kể cả 120fps';
    if (p95Ms <= 4) return '✅ OK cho 60fps trên hầu hết device';
    if (p95Ms <= 8) return '⚠️  Nên dùng Isolate (jank trên low-end)';
    if (p95Ms <= 16) return '🔴 BẮT BUỘC dùng Isolate (miss frame)';
    return '🔴🔴 CRITICAL — sẽ miss nhiều frame liên tiếp';
  }

  @override
  String toString() {
    return '''
┌─ $name ─────────────────────
│ Runs:    ${times.length}
│ Average: ${averageMs.toStringAsFixed(2)}ms
│ Median:  ${medianMs.toStringAsFixed(2)}ms
│ P95:     ${p95Ms.toStringAsFixed(2)}ms
│ Min/Max: ${minMs.toStringAsFixed(2)}ms / ${maxMs.toStringAsFixed(2)}ms
│ → $recommendation
└──────────────────────────────''';
  }
}
```

### Sử dụng

```dart
void runBenchmarks() {
  final jsonSmall = generateJsonString(100);   // ~10KB
  final jsonLarge = generateJsonString(10000); // ~1MB
  final listSmall = List.generate(1000, (i) => i)..shuffle();
  final listLarge = List.generate(100000, (i) => i)..shuffle();

  final benchmarks = [
    TaskBenchmark(name: 'JSON Parse 10KB')
        .measure(() => jsonDecode(jsonSmall)),
    TaskBenchmark(name: 'JSON Parse 1MB')
        .measure(() => jsonDecode(jsonLarge)),
    TaskBenchmark(name: 'Sort 1K items')
        .measure(() => [...listSmall]..sort()),
    TaskBenchmark(name: 'Sort 100K items')
        .measure(() => [...listLarge]..sort()),
  ];

  for (final result in benchmarks) {
    print(result);
  }
}
```

Output:

```
┌─ JSON Parse 10KB ─────────────────────
│ Runs:    20
│ Average: 0.82ms
│ Median:  0.78ms
│ P95:     1.15ms
│ Min/Max: 0.71ms / 1.30ms
│ → ✅ Safe cho mọi device, kể cả 120fps
└──────────────────────────────────────

┌─ JSON Parse 1MB ─────────────────────
│ Runs:    20
│ Average: 16.50ms
│ Median:  15.80ms
│ P95:     21.30ms
│ Min/Max: 14.20ms / 25.10ms
│ → 🔴 BẮT BUỘC dùng Isolate (miss frame)
└──────────────────────────────────────

┌─ Sort 1K items ──────────────────────
│ Runs:    20
│ Average: 0.22ms
│ Median:  0.20ms
│ P95:     0.31ms
│ Min/Max: 0.18ms / 0.35ms
│ → ✅ Safe cho mọi device, kể cả 120fps
└──────────────────────────────────────

┌─ Sort 100K items ────────────────────
│ Runs:    20
│ Average: 32.00ms
│ Median:  30.50ms
│ P95:     38.20ms
│ Min/Max: 28.00ms / 42.00ms
│ → 🔴🔴 CRITICAL — sẽ miss nhiều frame liên tiếp
└──────────────────────────────────────
```

---

## 5. Bảng ngưỡng tham khảo

```
Thời gian (P95)   Hệ quả                           Hành động
─────────────────────────────────────────────────────────────────
  < 1ms            Không ảnh hưởng gì                Main isolate ✅
  1-2ms            An toàn ở 60fps                    Main isolate ✅
                   Có thể jank nhẹ ở 120fps
  2-4ms            An toàn trên device tốt            Main isolate ✅
                   Rủi ro trên low-end                Xem xét isolate
  4-8ms            Có thể jank trên most devices      Nên dùng isolate ⚠️
                   Chắc chắn jank trên low-end
  8-16ms           Miss frame trên hầu hết device     Bắt buộc isolate 🔴
  > 16ms           Miss nhiều frame liên tiếp         Bắt buộc isolate 🔴🔴
                   App freeze rõ ràng
  > 100ms          User cảm nhận app đơ               Bắt buộc isolate 🔴🔴🔴
  > 1000ms         ANR warning (Android)              Bắt buộc isolate + UX loading
```

Bảng này tính cho **worst case scenario**: frame có nhiều animation, UI phức tạp, GC có thể xảy ra. Nếu screen đơn giản (ít widget, không animation), framework overhead thấp hơn và code có thể tốn nhiều hơn 4ms mà vẫn ổn. Nhưng lấy 4ms làm ngưỡng **mặc định** là cách tiếp cận an toàn và nhất quán.

---

## 6. Lưu ý quan trọng khi benchmark

**Đo trên Profile mode**: Debug mode chậm gấp 3-10x, không phản ánh thực tế. `flutter run --profile` cho kết quả sát release nhất.

**Đo trên thiết bị thật**: Emulator chạy trên x86 CPU của máy tính, nhanh hơn hoặc chậm hơn thiết bị thật tùy trường hợp. Luôn benchmark trên thiết bị yếu nhất mà app hỗ trợ.

**Đo với data thực tế**: JSON 10 item khác rất xa JSON 10,000 item. Benchmark với kích thước data mà production app thực sự xử lý.

**Đo nhiều lần lấy P95**: Một lần đo có thể trùng với GC pause hoặc OS scheduling delay. P95 qua 20+ lần đo cho kết quả đáng tin cậy hơn.

**Xem xét tần suất**: Task 5ms chạy một lần khi mở app thì không cần isolate. Task 3ms chạy mỗi khi user gõ phím (debounce 100ms → 10 lần/giây) thì cần xem xét vì nó chiếm 30ms mỗi giây — gần 2 frame budget.
