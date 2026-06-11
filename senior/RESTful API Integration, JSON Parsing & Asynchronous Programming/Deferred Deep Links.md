# Deferred Deep Links — Deep Dive

## 1. Phân biệt các loại Deep Link

Trước hết cần hiểu rõ 3 loại:

**a) Standard Deep Link** — app đã cài, đang chạy hoặc ở background:

```
User tap link → OS mở app → App nhận URI → Navigate
```

Đơn giản, không có gì phức tạp.

**b) Deferred Deep Link** — app CHƯA cài:

```
User tap link → App chưa cài → Mở Store → User install → Mở app lần đầu →
  ??? Bằng cách nào app biết user click link nào trước đó ???
  → Vẫn phải navigate đúng screen
```

Đây là vấn đề core: **context bị mất giữa lúc click link và lúc mở app**. Giữa 2 thời điểm đó, user đã qua App Store/Play Store, download, install — có thể mất vài phút đến vài ngày.

**c) Contextual Deep Link** — deferred + kèm metadata:

```
Link: https://app.link/product/123?referrer=alice&promo=SAVE20

User cài app xong, mở lên → app biết:
  - Navigate tới product/123
  - Ghi nhận alice là referrer
  - Tự động apply promo SAVE20
```

---

## 2. Branch.io giải quyết bài toán deferred deep link như thế nào?

Branch dùng kỹ thuật **fingerprinting + server-side matching**:

```
TRƯỚC KHI CÀI APP:
─────────────────────────────────────────────
1. User tap Branch link
2. Branch server ghi lại:
   - IP address
   - User agent (OS version, device model, browser)
   - Screen resolution
   - Timestamp
   - Link data: { screen: 'product', id: '123', promo: 'SAVE20' }
3. Redirect user → App Store / Play Store

SAU KHI CÀI VÀ MỞ APP:
─────────────────────────────────────────────
4. App khởi động → Branch SDK init
5. SDK gửi device fingerprint lên Branch server
6. Server match fingerprint → "À, device này click link kia 2 phút trước"
7. Server trả về link data cho SDK
8. App nhận data → navigate tới product/123
```

---

## 3. Vấn đề thực tế: Coordination Problem

Đây là phần **core** và **khó nhất**. Hãy xem app khởi động như thế nào:

```
App Launch (first time)
    │
    ├── Flutter engine init
    ├── runApp() → MaterialApp
    ├── Dependency injection setup
    ├── Branch SDK init ──────────────► Branch server
    ├── Auth check (token? onboarding?)          │
    ├── Router init                              │
    ├── Splash screen hiển thị                   │
    │                                            │
    │   ... 500ms - 3s ...                       │
    │                                            │
    │◄────────── Branch callback trả về data ────┘
    │
    ▼
    Navigate to... đâu?
```

### Race Condition xảy ra:

**Scenario 1 — Branch callback đến TRƯỚC khi app sẵn sàng:**

```
t=0ms     App start
t=100ms   Branch callback: { screen: 'product', id: '123' }
          → Router CHƯA init xong
          → DI container CHƯA sẵn sàng
          → Auth state CHƯA xác định
          → ❌ CRASH hoặc navigate fail
```

**Scenario 2 — Branch callback đến SAU khi app đã navigate:**

```
t=0ms     App start
t=500ms   App init xong → kiểm tra auth → đã login → navigate Home
t=800ms   Branch callback: { screen: 'product', id: '123' }
          → User đang ở Home rồi
          → Navigate tới product/123?
          → Nhưng nếu user chưa login thì sao?
          → Stack navigation đúng chưa? Back button sẽ đi đâu?
```

**Scenario 3 — First-time user cần onboarding:**

```
t=0ms     App start (first install)
t=300ms   Branch callback: { screen: 'product', id: '123' }
          → User chưa đăng ký/đăng nhập
          → Cần đi qua onboarding flow trước
          → Navigate product/123 NGAY thì user chưa có session
          → Lưu deep link data → chờ onboarding xong → rồi mới navigate
```

**Scenario 4 — Branch callback KHÔNG BAO GIỜ đến:**

```
t=0ms     App start
          Branch SDK init...
          ... chờ ...
          ... vẫn chờ ... (no internet? Branch server down?)
t=5000ms  → Không thể để user nhìn splash screen mãi
          → Cần timeout mechanism
```

---

## 4. Giải pháp: State Machine + Coordination Layer

### 4.1 Định nghĩa App Init State Machine

