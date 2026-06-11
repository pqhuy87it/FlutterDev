## Riverpod, Flutter Riverpod, Hooks Riverpod, Flutter Hooks

### 1. Tổng quan quan hệ giữa các package

```
                    ┌─────────────┐
                    │  riverpod   │  ← Core (pure Dart, không cần Flutter)
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │                         │
   ┌──────────▼──────────┐   ┌──────────▼───────────┐
   │  flutter_riverpod   │   │   hooks_riverpod     │
   │  (Flutter binding)  │   │  (Flutter + Hooks)   │
   └─────────────────────┘   └──────────┬───────────┘
                                        │ depends on
                              ┌─────────▼────────┐
                              │  flutter_hooks   │  ← Hook system (không liên quan Riverpod)
                              └──────────────────┘
```

Bốn package này không phải 4 lựa chọn thay thế nhau. Chúng là các tầng xây dựng lên nhau, và bạn chọn **một combo** tuỳ theo nhu cầu.

---

### 2. `riverpod` — Core thuần Dart

#### Là gì

Package lõi chứa toàn bộ logic state management: Provider, Notifier, ProviderContainer, ProviderScope concept, dependency injection, auto dispose... Viết bằng pure Dart, không import Flutter.

#### Khi nào dùng

Dùng khi viết Dart server, CLI tool, hoặc package library không phụ thuộc Flutter:

```dart
// pubspec.yaml
dependencies:
  riverpod: ^2.6.1
```

```dart
import 'package:riverpod/riverpod.dart';

// Không có Widget, không có BuildContext
final greetingProvider = Provider<String>((ref) => 'Hello');

final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);
  void increment() => state++;
}

// Dùng trực tiếp với ProviderContainer (không cần Widget tree)
void main() {
  final container = ProviderContainer();

  print(container.read(greetingProvider));  // "Hello"
  print(container.read(counterProvider));   // 0

  container.read(counterProvider.notifier).increment();
  print(container.read(counterProvider));   // 1

  container.dispose();
}
```

**Trong Flutter app thông thường, bạn KHÔNG dùng trực tiếp package này.** Dùng `flutter_riverpod` hoặc `hooks_riverpod` thay thế.

---

### 3. `flutter_riverpod` — Riverpod cho Flutter

#### Là gì

Xây dựng trên `riverpod`, thêm các Flutter-specific binding: `ProviderScope` (widget), `ConsumerWidget`, `ConsumerStatefulWidget`, `Consumer` builder, và extension trên `WidgetRef`.

```dart
// pubspec.yaml
dependencies:
  flutter_riverpod: ^2.6.1
  # TỰ ĐỘNG kéo theo package "riverpod" — không cần thêm riêng
```

#### Các widget cung cấp

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. ProviderScope — wrap root app, tạo ProviderContainer
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// 2. ConsumerWidget — thay thế StatelessWidget
class PointExchangeList extends ConsumerWidget {
  const PointExchangeList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //                               ↑
    //                     ref để read/watch provider
    final exchanges = ref.watch(pointExchangeProvider);

    return exchanges.when(
      data: (data) => ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) => Text(data[index].providerName),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text('Error: $e'),
    );
  }
}

// 3. ConsumerStatefulWidget — thay thế StatefulWidget
class ExchangeScreen extends ConsumerStatefulWidget {
  const ExchangeScreen({super.key});

  @override
  ConsumerState<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends ConsumerState<ExchangeScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // Dùng ref trong initState
    final initialValue = ref.read(defaultAmountProvider);
    _controller.text = initialValue.toString();
  }

  @override
  void dispose() {
    _controller.dispose();  // Phải tự quản lý lifecycle
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exchanges = ref.watch(pointExchangeProvider);
    return TextField(controller: _controller);
  }
}

