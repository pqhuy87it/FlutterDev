## Mocktail trong Flutter/Dart — Hướng dẫn chi tiết

### 1. Tại sao Mocktail thay vì Mockito?

Mockito trong Dart cần chạy `build_runner` để generate mock class. Mocktail không cần code generation — tạo mock bằng cách extend class `Mock` trực tiếp. Điều này giúp viết test nhanh hơn, không cần chờ generate, không bị lỗi file `.mocks.dart` outdated.

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
```

So sánh nhanh:

```dart
// Mockito — cần annotation + build_runner
@GenerateMocks([PointExchangeRepository])
import 'test.mocks.dart';
// → chạy: dart run build_runner build

// Mocktail — viết trực tiếp, không generate
class MockPointExchangeRepository extends Mock
    implements PointExchangeRepository {}
```

---

### 2. Tạo Mock

#### 2.1 Mock class thông thường

```dart
import 'package:mocktail/mocktail.dart';

// Abstract class hoặc concrete class đều mock được
class MockFirebaseFunctionsClient extends Mock
    implements FirebaseFunctionsClient {}

class MockApigeeClient extends Mock implements ApigeeClient {}

// Mock cho Riverpod Ref
class MockRef extends Mock implements Ref {}
```

#### 2.2 Mock class có generic type

```dart
// Mock cho class có generic
class MockStateNotifier extends Mock
    implements StateNotifier<ServiceOperatorsDocumentData?> {}

// Mock cho Future/Stream provider
class MockAsyncNotifier extends Mock
    implements AutoDisposeAsyncNotifier<List<PointExchangeModel>> {}
```

#### 2.3 Fake class — Khi cần truyền làm argument

Mocktail yêu cầu **register fallback value** cho mỗi custom type được dùng với `any()`. Dùng `Fake` cho việc này:

```dart
// Fake — lightweight hơn Mock, dùng làm fallback value
class FakeExchangePointForDocomoRequest extends Fake
    implements ExchangePointForDocomoRequest {}

class FakeExchangePointForAuRequest extends Fake
    implements ExchangePointForAuRequest {}

class FakeIsAuNumberAlreadyExistRequest extends Fake
    implements IsAuNumberAlreadyExistRequest {}