```dart
enum AppInitPhase {
  starting,          // Flutter engine, DI setup
  checkingAuth,      // Đọc token, validate session
  waitingDeepLink,   // Chờ Branch callback (có timeout)
  onboarding,        // First-time user flow
  ready,             // Mọi thứ sẵn sàng
}

class AppInitState {
  final AppInitPhase phase;
  final bool isAuthenticated;
  final bool onboardingCompleted;
  final DeepLinkData? pendingDeepLink;  // lưu tạm nếu chưa xử lý được
  final bool deepLinkResolved;          // Branch đã trả lời (hoặc timeout)
}
```

### 4.2 Deep Link Coordinator — trung tâm điều phối

```dart
class DeepLinkCoordinator {
  final BranchService _branchService;
  final AuthRepository _authRepo;
  final AppRouter _router;

  // Pending deep link — chờ app sẵn sàng mới xử lý
  DeepLinkData? _pendingDeepLink;

  // Completer: giải quyết race condition giữa Branch callback và app init
  final _deepLinkCompleter = Completer<DeepLinkData?>();

  // Trạng thái app
  bool _isAppReady = false;
  bool _isAuthenticated = false;

  /// Gọi ngay khi app start — bắt đầu lắng nghe Branch
  Future<void> init() async {
    // Lắng nghe deep links (cả deferred và standard)
    _branchService.onDeepLink.listen((data) {
      if (!_deepLinkCompleter.isCompleted) {
        _deepLinkCompleter.complete(data);
      } else {
        // App đang chạy, nhận link mới (standard deep link)
        _handleDeepLinkImmediate(data);
      }
    });

    // CRITICAL: Timeout — không chờ Branch mãi
    Future.delayed(const Duration(seconds: 3), () {
      if (!_deepLinkCompleter.isCompleted) {
        _deepLinkCompleter.complete(null); // không có deep link
      }
    });
  }

  /// Gọi sau khi auth check xong, trước khi navigate
  /// Returns: route mà app nên navigate tới
  Future<String> resolveInitialRoute({
    required bool isAuthenticated,
    required bool onboardingCompleted,
  }) async {
    _isAuthenticated = isAuthenticated;

    // ===== CHỜ BRANCH HOẶC TIMEOUT =====
    final deepLink = await _deepLinkCompleter.future;

    // ===== DECISION MATRIX =====

    // Case 1: Chưa onboarding → lưu deep link, đi onboarding
    if (!onboardingCompleted) {
      _pendingDeepLink = deepLink; // lưu để xử lý sau
      return '/onboarding';
    }

    // Case 2: Chưa login → lưu deep link, đi login
    if (!isAuthenticated) {
      _pendingDeepLink = deepLink; // lưu để xử lý sau
      return '/login';
    }

    // Case 3: Có deep link + đã sẵn sàng → navigate
    if (deepLink != null) {
      return _buildRouteFromDeepLink(deepLink);
    }

    // Case 4: Không có deep link → home
    return '/home';
  }

  /// Gọi sau khi user hoàn thành onboarding/login
  /// Kiểm tra xem có pending deep link không
  void onUserReady() {
    _isAppReady = true;
    _isAuthenticated = true;

    if (_pendingDeepLink != null) {
      _handleDeepLinkImmediate(_pendingDeepLink!);
      _pendingDeepLink = null;
    }
  }

  void _handleDeepLinkImmediate(DeepLinkData data) {
    final route = _buildRouteFromDeepLink(data);
    _router.go(route);
  }

  String _buildRouteFromDeepLink(DeepLinkData data) {
    return switch (data.type) {
      'product'  => '/home/product/${data.id}',
      'profile'  => '/home/profile/${data.id}',
      'promo'    => '/home/promo/${data.code}',
      _          => '/home',
    };
  }
}
```

### 4.3 Branch Service Wrapper

```dart
class BranchService {
  final _deepLinkController = StreamController<DeepLinkData>.broadcast();

  Stream<DeepLinkData> get onDeepLink => _deepLinkController.stream;

  Future<void> init() async {
    // === DEFERRED DEEP LINK (first open sau install) ===
    final params = await FlutterBranchSdk.getFirstReferringParams();
    if (_hasValidDeepLink(params)) {
      _deepLinkController.add(DeepLinkData.fromBranch(params));
    }

    // === STANDARD DEEP LINK (app đang chạy hoặc background) ===
    FlutterBranchSdk.listSession().listen((params) {
      if (_hasValidDeepLink(params)) {
        _deepLinkController.add(DeepLinkData.fromBranch(params));
      }
    });
  }

  bool _hasValidDeepLink(Map<dynamic, dynamic> params) {
    // Branch luôn trả callback, kể cả organic install
    // Cần filter: +clicked_branch_link phải là true
    return params['+clicked_branch_link'] == true;
  }
}
```

