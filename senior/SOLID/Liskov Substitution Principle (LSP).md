# Liskov Substitution Principle (LSP) trong Flutter/Dart

> *"Objects of a superclass should be replaceable with objects of its subclasses without breaking the correctness of the program."*
> — Barbara Liskov, 1987

Nói đơn giản: **nếu class `B` là subtype của class `A`, thì mọi chỗ dùng `A` đều có thể thay bằng `B` mà chương trình vẫn hoạt động đúng** — không crash, không có hành vi bất ngờ, không vi phạm contract của `A`.

---

## 1. Hiểu đúng "Thay thế được" nghĩa là gì

LSP không chỉ là "compile được". Nó yêu cầu **behavioral compatibility** — subclass phải giữ đúng **contract** (hợp đồng hành vi) của superclass:

| Quy tắc contract | Ý nghĩa |
|---|---|
| **Preconditions không được mạnh hơn** | Subclass không được đòi hỏi input khắt khe hơn cha |
| **Postconditions không được yếu hơn** | Subclass phải đảm bảo output ít nhất tốt bằng cha |
| **Invariants phải được bảo toàn** | Những điều kiện luôn đúng ở cha phải vẫn đúng ở con |
| **History constraint** | Subclass không được thay đổi state theo cách mà cha không cho phép |

---

## 2. Vi phạm LSP kinh điển — Rectangle vs Square

```dart
class Rectangle {
  double width;
  double height;

  Rectangle(this.width, this.height);

  double get area => width * height;

  void setWidth(double w) => width = w;
  void setHeight(double h) => height = h;
}

// ❌ Square IS-A Rectangle về mặt toán học,
// nhưng VI PHẠM LSP về mặt hành vi
class Square extends Rectangle {
  Square(double side) : super(side, side);

  @override
  void setWidth(double w) {
    width = w;
    height = w; // side effect bất ngờ!
  }

  @override
  void setHeight(double h) {
    width = h; // side effect bất ngờ!
    height = h;
  }
}
```

Client code bị break:

```dart
void resizeAndVerify(Rectangle rect) {
  rect.setWidth(5);
  rect.setHeight(10);
  
  // Contract của Rectangle: width=5, height=10 → area=50
  assert(rect.area == 50); // ❌ FAIL với Square! area = 100
}

resizeAndVerify(Rectangle(2, 3)); // ✅ OK
resizeAndVerify(Square(2));       // ❌ BOOM — assertion fails
```

**Bài học:** "IS-A" trong thế giới thực ≠ "IS-A" trong code. Quan hệ kế thừa phải dựa trên **behavioral compatibility**, không phải trực giác toán học.

---

## 3. Vi phạm LSP phổ biến trong Flutter

### 3a. Throw `UnimplementedError` — dấu hiệu rõ nhất

```dart
abstract class DataSource {
  Future<List<Item>> fetchAll();
  Future<void> save(Item item);
  Future<void> delete(String id);
}

// ReadOnlyDataSource thay thế DataSource được không?
class ReadOnlyDataSource extends DataSource {
  final ApiClient _api;
  ReadOnlyDataSource(this._api);

  @override
  Future<List<Item>> fetchAll() async => _api.getItems();

  @override
  Future<void> save(Item item) {
    throw UnimplementedError('Read-only!'); // ❌ Vi phạm LSP
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError('Read-only!'); // ❌ Vi phạm LSP
  }
}
```

Bất kỳ chỗ nào nhận `DataSource` và gọi `save()` đều crash khi truyền `ReadOnlyDataSource` vào. Subclass đã **phá vỡ contract** của cha.

**Fix — Tách interface (kết hợp ISP):**

```dart
abstract class Readable {
  Future<List<Item>> fetchAll();
}

abstract class Writable {
  Future<void> save(Item item);
  Future<void> delete(String id);
}

// Read-only chỉ implement Readable
class ReadOnlySource implements Readable {
  @override
  Future<List<Item>> fetchAll() async => _api.getItems();
}

// Full source implement cả hai
class FullDataSource implements Readable, Writable {
  @override
  Future<List<Item>> fetchAll() async => _api.getItems();
  @override
  Future<void> save(Item item) async => _api.saveItem(item);
  @override
  Future<void> delete(String id) async => _api.deleteItem(id);
}
```