// 4. Consumer — builder widget, dùng khi chỉ muốn wrap một phần
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Static header'),  // không rebuild

        Consumer(  // chỉ phần này rebuild khi provider thay đổi
          builder: (context, ref, child) {
            final count = ref.watch(counterProvider);
            return Text('Count: $count');
          },
        ),

        const Text('Static footer'),  // không rebuild
      ],
    );
  }
}
```

---

### 4. `flutter_hooks` — Hook system cho Flutter

#### Là gì

Package **hoàn toàn độc lập với Riverpod**. Mang concept React Hooks vào Flutter, giúp quản lý lifecycle của StatefulWidget (controller, animation, subscription...) bằng cách khai báo thay vì imperative init/dispose.

```dart
// pubspec.yaml
dependencies:
  flutter_hooks: ^0.20.5
  # KHÔNG phụ thuộc riverpod
```

#### Vấn đề flutter_hooks giải quyết

```dart
// ❌ Không dùng hooks — code dài, dễ quên dispose
class _ExchangeScreenState extends State<ExchangeScreen> {
  late TextEditingController _amountController;
  late TextEditingController _searchController;
  late AnimationController _fadeController;
  late ScrollController _scrollController;
  late FocusNode _amountFocus;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '1000');
    _searchController = TextEditingController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollController = ScrollController();
    _amountFocus = FocusNode();
    _subscription = someStream.listen((_) => setState(() {}));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();   // Quên 1 cái → memory leak
    _searchController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    _amountFocus.dispose();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: _amountController),
        TextField(controller: _searchController),
        FadeTransition(
          opacity: _fadeController,
          child: ListView(controller: _scrollController),
        ),
      ],
    );
  }
}
```

```dart
// ✅ Dùng hooks — ngắn gọn, tự dispose
class ExchangeScreen extends HookWidget {
  const ExchangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mỗi hook tự quản lý init + dispose
    final amountController = useTextEditingController(text: '1000');
    final searchController = useTextEditingController();
    final fadeController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final scrollController = useScrollController();
    final amountFocus = useFocusNode();

    // useEffect = initState + dispose kết hợp
    useEffect(() {
      fadeController.forward();
      final subscription = someStream.listen((_) {});
      return subscription.cancel;  // cleanup function = dispose
    }, []);  // [] = chạy 1 lần như initState

    return Column(
      children: [
        TextField(controller: amountController),
        TextField(controller: searchController),
        FadeTransition(
          opacity: fadeController,
          child: ListView(controller: scrollController),
        ),
      ],
    );
  }
}
```

#### Các hook phổ biến

```dart
class DemoScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {

    // === State hooks ===
    // useState — thay thế setState cho giá trị đơn giản
    final counter = useState(0);        // counter.value = 0
    final isLoading = useState(false);

    // === Controller hooks ===
    // Tự tạo và dispose controller
    final textController = useTextEditingController(text: 'initial');
    final scrollController = useScrollController();
    final focusNode = useFocusNode();
    final tabController = useTabController(initialLength: 3);
    final animController = useAnimationController(
      duration: const Duration(seconds: 1),
    );
    final animation = useAnimation(animController);  // lắng nghe value