### 4.4 Tích hợp vào App Startup

```dart
class AppStartup {
  final DeepLinkCoordinator _deepLinkCoordinator;
  final AuthRepository _authRepo;
  final OnboardingRepository _onboardingRepo;

  Future<String> execute() async {
    // Bước 1: Khởi tạo DI, services
    await _initDependencies();

    // Bước 2: Bắt đầu lắng nghe Branch (KHÔNG await callback)
    await _deepLinkCoordinator.init();

    // Bước 3: Check auth & onboarding (song song với Branch)
    final isAuthenticated = await _authRepo.hasValidSession();
    final onboardingDone = await _onboardingRepo.isCompleted();

    // Bước 4: Resolve route (SẼ await Branch ở đây, có timeout)
    final initialRoute = await _deepLinkCoordinator.resolveInitialRoute(
      isAuthenticated: isAuthenticated,
      onboardingCompleted: onboardingDone,
    );

    return initialRoute;
  }
}

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final startup = getIt<AppStartup>();
  final initialRoute = await startup.execute();

  runApp(MyApp(initialRoute: initialRoute));
}
```

### 4.5 Xử lý pending deep link sau onboarding/login

```dart
class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingFlow(
      onComplete: () {
        // User hoàn thành onboarding
        final coordinator = getIt<DeepLinkCoordinator>();
        coordinator.onUserReady();
        // coordinator sẽ tự navigate nếu có pending deep link
        // nếu không có → navigate home
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  void _onLoginSuccess(BuildContext context) {
    final coordinator = getIt<DeepLinkCoordinator>();
    coordinator.onUserReady();
  }
}
```

---

## 5. Navigation Stack — Chi tiết quan trọng

Khi deep link navigate tới `/home/product/123`, navigation stack phải đúng:

```dart
// ❌ SAI — user bấm Back → đóng app (không có Home trong stack)
_router.go('/product/123');

// ✅ ĐÚNG — user bấm Back → về Home
_router.go('/home/product/123');
// Với GoRouter, nested route tự tạo stack đúng:
// Stack: [Home, Product(123)]
```

Cấu hình router:

```dart
GoRouter(
  initialLocation: initialRoute,
  routes: [
    ShellRoute(
      builder: (_, __, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => HomeScreen(),
          routes: [
            GoRoute(
              path: 'product/:id',
              builder: (_, state) => ProductScreen(
                id: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/onboarding', builder: (_, __) => OnboardingScreen()),
    GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
  ],
);
```

---

## 6. Full Timing Diagram — Happy Path

```
t=0ms     ┌─ App Launch ─────────────────────────────┐
          │  WidgetsFlutterBinding.ensureInitialized │
          │  DI container setup                      │
          └──────────────┬───────────────────────────┘
                         │
t=50ms    ┌──────────────▼───────────────────────────┐
          │  deepLinkCoordinator.init()              │
          │  → Branch SDK bắt đầu gọi server         │
          │  → Timeout timer 3s bắt đầu đếm          │
          └──────────────┬───────────────────────────┘
                         │
t=100ms   ┌──────────────▼───────────────────────────┐
          │  Auth check + Onboarding check (parallel)│
          │  → hasValidSession() = true              │
          │  → isOnboardingCompleted() = true        │
          └──────────────┬───────────────────────────┘
                         │
t=150ms   ┌──────────────▼───────────────────────────┐
          │  resolveInitialRoute()                   │
          │  → await _deepLinkCompleter.future       │
          │  → ĐANG CHỜ Branch...                    │
          └──────────────┬───────────────────────────┘
                         │ (chờ)
t=600ms   ┌──────────────▼───────────────────────────┐
          │  Branch callback arrives!                │
          │  { +clicked_branch_link: true,           │
          │    screen: 'product', id: '123',         │
          │    promo: 'SAVE20' }                     │
          │  → Completer.complete(data)              │
          └──────────────┬───────────────────────────┘
                         │
t=610ms   ┌──────────────▼───────────────────────────┐
          │  resolveInitialRoute() resumes           │
          │  → authenticated ✅                      │
          │  → onboarded ✅                          │
          │  → deepLink ✅                           │
          │  → return '/home/product/123'            │
          └──────────────┬───────────────────────────┘
                         │
t=620ms   ┌──────────────▼───────────────────────────┐
          │  runApp(MyApp(initialRoute:              │
          │    '/home/product/123'))                 │
          │  → User thấy Product screen ngay         │
          │  → Back → Home (stack đúng)              │
          └──────────────────────────────────────────┘

Tổng thời gian splash: ~620ms — user gần như không nhận ra
```

