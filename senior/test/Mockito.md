## Mockito trong Flutter/Dart — Hướng dẫn chi tiết

### 1. Setup

Thêm dependencies vào `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.9
```

Mockito trong Dart dùng **code generation** để tạo mock class. Khác với Mockito Java/Kotlin có thể tạo mock runtime, Dart cần generate trước vì Dart không hỗ trợ runtime reflection đầy đủ.

---

### 2. Tạo Mock — Cơ bản

Giả sử có repository:

```dart
// lib/repositories/point_exchange_repository.dart
abstract class PointExchangeRepository {
  Future<List<PointExchangeModel>> fetchExchanges();
  Future<bool> checkDuplicate({
    required List<int> amounts,
    required String providerType,
  });
  int calcExchangePoint({
    required int exchangePoint,
    required int exchangeRate,
    required int tokyoPointRate,
  });
}
```

Tạo file test với annotation `@GenerateMocks`:

```dart
// test/repositories/point_exchange_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:your_app/repositories/point_exchange_repository.dart';

@GenerateMocks([PointExchangeRepository])
import 'point_exchange_repository_test.mocks.dart';

void main() {
  late MockPointExchangeRepository mockRepo;

  setUp(() {
    mockRepo = MockPointExchangeRepository();
  });
}
```

Chạy code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Lệnh này tạo file `point_exchange_repository_test.mocks.dart` chứa class `MockPointExchangeRepository`.

---

### 3. Stubbing — Định nghĩa hành vi cho mock

#### 3.1 `when().thenReturn()` — Trả về giá trị đồng bộ

```dart
test('calcExchangePoint trả về giá trị đúng', () {
  when(mockRepo.calcExchangePoint(
    exchangePoint: 1000,
    exchangeRate: 5,
    tokyoPointRate: 10,
  )).thenReturn(500);

  final result = mockRepo.calcExchangePoint(
    exchangePoint: 1000,
    exchangeRate: 5,
    tokyoPointRate: 10,
  );

  expect(result, 500);
});
```

#### 3.2 `when().thenAnswer()` — Trả về Future hoặc Stream

```dart
test('fetchExchanges trả về danh sách', () async {
  final mockData = [
    PointExchangeModel(
      provider: PointExchangeProviderType.docomo,
      exchangeRate: 100,
      // ...
    ),
  ];

  // ❌ Sai — thenReturn không dùng được với Future
  // when(mockRepo.fetchExchanges()).thenReturn(mockData);

  // ✅ Đúng — dùng thenAnswer cho async
  when(mockRepo.fetchExchanges()).thenAnswer((_) async => mockData);

  final result = await mockRepo.fetchExchanges();
  expect(result.length, 1);
  expect(result.first.provider, PointExchangeProviderType.docomo);
});
```

#### 3.3 `when().thenThrow()` — Giả lập lỗi

```dart
test('fetchExchanges throw exception khi API lỗi', () async {
  when(mockRepo.fetchExchanges()).thenThrow(
    DbFailureException(),
  );

  expect(
    () => mockRepo.fetchExchanges(),
    throwsA(isA<DbFailureException>()),
  );
});

// Với async method, dùng thenAnswer + throw
test('fetchExchanges throw async exception', () async {
  when(mockRepo.fetchExchanges()).thenAnswer(
    (_) async => throw DbFailureException(),
  );

  expect(
    () async => await mockRepo.fetchExchanges(),
    throwsA(isA<DbFailureException>()),
  );
});
```

#### 3.4 Trả về giá trị khác nhau cho mỗi lần gọi

```dart
test('lần đầu lỗi, lần hai thành công (retry logic)', () async {
  var callCount = 0;

  when(mockRepo.fetchExchanges()).thenAnswer((_) async {
    callCount++;
    if (callCount == 1) {
      throw DbFailureException();
    }
    return [/* mock data */];
  });

  // Lần 1: throw
  expect(
    () async => await mockRepo.fetchExchanges(),
    throwsA(isA<DbFailureException>()),
  );

  // Lần 2: success
  final result = await mockRepo.fetchExchanges();
  expect(result, isNotEmpty);
});
```

---

### 4. Argument Matchers

#### 4.1 `any` — Khớp bất kỳ giá trị nào

```dart
// Khớp mọi input
when(mockRepo.checkDuplicate(
  amounts: anyNamed('amounts'),
  providerType: anyNamed('providerType'),
)).thenAnswer((_) async => false);
```

**Quy tắc quan trọng:** Nếu dùng matcher cho một argument, phải dùng matcher cho TẤT CẢ arguments:

```dart
// ❌ Sai — trộn lẫn giá trị thật và matcher
when(mockRepo.checkDuplicate(
  amounts: [100],                       // giá trị thật
  providerType: anyNamed('providerType'), // matcher
)).thenAnswer((_) async => false);

// ✅ Đúng — dùng matcher cho tất cả
when(mockRepo.checkDuplicate(
  amounts: anyNamed('amounts'),
  providerType: anyNamed('providerType'),
)).thenAnswer((_) async => false);
```

#### 4.2 `argThat()` — Matcher có điều kiện

```dart
when(mockRepo.checkDuplicate(
  amounts: argThat(isNotEmpty, named: 'amounts'),
  providerType: argThat(equals('docomo'), named: 'providerType'),
)).thenAnswer((_) async => true);
```

#### 4.3 `captureAnyNamed()` — Bắt argument để kiểm tra sau

```dart
test('verify request được tạo đúng', () async {
  when(mockRepo.checkDuplicate(
    amounts: anyNamed('amounts'),
    providerType: anyNamed('providerType'),
  )).thenAnswer((_) async => false);

  await someUseCase.execute(point: 500, provider: 'docomo');

  final captured = verify(mockRepo.checkDuplicate(
    amounts: captureAnyNamed('amounts'),
    providerType: captureAnyNamed('providerType'),
  )).captured;

  expect(captured[0], [500]);      // amounts
  expect(captured[1], 'docomo');   // providerType
});
```

---

### 5. Verification — Kiểm tra mock có được gọi đúng không

#### 5.1 `verify()` — Xác nhận đã gọi

```dart
test('exchange flow gọi checkDuplicate trước khi exchange', () async {
  when(mockRepo.checkDuplicate(
    amounts: anyNamed('amounts'),
    providerType: anyNamed('providerType'),
  )).thenAnswer((_) async => false);

  when(mockRepo.fetchExchanges()).thenAnswer((_) async => []);

  await useCase.execute();

  // Xác nhận checkDuplicate được gọi đúng 1 lần
  verify(mockRepo.checkDuplicate(
    amounts: anyNamed('amounts'),
    providerType: anyNamed('providerType'),
  )).called(1);

  // Xác nhận fetchExchanges được gọi
  verify(mockRepo.fetchExchanges()).called(1);
});
```

#### 5.2 `verifyNever()` — Xác nhận KHÔNG được gọi

```dart
test('khi duplicate thì không gọi exchange', () async {
  when(mockRepo.checkDuplicate(
    amounts: anyNamed('amounts'),
    providerType: anyNamed('providerType'),
  )).thenAnswer((_) async => true); // duplicate = true

  await useCase.execute();

  // Exchange không được gọi
  verifyNever(mockRepo.fetchExchanges());
});
```

#### 5.3 `verifyInOrder()` — Xác nhận thứ tự gọi

```dart
test('flow: check duplicate → delete auth → exchange', () async {
  // setup stubs...

  await useCase.executeAuExchange();

  verifyInOrder([
    mockRepo.checkDuplicate(
      amounts: anyNamed('amounts'),
      providerType: anyNamed('providerType'),
    ),
    mockAuthRepo.deleteAuthCodeForAu(),
    mockRepo.exchangePointForAu(any),
  ]);
});
```

#### 5.4 `verifyNoMoreInteractions()` — Không có lần gọi nào khác

```dart
test('chỉ gọi đúng các method cần thiết', () async {
  // ... execute test ...

  verify(mockRepo.fetchExchanges()).called(1);
  verifyNoMoreInteractions(mockRepo);
  // Nếu có bất kỳ method nào khác được gọi → test fail
});
```

---

### 6. Ví dụ thực tế — Test PointExchange Logic

#### 6.1 Setup cấu trúc test

```dart
// test/features/point_exchange/point_exchange_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  FirebaseFunctionsClient,
  ApigeeClient,
  // Mock cho Firestore cần cách khác — xem phần 7
])
import 'point_exchange_test.mocks.dart';

void main() {
  late MockFirebaseFunctionsClient mockFunctions;
  late MockApigeeClient mockApigee;

  setUp(() {
    mockFunctions = MockFirebaseFunctionsClient();
    mockApigee = MockApigeeClient();
  });

  group('exchangePointForDocomo', () {
    test('trả về response khi thành công', () async {
      final request = ExchangePointForDocomoRequest(/* ... */);
      final expectedResponse = ExchangePointForDocomoResponse(/* ... */);

      when(mockFunctions.exchangePointForDocomo(any))
          .thenAnswer((_) async => ApiResult.success(expectedResponse));

      final result = await mockFunctions.exchangePointForDocomo(request);

      result.when(
        success: (response) {
          expect(response, expectedResponse);
        },
        failure: (error) => fail('Expected success'),
      );
    });

    test('throw ApiIsAlreadyExistsException khi duplicate', () async {
      when(mockFunctions.exchangePointForDocomo(any)).thenAnswer(
        (_) async => ApiResult.failure(
          ApiError(code: 'already-exists', message: 'S022'),
        ),
      );

      // Test error handling logic
      // ...
    });
  });
}
```

