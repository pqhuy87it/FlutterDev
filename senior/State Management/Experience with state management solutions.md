# State Management trong Flutter — Góc nhìn Senior Developer

State management là một trong những quyết định kiến trúc quan trọng nhất trong bất kỳ dự án Flutter nào. Ở level senior, bạn không chỉ cần biết *cách dùng* mà phải hiểu *khi nào dùng gì*, *trade-off* ra sao, và *tại sao* một giải pháp phù hợp hơn giải pháp khác trong từng ngữ cảnh cụ thể.

---

## 1. Bản chất vấn đề: Tại sao cần State Management?

Flutter xây dựng UI theo mô hình declarative — UI là hàm của state: `UI = f(state)`. Khi app nhỏ, `setState()` đủ dùng. Nhưng khi app scale lên, bạn đối mặt với ba vấn đề cốt lõi:

**Prop drilling** — truyền data qua nhiều tầng widget chỉ để một widget con sâu bên dưới cần dùng. **State synchronization** — nhiều widget cần phản ứng với cùng một thay đổi. **Separation of concerns** — logic nghiệp vụ bị trộn lẫn với UI code, khiến testing và maintain trở nên khó khăn.

State management giải quyết cả ba bằng cách tách biệt nơi lưu trữ state, nơi biến đổi state, và nơi hiển thị state.

---

## 2. Phân tích từng giải pháp

### 2.1 Provider

Provider thực chất là một wrapper đẹp hơn của `InheritedWidget`. Nó đưa dependency injection vào widget tree.

**Cách hoạt động:** Bạn "provide" một object ở trên cây widget, các widget con dùng `context.watch()` hoặc `context.read()` để truy cập. Kết hợp với `ChangeNotifier`, bạn có một reactive system đơn giản.

```dart
class CartNotifier extends ChangeNotifier {
  final List<Item> _items = [];
  List<Item> get items => UnmodifiableListView(_items);

  void add(Item item) {
    _items.add(item);
    notifyListeners(); // trigger rebuild
  }
}
```

**Ưu điểm:** Dễ học, ít boilerplate, được Flutter team recommend chính thức cho các app vừa và nhỏ. Tích hợp tự nhiên với widget tree lifecycle.

**Hạn chế ở góc nhìn senior:** `ChangeNotifier` không phân biệt được *phần nào* của state thay đổi — gọi `notifyListeners()` là rebuild tất cả listener. Với state phức tạp, bạn phải tự tách thành nhiều notifier nhỏ để tránh unnecessary rebuild. Ngoài ra, Provider phụ thuộc vào `BuildContext`, nên việc truy cập state ngoài widget tree (ví dụ trong service layer) không tự nhiên.

**Khi nào dùng:** App nhỏ-vừa, team mới với Flutter, hoặc khi bạn cần DI đơn giản mà không muốn overhead lớn.

---

### 2.2 Bloc (Business Logic Component)

Bloc áp dụng pattern **unidirectional data flow** rõ ràng nhất: `Event → Bloc → State`. Mọi thay đổi state đều đi qua một event, được xử lý trong bloc, và emit ra state mới.

```dart
// Events
sealed class CartEvent {}
class AddItem extends CartEvent { final Item item; AddItem(this.item); }

// State
class CartState {
  final List<Item> items;
  const CartState({this.items = const []});
}

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddItem>((event, emit) {
      emit(CartState(items: [...state.items, event.item]));
    });
  }
}
```

**Điểm mạnh ở level senior:**

**Traceability** — Mỗi state change đều có một event tương ứng. Bạn có thể log, replay, và debug toàn bộ luồng state thay đổi. `BlocObserver` cho phép monitor globally tất cả transitions trong app.

**Testability** — Test bloc cực kỳ sạch: given initial state, when event fired, then expect new state. Không cần mock UI, không cần widget test.

**Enforced separation** — Bloc buộc bạn phải suy nghĩ về domain event trước khi code. Điều này đặc biệt có giá trị với team lớn vì nó tạo ra một "contract" rõ ràng giữa UI và business logic.

**Hạn chế:** Boilerplate nhiều — mỗi feature cần ít nhất 3 file (event, state, bloc). Với các state đơn giản (toggle, counter), Bloc là overkill. Biến thể `Cubit` giảm bớt overhead bằng cách bỏ event layer, gọi method trực tiếp.

**Khi nào dùng:** App enterprise, team lớn cần convention rõ ràng, feature có logic phức tạp (payment flow, multi-step form), hoặc khi cần audit trail cho state changes.

---

### 2.3 Riverpod

