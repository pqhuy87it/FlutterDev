```Swift
// ============================================================
// FLUTTER INTEGRATION TEST TRÊN iOS & ANDROID — CHI TIẾT
// ============================================================
//
// Integration Test (trước gọi Driver Test) chạy app THẬT
// trên emulator/simulator/device, tương tác UI như USER THẬT.
//
// Flutter testing pyramid:
// ┌─────────────────────────────────────────┐
// │        Integration Tests                │ ← Ít nhất, chậm nhất
// │     (Full app, real device/emulator)     │    Test CRITICAL FLOWS
// ├─────────────────────────────────────────┤
// │          Widget Tests                   │ ← Trung bình
// │     (Single widget, no device needed)   │    Test UI components
// ├─────────────────────────────────────────┤
// │           Unit Tests                    │ ← Nhiều nhất, nhanh nhất
// │     (Pure logic, no UI)                 │    Test functions/classes
// └─────────────────────────────────────────┘
//
// Integration Test kiểm tra:
// - Full user flows (login → home → detail → back)
// - Navigation hoạt động đúng
// - API integration (real hoặc mock server)
// - Platform-specific behaviors
// - Performance (frame rates, scroll smoothness)
// ============================================================


// ╔══════════════════════════════════════════════════════════╗
// ║  1. PROJECT SETUP                                        ║
// ╚══════════════════════════════════════════════════════════╝

// === 1a. Thêm dependency ===
// pubspec.yaml:
//
// dev_dependencies:
//   integration_test:
//     sdk: flutter
//   flutter_test:
//     sdk: flutter
//
// Chạy: flutter pub get

// === 1b. Tạo cấu trúc thư mục ===
//
// my_app/
// ├── lib/
// │   ├── main.dart
// │   ├── screens/
// │   │   ├── login_screen.dart
// │   │   ├── home_screen.dart
// │   │   └── detail_screen.dart
// │   ├── widgets/
// │   └── services/
// ├── test/                        ← Unit + Widget tests
// │   └── ...
// ├── integration_test/            ← Integration tests ở ĐÂY
// │   ├── app_test.dart            ← Test entry point
// │   ├── login_flow_test.dart
// │   ├── home_flow_test.dart
// │   ├── robots/                  ← Page Object pattern
// │   │   ├── login_robot.dart
// │   │   ├── home_robot.dart
// │   │   └── base_robot.dart
// │   └── helpers/
// │       ├── test_helper.dart
// │       └── mock_data.dart
// └── test_driver/                 ← Cho screenshot/perf tests
//     └── integration_test.dart


// ╔══════════════════════════════════════════════════════════╗
// ║  2. TEST CƠ BẢN — VIẾT TEST ĐẦU TIÊN                    ║
// ╚══════════════════════════════════════════════════════════╝

// === File: integration_test/app_test.dart ===

/*
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;

void main() {
  // BẮT BUỘC: khởi tạo integration test binding
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {

    // === 2a. Test đơn giản nhất ===
    testWidgets('App launches successfully', (tester) async {
      // 1. Launch app
      app.main();
      
      // 2. Chờ app render xong
      await tester.pumpAndSettle();
      // pumpAndSettle(): chờ TẤT CẢ animations + futures hoàn thành
      // pump(): chỉ render 1 frame
      // pumpAndSettle(timeout): chờ với timeout

      // 3. Assert
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    // === 2b. Test login flow ===
    testWidgets('Login with valid credentials shows home', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tìm và nhập email
      final emailField = find.byKey(const Key('login_email_field'));
      expect(emailField, findsOneWidget);
      await tester.enterText(emailField, 'huy@example.com');

      // Tìm và nhập password
      final passwordField = find.byKey(const Key('login_password_field'));
      await tester.enterText(passwordField, 'password123');

      // Đóng keyboard (quan trọng trên mobile!)
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Tap login button
      final loginButton = find.byKey(const Key('login_submit_button'));
      await tester.tap(loginButton);

      // Chờ navigation + API call
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert: home screen hiện
      expect(find.byKey(const Key('home_screen')), findsOneWidget);
      expect(find.text('Xin chào, Huy!'), findsOneWidget);
    });

    // === 2c. Test login failure ===
    testWidgets('Login with wrong password shows error', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'wrong@email.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'wrongpassword',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert: error message hiện
      expect(find.text('Sai email hoặc mật khẩu'), findsOneWidget);
      
      // Assert: vẫn ở login screen
      expect(find.byKey(const Key('login_screen')), findsOneWidget);
    });
  });
}
*/


// ╔══════════════════════════════════════════════════════════╗
// ║  3. FINDERS — TÌM WIDGETS                                ║
// ╚══════════════════════════════════════════════════════════╝

/*
// === 3a. Tìm bằng Key (KHUYẾN KHÍCH NHẤT) ===
find.byKey(const Key('login_button'))
find.byKey(const ValueKey('item_123'))
find.byKey(const ValueKey<int>(42))

// === 3b. Tìm bằng Text ===
find.text('Đăng nhập')              // Exact match
find.textContaining('Xin chào')     // Contains
find.widgetWithText(ElevatedButton, 'Submit')  // Text trong widget type

// === 3c. Tìm bằng Type ===
find.byType(ElevatedButton)
find.byType(TextField)
find.byType(CircularProgressIndicator)

// === 3d. Tìm bằng Icon ===
find.byIcon(Icons.home)
find.byIcon(Icons.delete)

// === 3e. Tìm bằng Tooltip ===
find.byTooltip('Thêm mới')

// === 3f. Tìm bằng Semantic label ===
find.bySemanticsLabel('Email input field')
find.bySemanticsLabel(RegExp('.*email.*'))  // Regex

// === 3g. Tìm bằng Predicate ===
find.byWidgetPredicate(
  (widget) => widget is Text && (widget as Text).data?.contains('Hello') == true,
)

// === 3h. Tìm con/cha ===
find.descendant(
  of: find.byKey(const Key('user_card')),
  matching: find.text('Huy'),
)
// Tìm Text "Huy" BÊN TRONG widget có key "user_card"

find.ancestor(
  of: find.text('Delete'),
  matching: find.byType(ListTile),
)
// Tìm ListTile CHỨA Text "Delete"

// === 3i. Tìm element thứ N ===
find.byType(ListTile).at(0)  // ListTile đầu tiên
find.byType(ListTile).at(2)  // ListTile thứ 3

// === 3j. First / Last ===
find.byType(ListTile).first
find.byType(ListTile).last
*/


// ╔══════════════════════════════════════════════════════════╗
// ║  4. INTERACTIONS — TƯƠNG TÁC VỚI WIDGETS                 ║
// ╚══════════════════════════════════════════════════════════╝

/*
// === 4a. Tap ===
await tester.tap(find.byKey(const Key('submit_btn')));
await tester.pumpAndSettle();

// Tap tại vị trí cụ thể (offset từ center)
await tester.tapAt(const Offset(100, 200));

// Long press
await tester.longPress(find.byKey(const Key('item_cell')));
await tester.pumpAndSettle();

// Double tap
await tester.tap(find.byKey(const Key('photo')));
await tester.tap(find.byKey(const Key('photo')));

// === 4b. Text Input ===
// Nhập text (THÊM vào nội dung hiện tại)
await tester.enterText(find.byKey(const Key('email_field')), 'huy@example.com');

// Clear rồi nhập
final field = find.byKey(const Key('search_field'));
await tester.tap(field);
// Select all + delete
await tester.enterText(field, ''); // Clear
await tester.enterText(field, 'new query');

// Keyboard actions
await tester.testTextInput.receiveAction(TextInputAction.done);    // Done
await tester.testTextInput.receiveAction(TextInputAction.next);    // Next field
await tester.testTextInput.receiveAction(TextInputAction.search);  // Search

// === 4c. Scroll ===
// Drag gesture (scroll)
await tester.drag(
  find.byType(ListView),
  const Offset(0, -500),  // Scroll xuống 500px
);
await tester.pumpAndSettle();

// Scroll cho đến khi tìm thấy widget
await tester.scrollUntilVisible(
  find.text('Item 99'),     // Tìm element này
  500,                       // Scroll 500px mỗi lần
  scrollable: find.byType(Scrollable).first,
);

// Fling (scroll nhanh)
await tester.fling(
  find.byType(ListView),
  const Offset(0, -1000),  // Hướng + tốc độ
  2000,                     // Velocity
);
await tester.pumpAndSettle();

// === 4d. Swipe ===
// Swipe to dismiss / delete
await tester.drag(
  find.byKey(const Key('item_cell_1')),
  const Offset(-500, 0),  // Swipe trái
);
await tester.pumpAndSettle();

// Swipe phải
await tester.drag(
  find.byKey(const Key('item_cell_1')),
  const Offset(500, 0),
);

// === 4e. Pull to Refresh ===
await tester.drag(
  find.byType(RefreshIndicator),
  const Offset(0, 300),   // Kéo xuống
);
await tester.pumpAndSettle(const Duration(seconds: 3));

// === 4f. Pinch / Zoom ===
// Không có built-in pinch — dùng tester.startGesture()
final center = tester.getCenter(find.byKey(const Key('map')));
final gesture1 = await tester.startGesture(center + const Offset(0, -50));
final gesture2 = await tester.startGesture(center + const Offset(0, 50));
// Move fingers apart (zoom in)
await gesture1.moveBy(const Offset(0, -100));
await gesture2.moveBy(const Offset(0, 100));
await gesture1.up();
await gesture2.up();
await tester.pumpAndSettle();
*/


// ╔══════════════════════════════════════════════════════════╗
// ║  5. ASSERTIONS — KIỂM TRA KẾT QUẢ                        ║
// ╚══════════════════════════════════════════════════════════╝

/*
// === 5a. Existence ===
expect(find.text('Hello'), findsOneWidget);      // Chính xác 1
expect(find.text('Hello'), findsWidgets);         // ≥ 1
expect(find.text('Hello'), findsNothing);         // 0
expect(find.text('Hello'), findsNWidgets(3));     // Chính xác 3
expect(find.text('Hello'), findsAtLeast(2));      // ≥ 2 (Flutter 3.x)

// === 5b. Widget properties ===
final textWidget = tester.widget<Text>(find.byKey(const Key('title')));
expect(textWidget.data, 'Xin chào');
expect(textWidget.style?.fontSize, 24);

// TextField value
final textField = tester.widget<TextField>(find.byKey(const Key('email')));
expect(textField.controller?.text, 'huy@example.com');

// ElevatedButton enabled/disabled
final button = tester.widget<ElevatedButton>(find.byKey(const Key('submit')));
expect(button.onPressed, isNotNull);  // Enabled
expect(button.onPressed, isNull);     // Disabled

// === 5c. Visibility (widget tồn tại nhưng có thể offscreen) ===
// findsOneWidget chỉ check trong widget tree, KHÔNG check visibility
// Để check visible trên screen:
final element = find.byKey(const Key('item'));
expect(element, findsOneWidget);
// Check nếu widget đang visible trong viewport
final renderObject = tester.renderObject(element);
expect(renderObject.paintBounds.isEmpty, isFalse);

// === 5d. Wait for condition ===
// pumpAndSettle chờ animations + microtasks
await tester.pumpAndSettle();

// Chờ với timeout
await tester.pumpAndSettle(const Duration(seconds: 10));

// Pump từng frame (khi pumpAndSettle timeout — có animation loop)
await tester.pump(const Duration(milliseconds: 500));
await tester.pump(const Duration(milliseconds: 500));

// Custom wait loop
bool found = false;
for (int i = 0; i < 50; i++) {
  await tester.pump(const Duration(milliseconds: 100));
  if (tester.any(find.text('Loaded'))) {
    found = true;
    break;
  }
}
expect(found, isTrue);
*/


// ╔══════════════════════════════════════════════════════════╗
// ║  6. KEY SETUP TRONG APP CODE — CẦU NỐI VỚI TESTS        ║
// ╚══════════════════════════════════════════════════════════╝

// Gắn Key cho MỌI element cần test.
// Keys là CẦU NỐI DUY NHẤT giữa test và app code.

/*
// === lib/screens/login_screen.dart ===

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('login_screen'),  // ← Screen identifier
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('login_email_field'),  // ← Cho test tìm
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Nhập email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            TextField(
              key: const Key('login_password_field'),
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
            ),
            const SizedBox(height: 8),
            
            if (_error != null)
              Text(
                _error!,
                key: const Key('login_error_text'),
                style: const TextStyle(color: Colors.red),
              ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('login_submit_button'),
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        key: Key('login_loading_indicator'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Đăng nhập'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      await AuthService().login(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }
}
*/

// KEY NAMING CONVENTION:
// {screen}_{element}_{type}
// login_email_field
// login_submit_button
// home_item_{id}_tile
// home_search_field
// detail_back_button
// settings_theme_picker


// ╔══════════════════════════════════════════════════════════╗
// ║  7. ROBOT PATTERN — PAGE OBJECT CHO FLUTTER               ║
// ╚══════════════════════════════════════════════════════════╝

// Robot = Page Object cho Flutter tests.
// Mỗi screen = 1 Robot class.
// Tests gọi robot methods, KHÔNG query widgets trực tiếp.

/*
// === integration_test/robots/base_robot.dart ===

import 'package:flutter_test/flutter_test.dart';

class BaseRobot {
  final WidgetTester tester;
  
  const BaseRobot(this.tester);
  
  // ─── Shared helpers ───
  
  Future<void> waitForUI() async {
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }
  
  Future<void> tapByKey(String key) async {
    final finder = find.byKey(Key(key));
    expect(finder, findsOneWidget, reason: 'Widget with key "$key" not found');
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
  
  Future<void> enterTextByKey(String key, String text) async {
    final finder = find.byKey(Key(key));
    expect(finder, findsOneWidget);
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }
  
  Future<void> scrollUntilFound(String key, {int maxScrolls = 20}) async {
    final finder = find.byKey(Key(key));
    int scrolls = 0;
    while (scrolls < maxScrolls && !tester.any(finder)) {
      await tester.drag(
        find.byType(Scrollable).first,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      scrolls++;
    }
    expect(finder, findsOneWidget, reason: 'Widget "$key" not found after scrolling');
  }
  
  void expectExists(String key) {
    expect(find.byKey(Key(key)), findsOneWidget);
  }
  
  void expectNotExists(String key) {
    expect(find.byKey(Key(key)), findsNothing);
  }
  
  void expectText(String text) {
    expect(find.text(text), findsWidgets);
  }
}


// === integration_test/robots/login_robot.dart ===

import 'base_robot.dart';

class LoginRobot extends BaseRobot {
  const LoginRobot(super.tester);
  
  // ─── Assertions ───
  
  void verifyOnLoginScreen() {
    expectExists('login_screen');
    expectExists('login_email_field');
    expectExists('login_password_field');
    expectExists('login_submit_button');
  }
  
  void verifyErrorMessage(String message) {
    expectExists('login_error_text');
    expectText(message);
  }
  
  void verifyNoError() {
    expectNotExists('login_error_text');
  }
  
  void verifyLoading() {
    expectExists('login_loading_indicator');
  }
  
  // ─── Actions ───
  
  Future<void> enterEmail(String email) async {
    await enterTextByKey('login_email_field', email);
  }
  
  Future<void> enterPassword(String password) async {
    await enterTextByKey('login_password_field', password);
  }
  
  Future<void> tapLogin() async {
    await tapByKey('login_submit_button');
  }
  
  Future<void> dismissKeyboard() async {
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }
  
  // ─── Flows (high-level actions) ───
  
  Future<HomeRobot> loginWithCredentials(String email, String password) async {
    await enterEmail(email);
    await enterPassword(password);
    await dismissKeyboard();
    await tapLogin();
    await tester.pumpAndSettle(const Duration(seconds: 5));
    return HomeRobot(tester);
  }
  
  Future<void> attemptLoginExpectingError(String email, String password) async {
    await enterEmail(email);
    await enterPassword(password);
    await dismissKeyboard();
    await tapLogin();
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }
}


// === integration_test/robots/home_robot.dart ===

class HomeRobot extends BaseRobot {
  const HomeRobot(super.tester);
  
  void verifyOnHomeScreen() {
    expectExists('home_screen');
  }
  
  void verifyWelcomeMessage(String name) {
    expectText('Xin chào, $name!');
  }
  
  void verifyItemCount(int count) {
    final cells = find.byKey(const Key('home_item_tile'));
    // Hoặc count specific items
  }
  
  Future<DetailRobot> tapItem(String id) async {
    await tapByKey('home_item_${id}_tile');
    return DetailRobot(tester);
  }
  
  Future<void> deleteItem(String id) async {
    // Swipe to delete
    await tester.drag(
      find.byKey(Key('home_item_${id}_tile')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await tapByKey('confirm_delete_button');
  }
  
  Future<void> pullToRefresh() async {
    await tester.drag(
      find.byType(Scrollable).first,
      const Offset(0, 300),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }
  
  Future<void> search(String query) async {
    await enterTextByKey('home_search_field', query);
  }
  
  Future<ProfileRobot> goToProfile() async {
    await tapByKey('home_profile_button');
    return ProfileRobot(tester);
  }
}

class DetailRobot extends BaseRobot {
  const DetailRobot(super.tester);
  void verifyOnDetailScreen() => expectExists('detail_screen');
  Future<void> goBack() async => await tapByKey('detail_back_button');
}

class ProfileRobot extends BaseRobot {
  const ProfileRobot(super.tester);
  Future<LoginRobot> logout() async {
    await tapByKey('logout_button');
    await tapByKey('confirm_logout_button');
    return LoginRobot(tester);
  }
}


// === Tests SỬ DỤNG Robots ===
// File: integration_test/login_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;
import 'robots/login_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow', () {
    testWidgets('successful login', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final login = LoginRobot(tester);
      login.verifyOnLoginScreen();

      // Fluent: login trả về HomeRobot
      final home = await login.loginWithCredentials(
        'huy@example.com',
        'password123',
      );

      home.verifyOnHomeScreen();
      home.verifyWelcomeMessage('Huy');
    });

    testWidgets('login failure shows error', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final login = LoginRobot(tester);
      await login.attemptLoginExpectingError('wrong@email.com', 'wrong');
      
      login.verifyErrorMessage('Sai email hoặc mật khẩu');
      login.verifyOnLoginScreen(); // Vẫn ở login
    });

    testWidgets('login then logout returns to login', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final login = LoginRobot(tester);
      final home = await login.loginWithCredentials('huy@example.com', 'pass');
      home.verifyOnHomeScreen();

      final profile = await home.goToProfile();
      final backToLogin = await profile.logout();
      
      backToLogin.verifyOnLoginScreen();
    });
  });
}
*/


// ╔══════════════════════════════════════════════════════════╗
// ║  8. CHẠY TESTS — COMMANDS                                ║
// ╚══════════════════════════════════════════════════════════╝

// === 8a. Chạy trên device/emulator đang kết nối ===

// # Chạy TẤT CẢ integration tests
// flutter test integration_test

// # Chạy file cụ thể
// flutter test integration_test/login_flow_test.dart

// # Chạy trên device cụ thể
// flutter test integration_test --device-id=emulator-5554    # Android
// flutter test integration_test --device-id=iPhone-16-Pro    # iOS Sim

// # Liệt kê devices
// flutter devices

// === 8b. Chạy trên Android ===

// # Emulator phải đang chạy
// flutter emulators --launch Pixel_7_API_34
// flutter test integration_test

// # Hoặc trên device thật (USB connected + debug enabled)
// flutter test integration_test --device-id=DEVICE_SERIAL

// === 8c. Chạy trên iOS Simulator ===

// # Mở simulator
// open -a Simulator
// # Hoặc chọn device cụ thể
// xcrun simctl boot "iPhone 16 Pro"

// flutter test integration_test

// === 8d. Chạy trên iOS Device thật ===

// # Cần: Apple Developer account + provisioning profile
// # Device phải trust máy Mac + Developer Mode ON
// flutter test integration_test --device-id=IPHONE_UDID

// === 8e. Chạy với flavor/environment ===

// flutter test integration_test \
//   --dart-define=ENVIRONMENT=staging \
//   --dart-define=API_URL=https://staging.api.com

// # Với flavor (Android productFlavors / iOS schemes)
// flutter test integration_test --flavor staging


// ╔══════════════════════════════════════════════════════════╗
// ║  9. TEST CONFIGURATION — MOCK / STAGING / FLAGS           ║
// ╚══════════════════════════════════════════════════════════╝

/*
// === 9a. Environment flags trong app ===
// File: lib/config/test_config.dart

class TestConfig {
  static bool get isIntegrationTest {
    return const bool.fromEnvironment('INTEGRATION_TEST', defaultValue: false);
  }
  
  static String get apiBaseUrl {
    return const String.fromEnvironment(
      'API_URL',
      defaultValue: 'https://api.production.com',
    );
  }
}

// Chạy: flutter test integration_test \
//         --dart-define=INTEGRATION_TEST=true \
//         --dart-define=API_URL=http://localhost:8080


// === 9b. Custom test app entry point ===
// File: integration_test/test_app.dart

import 'package:my_app/app.dart';
import 'package:my_app/services/auth_service.dart';

/// Entry point cho integration tests
/// Inject mock dependencies
Future<void> launchTestApp() async {
  // Override API base URL
  ApiConfig.baseUrl = 'http://localhost:8080';
  
  // Hoặc inject mock services
  // ServiceLocator.register<AuthService>(MockAuthService());
  
  runApp(const MyApp());
}


// === 9c. setUp / tearDown ===

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Chạy TRƯỚC mỗi test
    // Reset app state
    // Clear SharedPreferences
    SharedPreferences.setMockInitialValues({});
    // Clear database
    // Reset mock server state
  });

  tearDown(() async {
    // Chạy SAU mỗi test
    // Cleanup resources
  });

  setUpAll(() async {
    // Chạy 1 LẦN trước TẤT CẢ tests
    // Start mock server
    // Seed database
  });

  tearDownAll(() async {
    // Chạy 1 LẦN sau TẤT CẢ tests
    // Stop mock server
  });
}
*/


// ╔══════════════════════════════════════════════════════════╗
// ║  10. SCREENSHOTS — CHỤP ẢNH MÀN HÌNH                     ║
// ╚══════════════════════════════════════════════════════════╝

/*
// === 10a. Chụp screenshot trong test ===

testWidgets('capture login screen', (tester) async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  app.main();
  await tester.pumpAndSettle();

  // Chụp screenshot
  await binding.takeScreenshot('01_login_screen');
  
  // Login
  await tester.enterText(find.byKey(const Key('email')), 'huy@test.com');
  await tester.enterText(find.byKey(const Key('password')), 'pass123');
  await tester.pumpAndSettle();
  
  await binding.takeScreenshot('02_login_filled');
  
  await tester.tap(find.byKey(const Key('submit')));
  await tester.pumpAndSettle(const Duration(seconds: 5));
  
  await binding.takeScreenshot('03_home_screen');
});


// === 10b. test_driver cho screenshot output ===
// File: test_driver/integration_test.dart

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      // Lưu screenshot vào file
      final File image = File('screenshots/$name.png');
      image.parent.createSync(recursive: true);
      image.writeAsBytesSync(bytes);
      return true;
    },
  );
}

// Chạy: flutter drive \
//   --driver=test_driver/integration_test.dart \
//   --target=integration_test/screenshot_test.dart \
//   --device-id=...
*/


// ╔══════════════════════════════════════════════════════════╗
// ║  11. PERFORMANCE TESTING                                  ║
// ╚══════════════════════════════════════════════════════════╝

/*
testWidgets('scroll performance', (tester) async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  app.main();
  await tester.pumpAndSettle();

  // Navigate to list screen
  await tester.tap(find.byKey(const Key('list_tab')));
  await tester.pumpAndSettle();

  // Record performance trace
  await binding.traceAction(
    () async {
      // Scroll liên tục
      for (int i = 0; i < 5; i++) {
        await tester.fling(
          find.byType(ListView),
          const Offset(0, -500),
          1500,
        );
        await tester.pumpAndSettle();
      }
    },
    reportKey: 'scroll_performance',
  );
  
  // Kết quả lưu trong timeline summary:
  // - Average frame build time
  // - Worst frame build time
  // - 90th/99th percentile
  // - Frame count
});

// Chạy performance test:
// flutter drive \
//   --driver=test_driver/perf_test_driver.dart \
//   --target=integration_test/perf_test.dart \
//   --profile  ← QUAN TRỌNG: chạy ở profile mode cho metrics chính xác
*/


// ╔══════════════════════════════════════════════════════════╗
// ║  12. PLATFORM-SPECIFIC NOTES                              ║
// ╚══════════════════════════════════════════════════════════╝

// === Android ===
// ✅ Chạy trên emulator hoặc device
// ✅ Không cần setup đặc biệt
// ⚠️ Emulator chậm hơn device → tăng timeouts
// ⚠️ Permission dialogs: xử lý bằng adb
//    adb shell pm grant com.myapp android.permission.CAMERA
// ⚠️ Keyboard overlay: dùng tester.testTextInput thay soft keyboard
// Tip: chạy emulator headless cho CI:
//    emulator -avd Pixel_7 -no-window -no-audio

// === iOS ===
// ✅ Chạy trên Simulator (không cần Apple account)
// ✅ Chạy trên device (cần provisioning + Apple account)
// ⚠️ Simulator KHÔNG hỗ trợ: camera, push notifications, biometric
// ⚠️ Parallel testing trên iOS Simulator hạn chế
// ⚠️ Permission dialogs: reset simulator state trước mỗi test
//    xcrun simctl privacy booted reset all com.myapp
// Tip: boot simulator trước khi test:
//    xcrun simctl boot "iPhone 16 Pro"

// === pumpAndSettle ISSUES ===
// pumpAndSettle TIMEOUT khi có:
// - AnimationController repeat forever (loading spinners)
// - Timer.periodic
// - Stream liên tục emit
//
// FIX: pump() từng frame thay pumpAndSettle:
// await tester.pump(const Duration(seconds: 2));
// Hoặc tắt animations trong test mode


// ╔══════════════════════════════════════════════════════════╗
// ║  13. CI/CD INTEGRATION                                    ║
// ╚══════════════════════════════════════════════════════════╝

// === 13a. GitHub Actions — Android ===
//
// name: Integration Tests (Android)
// on: [push, pull_request]
// jobs:
//   integration-test-android:
//     runs-on: ubuntu-latest
//     steps:
//       - uses: actions/checkout@v4
//       - uses: subosito/flutter-action@v2
//         with:
//           flutter-version: '3.24.0'
//           channel: 'stable'
//       
//       - name: Enable KVM (faster emulator)
//         run: |
//           echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules
//           sudo udevadm control --reload-rules
//           sudo udevadm trigger --name-match=kvm
//       
//       - name: Run Integration Tests
//         uses: reactivecircus/android-emulator-runner@v2
//         with:
//           api-level: 34
//           arch: x86_64
//           profile: Pixel 7
//           script: flutter test integration_test --timeout 600

// === 13b. GitHub Actions — iOS ===
//
// name: Integration Tests (iOS)
// on: [push, pull_request]
// jobs:
//   integration-test-ios:
//     runs-on: macos-15
//     steps:
//       - uses: actions/checkout@v4
//       - uses: subosito/flutter-action@v2
//         with:
//           flutter-version: '3.24.0'
//
//       - name: Boot iOS Simulator
//         run: |
//           DEVICE_ID=$(xcrun simctl list devices available -j | \
//             python3 -c "import sys,json; devices=json.load(sys.stdin)['devices']; \
//             print([d['udid'] for r in devices.values() for d in r if 'iPhone 16' in d['name']][0])")
//           xcrun simctl boot "$DEVICE_ID"
//
//       - name: Run Integration Tests
//         run: flutter test integration_test --timeout 600

// === 13c. Codemagic ===
// codemagic.yaml:
// workflows:
//   integration-tests:
//     name: Integration Tests
//     instance_type: mac_mini_m2
//     environment:
//       flutter: stable
//       xcode: latest
//     scripts:
//       - name: Run Android Tests
//         script: |
//           emulator -avd test_device -no-window &
//           adb wait-for-device
//           flutter test integration_test
//       - name: Run iOS Tests  
//         script: |
//           xcrun simctl boot "iPhone 16 Pro"
//           flutter test integration_test


// ╔══════════════════════════════════════════════════════════╗
// ║  14. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: pumpAndSettle timeout vì infinite animation
//    CircularProgressIndicator() → pumpAndSettle CHẠY MÃI
//    ✅ FIX: pump(Duration) thay pumpAndSettle khi có loader
//            Hoặc ẩn loader khi chạy integration test mode

// ❌ PITFALL 2: Test flaky vì timing
//    API chậm → element chưa hiện → assert fail
//    ✅ FIX: Tăng timeout: pumpAndSettle(Duration(seconds: 10))
//            Custom wait loop cho async content
//            Mock API trả về ngay

// ❌ PITFALL 3: Keyboard che widget
//    enterText → keyboard mở → button bị che → tap fail
//    ✅ FIX: Dismiss keyboard trước khi tap:
//            await tester.testTextInput.receiveAction(TextInputAction.done);
//            Hoặc scroll đến element sau khi dismiss keyboard

// ❌ PITFALL 4: Tests phụ thuộc lẫn nhau
//    Test A tạo data → Test B dựa vào data đó
//    ✅ FIX: Mỗi test SELF-CONTAINED
//            setUp() reset state hoàn toàn

// ❌ PITFALL 5: find.text() tìm NHIỀU matches
//    expect(find.text('OK'), findsOneWidget) // FAIL: 3 buttons có "OK"
//    ✅ FIX: Dùng find.byKey() thay find.text()
//            Hoặc find.widgetWithText(ElevatedButton, 'OK')
//            Hoặc find.descendant(of: ..., matching: find.text('OK'))

// ❌ PITFALL 6: iOS Simulator permission dialogs
//    Alert "Allow Notifications" → test stuck
//    ✅ FIX: Reset permissions trước test:
//            xcrun simctl privacy booted reset all com.myapp
//            Hoặc grant trước: xcrun simctl privacy booted grant ...

// ❌ PITFALL 7: Android emulator quá chậm trên CI
//    x86_64 emulator không có GPU acceleration
//    ✅ FIX: Enable KVM: reactivecircus/android-emulator-runner
//            Hoặc dùng Firebase Test Lab (real devices)

// ❌ PITFALL 8: Quên IntegrationTestWidgetsFlutterBinding
//    → Tests CRASH ngay lập tức
//    ✅ FIX: LUÔN gọi đầu tiên trong main():
//            IntegrationTestWidgetsFlutterBinding.ensureInitialized();

// ✅ BEST PRACTICES:
// 1. Key cho MỌI testable element: Key('screen_element_type')
// 2. Robot Pattern: 1 screen = 1 Robot class
// 3. pumpAndSettle với timeout ĐỦ LỚN cho API calls
// 4. pump() khi có infinite animations (spinners)
// 5. Dismiss keyboard trước khi tap buttons
// 6. Mock/staging API cho consistent test data
// 7. setUp() reset state — mỗi test independent
// 8. Screenshots cho failed tests (debug trên CI)
// 9. --profile mode cho performance tests
// 10. CI: Android dùng KVM, iOS dùng pre-booted simulator
// 11. Test CRITICAL FLOWS: login, core features, checkout
// 12. KHÔNG test mọi thứ — integration test CHỈ cho E2E flows
//     Unit test cho logic, Widget test cho components
```