### 3b. Override thay đổi hành vi bất ngờ

```dart
abstract class AuthProvider {
  /// Returns authenticated [User].
  /// Throws [AuthException] on failure.
  Future<User> signIn(String email, String password);
}

class EmailAuthProvider implements AuthProvider {
  @override
  Future<User> signIn(String email, String password) async {
    final result = await _firebaseAuth.signInWithEmail(email, password);
    return User.fromFirebase(result.user!);
  }
}

// ❌ Vi phạm LSP — thay đổi postcondition
class GuestAuthProvider implements AuthProvider {
  @override
  Future<User> signIn(String email, String password) async {
    // Bỏ qua email/password hoàn toàn — precondition contract bị phá
    // Trả về guest user không có email — postcondition contract bị phá
    return User(id: 'guest', email: '', name: 'Guest');
  }
}
```

Client expect `signIn` trả về user **đã xác thực** với email hợp lệ:

```dart
Future<void> onLogin(AuthProvider auth) async {
  final user = await auth.signIn(email, password);
  
  // Assume user.email is valid — contract of AuthProvider
  await sendWelcomeEmail(user.email); // ❌ '' với GuestAuth
  await loadUserProfile(user.id);     // 'guest' — hành vi sai
}
```

**Fix — Tách rõ contract:**

```dart
abstract class AuthProvider {
  Future<User> signIn(String email, String password);
}

abstract class AnonymousAuthProvider {
  Future<User> signInAnonymously();
}

class GuestAuthProvider implements AnonymousAuthProvider {
  @override
  Future<User> signInAnonymously() async {
    final result = await _firebaseAuth.signInAnonymously();
    return User.fromFirebase(result.user!);
  }
}
```

Giờ không ai nhầm lẫn `GuestAuthProvider` với `AuthProvider` thông thường.

### 3c. Precondition mạnh hơn — đòi hỏi nhiều hơn cha

```dart
abstract class PaymentProcessor {
  /// Process any positive amount.
  Future<PaymentResult> process(double amount);
}

// ❌ Vi phạm LSP — precondition mạnh hơn
class PremiumPaymentProcessor extends PaymentProcessor {
  @override
  Future<PaymentResult> process(double amount) async {
    // Cha chấp nhận mọi amount > 0
    // Con đòi thêm điều kiện → client code bị break
    if (amount < 100) {
      throw PaymentException('Premium requires minimum \$100');
    }
    return _processPayment(amount);
  }
}
```

```dart
void checkout(PaymentProcessor processor, double amount) async {
  // Client tin rằng bất kỳ amount > 0 đều OK (contract của cha)
  final result = await processor.process(50.0);
  // ❌ CRASH với PremiumPaymentProcessor
}
```

### 3d. Postcondition yếu hơn — trả về ít hơn cha hứa

```dart
abstract class Cache<T> {
  /// Stores item and guarantees it can be retrieved
  /// immediately after via [get].
  Future<void> put(String key, T value);
  Future<T?> get(String key);
}

// ❌ Vi phạm LSP — postcondition yếu hơn
class ExpirableCache<T> extends Cache<T> {
  final Duration ttl;
  ExpirableCache(this.ttl);

  @override
  Future<void> put(String key, T value) async {
    _store[key] = _Entry(value, DateTime.now());
  }

  @override
  Future<T?> get(String key) async {
    final entry = _store[key];
    if (entry == null) return null;
    
    // Cha đảm bảo: put rồi get ngay → có data
    // Con: có thể trả null ngay sau put nếu TTL cực ngắn
    if (DateTime.now().difference(entry.createdAt) > ttl) {
      _store.remove(key);
      return null; // ❌ Phá postcondition
    }
    return entry.value;
  }
}
```

**Fix — Làm rõ contract trong abstraction:**

