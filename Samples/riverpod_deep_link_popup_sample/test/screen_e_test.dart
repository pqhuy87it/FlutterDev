import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_deep_link_sample/app_link_controller.dart';
import 'package:riverpod_deep_link_sample/app_link_repository.dart';
import 'package:riverpod_deep_link_sample/navigation_service.dart';
import 'package:riverpod_deep_link_sample/screen_e.dart';

// --- 1. TẠO CÁC MOCK CLASSES ---

class MockAppLinkRepository extends Mock implements AppLinkRepository {}

class MockNavigationService extends Mock implements NavigationService {}

class MockScreenEController extends StateNotifier<ScreenEEvent>
    with Mock
    implements ScreenEController {
  MockScreenEController() : super(InitialEvent());
}
void main() {
  late ProviderContainer container;
  late MockAppLinkRepository mockRepo;
  late MockNavigationService mockNavService;
  late MockScreenEController mockScreenEController;
  late StreamController<Uri> uriStreamController;

  setUp(() {
    // 1. Khởi tạo các Mock và StreamController
    mockRepo = MockAppLinkRepository();
    mockNavService = MockNavigationService();
    mockScreenEController = MockScreenEController();
    uriStreamController = StreamController<Uri>.broadcast();

    // 2. Giả lập hành vi cho Repository (trả về stream của chúng ta)
    when(() => mockRepo.uriStream).thenAnswer((_) => uriStreamController.stream);

    // 3. Khởi tạo ProviderContainer với các Override
    container = ProviderContainer(
      overrides: [
        appLinkRepositoryProvider.overrideWithValue(mockRepo),
        navigationServiceProvider.overrideWithValue(mockNavService),
        // Override Controller để bắt được lệnh gọi ref.read(...).onDeepLinkReceived
        screenEControllerProvider.overrideWith((ref) => mockScreenEController),
        // (Nếu code bạn có dùng screenEProvider thì override nó luôn, nếu không thì bỏ qua)
        // screenEProvider.overrideWith((ref) => mockScreenENotifier),
      ],
    );

    // 4. QUAN TRỌNG: Khởi tạo Controller để nó bắt đầu lắng nghe Stream
    // Vì Provider là void nên ta chỉ cần read nó 1 lần để hàm body chạy
    container.read(appLinkControllerProvider);
  });

  tearDown(() {
    uriStreamController.close();
    container.dispose();
  });

  group('appLinkControllerProvider Logic', () {

    // TEST CASE 1: Link KHÔNG chứa '/e'
    test('Should DO NOTHING if uri path does not contain "/e"', () async {
      // Arrange
      final uri = Uri.parse('myapp://home');

      // Act
      uriStreamController.add(uri);
      await Future.microtask(() {}); // Chờ stream xử lý

      // Assert
      // Đảm bảo không có hàm nào của logic Screen E được gọi
      verifyNever(() => mockNavService.isAtScreenE);
      verifyNever(() => mockNavService.requestNavigateToE(any()));
      verifyNever(() => mockScreenEController.onDeepLinkReceived(any()));
    });

    // TEST CASE 2: Link chứa '/e' VÀ Đang ở màn hình E (isAtScreenE = true)
    test('Should call onDeepLinkReceived if at Screen E', () async {
      // Arrange
      final uri = Uri.parse('myapp://example.com/e?data=hello_world');
      // Giả lập đang ở màn hình E
      when(() => mockNavService.isAtScreenE).thenReturn(true);

      // Act
      uriStreamController.add(uri);
      await Future.microtask(() {}); // Chờ stream xử lý

      // Assert
      // 1. Kiểm tra xem đã check vị trí chưa
      verify(() => mockNavService.isAtScreenE).called(1);

      // 2. Kiểm tra xem hàm onDeepLinkReceived có được gọi với đúng data không
      verify(() => mockScreenEController.onDeepLinkReceived('hello_world')).called(1);

      // 3. Đảm bảo KHÔNG gọi hàm chuyển trang
      verifyNever(() => mockNavService.requestNavigateToE(any()));
    });

    // TEST CASE 3: Link chứa '/e' VÀ KHÔNG ở màn hình E (isAtScreenE = false)
    test('Should call requestNavigateToE if NOT at Screen E', () async {
      // Arrange
      final uri = Uri.parse('myapp://example.com/e?data=hello_world');
      // Giả lập KHÔNG ở màn hình E
      when(() => mockNavService.isAtScreenE).thenReturn(false);

      // Act
      uriStreamController.add(uri);
      await Future.microtask(() {});

      // Assert
      verify(() => mockNavService.isAtScreenE).called(1);

      // 1. Kiểm tra hàm điều hướng có được gọi đúng data không
      verify(() => mockNavService.requestNavigateToE('hello_world')).called(1);

      // 2. Đảm bảo KHÔNG gọi hàm xử lý tại chỗ
      verifyNever(() => mockScreenEController.onDeepLinkReceived(any()));
    });

    // TEST CASE 4: Kiểm tra xử lý data null/empty
    test('Should handle missing query parameters gracefully', () async {
      // Arrange
      final uri = Uri.parse('myapp://example.com/e'); // Không có ?data=...
      when(() => mockNavService.isAtScreenE).thenReturn(false);

      // Act
      uriStreamController.add(uri);
      await Future.microtask(() {});

      // Assert
      // Kiểm tra xem data truyền vào có phải là chuỗi rỗng '' như logic (?? '') không
      verify(() => mockNavService.requestNavigateToE('')).called(1);
    });
  });
}
