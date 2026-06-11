## Mixin, Extends, With, Implements trong Dart

### 1. Tổng quan nhanh

```dart
class Dog extends Animal with Swimmable implements Pet {
  //       ↑                ↑                  ↑
  //    kế thừa         trộn mixin        ký hợp đồng
  //   (1 class)      (nhiều mixin)     (nhiều interface)
  //  nhận code +     nhận code từ       CHỈ nhận signature,
  //  structure        mixin             phải tự viết code
}
```

---

### 2. `extends` — Kế thừa

#### Ý nghĩa

Tạo quan hệ cha-con giữa 2 class. Class con nhận toàn bộ properties, methods, constructor logic từ class cha. Dart chỉ cho phép **single inheritance** — mỗi class chỉ extends được MỘT class duy nhất.

#### Cách hoạt động

```dart
class Animal {
  String name;
  int age;

  Animal({required this.name, required this.age});

  void eat() {
    print('$name is eating');
  }

  void sleep() {
    print('$name is sleeping');
  }

  // Method có thể bị override
  String describe() {
    return 'Animal: $name, age: $age';
  }
}

class Dog extends Animal {
  String breed;

  // Constructor phải gọi super
  Dog({
    required super.name,
    required super.age,
    required this.breed,
  });

  // Thêm method riêng
  void bark() {
    print('$name: Woof!');
  }

  // Override method cha
  @override
  String describe() {
    return 'Dog: $name, breed: $breed, age: $age';
  }
}
```

```dart
void main() {
  final dog = Dog(name: 'Max', age: 3, breed: 'Golden');

  dog.eat();       // ✅ Kế thừa từ Animal: "Max is eating"
  dog.sleep();     // ✅ Kế thừa từ Animal: "Max is sleeping"
  dog.bark();      // ✅ Method riêng của Dog: "Max: Woof!"
  dog.describe();  // ✅ Override: "Dog: Max, breed: Golden, age: 3"

  // Dog IS-A Animal
  Animal animal = dog;  // ✅ Polymorphism
  animal.eat();         // ✅ "Max is eating"
  // animal.bark();     // ❌ Compile error — Animal không có bark()
}
```

#### Khi nào dùng

Dùng `extends` khi class con **là một loại** (IS-A) của class cha và cần kế thừa behavior thực sự:

```dart
// ✅ Đúng — StatefulWidget IS-A Widget
class PointExchangeScreen extends StatefulWidget {}

// ✅ Đúng — AsyncNotifier IS-A Notifier
class PointExchangeAsyncNotifier
    extends AutoDisposeAsyncNotifier<List<PointExchangeModel>> {}

// ✅ Đúng — StateNotifier IS-A Notifier
class ServiceOperatorsNotifier
    extends StateNotifier<ServiceOperatorsDocumentData?> {}
```

#### Giới hạn: Single inheritance

```dart
// ❌ Dart không cho phép kế thừa nhiều class
class Dog extends Animal, Pet {}  // COMPILE ERROR

// Đây là lý do mixin và implements tồn tại
```

---

### 3. `implements` — Ký hợp đồng (Interface)

#### Ý nghĩa

Trong Dart, **mọi class đều tự động là một interface**. Khi class A `implements` class B, A cam kết sẽ cung cấp implementation cho TẤT CẢ public members của B. A không nhận bất kỳ code nào từ B — phải tự viết lại toàn bộ.

#### Cách hoạt động

```dart
// Dù là class thường, nó vẫn có thể được dùng làm interface
class Animal {
  String name = '';

  void eat() {
    print('Animal eating');
  }

  void sleep() {
    print('Animal sleeping');
  }
}

class Robot implements Animal {
  // PHẢI implement TẤT CẢ — kể cả field

  @override
  String name = 'Robot-01';    // phải khai báo lại

  @override
  void eat() {                 // phải viết lại
    print('$name charging battery');
  }

  @override
  void sleep() {               // phải viết lại
    print('$name entering standby mode');
  }
}
```

So sánh với `extends`:

```dart
class Dog extends Animal {
  // Chỉ cần override method muốn thay đổi
  // eat() và sleep() tự động có từ Animal
  // name tự động có từ Animal
}

class Robot implements Animal {
  // PHẢI viết lại TẤT CẢ: name, eat(), sleep()
  // Không nhận được bất kỳ code nào từ Animal
}
```

