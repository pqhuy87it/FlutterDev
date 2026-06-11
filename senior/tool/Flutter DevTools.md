## Flutter DevTools — Hướng dẫn chi tiết toàn diện

### 1. Cách mở DevTools

**Từ Android Studio:** Khi app đang chạy debug mode, click biểu tượng Flutter DevTools trên thanh Run/Debug toolbar. Hoặc vào **View → Tool Windows → Flutter Inspector** → nhấn **Open DevTools in Browser**.

**Từ VS Code:** Mở Command Palette (Cmd+Shift+P / Ctrl+Shift+P) → gõ **"Dart: Open DevTools"** → chọn tab muốn mở.

**Từ Terminal:**

```bash
# Chạy app trước
flutter run

# Terminal hiển thị dòng này:
# Flutter DevTools is available at: http://127.0.0.1:9100?uri=...
# Click hoặc copy URL vào browser

# Hoặc mở DevTools thủ công
dart devtools
```

**Từ browser trực tiếp:** Truy cập `http://localhost:9100` sau khi DevTools server đã chạy. Paste **VM Service URI** (hiển thị khi `flutter run`) vào ô connect.

---

### 2. Tab Flutter Inspector — Widget Tree

#### 2.1 Widget Tree Panel

Hiển thị toàn bộ widget tree dạng cây. Mỗi node là một widget, click vào để xem chi tiết properties bên panel phải.

**Select Widget Mode** — biểu tượng con trỏ trên toolbar. Bật lên, tap vào bất kỳ widget nào trên app đang chạy → DevTools highlight widget tương ứng trong tree và hiển thị properties.

Thực hành với code point exchange:

```
PointExchangeListScreen
├── Scaffold
│   ├── AppBar
│   └── ListView.builder
│       ├── PointExchangeCard (docomo)    ← click vào đây
│       │   ├── Image (logo)
│       │   ├── Text ("dポイント")
│       │   └── Text ("100pt = 1pt")
│       └── PointExchangeCard (rakuten)
```

Click vào `PointExchangeCard` → panel phải hiển thị:

```
Widget: PointExchangeCard
├── provider: PointExchangeProviderType.docomo
├── paymentServiceProviderName: "dポイント"
├── exchangeRate: 100
├── tokyoPointRate: 1
├── size: Size(390.0, 120.0)
├── renderObject: RenderFlex
│   ├── constraints: BoxConstraints(0.0<=w<=390.0, 0.0<=h<=Infinity)
│   └── offset: Offset(0.0, 240.0)
```

#### 2.2 Layout Explorer

Khi click vào Flex widget (Row, Column, Flex, Wrap), tab **Layout Explorer** hiện lên hiển thị trực quan:

```
┌─ Column (MainAxisAlignment.start) ────────────────┐
│  ┌─ child 0: Text ───────┐  flex: null            │
│  │  "dポイント"            │  height: 24.0          │
│  └───────────────────────┘                        │
│  ┌─ child 1: Row ───────────────────┐  flex: null │
│  │  ┌─ Text ────┐  ┌─ Spacer ┐      │             │
│  │  │ "100pt"   │  │         │      │  height: 20 │
│  │  └───────────┘  └─────────┘      │             │
│  └──────────────────────────────────┘             │
│  ┌─ child 2: SizedBox ───┐  flex: null            │
│  │  height: 8.0          │                        │
│  └───────────────────────┘                        │
└───────────────────────────────────────────────────┘
```

Có thể **thay đổi trực tiếp** alignment, flex factor trong Layout Explorer và thấy kết quả realtime trên app. Rất hữu ích khi debug overflow hoặc layout không đúng ý.

#### 2.3 Debug Paint và Visual Flags

Trên toolbar Inspector có các toggle:

```dart
// Tương đương các flag sau trong code
debugPaintSizeEnabled = true;          // Border xanh quanh mỗi widget
debugPaintBaselinesEnabled = true;     // Baseline text
debugPaintPointersEnabled = true;      // Vùng touch
debugRepaintRainbowEnabled = true;     // Rainbow repaint indicator
```

