# Single Responsibility Principle (SRP) trong Flutter/Dart

> *"A class should have one, and only one, reason to change."*
> — Robert C. Martin

Phiên bản chính xác hơn từ chính Uncle Bob:

> *"A module should be responsible to one, and only one, actor."*

Nói đơn giản: **mỗi class/module chỉ phục vụ một "actor" (nhóm người/hệ thống yêu cầu thay đổi)** — khi business logic thay đổi, chỉ có đúng một lý do khiến class đó phải sửa.

---

## 1. Hiểu đúng "Responsibility" — Không phải "chỉ làm một việc"

SRP **không** có nghĩa là mỗi class chỉ có một method. Nó nói về **reason to change** — ai/cái gì gây ra thay đổi cho class này.

```
❌ Hiểu sai:  "Mỗi class chỉ có 1 method"
❌ Hiểu sai:  "Mỗi class chỉ làm 1 việc nhỏ"
✅ Hiểu đúng: "Mỗi class chỉ có 1 lý do để thay đổi"
✅ Hiểu đúng: "Mỗi class chỉ chịu trách nhiệm trước 1 actor"
```

**Ví dụ về "actor":**

| Actor | Yêu cầu thay đổi |
|---|---|
| **UI/UX Designer** | Layout, animation, theme |
| **Product Owner** | Business rules, feature logic |
| **Backend Team** | API contract, data format |
| **DevOps / QA** | Logging, monitoring, crash report |
| **Legal / Compliance** | Data privacy, consent, audit |

Nếu một class thay đổi khi Designer đổi layout **VÀ** khi Backend đổi API → class đó phục vụ 2 actor → vi phạm SRP.

---

## 2. Vi phạm SRP kinh điển trong Flutter

### 2a. God Widget — Widget ôm mọi thứ

```dart
// ❌ Widget này thay đổi khi:
// 1. UI layout thay đổi (Designer)
// 2. Business logic thay đổi (Product Owner)
// 3. API thay đổi (Backend)
// 4. Analytics thay đổi (Data Team)
// → 4 actors, 4 reasons to change

class ProductListPage extends StatefulWidget {
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> products = [];
  bool isLoading = false;
  String? error;
  String searchQuery = '';
  String selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // ❌ Responsibility 1: Networking + Data parsing (Backend actor)
  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://api.example.com/products'),
        headers: {'Authorization': 'Bearer ${await _getToken()}'},
      );
      final json = jsonDecode(response.body) as List;
      setState(() {
        products = json.map((e) => Product(
          id: e['id'] as String,
          name: e['product_name'] as String,     // mapping logic
          price: (e['price_cents'] as int) / 100, // business conversion
          category: e['cat'] as String,
        )).toList();
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ❌ Responsibility 2: Token management (Security actor)
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('Not authenticated');
    // Token refresh logic...
    return token;
  }

  // ❌ Responsibility 3: Business logic — filtering (Product Owner actor)
  List<Product> get _filteredProducts {
    return products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchesCategory =
          selectedCategory == 'all' || p.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList()
      ..sort((a, b) => b.price.compareTo(a.price)); // sort logic
  }

  // ❌ Responsibility 4: Analytics tracking (Data Team actor)
  void _trackProductView(Product product) {
    final payload = {
      'event': 'product_viewed',
      'product_id': product.id,
      'category': product.category,
      'timestamp': DateTime.now().toIso8601String(),
      'session_id': _getSessionId(),
    };
    http.post(
      Uri.parse('https://analytics.example.com/track'),
      body: jsonEncode(payload),
    );
  }

  // ❌ Responsibility 5: UI rendering (Designer actor)
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text('Error: $error'));
    
    return Column(
      children: [
        // Search bar UI
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Tìm sản phẩm...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // Category chips UI
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['all', 'electronics', 'clothing', 'food']
                .map((cat) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: selectedCategory == cat,
                        onSelected: (_) =>
                            setState(() => selectedCategory = cat),
                      ),
                    ))
                .toList(),
          ),
        ),
        // Product list UI
        Expanded(
          child: ListView.builder(
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('${product.price} VND'),
                onTap: () {
                  _trackProductView(product);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ProductDetailPage(product: product),
                  ));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
```