#### Implements nhiều interface

```dart
abstract class Printable {
  void printInfo();
}

abstract class Exportable {
  String toJson();
  String toCsv();
}

abstract class Loggable {
  void log(String message);
}

// ✅ Implements nhiều interface — không giới hạn số lượng
class PointExchangeModel implements Printable, Exportable, Loggable {
  final String provider;
  final int exchangeRate;

  PointExchangeModel({required this.provider, required this.exchangeRate});

  @override
  void printInfo() {
    print('$provider: rate=$exchangeRate');
  }

  @override
  String toJson() {
    return '{"provider": "$provider", "rate": $exchangeRate}';
  }

  @override
  String toCsv() {
    return '$provider,$exchangeRate';
  }

  @override
  void log(String message) {
    print('[PointExchange] $message');
  }
}
```

#### Abstract class làm interface

Trong thực tế, interface thường được khai báo bằng `abstract class` vì chỉ cần định nghĩa signature, không cần implementation:

```dart
// Định nghĩa interface
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

// Implementation thật — dùng trong production
class PointExchangeRepositoryImpl implements PointExchangeRepository {
  final FirebaseFunctionsClient _client;

  PointExchangeRepositoryImpl(this._client);

  @override
  Future<List<PointExchangeModel>> fetchExchanges() async {
    final settings = await _client.getPointExchangeSettingInfo();
    // ... transform data
    return models;
  }

  @override
  Future<bool> checkDuplicate({
    required List<int> amounts,
    required String providerType,
  }) async {
    // ... Firestore query
    return false;
  }

  @override
  int calcExchangePoint({
    required int exchangePoint,
    required int exchangeRate,
    required int tokyoPointRate,
  }) {
    return (exchangePoint * (exchangeRate / tokyoPointRate)).round();
  }
}

// Mock — dùng trong test
class MockPointExchangeRepository implements PointExchangeRepository {
  @override
  Future<List<PointExchangeModel>> fetchExchanges() async => [];

  @override
  Future<bool> checkDuplicate({
    required List<int> amounts,
    required String providerType,
  }) async => false;

  @override
  int calcExchangePoint({
    required int exchangePoint,
    required int exchangeRate,
    required int tokyoPointRate,
  }) => 0;
}
```

#### Khi nào dùng

Dùng `implements` khi muốn đảm bảo class tuân thủ một contract mà không cần kế thừa code:

```dart
// ✅ Repository pattern — tách interface và implementation
abstract class AuthRepository {
  Future<User?> signIn(String email, String password);
  Future<void> signOut();
}

// ✅ Strategy pattern — nhiều implementation cho cùng interface
class FirebaseAuthRepo implements AuthRepository { /* ... */ }
class ApigeeAuthRepo implements AuthRepository { /* ... */ }
class MockAuthRepo implements AuthRepository { /* ... */ }
```

---

### 4. `mixin` và `with` — Tái sử dụng code

#### Vấn đề mixin giải quyết

```dart
// Muốn Dog vừa biết swim, vừa biết fetch
// Nhưng không phải mọi Animal đều swim, không phải mọi Animal đều fetch

class Animal {
  void eat() => print('eating');
}

// ❌ Nếu đặt swim() vào Animal → Cat cũng có swim() (sai)
// ❌ Nếu tạo SwimmableAnimal extends Animal → chỉ kế thừa được 1 class
// ✅ Giải pháp: Mixin
```

#### Khai báo mixin

```dart
mixin Swimmable {
  // Mixin KHÔNG có constructor
  // Mixin CÓ THỂ có field và method với implementation đầy đủ

  int swimSpeed = 5;

  void swim() {
    print('Swimming at speed $swimSpeed');
  }

  void dive(int depth) {
    print('Diving to $depth meters');
  }
}

mixin Fetchable {
  void fetch(String item) {
    print('Fetching $item');
  }

  void dropItem() {
    print('Dropping item');
  }
}

mixin Trainable {
  final List<String> tricks = [];

  void learnTrick(String trick) {
    tricks.add(trick);
    print('Learned: $trick');
  }

  void showTricks() {
    print('Known tricks: $tricks');
  }
}
```

#### `with` — Áp dụng mixin