    // === Lifecycle hooks ===
    // useEffect — side effect với cleanup
    useEffect(() {
      print('Widget mounted');
      final timer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => print('tick'),
      );
      return timer.cancel;  // cleanup khi dispose hoặc dependency thay đổi
    }, const []);  // [] = chạy 1 lần; [dep1, dep2] = chạy lại khi dep thay đổi

    // useMemoized — cache giá trị tốn compute
    final sortedList = useMemoized(
      () => heavySort(rawData),
      [rawData],  // chỉ tính lại khi rawData thay đổi
    );

    // useValueChanged — react khi giá trị thay đổi
    useValueChanged(counter.value, (oldValue, _) {
      print('Counter changed from $oldValue to ${counter.value}');
    });

    // useFuture — lắng nghe Future
    final snapshot = useFuture(
      useMemoized(() => fetchData()),
      initialData: null,
    );

    // useStream — lắng nghe Stream
    final streamSnapshot = useStream(
      useMemoized(() => firestore.snapshots()),
    );

    return Column(
      children: [
        Text('Count: ${counter.value}'),
        ElevatedButton(
          onPressed: () => counter.value++,  // tự rebuild
          child: const Text('Increment'),
        ),
        if (snapshot.connectionState == ConnectionState.waiting)
          const CircularProgressIndicator()
        else
          Text('Data: ${snapshot.data}'),
      ],
    );
  }
}
```

#### Custom hook

```dart
// Tạo hook riêng — tái sử dụng logic phức tạp
ValueNotifier<bool> useNetworkStatus() {
  final isConnected = useState(true);

  useEffect(() {
    final subscription = Connectivity().onConnectivityChanged.listen((result) {
      isConnected.value = result != ConnectivityResult.none;
    });
    return subscription.cancel;
  }, []);

  return isConnected;
}

// Hook cho debounce search
String useDebouncedValue(String value, {Duration delay = const Duration(milliseconds: 300)}) {
  final debouncedValue = useState(value);

  useEffect(() {
    final timer = Timer(delay, () {
      debouncedValue.value = value;
    });
    return timer.cancel;
  }, [value, delay]);

  return debouncedValue.value;
}

// Sử dụng
class SearchScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchText = useState('');
    final debouncedSearch = useDebouncedValue(searchText.value);
    final isConnected = useNetworkStatus();

    return Column(
      children: [
        if (!isConnected.value)
          const Banner(message: 'Offline'),
        TextField(
          controller: searchController,
          onChanged: (v) => searchText.value = v,
        ),
        // debouncedSearch chỉ cập nhật sau 300ms ngừng gõ
        SearchResults(query: debouncedSearch),
      ],
    );
  }
}
```

---

### 5. `hooks_riverpod` — Kết hợp cả hai

#### Là gì

Thay thế `flutter_riverpod`, thêm tích hợp hooks. Cung cấp `HookConsumerWidget` — widget vừa có `ref` (Riverpod) vừa dùng được hooks.

```dart
// pubspec.yaml
dependencies:
  hooks_riverpod: ^2.6.1
  flutter_hooks: ^0.20.5
  # TỰ ĐỘNG kéo theo flutter_riverpod và riverpod
  # KHÔNG cần thêm flutter_riverpod riêng
```

#### So sánh widget types

```dart
// flutter_riverpod — KHÔNG có hooks
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(myProvider);  // ✅ Riverpod
    // useTextEditingController();       // ❌ Không dùng được hooks
    return Text('$data');
  }
}

// flutter_hooks — KHÔNG có Riverpod
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();  // ✅ Hooks
    // ref.watch(myProvider);                        // ❌ Không có ref
    return TextField(controller: controller);
  }
}

// hooks_riverpod — CÓ CẢ HAI
class MyWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(myProvider);             // ✅ Riverpod
    final controller = useTextEditingController();  // ✅ Hooks
    return TextField(controller: controller);
  }
}
```

#### Ví dụ thực tế — Point Exchange Screen

```dart
// ❌ Dùng flutter_riverpod — cần ConsumerStatefulWidget dài dòng
class PointExchangeScreen extends ConsumerStatefulWidget {
  const PointExchangeScreen({super.key});

  @override
  ConsumerState<PointExchangeScreen> createState() =>
      _PointExchangeScreenState();
}