#### 6.2 Test checkDuplicate logic

```dart
group('checkDuplicate', () {
  late MockFirebaseFirestore mockFirestore;

  test('trả về true khi có transaction trùng amount trong 1 phút', () async {
    // Giả lập data Firestore trả về
    final mockTransactions = [
      TransactionsDocumentData(
        to: 'docomo',
        operationType: 'SUB',
        operationId: 'OP27',
        status: TransactionStatus.general,
        mode: 1,
        amount: 500,
        paymentId: null,
        tranId: 'tran_001',
        createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
      ),
    ];

    // Dùng fake thay vì mock cho Firestore (xem phần 7)
    final result = await notifier.checkDuplicate(
      amounts: [500],
      providerType: PointExchangeProviderType.docomo,
    );

    expect(result, true);
  });

  test('trả về false khi không có transaction trùng', () async {
    // amounts khác với transaction đã có
    final result = await notifier.checkDuplicate(
      amounts: [999],
      providerType: PointExchangeProviderType.docomo,
    );

    expect(result, false);
  });
});
```

#### 6.3 Test calcExchangePoint

Method thuần logic, không cần mock:

```dart
group('calcExchangePoint', () {
  test('tính đúng với rate 5, tokyoPointRate 10', () {
    final result = notifier.calcExchangePoint(
      exchangePoint: 1000,
      exchangeRate: 5,
      tokyoPointRate: 10,
    );
    // 1000 * (5 / 10) = 500
    expect(result, 500);
  });

  test('làm tròn khi kết quả lẻ', () {
    final result = notifier.calcExchangePoint(
      exchangePoint: 100,
      exchangeRate: 3,
      tokyoPointRate: 7,
    );
    // 100 * (3 / 7) = 42.857... → round = 43
    expect(result, 43);
  });

  test('trả về 0 khi exchangePoint = 0', () {
    final result = notifier.calcExchangePoint(
      exchangePoint: 0,
      exchangeRate: 5,
      tokyoPointRate: 10,
    );
    expect(result, 0);
  });
});
```

#### 6.4 Test maskedIdentifier

```dart
group('maskedIdentifier', () {
  test('docomo — mask tất cả trừ 4 số cuối', () {
    final result = notifier.maskedIdentifier(
      type: PointExchangeProviderType.docomo,
      no: '1234567890',
    );
    expect(result, '＊＊＊＊＊＊7890');
  });

  test('au — mask tất cả trừ 5 số cuối', () {
    final result = notifier.maskedIdentifier(
      type: PointExchangeProviderType.au,
      no: '1234567890123456789',
    );
    expect(result, '＊＊＊＊＊＊＊＊＊＊＊＊＊＊56789');
  });

  test('au — pad left khi số ngắn hơn 19 ký tự', () {
    final result = notifier.maskedIdentifier(
      type: PointExchangeProviderType.au,
      no: '12345',
    );
    expect(result, '＊＊＊＊＊＊＊＊＊＊＊＊＊＊12345');
  });
});
```

---

### 7. Mock Firestore và Firebase — fake_cloud_firestore

Firestore có API phức tạp (collection → doc → get → snapshot). Mock bằng Mockito rất cồng kềnh. Dùng package `fake_cloud_firestore` thay thế:

```yaml
dev_dependencies:
  fake_cloud_firestore: ^3.0.3
```

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

test('getUsersSecureForAu trả về data khi document tồn tại', () async {
  final fakeFirestore = FakeFirebaseFirestore();

  // Seed data giả
  await fakeFirestore
      .collection('users')
      .doc('test_uid')
      .collection('secure')
      .doc('au')
      .set({
    'auNumber': '1234567890123456789',
    'createdAt': Timestamp.now(),
  });

  // Inject fakeFirestore vào code cần test
  // Cách 1: Truyền qua constructor
  final notifier = PointExchangeAsyncNotifier(
    firestore: fakeFirestore,
  );

  final result = await notifier.getUsersSecureForAu();
  expect(result, isNotNull);
  expect(result!.auNumber, '1234567890123456789');
});

