# Refactoring PointExchangeDetailView theo SOLID

## Phân tích vi phạm SOLID hiện tại

Trước khi refactor, cần nhận diện rõ từng vi phạm:

```
┌─ File hiện tại: ~1100 dòng, 1 class làm MỌI THỨ ────────────┐
│                                                             │
│  S (Single Responsibility) ❌                               │
│  ├─ Render UI                                               │
│  ├─ Handle lifecycle (WidgetsBindingObserver)               │
│  ├─ Handle deep link cho 5 providers                        │
│  ├─ Gọi API exchange cho 5 providers                        │
│  ├─ Quản lý dialog (waiting, confirm, error, complete...)   │
│  ├─ State restoration (SharedPreferences)                   │
│  ├─ Lock checking (Timer + polling)                         │
│  └─ Duplicate payment checking                              │
│                                                             │
│  O (Open/Closed) ❌                                         │
│  ├─ Thêm provider mới (ex: PayPay) → sửa 5+ switch/if       │
│  ├─ _buildProviderInfo() → thêm case                        │
│  ├─ _processPointExchangeDeepLink() → thêm case             │
│  ├─ _onPressExchange() → thêm if                            │
│  └─ Thêm UI info widget mới                                 │
│                                                             │
│  L (Liskov Substitution) ⚠️                                │
│  └─ Không có abstraction nên không áp dụng trực tiếp        │
│                                                             │
│  I (Interface Segregation) ❌                               │
│  └─ Widget phụ thuộc vào MỌI provider logic dù chỉ          │
│     hiển thị 1 provider tại 1 thời điểm                     │
│                                                             │
│  D (Dependency Inversion) ❌                                │
│  ├─ ref.read() trực tiếp trong Widget (concrete)            │
│  ├─ PointExchangeProgressModel.load() static call           │
│  ├─ AccountLockUtil() khởi tạo trực tiếp                    │
│  ├─ launchUrl() gọi trực tiếp                               │
│  └─ TTPFirebaseAnalytics.logEvent() static call             │
└─────────────────────────────────────────────────────────────┘
```

---

## Refactoring Plan

```
TRƯỚC:
  PointExchangeDetailView (1100 dòng, làm tất cả)

SAU:
  ┌─ Abstraction Layer ──────────────────────────────────┐
  │  PointExchangeHandler (interface)                    │
  │  DeepLinkHandler (interface)                         │
  │  ExchangeDialogCoordinator (interface)               │
  └──────────────────────────────────────────────────────┘
  
  ┌─ Provider Strategies ────────────────────────────────┐
  │  DocomoExchangeHandler                               │
  │  MercariExchangeHandler                              │
  │  VPointExchangeHandler                               │
  │  RakutenExchangeHandler                              │
  │  AuExchangeHandler                                   │
  └──────────────────────────────────────────────────────┘
  
  ┌─ UI Components ──────────────────────────────────────┐
  │  PointExchangeDetailView (UI only, ~200 dòng)        │
  │  Provider Info Widgets (riêng mỗi provider)          │
  │  ExchangePointSummarySection                         │
  │  ExchangeInputSection                                │
  └──────────────────────────────────────────────────────┘
  
  ┌─ Supporting Services ────────────────────────────────┐
  │  PointExchangeLifecycleHandler                       │
  │  PointExchangeStateRestorer                          │
  │  AccountLockChecker                                  │
  └──────────────────────────────────────────────────────┘
```

---

## 1. S — Single Responsibility: Tách abstractions## Tổng kết: Mỗi nguyên tắc SOLID áp dụng như thế nào

### S — Single Responsibility

File gốc 1100 dòng đảm nhiệm 8+ trách nhiệm. Sau refactor:

```
PointExchangeDetailView        → CHỈ render UI + wire dependencies
PointExchangeHandler (mỗi impl)→ CHỈ logic exchange của 1 provider
PointExchangeLifecycleHandler  → CHỈ quản lý lifecycle + waiting dialog
AccountLockChecker             → CHỈ polling lock state
ExternalLinkLauncher           → CHỈ launch URL
PointExchangeInputSection      → CHỈ UI phần input points
DocomoInfoWidget, MercariInfo..→ CHỈ hiển thị info 1 provider
```

Mỗi class thay đổi vì **đúng 1 lý do**. Sửa UI không chạm logic exchange. Sửa Docomo API không chạm Mercari.

### O — Open/Closed

Trước: thêm provider mới (PayPay) phải sửa **5+ switch/if** rải rác trong 1 file.

Sau: thêm provider mới chỉ cần **2 bước**, không sửa code cũ:

```dart
// Bước 1: Tạo class mới
class PayPayExchangeHandler extends BaseExchangeHandler { ... }

// Bước 2: Register
ExchangeHandlerFactory.register(
  PointExchangeProviderType.paypay,
  () => PayPayExchangeHandler(),
);
```

`PointExchangeDetailView` không biết PayPay tồn tại — nó chỉ gọi `_handler.startExchange()`.

### L — Liskov Substitution

Mọi handler đều extend `BaseExchangeHandler` và có thể thay thế cho nhau qua interface `PointExchangeHandler`:

```dart
// Widget KHÔNG quan tâm handler cụ thể là gì
late final PointExchangeHandler _handler;

// Docomo, Mercari, VPoint... đều hoạt động đúng khi gọi:
_handler.startExchange(...);
_handler.handleDeepLink(...);
_handler.buildProviderInfo();
```

`BaseExchangeHandler` dùng **Template Method Pattern**: define skeleton (`startExchange` → validate → `onPreExchange`), subclass chỉ override phần đặc thù mà không phá vỡ flow chung.

### I — Interface Segregation

Trước: Widget phụ thuộc vào logic của **tất cả 5 providers** dù chỉ dùng 1.

Sau: tách thành interfaces nhỏ, client chỉ phụ thuộc interface cần:

```dart
// Interface chính — mọi handler đều implement
abstract class PointExchangeHandler { ... }

// Interface riêng cho duplicate check — không phải mọi flow đều cần
abstract class DuplicateCheckable { ... }

// Interface riêng cho dialog — có thể swap implementation
abstract class ExchangeDialogCoordinator { ... }
```

### D — Dependency Inversion

Trước: Widget gọi trực tiếp concrete class ở khắp nơi:

```dart
// ❌ High-level module phụ thuộc low-level detail
AccountLockUtil().checkLocking();
PointExchangeProgressModel.load();
launchUrl(Uri.parse(url), ...);
TTPFirebaseAnalytics.logEvent(...);
```

Sau: Widget phụ thuộc **abstractions**, concrete được inject:

```dart
// ✅ Phụ thuộc abstraction
late final PointExchangeHandler _handler;        // interface
late final PointExchangeLifecycleHandler _lifecycle; // injectable
late final AccountLockChecker _lockChecker;      // injectable

// Factory resolve concrete implementation
_handler = ExchangeHandlerFactory.create(widget.model.provider);
```

### Kết quả thực tế

```
TRƯỚC                           SAU
─────                           ────
1 file, 1100 dòng              12 files, mỗi file 50-150 dòng
Thêm provider: sửa 5+ chỗ     Thêm provider: tạo 1 file mới
Test: phải mock mọi thứ        Test handler riêng, UI riêng
Merge conflict: thường xuyên   Mỗi người làm file riêng
Debug: scroll 1100 dòng        Đọc đúng file cần thiết
```