---

Đây là chủ đề quan trọng cho Flutter production — integration test chạy app thật trên emulator/device, tương tác như user thật. Mình sẽ giải thích toàn bộ từ setup, viết test, chạy trên cả 2 platforms, đến CI/CD.Mình đã tổng hợp toàn bộ kiến thức Flutter Integration Test trong 14 phần. Đây là những điểm cốt lõi:

**Integration Test chạy app thật** trên emulator/simulator/device, tương tác UI như user thật — khác Unit Test (logic thuần) và Widget Test (single component). Dùng `integration_test` package (built-in SDK), không cần 3rd party.

**Năm phần giá trị nhất cho production:**

**Phần 2 & 6 — Setup + Keys**: `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` là dòng đầu tiên bắt buộc. Mọi testable widget phải có `Key('screen_element_type')` — đây là **cầu nối duy nhất** giữa test và app code. Dùng `find.byKey()` thay `find.text()` để test không vỡ khi thay đổi text/localization.

**Phần 7 — Robot Pattern**: Equivalent của Page Object trong mobile testing. Mỗi screen = 1 Robot class chứa elements + actions + assertions. Tests gọi `loginRobot.loginWithCredentials()` thay vì query widgets trực tiếp. UI thay đổi → sửa **1 Robot**, không sửa 20 test files. Fluent API: `login.loginWith(...) → home.tapProfile() → profile.logout()`.