class _PointExchangeScreenState extends ConsumerState<PointExchangeScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollController = ScrollController();
    _animController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exchanges = ref.watch(pointExchangeAsyncNotifierProvider);
    final searchState = ref.watch(pointExchangeSearchStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ポイント交換')),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => ref
                .read(pointExchangeSearchStateProvider.notifier)
                .updateSearch(value),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _animController,
              child: exchanges.when(
                data: (data) => ListView.builder(
                  controller: _scrollController,
                  itemCount: data.length,
                  itemBuilder: (context, index) =>
                      PointExchangeCard(model: data[index]),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Error: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

```dart
// ✅ Dùng hooks_riverpod — ngắn hơn nhiều, không cần StatefulWidget
class PointExchangeScreen extends HookConsumerWidget {
  const PointExchangeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final animController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final scrollController = useScrollController();

    // useEffect thay initState
    useEffect(() {
      animController.forward();
      return null;  // không cần cleanup vì hooks tự dispose controller
    }, []);

    final exchanges = ref.watch(pointExchangeAsyncNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ポイント交換')),
      body: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: (value) => ref
                .read(pointExchangeSearchStateProvider.notifier)
                .updateSearch(value),
          ),
          Expanded(
            child: FadeTransition(
              opacity: animController,
              child: exchanges.when(
                data: (data) => ListView.builder(
                  controller: scrollController,
                  itemCount: data.length,
                  itemBuilder: (context, index) =>
                      PointExchangeCard(model: data[index]),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Error: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### 6. So sánh tổng hợp

```
Package            Cung cấp gì              Phụ thuộc           Dùng khi
──────────────────────────────────────────────────────────────────────────
riverpod           Provider, Notifier,       Không               Pure Dart project
                   ProviderContainer                             (server, CLI, test)

flutter_riverpod   ConsumerWidget,           riverpod            Flutter app
                   ConsumerStatefulWidget,                       KHÔNG cần hooks
                   ProviderScope, Consumer

flutter_hooks      HookWidget,               flutter             Muốn hooks
                   useState, useEffect,                          KHÔNG cần Riverpod
                   useController...

hooks_riverpod     HookConsumerWidget         flutter_riverpod   Flutter app
                                              + flutter_hooks    CẦN cả Riverpod + hooks
```

#### Bạn chỉ cần chọn MỘT trong 3 combo

```yaml
# Combo 1: Riverpod only (project hiện tại đang dùng)
dependencies:
  flutter_riverpod: ^2.6.1

# Combo 2: Riverpod + Hooks (khuyên dùng nếu có nhiều controller/animation)
dependencies:
  hooks_riverpod: ^2.6.1
  flutter_hooks: ^0.20.5

# Combo 3: Hooks only, không Riverpod (hiếm khi dùng)
dependencies:
  flutter_hooks: ^0.20.5
```

**Không bao giờ** thêm cả `flutter_riverpod` lẫn `hooks_riverpod` vào cùng pubspec. `hooks_riverpod` đã bao gồm `flutter_riverpod` bên trong.

---

### 7. Nên dùng combo nào cho project hiện tại

Project point exchange đang dùng `flutter_riverpod` với nhiều `ConsumerStatefulWidget` có controller (TextEditingController, ScrollController) và StreamSubscription. Code có nhiều chỗ `initState` / `dispose` dài:

```dart
// Code hiện tại trong providers.dart:
// - ServiceOperatorsNotifier: StreamSubscription cần dispose
// - MerchantsNotifier: 3 StreamSubscription cần dispose
// - UsersNotifier: StreamSubscription cần dispose
// - NewsCategoriesNotifier: StreamSubscription cần dispose
// - NewsNotifier: StreamSubscription cần dispose
```

Nếu migrate sang `hooks_riverpod`, các screen UI sẽ ngắn gọn hơn đáng kể nhờ hooks quản lý controller lifecycle. Tuy nhiên, các StateNotifier trong `providers.dart` vẫn giữ nguyên vì chúng là business logic layer, không phải UI — hooks chỉ hữu ích ở UI layer.

Quyết định phụ thuộc vào team: nếu team quen React Hooks hoặc sẵn sàng học → dùng `hooks_riverpod`. Nếu team muốn giữ Flutter thuần → `flutter_riverpod` hiện tại là đủ.