**File này sẽ thay đổi khi:**

| Thay đổi | Actor | Dòng code bị ảnh hưởng |
|---|---|---|
| API đổi field name | Backend | `_loadProducts` |
| Đổi thuật toán sort/filter | Product Owner | `_filteredProducts` |
| Redesign UI | Designer | `build` |
| Đổi analytics event | Data Team | `_trackProductView` |
| Đổi token storage | Security | `_getToken` |

→ Mọi thay đổi đều sửa **cùng 1 file**, mọi dev đều conflict nhau.

---

## 3. Áp dụng SRP — Tách theo Actor/Responsibility

### Layer 1: Data Layer — Phục vụ Backend actor

```dart
// ── Model: chỉ thay đổi khi data structure thay đổi ──
class ProductDto {
  final String id;
  final String productName;
  final int priceCents;
  final String cat;

  ProductDto.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        productName = json['product_name'] as String,
        priceCents = json['price_cents'] as int,
        cat = json['cat'] as String;
}

class Product {
  final String id;
  final String name;
  final double price;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });
}

// ── Mapper: chỉ thay đổi khi mapping logic thay đổi ──
class ProductMapper {
  Product fromDto(ProductDto dto) => Product(
        id: dto.id,
        name: dto.productName,
        price: dto.priceCents / 100,
        category: dto.cat,
      );

  List<Product> fromDtoList(List<ProductDto> dtos) =>
      dtos.map(fromDto).toList();
}

// ── API Client: chỉ thay đổi khi endpoint/contract thay đổi ──
class ProductApiClient {
  final Dio _dio;
  ProductApiClient(this._dio);

  Future<List<ProductDto>> fetchProducts() async {
    final response = await _dio.get('/products');
    return (response.data as List)
        .map((e) => ProductDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

// ── Repository: orchestrate data sources ──
class ProductRepository {
  final ProductApiClient _api;
  final ProductMapper _mapper;

  ProductRepository(this._api, this._mapper);

  Future<List<Product>> getProducts() async {
    final dtos = await _api.fetchProducts();
    return _mapper.fromDtoList(dtos);
  }
}
```

**Khi Backend đổi API:** chỉ sửa `ProductDto.fromJson` + có thể `ProductApiClient` → không ảnh hưởng UI, business logic, analytics.

### Layer 2: Domain/Business Layer — Phục vụ Product Owner actor

```dart
// ── Filter logic: chỉ thay đổi khi business rule filter thay đổi ──
class ProductFilter {
  final String query;
  final String category;

  const ProductFilter({this.query = '', this.category = 'all'});

  List<Product> apply(List<Product> products) {
    return products.where((p) {
      final matchesSearch =
          query.isEmpty || p.name.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == 'all' || p.category == category;
      return matchesSearch && matchesCategory;
    }).toList();
  }
}

// ── Sort logic: tách riêng vì sort rule có thể thay đổi độc lập ──
enum ProductSortType { priceAsc, priceDesc, nameAsc, newest }

class ProductSorter {
  List<Product> sort(List<Product> products, ProductSortType type) {
    final sorted = List<Product>.from(products);
    return switch (type) {
      ProductSortType.priceAsc  => sorted..sort((a, b) => a.price.compareTo(b.price)),
      ProductSortType.priceDesc => sorted..sort((a, b) => b.price.compareTo(a.price)),
      ProductSortType.nameAsc   => sorted..sort((a, b) => a.name.compareTo(b.name)),
      ProductSortType.newest    => sorted..sort((a, b) => b.id.compareTo(a.id)),
    };
  }
}
```

**Khi Product Owner muốn đổi thuật toán filter:** chỉ sửa `ProductFilter` → không ảnh hưởng API, UI, analytics.