Riverpod được tạo bởi chính tác giả của Provider (Remi Rousselet) để giải quyết các hạn chế căn bản của Provider. Điểm khác biệt lớn nhất: **Riverpod không phụ thuộc vào BuildContext**.

```dart
// Khai báo provider ở top-level — compile-time safe
final cartProvider = NotifierProvider<CartNotifier, List<Item>>(CartNotifier.new);

class CartNotifier extends Notifier<List<Item>> {
  @override
  List<Item> build() => []; // initial state

  void add(Item item) {
    state = [...state, item];
  }
}
```

**Điểm mạnh ở level senior:**

**Compile-time safety** — Provider truyền thống throw runtime error nếu bạn `watch` một provider chưa được cung cấp. Riverpod detect lỗi này lúc compile.

**Independent of widget tree** — Provider được khai báo global, có thể truy cập từ bất kỳ đâu. Điều này giải quyết triệt để vấn đề scoping mà Provider gặp phải.

**Fine-grained reactivity** — `select` cho phép widget chỉ rebuild khi một phần cụ thể của state thay đổi: `ref.watch(cartProvider.select((items) => items.length))`. Widget này chỉ rebuild khi *số lượng* item thay đổi, không phải khi list thay đổi.

**Auto-dispose** — Provider tự dọn dẹp khi không còn listener. Bạn kiểm soát lifecycle state mà không cần quản lý thủ công.

**Provider combination** — Một provider có thể `watch` provider khác, tạo ra dependency graph reactive. Riverpod tự xử lý thứ tự cập nhật.

**Hạn chế:** Learning curve cao hơn, đặc biệt với code generation (`@riverpod` annotation). API surface lớn — `Provider`, `StateProvider`, `FutureProvider`, `StreamProvider`, `NotifierProvider`, `AsyncNotifierProvider`... mỗi loại có use case riêng.

**Khi nào dùng:** App trung bình-lớn, khi cần kiểm soát fine-grained rebuild, khi logic cần truy cập state ngoài widget tree, hoặc khi team đã quen với reactive/functional programming paradigm.

---

## 3. So sánh chiến lược

| Tiêu chí | Provider | Bloc | Riverpod |
|---|---|---|---|
| Boilerplate | Thấp | Cao | Trung bình |
| Testability | Trung bình | Rất cao | Cao |
| Learning curve | Thấp | Trung bình | Trung bình-Cao |
| Scalability | Trung bình | Rất cao | Cao |
| Traceability | Thấp | Rất cao (event log) | Trung bình |
| Rebuild optimization | Thủ công | Tốt (buildWhen) | Rất tốt (select) |
| Context dependency | Có | Có (qua BlocProvider) | Không |

---

## 4. Góc nhìn Senior: Những điều thực sự quan trọng

### Không có "best" solution — chỉ có "right" solution cho context

Senior developer không trung thành với một giải pháp. Câu hỏi đúng không phải "Bloc hay Riverpod?" mà là: team size bao nhiêu? Onboarding speed quan trọng không? App cần audit trail không? Mức độ phức tạp của business logic ra sao?

### Mixing là hợp lý

Nhiều production app dùng kết hợp: Riverpod cho DI và simple state, Bloc cho complex business flow. Điều quan trọng là **consistency trong từng layer** — đừng dùng 3 giải pháp khác nhau cho cùng một loại vấn đề.

### State granularity matters

Dù dùng giải pháp nào, senior developer luôn nghĩ về granularity. Một "UserState" chứa profile, settings, và notifications sẽ khiến mọi thay đổi nhỏ rebuild tất cả widget phụ thuộc. Tách thành `UserProfileState`, `UserSettingsState`, `NotificationState` giúp kiểm soát rebuild scope.

### Immutability là non-negotiable

Ở mọi giải pháp, state phải immutable. Mutate state trực tiếp là nguồn gốc của những bug khó reproduce nhất. Package như `freezed` giúp enforce điều này với `copyWith`, `==` override, và sealed union cho state variants.

### Testing strategy phải đi kèm

Chọn state management mà không có testing strategy là chọn sai. Bloc test bằng `blocTest()`, Riverpod test bằng `ProviderContainer`, Provider test bằng mock notifier. Senior developer chọn giải pháp một phần dựa trên khả năng test dễ dàng của nó.

---

Tóm lại, khi nhà tuyển dụng yêu cầu "experience with state management solutions", họ không chỉ muốn bạn biết API. Họ muốn thấy bạn hiểu trade-off, biết khi nào chọn gì, và có khả năng thiết kế state architecture cho một app có thể scale — cả về codebase lẫn team size.