```dart
// "with" trộn mixin vào class
class Dog extends Animal with Swimmable, Fetchable, Trainable {
  String breed;

  Dog({required this.breed});

  // Dog tự động có TẤT CẢ methods và fields từ 3 mixin:
  // swim(), dive(), swimSpeed     ← từ Swimmable
  // fetch(), dropItem()           ← từ Fetchable
  // learnTrick(), showTricks(), tricks  ← từ Trainable
  // eat()                         ← từ Animal (extends)
}

class Cat extends Animal with Trainable {
  // Cat chỉ có Trainable, KHÔNG có Swimmable và Fetchable
  // Cat có: eat() từ Animal, learnTrick() và showTricks() từ Trainable
}

void main() {
  final dog = Dog(breed: 'Golden');
  dog.eat();                    // từ Animal
  dog.swim();                   // từ Swimmable
  dog.fetch('ball');            // từ Fetchable
  dog.learnTrick('sit');        // từ Trainable
  dog.showTricks();             // từ Trainable

  final cat = Cat();
  cat.eat();                    // từ Animal
  cat.learnTrick('jump');       // từ Trainable
  // cat.swim();                // ❌ Compile error — Cat không có Swimmable
}
```

#### Mixin với `on` — Giới hạn class được dùng

```dart
// Mixin này CHỈ dùng được với class extends Animal
mixin HuntingSkill on Animal {
  void hunt() {
    print('$name is hunting');  // ← truy cập được "name" từ Animal
    eat();                       // ← gọi được eat() từ Animal
  }
}

// ✅ OK — Dog extends Animal
class Dog extends Animal with HuntingSkill {}

// ❌ Compile error — Robot không extends Animal
// class Robot with HuntingSkill {}  // ERROR
```

Ví dụ thực tế trong Flutter:

```dart
// SingleTickerProviderStateMixin chỉ dùng với State
mixin SingleTickerProviderStateMixin<T extends StatefulWidget> on State<T> {
  // truy cập được this (State), context, widget...
}

// ✅ Đúng — _MyState extends State
class _MyScreenState extends State<MyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,  // "this" implement TickerProvider nhờ mixin
      duration: const Duration(milliseconds: 300),
    );
  }
}
```

#### Mixin giải quyết Diamond Problem

Khi nhiều mixin có method trùng tên, Dart dùng **linearization** — mixin cuối cùng trong danh sách `with` thắng:

```dart
mixin A {
  String greet() => 'Hello from A';
}

mixin B {
  String greet() => 'Hello from B';
}

mixin C {
  String greet() => 'Hello from C';
}

class MyClass with A, B, C {}
//                      ↑
//                  C là cuối cùng → C.greet() thắng

void main() {
  print(MyClass().greet());  // "Hello from C"
}
```

Với `super` call, linearization rõ hơn:

```dart
class Base {
  String greet() => 'Base';
}

mixin A on Base {
  @override
  String greet() => 'A → ${super.greet()}';
}

mixin B on Base {
  @override
  String greet() => 'B → ${super.greet()}';
}

class MyClass extends Base with A, B {}
// Linearization order: MyClass → B → A → Base
// B.greet() gọi super → A.greet() gọi super → Base.greet()

void main() {
  print(MyClass().greet());  // "B → A → Base"
}
```

---

### 5. Kết hợp extends, with, implements

```dart
// Thứ tự bắt buộc: extends → with → implements
class PointExchangeService extends BaseService
    with LoggableMixin, CacheableMixin
    implements Disposable, Refreshable {

  // Từ BaseService (extends): nhận code + field + constructor chain
  // Từ LoggableMixin (with): nhận log(), logError() có sẵn implementation
  // Từ CacheableMixin (with): nhận cache(), invalidate() có sẵn implementation
  // Từ Disposable (implements): PHẢI tự viết dispose()
  // Từ Refreshable (implements): PHẢI tự viết refresh()

  @override
  void dispose() {
    // Bắt buộc implement vì Disposable yêu cầu
    logInfo('Disposing PointExchangeService');
    invalidateCache();
  }

  @override
  Future<void> refresh() async {
    // Bắt buộc implement vì Refreshable yêu cầu
    logInfo('Refreshing data');
    await fetchData();
  }
}
```

Ví dụ thực tế áp dụng cho project:

```dart
// Base class
abstract class BaseRepository {
  final FirebaseFunctionsClient client;
  BaseRepository(this.client);

  // Shared logic cho tất cả repository
  Future<T> safeCall<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      DebugUtil.logger.e(e);
      rethrow;
    }
  }
}

// Mixin cho logging
mixin RepositoryLogger {
  void logRequest(String method, Map<String, dynamic>? params) {
    DebugUtil.logger.i('API Request: $method, params: $params');
  }

  void logResponse(String method, dynamic response) {
    DebugUtil.logger.i('API Response: $method, data: $response');
  }

  void logError(String method, dynamic error) {
    DebugUtil.logger.e('API Error: $method, error: $error');
  }
}

// Mixin cho duplicate check
mixin DuplicateChecker {
  Future<bool> isDuplicate({
    required String uid,
    required List<int> amounts,
    required String providerType,
  }) async {
    final transactionsCollection = await FirebaseFirestore.instance
        .collection(FirestoreCollectionNames.transactions)
        .where('uid', isEqualTo: uid)
        .where('createdAt',
            isGreaterThan: DateTime.now().subtract(const Duration(minutes: 1)))
        .orderBy('createdAt', descending: true)
        .get(const GetOptions(source: Source.server));

    final totalAmount = amounts.fold<int>(0, (a, b) => a + b);
    final paymentIdAmount = <String, int>{};

    for (var doc in transactionsCollection.docs) {
      final transaction = TransactionsDocumentData.fromJson(doc.data());
      if (transaction.to == providerType &&
          transaction.operationType == 'SUB' &&
          transaction.operationId == 'OP27' &&
          transaction.status == TransactionStatus.general &&
          transaction.mode == 1) {
        final paymentId = transaction.paymentId ?? transaction.tranId;
        paymentIdAmount[paymentId] =
            (paymentIdAmount[paymentId] ?? 0) + transaction.amount;
      }
    }

    return paymentIdAmount.values.contains(totalAmount);
  }
}

// Interface cho exchange operation
abstract class ExchangeOperation<TRequest, TResponse> {
  Future<TResponse> exchange(TRequest request);
  String get providerName;
}

// Kết hợp tất cả
class DocomoExchangeRepository extends BaseRepository
    with RepositoryLogger, DuplicateChecker
    implements ExchangeOperation<ExchangePointForDocomoRequest,
        ExchangePointForDocomoResponse> {

  DocomoExchangeRepository(super.client);

  @override
  String get providerName => 'docomo';

  @override
  Future<ExchangePointForDocomoResponse> exchange(
    ExchangePointForDocomoRequest request,
  ) async {
    logRequest('exchangePointForDocomo', request.toJson());

    return safeCall(() async {
      final result = await client.exchangePointForDocomo(request);
      return result.when(
        success: (response) {
          logResponse('exchangePointForDocomo', response);
          return response;
        },
        failure: (error) {
          logError('exchangePointForDocomo', error);
          if (error.isAlreadyExists) {
            throw ApiIsAlreadyExistsException();
          }
          throw ApiExceptionHandler.getError(error).getMessageDetails();
        },
      );
    });
  }
}
```

---

### 6. So sánh tổng hợp

```
                    extends         with (mixin)       implements
─────────────────────────────────────────────────────────────────
Số lượng            1 class         nhiều mixin        nhiều interface
Nhận code           ✅ Có            ✅ Có               ❌ Không
Phải override all   ❌ Không         ❌ Không            ✅ Phải
Có constructor      ✅ Có            ❌ Không            ✅ Có (nhưng không kế thừa)
Quan hệ             IS-A            CAN-DO             LOOKS-LIKE
Ví dụ đời thật      Con kế thừa     Kỹ năng học thêm   Giấy phép hành nghề
                    từ cha mẹ       (bơi, nấu ăn)      (phải đạt tiêu chuẩn)
```

Cách nhớ đơn giản:

```dart
class Developer extends Human        // Developer LÀ Human
    with CodingSkill, DebuggingSkill  // Developer BIẾT code, BIẾT debug
    implements TaxPayer, Employable { // Developer CAM KẾT đóng thuế, có thể tuyển dụng
}
```

**`extends`** — "Tôi **là** loại này" → nhận mọi thứ từ cha.

**`with`** — "Tôi **biết làm** những thứ này" → nhận code có sẵn từ mixin.

**`implements`** — "Tôi **cam kết** làm được những thứ này" → phải tự viết toàn bộ code.