### Layer 3: Analytics — Phục vụ Data Team actor

```dart
// ── Tracker: chỉ thay đổi khi analytics requirement thay đổi ──
abstract class AnalyticsTracker {
  void trackEvent(String name, Map<String, dynamic> properties);
}

class ProductAnalytics {
  final AnalyticsTracker _tracker;
  ProductAnalytics(this._tracker);

  void trackProductViewed(Product product) {
    _tracker.trackEvent('product_viewed', {
      'product_id': product.id,
      'category': product.category,
      'price': product.price,
    });
  }

  void trackSearchPerformed(String query, int resultCount) {
    _tracker.trackEvent('search_performed', {
      'query': query,
      'result_count': resultCount,
    });
  }

  void trackFilterApplied(String category) {
    _tracker.trackEvent('filter_applied', {'category': category});
  }
}
```

### Layer 4: State Management — Orchestrate, không chứa logic

```dart
// ── State: chỉ là data container ──
class ProductListState {
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final ProductFilter filter;
  final ProductSortType sortType;
  final bool isLoading;
  final String? error;

  const ProductListState({
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.filter = const ProductFilter(),
    this.sortType = ProductSortType.priceDesc,
    this.isLoading = false,
    this.error,
  });

  ProductListState copyWith({
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    ProductFilter? filter,
    ProductSortType? sortType,
    bool? isLoading,
    String? error,
  }) => ProductListState(
    allProducts: allProducts ?? this.allProducts,
    filteredProducts: filteredProducts ?? this.filteredProducts,
    filter: filter ?? this.filter,
    sortType: sortType ?? this.sortType,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );
}

// ── Cubit: ORCHESTRATE, không chứa business logic ──
class ProductListCubit extends Cubit<ProductListState> {
  final ProductRepository _repository;
  final ProductFilter _filter = const ProductFilter();
  final ProductSorter _sorter;
  final ProductAnalytics _analytics;

  ProductListCubit({
    required ProductRepository repository,
    required ProductSorter sorter,
    required ProductAnalytics analytics,
  })  : _repository = repository,
        _sorter = sorter,
        _analytics = analytics,
        super(const ProductListState());

  Future<void> loadProducts() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final products = await _repository.getProducts();
      final filtered = state.filter.apply(products);
      final sorted = _sorter.sort(filtered, state.sortType);
      emit(state.copyWith(
        allProducts: products,
        filteredProducts: sorted,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void updateSearch(String query) {
    final newFilter = ProductFilter(
      query: query,
      category: state.filter.category,
    );
    final filtered = newFilter.apply(state.allProducts);
    final sorted = _sorter.sort(filtered, state.sortType);

    _analytics.trackSearchPerformed(query, filtered.length);
    emit(state.copyWith(filter: newFilter, filteredProducts: sorted));
  }

  void updateCategory(String category) {
    final newFilter = ProductFilter(
      query: state.filter.query,
      category: category,
    );
    final filtered = newFilter.apply(state.allProducts);
    final sorted = _sorter.sort(filtered, state.sortType);

    _analytics.trackFilterApplied(category);
    emit(state.copyWith(filter: newFilter, filteredProducts: sorted));
  }

  void trackProductViewed(Product product) {
    _analytics.trackProductViewed(product);
  }
}
```

### Layer 5: UI — Phục vụ Designer actor