Bật **Debug Paint** → app hiển thị viền xanh quanh mỗi RenderObject với mũi tên chỉ hướng và kích thước. Padding hiển thị màu xanh nhạt, margin hiển thị vùng trống.

---

### 3. Tab Performance — Frame Analysis

#### 3.1 Frame Chart

Phần trên hiển thị bar chart, mỗi bar là một frame:

```
Frame Timeline:
  16ms ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  (60fps target)
   |
   |  ██  ██  ██  ██████  ██  ██  ██  ██
   |  ██  ██  ██  ██████  ██  ██  ██  ██
   |  ██  ██  ██  ██████  ██  ██  ██  ██
   └──────────────────────────────────────
      UI thread (trên) / Raster thread (dưới)
      
   Xanh = OK (<16ms)
   Đỏ = Jank (>16ms)  ← frame thứ 4 bị jank
```

Click vào frame đỏ để xem chi tiết.

#### 3.2 Timeline Events

Sau khi click frame, phần dưới hiển thị flame chart:

```
UI Thread:
├── Build              2.1ms
│   ├── MyApp.build    0.3ms
│   ├── Scaffold.build 0.5ms
│   └── ListView.build 1.3ms  ← tốn nhất trong build
├── Layout             1.8ms
│   └── RenderFlex.performLayout 1.2ms
├── Paint              12.5ms  ← BOTTLENECK
│   ├── RenderImage.paint  8.2ms  ← ảnh lớn
│   └── RenderDecoration   3.1ms
└── Compositing        0.8ms
                       ─────
                       17.2ms (> 16ms → jank)
```

Từ breakdown này, bạn biết paint tốn 12.5ms do `RenderImage.paint` 8.2ms → nguyên nhân là ảnh lớn chưa được cache hoặc resize.

#### 3.3 Enhance Tracing

Bật các checkbox trong **Enhance Tracing** panel:

**Track Widget Builds** — ghi lại widget nào rebuild trong mỗi frame. Sau khi bật, click frame bất kỳ → trong timeline sẽ thấy:

```
Build:
├── PointExchangeListScreen.build    0.8ms
├── PointExchangeCard.build          0.3ms  ← rebuild
├── PointExchangeCard.build          0.3ms  ← rebuild
├── PointExchangeCard.build          0.3ms  ← rebuild
└── Header.build                     0.1ms  ← rebuild không cần thiết
```

Nếu `Header.build` xuất hiện mà data header không đổi → đây là rebuild thừa, cần tách widget.

**Track Layouts** — ghi lại RenderObject nào thực hiện layout lại. **Track Paints** — ghi lại RenderObject nào repaint.

#### 3.4 Thực hành debug jank với project hiện tại

Bước 1: Mở Performance tab, bật Track Widget Builds.

Bước 2: Trên app, scroll danh sách point exchange nhanh.

Bước 3: Quan sát frame chart, tìm frame đỏ.

Bước 4: Click frame đỏ, xem timeline:

```
// Ví dụ phát hiện: mỗi lần scroll, tất cả card rebuild
Build:
├── PointExchangeCard(docomo).build      0.4ms
├── PointExchangeCard(rakuten).build     0.4ms
├── PointExchangeCard(vpoint).build      0.4ms
├── PointExchangeCard(mercari).build     0.4ms
├── PointExchangeCard(au).build          0.4ms
└── Total build: 2.0ms

// Nếu chỉ 1 card thay đổi mà tất cả rebuild → vấn đề
```

Bước 5: Fix bằng cách dùng `const` constructor hoặc tách state:

```dart
// ❌ Tất cả card rebuild khi parent setState
ListView.builder(
  itemBuilder: (context, index) {
    return PointExchangeCard(model: exchanges[index]);
  },
);

// ✅ Dùng const constructor + Equatable
class PointExchangeCard extends StatelessWidget {
  const PointExchangeCard({super.key, required this.model});
  final PointExchangeModel model;
  // ...
}
```

---

### 4. Tab CPU Profiler — Tìm function chậm

#### 4.1 Record và phân tích

Nhấn **Record** → thao tác trên app (ví dụ nhấn nút exchange) → **Stop**.

**Call Tree** — cây gọi hàm top-down:

```
Total: 450ms
├── exchangePointForDocomo         320ms (71%)
│   ├── ApigeeClient.post          280ms (62%)  ← network call
│   │   └── HttpClient.send        278ms
│   └── ApiResult.when             2ms
├── checkDuplicate                 100ms (22%)
│   ├── Firestore.get              85ms   ← Firestore query
│   └── TransactionsDocumentData
│       .fromJson                  12ms   ← parsing
└── calcExchangePoint              0.1ms  (0%)
```

Từ đây biết: 62% thời gian là network call → không optimize được phía client. 22% là Firestore query → có thể optimize bằng index hoặc cache.

**Bottom Up** — function tốn nhất ở trên:

```
HttpClient.send          278ms  ← called by ApigeeClient.post
Firestore.get            85ms   ← called by checkDuplicate
fromJson                 12ms   ← called by checkDuplicate
```

**Flame Chart** — trục x là thời gian, trục y là depth. Vùng rộng = chạy lâu:

```
|←── exchangePointForDocomo (320ms) ──────────────────→|
|←── ApigeeClient.post (280ms) ──────────────────→|   |
|←── HttpClient.send (278ms) ────────────────→|   |   |
                                                       
|checkDuplicate (100ms)|
|Firestore.get (85ms)  |
```

#### 4.2 Filter noise

CPU Profiler ghi lại cả framework internal call. Dùng filter:

```
Filter bar: [Hide native code ✓] [Hide core libraries ✓]
            [Filter: "point_exchange"]  ← chỉ hiện code của bạn
```

---

### 5. Tab Memory — Phát hiện Memory Leak

#### 5.1 Memory Overview Chart

Hiển thị realtime:

```
Dart Heap ────────────────────────────────────
         ╱╲    ╱╲         ╱╲╱╲╱╲╱╲
────────╱──╲──╱──╲───────╱──────────╲────────
       ╱    ╲╱    ╲     ╱            ╲
      A      B     C   D              E

A: Vào màn hình PointExchange (heap tăng)
B: GC tự động (heap giảm)
C: Rời màn hình (heap giảm một phần)
D: Vào lại nhiều lần (heap tăng dần → LEAK!)
E: Force GC nhưng heap không giảm → xác nhận LEAK
```

#### 5.2 Quy trình phát hiện leak

Bước 1: Mở Memory tab, note heap size hiện tại (ví dụ 45MB).

Bước 2: Navigate vào màn hình point exchange.

Bước 3: Thao tác bình thường (scroll, filter, search).

Bước 4: Navigate ra khỏi màn hình.

Bước 5: Nhấn **GC** button (biểu tượng thùng rác).

Bước 6: Kiểm tra heap size. Nếu > 45MB → có leak.

Bước 7: Lặp lại bước 2-6 ba lần. Nếu heap tăng mỗi lần → xác nhận leak.

#### 5.3 Heap Snapshot — Tìm object gây leak

Nhấn **Take Heap Snapshot** → DevTools chụp toàn bộ object trong heap.

Sắp xếp theo **Retained Size** (dung lượng memory mà object giữ, tính cả reference):

```
Class                              Instances   Retained Size
─────────────────────────────────────────────────────────────
_Uint8List                         1,245       12.3 MB
ImageInfo                          89          8.1 MB  ← ảnh logo?
PointExchangeSettingsDocumentData  150         2.4 MB  ← leak?
StreamSubscription                 23          1.1 MB  ← chưa cancel?
PointExchangeAsyncNotifier         5           0.8 MB  ← 5 instances!
```

Nếu `PointExchangeAsyncNotifier` có 5 instances mà bạn chỉ expect 1 → leak. Click vào xem **Retaining Path** (chuỗi reference giữ object sống):

```
PointExchangeAsyncNotifier
  ← _pointExchangeSettingsListener (StreamSubscription)
    ← _StreamController
      ← FirebaseFirestore._queryListeners
        ← ROOT (GC root — không bao giờ bị thu hồi)
```

Nguyên nhân: `_pointExchangeSettingsListener` chưa được cancel → Firestore giữ reference → notifier không bị GC.