// Register trong setUpAll — chạy MỘT LẦN trước tất cả test
void main() {
  setUpAll(() {
    registerFallbackValue(FakeExchangePointForDocomoRequest());
    registerFallbackValue(FakeExchangePointForAuRequest());
    registerFallbackValue(FakeIsAuNumberAlreadyExistRequest());
  });
}
```

**Tại sao cần `registerFallbackValue`?** Khi bạn viết `when(() => mock.method(any()))`, Mocktail cần truyền một giá trị thực vào `method()` để set up stub. Fallback value chính là giá trị đó. Không register → runtime error.

---

### 3. Stubbing — Định nghĩa hành vi

Điểm khác biệt lớn nhất với Mockito: **Mocktail wrap lời gọi trong lambda**.

```dart
// Mockito: when(mock.method()).thenReturn(value)
// Mocktail: when(() => mock.method()).thenReturn(value)
//           ^^^                  ^^^
//           lambda bọc ngoài
```

#### 3.1 `when().thenReturn()` — Giá trị đồng bộ

```dart
test('calcExchangePoint', () {
  final mockRepo = MockPointExchangeRepository();

  when(() => mockRepo.calcExchangePoint(
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

#### 3.2 `when().thenAnswer()` — Future / async

```dart
test('fetchExchanges trả về danh sách', () async {
  final mockClient = MockFirebaseFunctionsClient();
  final mockData = [
    PointExchangeSettingsDocumentData(
      paymentServiceProvider: 'docomo',
      status: 1,
      // ...
    ),
  ];

  when(() => mockClient.getPointExchangeSettingInfo())
      .thenAnswer((_) async => mockData);

  final result = await mockClient.getPointExchangeSettingInfo();
  expect(result.length, 1);
});
```

#### 3.3 `when().thenThrow()` — Giả lập lỗi

```dart
test('throw DbFailureException khi API lỗi', () async {
  when(() => mockClient.getPointExchangeSettingInfo())
      .thenThrow(DbFailureException());

  expect(
    () => mockClient.getPointExchangeSettingInfo(),
    throwsA(isA<DbFailureException>()),
  );
});

// Với async — dùng thenAnswer + throw
test('throw async exception', () async {
  when(() => mockClient.getPointExchangeSettingInfo())
      .thenAnswer((_) async => throw DbFailureException());

  expect(
    () async => await mockClient.getPointExchangeSettingInfo(),
    throwsA(isA<DbFailureException>()),
  );
});
```

#### 3.4 Trả về giá trị khác nhau mỗi lần gọi

```dart
test('lần đầu lỗi, lần hai thành công', () async {
  var callCount = 0;

  when(() => mockClient.getPointExchangeSettingInfo())
      .thenAnswer((_) async {
    callCount++;
    if (callCount == 1) throw DbFailureException();
    return [/* mock data */];
  });

  // Lần 1
  expect(
    () async => await mockClient.getPointExchangeSettingInfo(),
    throwsA(isA<DbFailureException>()),
  );

  // Lần 2
  final result = await mockClient.getPointExchangeSettingInfo();
  expect(result, isNotEmpty);
});
```

#### 3.5 Stream stubbing

```dart
class MockFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

test('listen to Firestore snapshots', () {
  final mockCollection = MockCollectionReference();
  final controller = StreamController<QuerySnapshot>();

  when(() => mockCollection.snapshots(
    includeMetadataChanges: any(named: 'includeMetadataChanges'),
  )).thenAnswer((_) => controller.stream);

  // Emit fake snapshot
  controller.add(fakeSnapshot);

  // Cleanup
  addTearDown(() => controller.close());
});
```

---

### 4. Argument Matchers

#### 4.1 `any()` — Khớp bất kỳ giá trị nào

```dart
// Positional argument
when(() => mockClient.exchangePointForDocomo(any()))
    .thenAnswer((_) async => ApiResult.success(mockResponse));

// Named argument
when(() => mockRepo.checkDuplicate(
  amounts: any(named: 'amounts'),
  providerType: any(named: 'providerType'),
)).thenAnswer((_) async => false);
```

**Khác với Mockito:** Mocktail cho phép trộn giá trị thật và matcher:

```dart
// ✅ Mocktail cho phép — Mockito thì không
when(() => mockRepo.checkDuplicate(
  amounts: [100, 200],                    // giá trị thật
  providerType: any(named: 'providerType'), // matcher
)).thenAnswer((_) async => true);
```

#### 4.2 `any(that:)` — Matcher có điều kiện

```dart
// amounts phải không rỗng
when(() => mockRepo.checkDuplicate(
  amounts: any(named: 'amounts', that: isNotEmpty),
  providerType: any(named: 'providerType', that: equals('docomo')),
)).thenAnswer((_) async => true);

// Custom matcher
when(() => mockClient.exchangePointForAu(
  any(that: predicate<ExchangePointForAuRequest>(
    (req) => req.keyType == PointExchangeAuKeyType.pin.id,
  )),
)).thenAnswer((_) async => ApiResult.success(mockResponse));
```

#### 4.3 Capture arguments

```dart
test('verify request body đúng', () async {
  when(() => mockClient.exchangePointForDocomo(any()))
      .thenAnswer((_) async => ApiResult.success(mockResponse));

  await notifier.exchangePointForDocomo(request);

  final captured = verify(
    () => mockClient.exchangePointForDocomo(captureAny()),
  ).captured;

  final sentRequest = captured.first as ExchangePointForDocomoRequest;
  expect(sentRequest.amount, 500);
  expect(sentRequest.userId, 'user_123');
});

// Capture named argument
final captured = verify(
  () => mockRepo.checkDuplicate(
    amounts: captureAny(named: 'amounts'),
    providerType: captureAny(named: 'providerType'),
  ),
).captured;

expect(captured[0], [500]);
expect(captured[1], 'docomo');
```

---

### 5. Verification

#### 5.1 `verify` — Xác nhận đã gọi

```dart
test('exchange gọi đúng flow', () async {
  when(() => mockClient.exchangePointForDocomo(any()))
      .thenAnswer((_) async => ApiResult.success(mockResponse));

  await notifier.exchangePointForDocomo(request);

  // Gọi đúng 1 lần
  verify(() => mockClient.exchangePointForDocomo(any())).called(1);
});
```

#### 5.2 `verifyNever` — Xác nhận KHÔNG gọi

```dart
test('khi duplicate thì không gọi exchange', () async {
  when(() => mockRepo.checkDuplicate(
    amounts: any(named: 'amounts'),
    providerType: any(named: 'providerType'),
  )).thenAnswer((_) async => true);

  await useCase.execute();

  verifyNever(() => mockClient.exchangePointForDocomo(any()));
});
```

#### 5.3 `verifyInOrder` — Xác nhận thứ tự

```dart
test('au exchange: check duplicate → delete auth → exchange', () async {
  // stubs...

  await notifier.exchangePointForAu(request);

  verifyInOrder([
    () => mockClient.isAuNumberAlreadyExist(any()),
    () => mockClient.deleteAuthCodeForAu(),
    () => mockClient.exchangePointForAu(any()),
  ]);
});
```

#### 5.4 `verifyNoMoreInteractions` — Không gọi thêm gì

```dart
verify(() => mockClient.getPointExchangeSettingInfo()).called(1);
verifyNoMoreInteractions(mockClient);
```

---

### 6. Reset Mock

```dart
test('reset giữa các test case', () {
  // Xóa tất cả stubs và recorded interactions
  reset(mockClient);

  // Hoặc trong setUp
  setUp(() {
    reset(mockClient);
    reset(mockApigee);
  });
});
```

Khác biệt giữa 3 loại reset:

```dart
// Xóa stubs + interactions + captured args
reset(mock);

// Chỉ xóa recorded interactions, giữ stubs
resetMocktailState(); // reset TẤT CẢ mock (global)

// Trong thực tế, tạo mock mới trong setUp là cách phổ biến nhất
setUp(() {
  mockClient = MockFirebaseFunctionsClient();
  // Mock mới = clean state, không cần reset
});
```

---

### 7. Ví dụ thực tế — Test PointExchange

#### 7.1 File test hoàn chỉnh

```dart
// test/features/point_exchange/point_exchange_notifier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockFirebaseFunctionsClient extends Mock
    implements FirebaseFunctionsClient {}

class MockApigeeClient extends Mock implements ApigeeClient {}

// Fakes cho registerFallbackValue
class FakeExchangePointForDocomoRequest extends Fake
    implements ExchangePointForDocomoRequest {}

class FakeExchangePointForAuRequest extends Fake
    implements ExchangePointForAuRequest {}

class FakeIsAuNumberAlreadyExistRequest extends Fake
    implements IsAuNumberAlreadyExistRequest {}

void main() {
  late MockFirebaseFunctionsClient mockFunctions;
  late MockApigeeClient mockApigee;

  setUpAll(() {
    registerFallbackValue(FakeExchangePointForDocomoRequest());
    registerFallbackValue(FakeExchangePointForAuRequest());
    registerFallbackValue(FakeIsAuNumberAlreadyExistRequest());
  });

  setUp(() {
    mockFunctions = MockFirebaseFunctionsClient();
    mockApigee = MockApigeeClient();
  });

  // Tests go here...
}
```

#### 7.2 Test exchangePointForDocomo

```dart
group('exchangePointForDocomo', () {
  final request = ExchangePointForDocomoRequest(
    amount: 500,
    userId: 'user_123',
  );

  test('trả về response khi Firebase Functions thành công', () async {
    final expectedResponse = ExchangePointForDocomoResponse(
      transactionId: 'txn_001',
    );

    // Apigee OFF
    when(() => mockApigee.useApigee).thenReturn(false);

    when(() => mockFunctions.exchangePointForDocomo(any()))
        .thenAnswer((_) async => ApiResult.success(expectedResponse));

    final notifier = PointExchangeAsyncNotifier();
    // inject mocks...

    final result = await notifier.exchangePointForDocomo(request);
    expect(result.transactionId, 'txn_001');

    verify(() => mockFunctions.exchangePointForDocomo(any())).called(1);
    verifyNever(() => mockApigee.exchangePointForDocomo(any()));
  });

  test('trả về response khi Apigee thành công', () async {
    final expectedResponse = ExchangePointForDocomoResponse(
      transactionId: 'txn_002',
    );

    // Apigee ON
    when(() => mockApigee.useApigee).thenReturn(true);

    when(() => mockApigee.exchangePointForDocomo(any()))
        .thenAnswer((_) async => ApiResult.success(expectedResponse));

    final notifier = PointExchangeAsyncNotifier();
    final result = await notifier.exchangePointForDocomo(request);

    expect(result.transactionId, 'txn_002');
    verify(() => mockApigee.exchangePointForDocomo(any())).called(1);
    verifyNever(() => mockFunctions.exchangePointForDocomo(any()));
  });

  test('throw ApiIsAlreadyExistsException khi isAlreadyExists', () async {
    when(() => mockApigee.useApigee).thenReturn(false);

    final error = ApiError(code: 'already-exists', message: 'S022');
    when(() => mockFunctions.exchangePointForDocomo(any()))
        .thenAnswer((_) async => ApiResult.failure(error));

    final notifier = PointExchangeAsyncNotifier();

    expect(
      () async => await notifier.exchangePointForDocomo(request),
      throwsA(isA<ApiIsAlreadyExistsException>()),
    );
  });
});
```

#### 7.3 Test exchangePointForAu — Flow phức tạp

```dart
group('exchangePointForAu', () {
  test('check duplicate trước khi exchange với keyType PIN', () async {
    final request = ExchangePointForAuRequest(
      keyType: PointExchangeAuKeyType.pin.id,
      identifier: '1234567890123456789',
      amount: 1000,
    );

    // Step 1: isAuNumberAlreadyExist → không trùng
    when(() => mockFunctions.isAuNumberAlreadyExist(any()))
        .thenAnswer((_) async => ApiResult.success(
              IsAuNumberAlreadyExistResponse(exist: false),
            ));

    // Step 2: exchange thành công
    when(() => mockApigee.useApigee).thenReturn(false);
    when(() => mockFunctions.exchangePointForAu(any()))
        .thenAnswer((_) async => ApiResult.success(
              ExchangePointForAuResponse(transactionId: 'txn_au_001'),
            ));

    final notifier = PointExchangeAsyncNotifier();
    final result = await notifier.exchangePointForAu(request);

    expect(result.transactionId, 'txn_au_001');

    // Verify đã check duplicate
    verify(() => mockFunctions.isAuNumberAlreadyExist(any())).called(1);

    // Verify request đúng
    final captured = verify(
      () => mockFunctions.isAuNumberAlreadyExist(captureAny()),
    ).captured;
    final sentRequest =
        captured.first as IsAuNumberAlreadyExistRequest;
    expect(sentRequest.auNumber, '1234567890123456789');
  });

  test('throw khi au number đã tồn tại', () async {
    final request = ExchangePointForAuRequest(
      keyType: PointExchangeAuKeyType.pin.id,
      identifier: '1234567890123456789',
      amount: 1000,
    );

    when(() => mockFunctions.isAuNumberAlreadyExist(any()))
        .thenAnswer((_) async => ApiResult.success(
              IsAuNumberAlreadyExistResponse(exist: true), // đã tồn tại
            ));

    final notifier = PointExchangeAsyncNotifier();

    expect(
      () async => await notifier.exchangePointForAu(request),
      throwsA(equals(PointExchangeException.auIsAuNumberAlreadyExist)),
    );

    // Exchange KHÔNG được gọi
    verifyNever(() => mockFunctions.exchangePointForAu(any()));
  });

  test('skip duplicate check khi keyType không phải PIN', () async {
    final request = ExchangePointForAuRequest(
      keyType: 'oauth', // không phải PIN
      identifier: 'oauth_token_xyz',
      amount: 1000,
    );

    when(() => mockApigee.useApigee).thenReturn(false);
    when(() => mockFunctions.exchangePointForAu(any()))
        .thenAnswer((_) async => ApiResult.success(
              ExchangePointForAuResponse(transactionId: 'txn_au_002'),
            ));

    final notifier = PointExchangeAsyncNotifier();
    await notifier.exchangePointForAu(request);

    // isAuNumberAlreadyExist KHÔNG được gọi
    verifyNever(() => mockFunctions.isAuNumberAlreadyExist(any()));
  });
});
```

#### 7.4 Test pure functions — Không cần mock

```dart
group('maskedIdentifier', () {
  late PointExchangeAsyncNotifier notifier;

  setUp(() {
    notifier = PointExchangeAsyncNotifier();
  });

  test('docomo — hiển thị 4 số cuối', () {
    final result = notifier.maskedIdentifier(
      type: PointExchangeProviderType.docomo,
      no: '1234567890',
    );
    expect(result, '＊＊＊＊＊＊7890');
  });

  test('au — hiển thị 5 số cuối, pad nếu ngắn', () {
    expect(
      notifier.maskedIdentifier(
        type: PointExchangeProviderType.au,
        no: '1234567890123456789',
      ),
      '＊＊＊＊＊＊＊＊＊＊＊＊＊＊56789',
    );

    expect(
      notifier.maskedIdentifier(
        type: PointExchangeProviderType.au,
        no: '12345',
      ),
      '＊＊＊＊＊＊＊＊＊＊＊＊＊＊12345',
    );
  });

  test('trả về empty string cho provider khác', () {
    expect(
      notifier.maskedIdentifier(
        type: PointExchangeProviderType.rakuten,
        no: '123456',
      ),
      '',
    );
  });
});

group('splitAuNo', () {
  test('tách đúng 16 + 3 ký tự', () {
    final result = notifier.splitAuNo('1234567890123456789');
    expect(result[0], '1234567890123456');
    expect(result[1], '789');
  });
});

group('calcExchangePoint', () {
  test('tính chính xác', () {
    expect(
      notifier.calcExchangePoint(
        exchangePoint: 1000,
        exchangeRate: 5,
        tokyoPointRate: 10,
      ),
      500,
    );
  });

  test('làm tròn khi lẻ', () {
    expect(
      notifier.calcExchangePoint(
        exchangePoint: 100,
        exchangeRate: 3,
        tokyoPointRate: 7,
      ),
      43, // 42.857 → round
    );
  });
});
```

---

### 8. Test Riverpod Provider với Mocktail

```dart
group('PointExchangeAsyncNotifier với Riverpod', () {
  test('build thành công với mock data', () async {
    final mockServices = [
      ServicesDocumentData(
        type: ServiceType.point,
        subType: ServiceSubType.main,
        exchangePointSettings: [
          ExchangePointSetting(
            paymentServiceProvider: 'docomo',
            auPayDisplayName: null,
          ),
        ],
      ),
    ];

    final mockOperator = ServiceOperatorsDocumentData(
      pointExchangePaymentServiceProviderSettings:
          PointExchangePaymentServiceProviderSettings(
        layoutIndex: ['setting_docomo'],
        docomo: DocomoSetting(
          enableExchangeV2: true,
          paymentServiceProviderName: 'dポイント',
          logoFilePath: 'path/to/logo',
        ),
      ),
    );

    final mockFunctions = MockFirebaseFunctionsClient();
    when(() => mockFunctions.getPointExchangeSettingInfo())
        .thenAnswer((_) async => [
              PointExchangeSettingsDocumentData(
                pointExchangeSettingId: 'setting_docomo',
                paymentServiceProvider: 'docomo',
                status: 1,
                maxExchangePointPerUse: 10000,
                exchangeAmountPerUnit: 1,
                exchangeTokyoPointAmount: 1,
              ),
            ]);

    final container = ProviderContainer(
      overrides: [
        servicesProvider.overrideWith((ref) async => mockServices),
        serviceOperatorsStateNotifierProvider.overrideWith(
          (ref) {
            final notifier = ServiceOperatorsNotifier();
            notifier.state = mockOperator;
            return notifier;
          },
        ),
        // Override Firebase Functions
        firebaseFunctionsProvider
            .overrideWithValue(mockFunctions),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      pointExchangeAsyncNotifierProvider.future,
    );

    expect(result, isNotEmpty);
    expect(result.first.provider, PointExchangeProviderType.docomo);
  });

  test('trả về empty list khi exchangePointSettings rỗng', () async {
    final mockServices = [
      ServicesDocumentData(
        type: ServiceType.point,
        subType: ServiceSubType.main,
        exchangePointSettings: [], // rỗng
      ),
    ];

    final container = ProviderContainer(
      overrides: [
        servicesProvider.overrideWith((ref) async => mockServices),
        serviceOperatorsStateNotifierProvider.overrideWith((ref) {
          final n = ServiceOperatorsNotifier();
          n.state = ServiceOperatorsDocumentData();
          return n;
        }),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      pointExchangeAsyncNotifierProvider.future,
    );

    expect(result, isEmpty);
  });
});
```

---

### 9. Test Widget với Mocktail

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockPointExchangeNotifier extends Mock
    implements PointExchangeAsyncNotifier {}

testWidgets('hiển thị danh sách point exchange', (tester) async {
  final mockData = [
    PointExchangeModel(
      provider: PointExchangeProviderType.docomo,
      paymentServiceProviderName: 'dポイント',
      exchangeRate: 100,
      tokyoPointRate: 1,
    ),
    PointExchangeModel(
      provider: PointExchangeProviderType.rakuten,
      paymentServiceProviderName: '楽天ポイント',
      exchangeRate: 80,
      tokyoPointRate: 1,
    ),
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pointExchangeAsyncNotifierProvider.overrideWith(() {
          final notifier = MockPointExchangeNotifier();
          // State là AsyncData với mock data
          return notifier;
        }),
      ],
      child: const MaterialApp(
        home: PointExchangeListScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle();

  // Verify UI hiển thị đúng
  expect(find.text('dポイント'), findsOneWidget);
  expect(find.text('楽天ポイント'), findsOneWidget);
});

testWidgets('hiển thị error khi load thất bại', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pointExchangeAsyncNotifierProvider.overrideWith(() {
          // Trả về error state
          throw '事業者情報の取得に失敗しました。';
        }),
      ],
      child: const MaterialApp(
        home: PointExchangeListScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.text('事業者情報の取得に失敗しました。'), findsOneWidget);
});
```

---

### 10. Các lỗi thường gặp

#### Quên `registerFallbackValue`

```dart
// ❌ Runtime error: "No fallback value registered for type..."
when(() => mockClient.exchangePointForDocomo(any()))
    .thenAnswer((_) async => ApiResult.success(response));

// ✅ Fix: register trong setUpAll
setUpAll(() {
  registerFallbackValue(FakeExchangePointForDocomoRequest());
});
```

**Quy tắc:** Mỗi custom type dùng với `any()`, `captureAny()` đều cần fallback. Primitive types (String, int, bool, List, Map) không cần.

#### Stub method trả void

```dart
class MockLogger extends Mock implements DebugLogger {}

// ❌ Sai
when(() => mockLogger.e(any())).thenReturn(null);

// ✅ Đúng — không cần stub, Mock tự return void
// Chỉ cần verify nếu muốn
verify(() => mockLogger.e('expected error message')).called(1);
```

#### Mock getter/setter

```dart
class MockApigeeClient extends Mock implements ApigeeClient {}

// Stub getter
when(() => mockApigee.useApigee).thenReturn(true);

// Stub setter — dùng verify thay vì when
mockApigee.useApigee = true;
verify(() => mockApigee.useApigee = true).called(1);
```

#### Mock extension methods — Không mock được

```dart
// Extension methods KHÔNG thể mock
extension ApiErrorExtension on ApiError {
  bool get isAlreadyExists => code == 'already-exists';
}

// Khi test, mock object gốc và để extension chạy trên mock:
final mockError = ApiError(code: 'already-exists', message: 'S022');
expect(mockError.isAlreadyExists, true);
// Extension chạy trên data thật, không cần mock
```

---

### 11. Tổng kết Mocktail vs Mockito

| Tiêu chí | Mocktail | Mockito |
|---|---|---|
| Code generation | Không cần | Cần `build_runner` |
| Syntax | `when(() => mock.method())` | `when(mock.method())` |
| Trộn matcher với giá trị thật | Cho phép | Không cho phép |
| Fallback value | Cần `registerFallbackValue` cho custom types | Tự xử lý qua codegen |
| Nice mock (default return) | Mặc định là nice mock | Cần `@GenerateNiceMocks` |
| Performance | Nhanh hơn (không generate) | Chậm hơn khi chạy `build_runner` |
| Phổ biến trong Flutter | Đang tăng nhanh, Flutter team khuyên dùng | Vẫn phổ biến, nhiều project cũ dùng |

Với project point exchange hiện tại, mocktail phù hợp hơn vì không cần thêm bước generate, và code base đã có nhiều class phức tạp (Firestore, Firebase Functions, Apigee) — việc tạo mock nhanh bằng `extends Mock implements X` giúp tiết kiệm thời gian đáng kể.