```dart
abstract class Cache<T> {
  Future<void> put(String key, T value);
  Future<T?> get(String key);
}

/// A cache where entries may expire.
/// Callers must handle null even after put.
abstract class ExpirableCache<T> extends Cache<T> {
  Duration get ttl;
}
```

Khi consumer nhận `ExpirableCache`, nó **biết trước** rằng data có thể biến mất — contract rõ ràng, không bất ngờ.

---

## 4. LSP trong Widget Hierarchy

### 4a. Custom Widget phải tôn trọng contract của cha

```dart
// ❌ Vi phạm — StatelessWidget nhưng có side effect
class AnalyticsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AnalyticsButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Side effect trong build! Vi phạm contract của StatelessWidget
    // build() should be pure — có thể gọi nhiều lần bất kỳ lúc nào
    AnalyticsService.track('button_viewed'); // ❌
    
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Click me'),
    );
  }
}
```

`StatelessWidget.build()` có contract ngầm: **pure function**, không side effect, có thể được framework gọi lại bất kỳ lúc nào. Vi phạm điều này → tracking bị duplicate không kiểm soát.

**Fix:**

```dart
class AnalyticsButton extends StatefulWidget {
  final VoidCallback onPressed;
  const AnalyticsButton({required this.onPressed});

  @override
  State<AnalyticsButton> createState() => _AnalyticsButtonState();
}

class _AnalyticsButtonState extends State<AnalyticsButton> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.track('button_viewed'); // ✅ chỉ 1 lần
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        AnalyticsService.track('button_clicked');
        widget.onPressed();
      },
      child: const Text('Click me'),
    );
  }
}
```

### 4b. Custom ScrollView phải giữ scroll contract

```dart
// ❌ Vi phạm — CustomScrollView nhưng disable scroll
class LockedScrollView extends CustomScrollView {
  // Người dùng expect CustomScrollView có thể scroll
  // Nhưng subclass lại khóa cứng
  @override
  ScrollPhysics get physics => const NeverScrollableScrollPhysics();
  
  // Consumer code:
  // void scrollToTop(CustomScrollView view) {
  //   view.controller.animateTo(0, ...); ← silent failure
  // }
}
```

---

## 5. LSP trong BLoC / State Management

```dart
// Base contract cho mọi list bloc
abstract class ListBloc<T> extends Bloc<ListEvent, ListState<T>> {
  ListBloc() : super(ListInitial()) {
    on<LoadList>(_onLoad);
    on<RefreshList>(_onRefresh);
  }

  /// Contract: LoadList → emit Loading → emit Loaded/Error
  Future<void> _onLoad(LoadList event, Emitter<ListState<T>> emit) async {
    emit(ListLoading());
    try {
      final items = await fetchItems();
      emit(ListLoaded(items));
    } catch (e) {
      emit(ListError(e.toString()));
    }
  }

  /// Contract: RefreshList → emit Loaded (no Loading state)
  Future<void> _onRefresh(RefreshList event, Emitter<ListState<T>> emit) async {
    try {
      final items = await fetchItems();
      emit(ListLoaded(items));
    } catch (e) {
      emit(ListError(e.toString()));
    }
  }

  Future<List<T>> fetchItems();
}
```

Subclass phải tôn trọng state flow contract:

```dart
// ✅ Tuân thủ LSP — giữ đúng contract
class ProductListBloc extends ListBloc<Product> {
  final ProductReader _reader;
  ProductListBloc(this._reader);

  @override
  Future<List<Product>> fetchItems() => _reader.fetchProducts();
}

// ❌ Vi phạm LSP — phá vỡ state flow contract
class CachedProductListBloc extends ListBloc<Product> {
  @override
  Future<void> _onLoad(LoadList event, Emitter emit) async {
    // Không emit ListLoading → UI không hiện spinner
    // Phá vỡ contract: consumer expect Loading state
    final cached = await _cache.get('products');
    if (cached != null) {
      emit(ListLoaded(cached)); // skip Loading
      return;
    }
    // ...
  }
}
```

UI depend vào contract `LoadList → Loading → Loaded`:

```dart
BlocBuilder<ListBloc<Product>, ListState<Product>>(
  builder: (context, state) {
    if (state is ListLoading) return const Spinner(); // ← never shown!
    if (state is ListLoaded<Product>) return ProductGrid(state.items);
    if (state is ListError) return ErrorWidget(state.message);
    return const SizedBox.shrink();
  },
)
```

**Fix — Extend contract, đừng phá vỡ nó:**

```dart
// Thêm state mới thay vì skip state cũ
class ListLoadedFromCache<T> extends ListLoaded<T> {
  ListLoadedFromCache(super.items);
}

class CachedProductListBloc extends ListBloc<Product> {
  @override
  Future<void> _onLoad(LoadList event, Emitter emit) async {
    final cached = await _cache.get('products');
    if (cached != null) {
      emit(ListLoadedFromCache(cached)); // ✅ vẫn IS-A ListLoaded
      // UI hiện data, và có thể distinguish source nếu cần
    }
    
    // Vẫn emit Loading → Loaded cho fresh data
    emit(ListLoading());
    final fresh = await fetchItems();
    emit(ListLoaded(fresh));
  }
}
```

---

## 6. LSP trong Repository Pattern

```dart
abstract class UserRepository {
  /// Returns [User] if found, `null` if not.
  /// Never throws for "not found" case.
  Future<User?> findById(String id);

  /// Saves user. Returns saved user with server-generated fields populated.
  /// Throws [ValidationException] if user data is invalid.
  /// Throws [NetworkException] on connectivity issues.
  Future<User> save(User user);
}
```

```dart
// ✅ Tuân thủ LSP
class FirestoreUserRepository implements UserRepository {
  @override
  Future<User?> findById(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    return doc.exists ? User.fromFirestore(doc) : null; // null, không throw
  }

  @override
  Future<User> save(User user) async {
    user.validate(); // throws ValidationException ← đúng contract
    try {
      final ref = await _firestore.collection('users').doc(user.id).set(user.toMap());
      return user.copyWith(updatedAt: DateTime.now());
    } on FirebaseException catch (e) {
      throw NetworkException(e.message); // ← đúng contract
    }
  }
}

// ❌ Vi phạm LSP
class CachedUserRepository implements UserRepository {
  @override
  Future<User?> findById(String id) async {
    final cached = _cache[id];
    if (cached == null) {
      throw NotFoundException('User $id not in cache');
      // ❌ Contract nói trả null, không throw!
    }
    return cached;
  }

  @override
  Future<User> save(User user) async {
    _cache[user.id] = user;
    return user;
    // ❌ Không populate server-generated fields
    // Postcondition yếu hơn cha
  }
}
```

**Fix:**

```dart
class CachedUserRepository implements UserRepository {
  final UserRepository _remote;

  @override
  Future<User?> findById(String id) async {
    return _cache[id] ?? await _remote.findById(id); // ✅ null nếu không có
  }

  @override
  Future<User> save(User user) async {
    final saved = await _remote.save(user); // ✅ delegate để đảm bảo postcondition
    _cache[saved.id] = saved;
    return saved; // ✅ có server-generated fields
  }
}
```

---

## 7. LSP và Covariant Return / Contravariant Parameter trong Dart

Dart cho phép **covariant parameter** — nhưng cẩn thận, nó có thể phá LSP:

```dart
class Animal {
  void eat(Food food) => print('Eating ${food.name}');
}

class Cat extends Animal {
  // ❌ covariant thu hẹp input type → precondition mạnh hơn → vi phạm LSP
  @override
  void eat(covariant CatFood food) => print('Cat eating ${food.name}');
}

void feedAnimal(Animal animal) {
  animal.eat(Food('Generic kibble')); // ❌ Runtime error với Cat!
}
```

`covariant` bypass type checker nhưng **không bypass LSP**. Dùng nó khi bạn chắc chắn caller context luôn đúng type, không phải để thu hẹp contract.

**Dùng đúng cách:**

```dart
abstract class TypedRepository<T> {
  Future<void> save(T item);
}

class UserRepo extends TypedRepository<User> {
  @override
  Future<void> save(User item) async { /* ... */ }
  // Generic đã ràng buộc type — không cần covariant, không phá LSP
}
```