**Phần 5 — pumpAndSettle vs pump**: `pumpAndSettle()` chờ tất cả animations + async hoàn thành — nhưng **timeout nếu có infinite animation** (CircularProgressIndicator, shimmer). Fix bằng `pump(Duration)` pump từng frame cụ thể. Đây là nguồn flaky tests số 1 trong Flutter.

**Phần 8 — Chạy trên cả 2 platforms**: Cùng 1 test file chạy cho cả iOS và Android bằng `flutter test integration_test`. Android cần emulator đang chạy, iOS cần Simulator đã boot. Với device thật: Android cần USB debug, iOS cần provisioning profile. `--device-id` chọn device cụ thể.

**Phần 13 — CI/CD**: Android trên GitHub Actions dùng `reactivecircus/android-emulator-runner` + KVM acceleration. iOS chạy trên `macos-15` runner + pre-boot simulator bằng `xcrun simctl boot`. Codemagic hỗ trợ cả hai platforms native. Quan trọng: `--timeout 600` cho CI vì emulator chậm hơn local.

**Pitfall #1 quan trọng nhất**: `pumpAndSettle()` chạy mãi không dừng khi app có loading spinner (`CircularProgressIndicator`) — vì nó chờ **mọi animation dừng**. Fix: dùng `pump(Duration(seconds: 2))` thay pumpAndSettle ở những screen có loaders, hoặc tắt animations trong integration test mode.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