```dart
// ── Page: chỉ layout + kết nối state ──
class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductListCubit>()..loadProducts(),
      child: const _ProductListView(),
    );
  }
}

class _ProductListView extends StatelessWidget {
  const _ProductListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm')),
      body: Column(
        children: const [
          _SearchBar(),
          _CategoryChips(),
          Expanded(child: _ProductGrid()),
        ],
      ),
    );
  }
}

// ── Mỗi widget con: 1 responsibility duy nhất ──

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: context.read<ProductListCubit>().updateSearch,
        decoration: InputDecoration(
          hintText: 'Tìm sản phẩm...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips();

  static const _categories = ['all', 'electronics', 'clothing', 'food'];

  @override
  Widget build(BuildContext context) {
    final selected = context.select<ProductListCubit, String>(
      (c) => c.state.filter.category,
    );
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return ChoiceChip(
            label: Text(cat),
            selected: selected == cat,
            onSelected: (_) =>
                context.read<ProductListCubit>().updateCategory(cat),
          );
        },
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListCubit, ProductListState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return _ErrorView(
            message: state.error!,
            onRetry: context.read<ProductListCubit>().loadProducts,
          );
        }
        if (state.filteredProducts.isEmpty) {
          return const Center(child: Text('Không tìm thấy sản phẩm'));
        }
        return ListView.builder(
          itemCount: state.filteredProducts.length,
          itemBuilder: (context, index) => ProductCard(
            product: state.filteredProducts[index],
            onTap: () {
              final product = state.filteredProducts[index];
              context.read<ProductListCubit>().trackProductViewed(product);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => ProductDetailPage(product: product),
              ));
            },
          ),
        );
      },
    );
  }
}
```

---

## 4. Bản đồ Responsibility sau khi tách

```
Thay đổi từ actor nào?     │  Sửa class nào?           │  Ảnh hưởng gì khác?
────────────────────────────┼───────────────────────────┼─────────────────────
Backend đổi API field       │  ProductDto, ApiClient    │  Không gì
Product Owner đổi filter    │  ProductFilter            │  Không gì
Product Owner đổi sort      │  ProductSorter            │  Không gì
Designer đổi layout         │  _ProductGrid, _SearchBar │  Không gì
Data Team đổi tracking      │  ProductAnalytics         │  Không gì
Security đổi token logic    │  TokenManager (riêng)     │  Không gì
```

**Mỗi hàng = 1 actor, 1 class, 0 side effect** — đó là SRP.

---

## 5. SRP ở các tầng khác trong Flutter

### 5a. Navigation — Tách routing logic khỏi Widget

```dart
// ❌ Widget biết cách navigate + biết tất cả destination
class ProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Widget biết routing detail → thay đổi khi navigation thay đổi
        if (product.isExternal) {
          launchUrl(Uri.parse(product.externalUrl));
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(id: product.id),
            ),
          );
        }
      },
      child: /* ... */,
    );
  }
}

// ✅ Widget chỉ biết "tôi muốn navigate" — không biết "đi bằng cách nào"
abstract class ProductNavigator {
  void goToDetail(BuildContext context, Product product);
}

class ProductNavigatorImpl implements ProductNavigator {
  @override
  void goToDetail(BuildContext context, Product product) {
    if (product.isExternal) {
      launchUrl(Uri.parse(product.externalUrl));
    } else {
      context.pushNamed('/product', arguments: product.id);
    }
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductNavigator navigator;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigator.goToDetail(context, product),
      child: /* ... */,
    );
  }
}
```

### 5b. Error Handling — Tách error formatting khỏi business logic

```dart
// ❌ Repository vừa fetch data vừa format error message cho UI
class ProductRepository {
  Future<List<Product>> getProducts() async {
    try {
      return await _api.fetchProducts();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Lỗi hệ thống. Vui lòng thử lại sau.');
      }
      throw Exception('Không thể kết nối. Kiểm tra mạng.');
    }
  }
}

// ✅ Tách: Repository throw typed exception, UI layer format message
// Repository — chỉ biết data
sealed class AppException implements Exception {
  final String code;
  final String? debugMessage;
  const AppException(this.code, [this.debugMessage]);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String? msg]) : super('unauthorized', msg);
}

class ServerException extends AppException {
  const ServerException([String? msg]) : super('server_error', msg);
}

class NetworkException extends AppException {
  const NetworkException([String? msg]) : super('network', msg);
}

class ProductRepository {
  Future<List<Product>> getProducts() async {
    try {
      return await _api.fetchProducts();
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 401: throw const UnauthorizedException();
        case 500: throw ServerException(e.message);
        default:  throw NetworkException(e.message);
      }
    }
  }
}

// ErrorMapper — chỉ biết convert exception → user message
class ErrorMapper {
  String toUserMessage(AppException exception) => switch (exception) {
    UnauthorizedException() => 'Phiên đăng nhập đã hết hạn.',
    ServerException()       => 'Lỗi hệ thống. Vui lòng thử lại sau.',
    NetworkException()      => 'Không thể kết nối. Kiểm tra mạng.',
  };
}
```