---

## 8. Exception Contract — Phần hay bị bỏ qua

```dart
abstract class FileStorage {
  /// Throws [StorageException] on failure.
  /// Throws [PermissionException] if access denied.
  /// Does NOT throw on file-not-found — returns null.
  Future<FileData?> read(String path);
}

// ❌ Vi phạm — throw exception type ngoài contract
class EncryptedFileStorage implements FileStorage {
  @override
  Future<FileData?> read(String path) async {
    try {
      final raw = await _storage.read(path);
      return _decrypt(raw);
    } catch (e) {
      // Throw DecryptionException — client không expect điều này
      throw DecryptionException('Failed to decrypt $path');
      // ❌ Contract chỉ cho phép StorageException, PermissionException
    }
  }
}

// ✅ Tuân thủ — wrap exception đúng contract
class EncryptedFileStorage implements FileStorage {
  @override
  Future<FileData?> read(String path) async {
    try {
      final raw = await _storage.read(path);
      if (raw == null) return null;
      return _decrypt(raw);
    } on StorageException {
      rethrow; // ✅ đúng contract
    } on PermissionException {
      rethrow; // ✅ đúng contract  
    } catch (e) {
      throw StorageException(
        'Failed to read encrypted file: $e',
      ); // ✅ wrap vào exception type đúng contract
    }
  }
}
```

---

## 9. Checklist kiểm tra LSP

Mỗi khi viết subclass hoặc implement abstract class, tự hỏi:

```
┌─────────────────────────────────────────────────────────┐
│  1. Có method nào throw UnimplementedError không?       │
│     → Vi phạm. Tách interface (ISP).                    │
│                                                         │
│  2. Subclass có đòi input khắt khe hơn cha không?       │
│     → Precondition mạnh hơn = vi phạm.                  │
│                                                         │
│  3. Subclass có trả output "ít" hơn cha hứa không?      │
│     → Postcondition yếu hơn = vi phạm.                  │
│                                                         │
│  4. Subclass có throw exception ngoài contract không?   │
│     → Vi phạm. Wrap vào exception type đúng.            │
│                                                         │
│  5. Side effect có khác cha không?                      │
│     → Cha set width, con set cả height = vi phạm.       │
│                                                         │
│  6. State transition có giữ đúng flow không?            │
│     → Skip state mà consumer expect = vi phạm.          │
│                                                         │
│  7. Có thể replace cha bằng con trong MỌI test mà       │
│     test vẫn pass không?                                │
│     → Nếu không → vi phạm LSP.                          │
└─────────────────────────────────────────────────────────┘
```

---

## 10. Mối quan hệ LSP với các nguyên tắc SOLID khác

| Kết hợp | Giải thích |
|---|---|
| **LSP + ISP** | Vi phạm LSP thường do interface quá rộng → tách nhỏ (ISP) giúp mỗi subtype chỉ cần tuân thủ contract phù hợp |
| **LSP + OCP** | LSP đảm bảo bạn có thể mở rộng hệ thống bằng cách thêm subtype mới (OCP) mà không phá vỡ code hiện tại |
| **LSP + DIP** | Depend vào abstraction (DIP) chỉ có ý nghĩa khi mọi implementation thực sự tuân thủ contract (LSP) |

---

## 11. Tóm tắt

LSP trong Flutter/Dart quy về một nguyên tắc cốt lõi: **subtype phải giữ đúng lời hứa của supertype**.

- **Preconditions** không được mạnh hơn — đừng đòi hỏi nhiều hơn cha.
- **Postconditions** không được yếu hơn — đừng trả về ít hơn cha hứa.
- **Exceptions** phải nằm trong contract — đừng throw thứ client không expect.
- **State transitions** phải nhất quán — đừng skip step mà consumer depend vào.
- **Nếu phải throw `UnimplementedError`** → đó là tín hiệu cần tách interface, không phải cố ép kế thừa.

Kiểm tra đơn giản nhất: **thay cha bằng con trong mọi unit test — nếu test vẫn pass, bạn đang tuân thủ LSP.**