Fix trong code hiện tại:

```dart
// Code đã có onDispose, nhưng kiểm tra xem có thực sự chạy không
ref.onDispose(() {
  _pointExchangeSettingsListener?.cancel();
  _pointExchangeSettingsListener = null;
  debugPrint('=== PointExchangeAsyncNotifier disposed ==='); // thêm log
});
```

#### 5.4 Allocation Tracing

Trong Memory tab → **Trace** → check class muốn theo dõi (ví dụ `StreamSubscription`).

Thao tác trên app. Quay lại DevTools → xem allocation call stack cho mỗi instance:

```
StreamSubscription allocated at:
  #0 PointExchangeAsyncNotifier._setupFirestoreListener (line 45)
  #1 PointExchangeAsyncNotifier.build (line 30)
  #2 AutoDisposeAsyncNotifier._build
```

Biết chính xác dòng code nào tạo object.

#### 5.5 Diff Snapshots

Chụp snapshot tại 2 thời điểm và so sánh:

```
Snapshot A (trước khi vào màn hình): 45MB
Snapshot B (sau khi ra + GC):       52MB

Diff (B - A):
Class                              +Instances  +Size
─────────────────────────────────────────────────────
StreamSubscription                 +3          +0.5MB  ← leak
PointExchangeSettingsDocumentData  +50         +1.2MB  ← leak
Timer                              +2          +0.1MB  ← leak
```

---

### 6. Tab Network — HTTP Inspector

#### 6.1 Request/Response detail

Mở Network tab → thao tác trên app → xem timeline:

```
Method  URL                                    Status  Duration
GET     /api/v1/getPointExchangeSettingInfo     200     234ms
POST    /api/v1/exchangePointForDocomo          200     1,203ms
GET     /api/v1/getServiceInfo                  200     156ms
POST    /api/v1/isAuNumberAlreadyExist          400     89ms  ← lỗi!
```

Click vào request để xem chi tiết:

**Request tab:**

```
Headers:
  Authorization: Bearer eyJhbGciOiJSUzI1...
  Content-Type: application/json
  X-Service-Operator-Id: op_123

Body:
  {
    "auNumber": "1234567890123456789"
  }
```

**Response tab:**

```
Status: 400 Bad Request
Headers:
  Content-Type: application/json

Body:
  {
    "error": {
      "code": "invalid-argument",
      "message": "E014",
      "details": "パラメータが不正です。auPayDisplayName"
    }
  }
```

**Timing tab:**

```
DNS Lookup:     2ms
Connection:     15ms
TLS Handshake:  45ms
Request Sent:   1ms
Waiting (TTFB): 820ms  ← server processing lâu
Content Download: 3ms
Total:          886ms
```

#### 6.2 Filter và Search

```
Filter bar: [POST only] [Status: 4xx, 5xx] [URL contains: "exchange"]
```

Chỉ hiển thị request exchange bị lỗi → debug nhanh hơn.

#### 6.3 Lưu ý với Firebase

Firebase SDK dùng gRPC/WebSocket cho Firestore realtime listener → không hiển thị trong Network tab. Chỉ Cloud Functions call qua HTTP và Apigee REST API mới hiển thị đầy đủ.

Nếu cần debug Firestore traffic, dùng Charles Proxy hoặc Proxyman.

---

### 7. Tab Logging — Structured Logs

#### 7.1 Log levels

```
Timestamp    Level   Source              Message
──────────────────────────────────────────────────────
14:23:01.123 INFO    point_exchange      Exchange started for docomo
14:23:01.456 FINE    api_client          POST /exchangePointForDocomo
14:23:02.789 INFO    point_exchange      Exchange success: txn_001
14:23:05.012 ERROR   point_exchange      Exchange failed: S022
14:23:05.013 ERROR   point_exchange      Stack trace: ...
```

#### 7.2 Structured logging trong code