### 5c. Form — Tách validation, submission, state

```dart
// ── Validation: chỉ thay đổi khi validation rules thay đổi ──
class RegisterFormValidator {
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email là bắt buộc';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Mật khẩu là bắt buộc';
    if (value.length < 8) return 'Tối thiểu 8 ký tự';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Cần ít nhất 1 chữ hoa';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (!RegExp(r'^(0|\+84)(3|5|7|8|9)\d{8}$').hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }
}

// ── Submission: chỉ thay đổi khi API registration thay đổi ──
class RegisterService {
  final AuthApiClient _api;
  RegisterService(this._api);

  Future<User> register({
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _api.register(email, password, phone);
    return User.fromJson(response.data);
  }
}

// ── Cubit: orchestrate validation + submission ──
class RegisterCubit extends Cubit<RegisterState> {
  final RegisterFormValidator _validator;
  final RegisterService _service;
  final ProductAnalytics _analytics;

  RegisterCubit(this._validator, this._service, this._analytics)
      : super(const RegisterState());

  void emailChanged(String value) {
    emit(state.copyWith(
      email: value,
      emailError: _validator.validateEmail(value),
    ));
  }

  Future<void> submit() async {
    // validate all fields
    final emailErr = _validator.validateEmail(state.email);
    final passErr = _validator.validatePassword(state.password);
    if (emailErr != null || passErr != null) {
      emit(state.copyWith(emailError: emailErr, passwordError: passErr));
      return;
    }

    emit(state.copyWith(isSubmitting: true));
    try {
      final user = await _service.register(
        email: state.email,
        password: state.password,
        phone: state.phone,
      );
      emit(state.copyWith(isSubmitting: false, success: true));
    } on AppException catch (e) {
      emit(state.copyWith(isSubmitting: false, submitError: e.code));
    }
  }
}
```

### 5d. Formatting / Presentation Logic — Tách khỏi Widget

```dart
// ❌ Widget chứa formatting logic
class OrderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      // Formatting logic nằm trong build → sửa khi format thay đổi
      '${order.amount.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          )} ₫',
    );
  }
}

// ✅ Tách formatter riêng
class CurrencyFormatter {
  String formatVnd(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '$formatted ₫';
  }

  String formatUsd(double amount) => '\$${amount.toStringAsFixed(2)}';
}

class DateFormatter {
  String relative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${date.day}/${date.month}/${date.year}';
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    return 'Vừa xong';
  }
}

// Widget chỉ hiển thị — không biết format
class OrderCard extends StatelessWidget {
  final CurrencyFormatter currencyFormatter;
  final DateFormatter dateFormatter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(currencyFormatter.formatVnd(order.amount)),
        Text(dateFormatter.relative(order.createdAt)),
      ],
    );
  }
}
```

---

## 6. SRP trong Project Structure — Module Level

SRP không chỉ áp dụng ở class level mà còn ở **module/package level**:

```
lib/
├── core/                          # Shared utilities — thay đổi hiếm
│   ├── network/
│   │   ├── api_client.dart        # HTTP abstraction
│   │   ├── interceptors/          # Mỗi interceptor 1 file
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── logging_interceptor.dart
│   │   │   └── retry_interceptor.dart
│   │   └── exceptions.dart
│   ├── formatters/
│   │   ├── currency_formatter.dart
│   │   └── date_formatter.dart
│   └── analytics/
│       ├── analytics_tracker.dart     # Abstract
│       └── firebase_tracker.dart      # Implementation
│
├── features/
│   └── product/
│       ├── data/                       # Backend actor
│       │   ├── dto/
│       │   │   └── product_dto.dart
│       │   ├── mapper/
│       │   │   └── product_mapper.dart
│       │   ├── datasource/
│       │   │   ├── product_api_client.dart
│       │   │   └── product_local_source.dart
│       │   └── repository/
│       │       └── product_repository.dart
│       │
│       ├── domain/                     # Product Owner actor
│       │   ├── model/
│       │   │   └── product.dart
│       │   ├── filter/
│       │   │   └── product_filter.dart
│       │   └── sorter/
│       │       └── product_sorter.dart
│       │
│       ├── analytics/                  # Data Team actor
│       │   └── product_analytics.dart
│       │
│       └── presentation/              # Designer actor
│           ├── cubit/
│           │   ├── product_list_cubit.dart
│           │   └── product_list_state.dart
│           ├── pages/
│           │   └── product_list_page.dart
│           └── widgets/
│               ├── search_bar.dart
│               ├── category_chips.dart
│               ├── product_card.dart
│               └── product_grid.dart
```

**Mỗi folder tương ứng với một actor** — khi actor đó yêu cầu thay đổi, dev chỉ cần mở đúng folder đó.

---

## 7. SRP giúp Testing đơn giản hóa triệt để

```dart
// Mỗi class có 1 responsibility → test tập trung, không noise

// Test filter — không cần mock API, không cần mock UI
void main() {
  group('ProductFilter', () {
    final products = [
      Product(id: '1', name: 'iPhone', price: 999, category: 'electronics'),
      Product(id: '2', name: 'T-Shirt', price: 29, category: 'clothing'),
      Product(id: '3', name: 'iPad', price: 799, category: 'electronics'),
    ];

    test('filters by search query', () {
      final filter = ProductFilter(query: 'ip');
      final result = filter.apply(products);
      expect(result.length, 2); // iPhone + iPad
    });

    test('filters by category', () {
      final filter = ProductFilter(category: 'clothing');
      final result = filter.apply(products);
      expect(result.length, 1);
      expect(result.first.name, 'T-Shirt');
    });

    test('combines search and category', () {
      final filter = ProductFilter(query: 'ip', category: 'electronics');
      final result = filter.apply(products);
      expect(result.length, 2);
    });
  });
}

// Test repository — chỉ mock API client, không cần mock UI/analytics
void main() {
  group('ProductRepository', () {
    late MockProductApiClient mockApi;
    late ProductRepository repository;

    setUp(() {
      mockApi = MockProductApiClient();
      repository = ProductRepository(mockApi, ProductMapper());
    });

    test('maps DTO to domain model correctly', () async {
      when(() => mockApi.fetchProducts()).thenAnswer(
        (_) async => [ProductDto.fromJson({'id': '1', 'product_name': 'Test', 'price_cents': 1999, 'cat': 'electronics'})],
      );

      final products = await repository.getProducts();
      expect(products.first.name, 'Test');
      expect(products.first.price, 19.99);
    });
  });
}

// Test cubit — mock repository + analytics, không cần real API
void main() {
  group('ProductListCubit', () {
    late MockProductRepository mockRepo;
    late MockProductAnalytics mockAnalytics;
    late ProductListCubit cubit;

    setUp(() {
      mockRepo = MockProductRepository();
      mockAnalytics = MockProductAnalytics();
      cubit = ProductListCubit(
        repository: mockRepo,
        sorter: ProductSorter(),
        analytics: mockAnalytics,
      );
    });

    blocTest<ProductListCubit, ProductListState>(
      'emits [loading, loaded] when loadProducts succeeds',
      build: () {
        when(() => mockRepo.getProducts()).thenAnswer((_) async => mockProducts);
        return cubit;
      },
      act: (c) => c.loadProducts(),
      expect: () => [
        isA<ProductListState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ProductListState>().having((s) => s.filteredProducts.length, 'count', 3),
      ],
    );
  });
}
```