---

## 7. Edge Cases & Production Hardening

**a) Prevent duplicate handling:**

```dart
class DeepLinkCoordinator {
  String? _lastHandledLinkId;

  void _handleDeepLinkImmediate(DeepLinkData data) {
    // Branch có thể gọi callback nhiều lần cho cùng một link
    if (data.linkId == _lastHandledLinkId) return;
    _lastHandledLinkId = data.linkId;

    final route = _buildRouteFromDeepLink(data);
    _router.go(route);
  }
}
```

**b) Analytics attribution — lưu deep link params cho analytics:**

```dart
Future<String> resolveInitialRoute(...) async {
  final deepLink = await _deepLinkCompleter.future;

  if (deepLink != null) {
    // Ghi nhận attribution DÙ user chưa login
    _analyticsService.setAttribution(
      source: deepLink.channel,      // 'facebook', 'email'
      campaign: deepLink.campaign,   // 'summer_sale'
      referrer: deepLink.referrer,   // 'alice'
    );

    // Lưu promo code vào local storage
    if (deepLink.promoCode != null) {
      _promoStorage.savePendingPromo(deepLink.promoCode!);
    }
  }
  // ... routing logic
}
```

**c) Testing — mock Branch trong tests:**

```dart
// Interface cho DI
abstract class DeepLinkProvider {
  Stream<DeepLinkData> get onDeepLink;
  Future<Map<dynamic, dynamic>> getFirstReferringParams();
}

class BranchDeepLinkProvider implements DeepLinkProvider { /* real */ }
class MockDeepLinkProvider implements DeepLinkProvider { /* test */ }

// Trong test:
test('deferred deep link navigates to product after onboarding', () async {
  final mockProvider = MockDeepLinkProvider();

  // Giả lập: user click link product/123 → install → open
  mockProvider.emitDeferred(DeepLinkData(type: 'product', id: '123'));

  final coordinator = DeepLinkCoordinator(mockProvider, ...);
  await coordinator.init();

  final route = await coordinator.resolveInitialRoute(
    isAuthenticated: false,
    onboardingCompleted: false,
  );

  expect(route, '/onboarding');
  expect(coordinator.hasPendingDeepLink, true);

  // Simulate: user hoàn thành onboarding + login
  coordinator.onUserReady();

  verify(() => router.go('/home/product/123')).called(1);
});
```

---

## 8. Tóm tắt Decision Matrix

```
                    ┌─────────────┬──────────────┬──────────────┐
                    │ Has Deep    │ Authenticated│ Onboarded    │
                    │ Link?       │              │              │
                    ├─────────────┼──────────────┼──────────────┤
Scenario 1          │ ✅          │ ✅           │ ✅          │
→ Navigate deep     │             │              │              │
  link route        │             │              │              │
                    ├─────────────┼──────────────┼──────────────┤
Scenario 2          │ ✅          │ ✅           │ ❌          │
→ Save pending,     │             │              │              │
  go onboarding     │             │              │              │
                    ├─────────────┼──────────────┼──────────────┤
Scenario 3          │ ✅          │ ❌          │ ✅           │
→ Save pending,     │             │              │              │
  go login          │             │              │              │
                    ├─────────────┼──────────────┼──────────────┤
Scenario 4          │ ❌          │ ✅          │ ✅           │
→ Go home           │             │              │              │
                    ├─────────────┼──────────────┼──────────────┤
Scenario 5          │ Timeout     │ ✅          │ ✅           │
→ Go home           │             │              │              │
(treat as no link)  │             │              │              │
                    └─────────────┴──────────────┴──────────────┘
```

Bản chất bài toán này là **coordination giữa nhiều async sources** (Branch server, auth state, onboarding state) mà tất cả đều có thể sẵn sàng ở thời điểm khác nhau. `Completer` + timeout + pending queue là pattern chuẩn để giải quyết. Trong production, thêm analytics attribution và duplicate prevention để hệ thống robust.