```dart
import 'dart:developer' as developer;

// Log có structured data — hiển thị đẹp trong DevTools
developer.log(
  'Exchange completed',
  name: 'point_exchange',          // source column
  error: null,                      // error object nếu có
  level: 800,                       // INFO level
);

// Log với object inspection
developer.log(
  'Exchange request',
  name: 'point_exchange',
  error: jsonEncode(request.toJson()), // hiển thị trong detail panel
);

// Timeline event — hiển thị trong Performance tab
developer.Timeline.startSync('exchangePointForDocomo');
final result = await client.exchangePointForDocomo(request);
developer.Timeline.finishSync();
```

#### 7.3 Filter

```
Filter: [Level >= WARNING] [Source: "point_exchange"]
```

Chỉ hiện log warning/error từ module point exchange.

---

### 8. Tab App Size — Phân tích kích thước build

#### 8.1 Tạo size analysis file

```bash
# Build với flag analysis
flutter build apk --analyze-size
flutter build ios --analyze-size

# Output:
# app-release.apk: 24.5 MB
# Wrote size analysis to: /path/to/apk-code-size-analysis_01.json
```

#### 8.2 Load vào DevTools

Mở tab **App Size** → **Upload** file JSON vừa generate.

**Treemap view:**

```
Total: 24.5 MB
├── Native libraries:     8.2 MB (33%)
│   ├── libflutter.so     5.1 MB
│   └── libapp.so         3.1 MB
├── Assets:               6.8 MB (28%)
│   ├── fonts/            2.1 MB
│   ├── images/           4.2 MB  ← ảnh logo point exchange?
│   └── certificates/     0.5 MB
├── Dart code:            5.3 MB (22%)
│   ├── package:api_client    1.8 MB
│   ├── package:flutter       1.2 MB
│   ├── package:firebase_core 0.8 MB
│   └── package:ttp           1.5 MB
│       ├── point_exchange/   0.3 MB
│       ├── news/             0.2 MB
│       └── merchants/        0.4 MB
└── Other:                4.2 MB (17%)
```

#### 8.3 Diff hai builds

Upload 2 file JSON (ví dụ trước và sau khi thêm feature) → DevTools hiển thị diff:

```
Changed:
+ package:api_client/exchange_point_for_mercari  +45 KB (new)
+ assets/images/mercari_logo.png                 +12 KB (new)
~ package:ttp/point_exchange/notifier            +3 KB (modified)
- package:unused_library                         -120 KB (removed)
```

---

### 9. Tab Debugger — Breakpoint và Step

DevTools có tab Debugger tương tự IDE nhưng chạy trên browser.

**Set breakpoint:** Click số dòng trong source panel. **Conditional breakpoint:** Click chuột phải → Add conditional breakpoint:

```dart
// Condition: chỉ dừng khi provider là au
providerType == PointExchangeProviderType.au
```

**Step controls:**

```
[Continue F8] [Step Over F10] [Step Into F11] [Step Out Shift+F11]

// Step Over: chạy hết dòng hiện tại, sang dòng tiếp
// Step Into: nhảy vào trong function đang gọi
// Step Out: chạy hết function hiện tại, quay về caller
```

**Variables panel** — khi đang pause tại breakpoint:

```
Locals:
  providerType: PointExchangeProviderType.au
  setting: PaymentServiceProviderSetting
    ├── enableExchange: true
    ├── enableExchangeV2: true
    └── paymentServiceProviderName: "au PAY"
  pointExchangeSetting: PointExchangeSettingsDocumentData
    ├── status: 1
    ├── maxExchangePointPerUse: 10000
    └── exchangeRateSettings: List<PointExchangeRateSetting> (3)
        ├── [0]: {periodStart: 2024-01-01, periodEnd: 2024-06-30, rate: 100}
        ├── [1]: {periodStart: 2024-07-01, periodEnd: 2024-12-31, rate: 120}
        └── [2]: {periodStart: 2025-01-01, periodEnd: 2025-06-30, rate: 110}
```

**Evaluate expression** (Console panel dưới cùng):

```
> pointExchangeSettings.where((e) => e.status == 1).length
3
> mainService?.exchangePointSettings?.map((e) => e.paymentServiceProvider).toList()
["au", "docomo", "rakuten", "vpoint", "mercari"]
> DateTime.now().millisecondsSinceEpoch
1710672000000
```

---

### 10. Deep Links Tool