test('getUsersSecureForAu trả về null khi document không tồn tại', () async {
  final fakeFirestore = FakeFirebaseFirestore();
  // Không seed data

  final notifier = PointExchangeAsyncNotifier(
    firestore: fakeFirestore,
  );

  final result = await notifier.getUsersSecureForAu();
  expect(result, isNull);
});
```

---

### 8. Mock với Riverpod — ProviderContainer

Test Riverpod provider bằng `ProviderContainer` với overrides:

```dart
test('PointExchangeAsyncNotifier build thành công', () async {
  final mockServices = [
    ServicesDocumentData(
      type: ServiceType.point,
      subType: ServiceSubType.main,
      exchangePointSettings: [/* ... */],
    ),
  ];

  final mockServiceOperator = ServiceOperatorsDocumentData(
    pointExchangePaymentServiceProviderSettings: /* ... */,
  );

  final container = ProviderContainer(
    overrides: [
      // Override servicesProvider trả về mock data
      servicesProvider.overrideWith((ref) async => mockServices),

      // Override serviceOperator
      serviceOperatorsStateNotifierProvider.overrideWith(
        (ref) => ServiceOperatorsNotifier()..state = mockServiceOperator,
      ),
    ],
  );
  addTearDown(container.dispose);

  // Đọc provider và chờ kết quả
  final result = await container.read(
    pointExchangeAsyncNotifierProvider.future,
  );

  expect(result, isNotEmpty);
  expect(result.first.provider, PointExchangeProviderType.docomo);
});

test('PointExchangeAsyncNotifier throw khi mainService null', () async {
  final container = ProviderContainer(
    overrides: [
      // Trả về list rỗng → mainService = null
      servicesProvider.overrideWith((ref) async => []),
      serviceOperatorsStateNotifierProvider.overrideWith(
        (ref) => ServiceOperatorsNotifier(),
      ),
    ],
  );
  addTearDown(container.dispose);

  expect(
    () async => await container.read(
      pointExchangeAsyncNotifierProvider.future,
    ),
    throwsA(isA<String>()),
  );
});
```

---

### 9. Các lỗi thường gặp

#### `MissingStubError` — Quên stub method

```dart
// ❌ Gọi method chưa được stub
test('lỗi MissingStubError', () {
  final mock = MockPointExchangeRepository();
  mock.fetchExchanges(); // MissingStubError!
});

// ✅ Fix: stub trước khi gọi
test('fix', () {
  final mock = MockPointExchangeRepository();
  when(mock.fetchExchanges()).thenAnswer((_) async => []);
  mock.fetchExchanges(); // OK
});

// ✅ Hoặc dùng @GenerateNiceMocks — tự trả về default value
@GenerateNiceMocks([MockSpec<PointExchangeRepository>()])
import '...mocks.dart';
// NiceMock: Future trả về Future.value(null), List trả về [], int trả về 0
```

#### Mock singleton/static method

Code hiện tại dùng nhiều singleton (`FirebaseFunctionsClient.instance`, `ApigeeClient.instance`). Không thể mock trực tiếp bằng Mockito. Cần refactor:

```dart
// ❌ Không mock được
class PointExchangeAsyncNotifier {
  Future<void> fetch() async {
    // Singleton — hard dependency
    final data = await FirebaseFunctionsClient.instance.getPointExchangeSettingInfo();
  }
}

// ✅ Inject dependency qua constructor hoặc Riverpod provider
final firebaseFunctionsProvider = Provider<FirebaseFunctionsClient>((ref) {
  return FirebaseFunctionsClient.instance;
});

class PointExchangeAsyncNotifier extends AutoDisposeAsyncNotifier<...> {
  @override
  Future<...> build() async {
    final functionsClient = ref.watch(firebaseFunctionsProvider);
    final data = await functionsClient.getPointExchangeSettingInfo();
    // ...
  }
}

// Test: override provider
final container = ProviderContainer(
  overrides: [
    firebaseFunctionsProvider.overrideWithValue(mockFunctionsClient),
  ],
);
```

#### Verify trên `any` nhưng muốn check argument cụ thể

```dart
// ❌ Verify chỉ biết method được gọi, không biết argument
verify(mockRepo.exchangePointForDocomo(any)).called(1);

// ✅ Dùng captureAny để bắt và kiểm tra
final captured = verify(
  mockRepo.exchangePointForDocomo(captureAny),
).captured;

final request = captured.first as ExchangePointForDocomoRequest;
expect(request.amount, 500);
expect(request.userId, 'user_123');
```

---

### 10. Tóm tắt workflow

Workflow viết test với Mockito cho project hiện tại:

Bước 1: Xác định class cần test và dependencies của nó. Bước 2: Tạo mock cho dependencies bằng `@GenerateMocks` hoặc `@GenerateNiceMocks`. Bước 3: Chạy `dart run build_runner build`. Bước 4: Trong `setUp()`, khởi tạo mock và stub các method cần thiết. Bước 5: Viết test case, gọi method cần test, dùng `expect` để kiểm tra kết quả. Bước 6: Dùng `verify` để đảm bảo dependencies được gọi đúng cách. Bước 7: Test cả happy path và error path (exception, null, empty list).

Với code point exchange hiện tại, ưu tiên test `calcExchangePoint`, `maskedIdentifier`, `splitAuNo` trước vì chúng là pure function, không cần mock. Sau đó mới test các method có dependency phức tạp hơn như `fetchPointExchange` và `checkDuplicate`.