---

## 8. Dấu hiệu vi phạm SRP

| Dấu hiệu | Giải thích |
|---|---|
| File **>300 dòng** | Có thể ôm nhiều responsibility |
| Class cần **5+ dependencies** inject vào | Đang orchestrate quá nhiều concern |
| **Nhiều import** không liên quan nhau | `import 'http'` + `import 'analytics'` + `import 'local_db'` trong 1 widget |
| Commit message: **"Fix A and update B and refactor C"** | 1 file chứa logic A, B, C |
| **Merge conflict** thường xuyên trên cùng 1 file | Nhiều actor cùng sửa |
| Tên class chứa **"And"**: `FetchAndCacheProducts` | 2 responsibility trong tên |
| Test cần **mock 5+ dependencies** | Class biết quá nhiều |
| Khi hỏi **"class này làm gì?"** phải dùng từ **"và"** | "Nó fetch data **và** format **và** track analytics" |

---

## 9. SRP vs Over-engineering — Ranh giới thực dụng

```dart
// ❌ Quá mức — tách mỗi method thành 1 class
class ProductNameCapitalizer {
  String capitalize(String name) => name.toUpperCase();
}

class ProductPriceRounder {
  double round(double price) => (price * 100).round() / 100;
}

// ✅ Thực dụng — gom utility cùng domain vào 1 chỗ
extension ProductFormatting on Product {
  String get displayName => name.toUpperCase();
  String get displayPrice => '${(price * 100).round() / 100} ₫';
}
```

**Quy tắc thực dụng:**

- SRP ở **class level**: tách khi class phục vụ **2+ actor khác nhau**.
- SRP ở **method level**: tách khi method dài >30 dòng hoặc có nhiều level of abstraction.
- **Đừng tách** nếu: logic chỉ dùng ở 1 chỗ, đơn giản, ít thay đổi, và không phục vụ actor khác nhau.
- **Nên tách** nếu: bạn thấy mình sửa 1 file vì 2 lý do hoàn toàn khác nhau, hoặc merge conflict lặp đi lặp lại.

---

## 10. Mối quan hệ SRP với các nguyên tắc SOLID khác

| Kết hợp | Cách hoạt động |
|---|---|
| **SRP + OCP** | Class đơn responsibility → dễ extend mà không sửa, vì mỗi extension point rõ ràng |
| **SRP + LSP** | Class nhỏ, tập trung → subclass dễ tuân thủ contract vì contract đơn giản |
| **SRP + ISP** | SRP nhìn từ phía implementation (class), ISP nhìn từ phía consumer (interface) — bổ trợ nhau |
| **SRP + DIP** | Class đơn responsibility → dễ abstract hóa thành interface → dễ inject dependency |

---

## 11. Tóm tắt

SRP trong Flutter/Dart xoay quanh câu hỏi: **"Ai/cái gì gây ra thay đổi cho class này?"**

- **Xác định actor**: Backend, Designer, Product Owner, Data Team, Security… Mỗi class chỉ phục vụ **một** actor.
- **Tách layer rõ ràng**: Data (DTO, API, Mapper, Repository) → Domain (Model, Filter, Sorter) → Presentation (Cubit/Bloc, Widget).
- **Widget chỉ hiển thị**: không chứa business logic, formatting, networking, hay analytics.
- **Cubit/Bloc chỉ orchestrate**: delegate logic cho các class chuyên biệt, không tự implement.
- **Test là thước đo**: nếu test cần mock 5+ dependencies → class đang ôm quá nhiều responsibility.

Kiểm tra đơn giản nhất: **mô tả class bằng một câu không có từ "và"**. Nếu phải nói "class này fetch data **và** format **và** track analytics" → tách ra.