Từ DevTools → tab **Deep Links**. Kiểm tra deep link configuration:

```
Android:
  ✅ AndroidManifest.xml has intent-filter for scheme "ttp"
  ✅ assetlinks.json verified at https://yourdomain/.well-known/assetlinks.json
  ⚠️  Missing intent-filter for "https://yourdomain/exchange/callback"

iOS:
  ✅ Info.plist has URL scheme "ttp"
  ✅ apple-app-site-association verified
  ✅ Associated domain: applinks:yourdomain
```

Với point exchange code hiện tại, au authentication dùng deep link return flow → tool này giúp verify deep link config đúng.

---

### 11. DevTools Extensions

Một số package tích hợp extension riêng vào DevTools:

**Riverpod DevTools** (package `riverpod`):

```
Provider Graph:
servicesProvider (AsyncData<List<ServicesDocumentData>>)
  ↓ watched by
pointExchangeAsyncNotifierProvider (AsyncData<List<PointExchangeModel>>)
  ↓ watched by
PointExchangeListScreen

serviceOperatorsStateNotifierProvider (ServiceOperatorsDocumentData)
  ↓ read by
pointExchangeAsyncNotifierProvider
```

Click vào provider → xem state hiện tại:

```
pointExchangeAsyncNotifierProvider:
  State: AsyncData
  Value: List<PointExchangeModel> (3 items)
    [0]: {provider: docomo, rate: 100, tokyoPointRate: 1}
    [1]: {provider: rakuten, rate: 80, tokyoPointRate: 1}
    [2]: {provider: au, rate: 110, tokyoPointRate: 1, auPayDisplayName: "au PAY"}
  
  Listeners: 2 (PointExchangeListScreen, PointExchangeDetailScreen)
  Dependencies: servicesProvider, serviceOperatorsStateNotifierProvider
```

---

### 12. Workflow debug thực tế cho project Point Exchange

#### Scenario 1: Danh sách point exchange không hiển thị

```
1. Flutter Inspector → Select Widget Mode → tap vùng trống trên app
   → Xem widget tree có PointExchangeCard không
   
2. Nếu không có → Riverpod DevTools → kiểm tra state của
   pointExchangeAsyncNotifierProvider
   → AsyncLoading? AsyncError? AsyncData([])?
   
3. Nếu AsyncError → xem error message
   → "事業者情報の取得に失敗しました。" → servicesProvider trả về []
   
4. Network tab → kiểm tra getServiceInfo request
   → 401 Unauthorized → token hết hạn
```

#### Scenario 2: Exchange bị chậm

```
1. Performance tab → bật Enhance Tracing → nhấn exchange
   → Xem frame nào bị jank
   
2. CPU Profiler → Record → nhấn exchange → Stop
   → Call Tree: exchangePointForDocomo 1.2s
     → ApigeeClient.post 1.1s → network chậm, không phải client
   
3. Network tab → xem request timing
   → TTFB 900ms → server xử lý lâu → báo backend team
```

#### Scenario 3: Memory tăng liên tục khi navigate

```
1. Memory tab → note heap: 50MB
2. Vào PointExchange screen
3. Ra PointExchange screen
4. Lặp 5 lần
5. Force GC → heap: 62MB → leak 12MB
6. Take Snapshot → sort by Retained Size
   → StreamSubscription: 15 instances (expect 0 sau khi ra screen)
   → Retaining Path: _pointExchangeSettingsListener → chưa cancel
7. Fix: verify ref.onDispose đang chạy đúng
```

#### Scenario 4: UI bị giật khi scroll danh sách

```
1. Performance tab → scroll nhanh → quan sát frame chart
   → Nhiều frame đỏ (>16ms)
   
2. Click frame đỏ → Timeline:
   Paint: 14ms
   └── RenderImage.paint: 11ms (logo ảnh lớn)
   
3. Fix: cache và resize ảnh
   CachedNetworkImage(
     imageUrl: model.logoFilePath,
     maxWidth: 48,
     maxHeight: 48,
     memCacheWidth: 96,  // 2x for retina
   )
   
4. Sau fix → scroll lại → frame xanh hết
```
