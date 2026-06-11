## Cài đặt Riverpod DevTools

### 1. Yêu cầu phiên bản

Riverpod DevTools extension chỉ hoạt động với **Riverpod 2.0+** và cần **Flutter 3.19+** (Dart 3.3+). Kiểm tra phiên bản hiện tại:

```bash
flutter --version
dart pub deps | grep riverpod
```

---

### 2. Thêm dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1   # nếu dùng code generation

dev_dependencies:
  riverpod_generator: ^2.6.3    # nếu dùng code generation
  riverpod_lint: ^2.6.3         # lint rules cho Riverpod
  custom_lint: ^0.7.0           # required by riverpod_lint
```

```bash
flutter pub get
```

---

### 3. Thêm RiverpodObserver

Đây là bước quan trọng nhất. DevTools extension cần observer để theo dõi state changes.

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      observers: [
        // Bật observer để DevTools nhận được events
        // Từ Riverpod 2.0+, DevTools extension tự hook vào
        // không cần custom observer cho DevTools
        
        // Tuy nhiên, thêm custom observer để debug log rất hữu ích:
        if (kDebugMode) _DebugProviderObserver(),
      ],
      child: const MyApp(),
    ),
  );
}

// Optional: Custom observer để log ra console
class _DebugProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    debugPrint('[Riverpod] ADDED: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint(
      '[Riverpod] UPDATED: ${provider.name ?? provider.runtimeType}\n'
      '  old: $previousValue\n'
      '  new: $newValue',
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    debugPrint('[Riverpod] DISPOSED: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    debugPrint(
      '[Riverpod] ERROR: ${provider.name ?? provider.runtimeType}\n'
      '  error: $error',
    );
  }
}
```

---

### 4. Mở Riverpod DevTools Extension

#### Cách 1: Từ Flutter DevTools trên browser

```
1. Chạy app ở debug mode: flutter run
2. Mở DevTools URL hiển thị trong terminal
3. Trên thanh tab của DevTools, tìm tab "Riverpod"
   (nằm cạnh các tab Performance, Memory, Network...)
4. Nếu không thấy tab → xem phần Troubleshooting bên dưới
```

#### Cách 2: Từ Android Studio

```
1. Chạy app debug mode
2. View → Tool Windows → Flutter Inspector
3. Click "Open DevTools in Browser"
4. Trong browser, chọn tab "Riverpod"
```

#### Cách 3: Từ VS Code

```
1. Chạy app debug mode
2. Cmd+Shift+P → "Dart: Open DevTools"
3. Chọn "Open DevTools in Browser"
4. Chọn tab "Riverpod"
```

---

### 5. Sử dụng Riverpod DevTools

#### 5.1 Provider List

Panel bên trái hiển thị tất cả provider đang active:

```
Active Providers:
├── servicesProvider                    AsyncData<List<ServicesDocumentData>>
├── serviceOperatorsStateNotifierProvider  ServiceOperatorsDocumentData?
├── pointExchangeAsyncNotifierProvider  AsyncData<List<PointExchangeModel>>
├── usersStateNotifierProvider          UsersDocumentData?
├── merchantsStateNotifierProvider      MerchantsState
├── newsCategoriesStateNotifierProvider List<NewsCategoriesDocumentData>
└── newsStateNotifierProvider           List<NewsDocumentData>
```

Click vào provider → panel phải hiển thị chi tiết state.

#### 5.2 Provider Detail

Click vào `pointExchangeAsyncNotifierProvider`:

```
Name: pointExchangeAsyncNotifierProvider
Type: AutoDisposeAsyncNotifierProvider<List<PointExchangeModel>>
State: AsyncData

Value:
  List<PointExchangeModel> (3 items)
  ├── [0]:
  │   ├── provider: PointExchangeProviderType.docomo
  │   ├── paymentServiceProviderName: "dポイント"
  │   ├── exchangeRate: 100
  │   ├── tokyoPointRate: 1
  │   └── maxExchangePointPerUse: 10000
  ├── [1]:
  │   ├── provider: PointExchangeProviderType.rakuten
  │   ├── paymentServiceProviderName: "楽天ポイント"
  │   ├── exchangeRate: 80
  │   └── tokyoPointRate: 1
  └── [2]:
      ├── provider: PointExchangeProviderType.au
      ├── paymentServiceProviderName: "au PAY"
      ├── exchangeRate: 110
      └── auPayDisplayName: "au PAY マーケット"
```

#### 5.3 Provider Graph

Hiển thị dependency graph giữa các provider:

```
┌─────────────────────┐     ┌──────────────────────────────────┐
│  servicesProvider    │────→│  pointExchangeAsyncNotifierProvider │
└─────────────────────┘     └──────────────────────────────────┘
                                          ↑
┌─────────────────────────────────┐       │
│ serviceOperatorsStateNotifier   │───────┘
│ Provider                        │
└─────────────────────────────────┘
```

Giúp bạn thấy rõ khi `servicesProvider` thay đổi, provider nào bị rebuild theo.

#### 5.4 State Timeline

Hiển thị lịch sử thay đổi state theo thời gian:

```
14:23:01.100  pointExchangeAsyncNotifierProvider
              AsyncLoading → AsyncData (3 items)

14:23:05.200  pointExchangeAsyncNotifierProvider
              AsyncData (3 items) → AsyncLoading (refresh)

14:23:05.800  pointExchangeAsyncNotifierProvider
              AsyncLoading → AsyncData (3 items)

14:25:00.000  pointExchangeAsyncNotifierProvider
              AsyncData → DISPOSED (navigate ra)

14:25:02.000  pointExchangeAsyncNotifierProvider
              CREATED → AsyncLoading (navigate vào lại)
```

---

### 6. Troubleshooting

#### Tab Riverpod không hiển thị trong DevTools

**Nguyên nhân 1: Phiên bản cũ**

```bash
# Kiểm tra version
dart pub deps | grep flutter_riverpod
# Cần >= 2.4.0 để extension hoạt động tốt

# Upgrade
flutter pub upgrade flutter_riverpod
```

**Nguyên nhân 2: DevTools cũ**

```bash
# Update DevTools
dart pub global activate devtools

# Hoặc update Flutter (DevTools đi kèm Flutter SDK)
flutter upgrade
```

**Nguyên nhân 3: Extension chưa được enable**

Trong DevTools browser → click biểu tượng gear (Settings) ở góc phải → **Extensions** → kiểm tra "Riverpod" đã được enable chưa. Nếu hiển thị "Available extensions" → click **Enable**.

**Nguyên nhân 4: App không chạy debug mode**

```bash
# ❌ Profile/Release mode — DevTools extensions không hoạt động
flutter run --profile
flutter run --release

# ✅ Debug mode
flutter run
flutter run --debug
```

**Nguyên nhân 5: Thiếu ProviderScope**

```dart
// ❌ Không có ProviderScope → Riverpod không hoạt động
void main() {
  runApp(const MyApp());
}

// ✅ Phải wrap trong ProviderScope
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

#### Extension hiển thị nhưng không có data

**Nguyên nhân: Provider chưa được read/watch**

Riverpod là lazy — provider chỉ khởi tạo khi có ai đó read hoặc watch. Nếu chưa navigate vào màn hình point exchange, `pointExchangeAsyncNotifierProvider` sẽ không xuất hiện trong DevTools.

Navigate vào màn hình tương ứng → provider sẽ xuất hiện.

#### State hiển thị "Instance of 'ClassName'" thay vì chi tiết

Thêm `toString()` override cho model:

```dart
class PointExchangeModel {
  final PointExchangeProviderType provider;
  final int exchangeRate;
  // ...

  @override
  String toString() {
    return 'PointExchangeModel('
        'provider: $provider, '
        'exchangeRate: $exchangeRate, '
        'tokyoPointRate: $tokyoPointRate'
        ')';
  }
}
```

Hoặc dùng `freezed` / `equatable` — chúng tự generate `toString()`:

```dart
@freezed
class PointExchangeModel with _$PointExchangeModel {
  const factory PointExchangeModel({
    required PointExchangeProviderType provider,
    required int exchangeRate,
    required int tokyoPointRate,
    // ...
  }) = _PointExchangeModel;
}
// freezed tự tạo toString() có đầy đủ field values
```

---

### 7. Kết hợp riverpod_lint

`riverpod_lint` cung cấp lint rules giúp phát hiện lỗi Riverpod tại compile time:

```yaml
# analysis_options.yaml
analyzer:
  plugins:
    - custom_lint
```

```bash
# Chạy lint
dart run custom_lint
```

Các rule hữu ích nó phát hiện:

```dart
// ⚠️ riverpod_lint: avoid_ref_inside_state_dispose
// Không dùng ref trong dispose
@override
void dispose() {
  ref.read(someProvider); // WARNING
  super.dispose();
}

// ⚠️ riverpod_lint: provider_dependencies
// Provider phụ thuộc nhau nhưng chưa khai báo
@Riverpod(dependencies: [servicesProvider]) // phải khai báo
class PointExchangeAsyncNotifier extends _$PointExchangeAsyncNotifier {
  @override
  Future<List<PointExchangeModel>> build() async {
    final services = await ref.watch(servicesProvider.future);
    // ...
  }
}

// ⚠️ riverpod_lint: avoid_manual_providers_as_generated_provider_dependency  
// Dùng ref.read thay vì ref.watch → state không auto refresh
serviceOperator = ref.read(serviceOperatorsStateNotifierProvider); // WARNING
```

---

### 8. Thực hành debug project hiện tại

Sau khi cài xong, thực hành:

**Bài 1: Kiểm tra provider lifecycle**

Mở Riverpod tab → navigate vào màn hình point exchange → observe `pointExchangeAsyncNotifierProvider` xuất hiện với state `AsyncLoading` → chuyển sang `AsyncData`. Navigate ra → observe provider bị DISPOSED (vì `autoDispose`). Navigate vào lại → observe provider CREATED lại và gọi API lần nữa.

Nếu thấy provider không dispose khi navigate ra → có widget đang giữ reference.

**Bài 2: Kiểm tra dependency chain**

Mở Provider Graph → xác nhận `pointExchangeAsyncNotifierProvider` phụ thuộc `servicesProvider`. Invalidate `servicesProvider` (bằng code hoặc hot restart) → observe cả chain rebuild.

**Bài 3: Debug state bất thường**

Mở State Timeline → thực hiện exchange → observe state chuyển qua các phase: `AsyncData` → `AsyncLoading` (fetchPointExchange gọi lại) → `AsyncData` mới. Nếu state chuyển sang `AsyncError` → xem error message trong detail panel để biết nguyên nhân.
