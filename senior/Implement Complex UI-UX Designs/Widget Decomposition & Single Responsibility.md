# Widget Decomposition & Single Responsibility trong Flutter

Đây là kỹ năng phân biệt rõ nhất giữa mid-level và senior Flutter developer. Không phải "biết tách" mà là **biết tách đúng chỗ, đúng mức, và vì đúng lý do**.

---

## 1. Tại sao God-widget là vấn đề nghiêm trọng

Hãy hình dung một `ProductDetailScreen` 1500 dòng chứa tất cả: app bar logic, image carousel, price calculation, review list, add-to-cart button, bottom sheet, animation controller, API call... Đây là God-widget.

**Vấn đề thực tế nó gây ra:**

**a. Rebuild performance**

Flutter rebuild widget theo cơ chế: khi `setState()` được gọi, **toàn bộ subtree** của widget đó rebuild. Nếu God-widget gọi `setState` chỉ để update số lượng trong giỏ hàng, toàn bộ image carousel, review list, price section... đều rebuild lại — dù chúng không thay đổi gì.

```dart
// ❌ God-widget: setState rebuild MỌI THỨ
class ProductDetailScreen extends StatefulWidget {
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool isFavorite = false;
  List<Review> reviews = [];
  int currentImageIndex = 0;
  bool isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 200 dòng build app bar + image carousel
          SliverAppBar(
            flexibleSpace: _buildImageCarousel(), // rebuild khi quantity thay đổi!
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildPriceSection(),      // 80 dòng
                _buildDescription(),       // 60 dòng  
                _buildReviewList(),        // 150 dòng — rebuild khi quantity thay đổi!
                _buildRelatedProducts(),   // 100 dòng — rebuild khi quantity thay đổi!
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildAddToCartBar(), // chỉ cần update cái này
    );
  }

  // ... 20+ private methods, 1500 dòng tổng cộng
}
```

Khi user nhấn nút tăng quantity → `setState(() => quantity++)` → **toàn bộ** `build()` chạy lại → tất cả `_build*` methods đều execute lại. Flutter framework sẽ diff và chỉ update pixel thực sự thay đổi, nhưng việc **chạy lại toàn bộ build logic** vẫn tốn CPU, đặc biệt khi có computation trong build (format price, filter review, sort list...).

**b. Không thể test độc lập**

Muốn test riêng review section? Không được — nó là private method `_buildReviewList()` của God-widget. Phải setup toàn bộ `ProductDetailScreen` với mock product, mock API, mock navigation... chỉ để test một phần nhỏ.

**c. Conflict khi làm team**

Dev A sửa image carousel, dev B sửa review section — cả hai edit cùng một file 1500 dòng. Merge conflict liên tục, code review painful vì reviewer phải đọc hiểu toàn bộ file để review một thay đổi nhỏ.

**d. Không reusable**

Price section trong product detail giống 80% với price section trong cart item. Nhưng vì nó là private method, không thể reuse — phải copy-paste rồi sửa, tạo ra duplication.

---

## 2. Nguyên tắc tách — Không phải "cứ nhỏ là tốt"

Senior developer tách widget dựa trên **lý do rõ ràng**, không phải mechanical rule "mỗi method thành widget". Có 4 lý do chính đáng để tách:

**a. Khác biệt về rebuild boundary**

Đây là lý do quan trọng nhất và cũng là lý do kỹ thuật nhất. Khi tách thành widget riêng (class riêng, không phải method), Flutter tạo **Element riêng** cho nó. Nếu widget con nhận cùng input (same props) → Flutter skip rebuild hoàn toàn cho subtree đó.

```dart
// ✅ Widget riêng = rebuild boundary riêng
class QuantitySelector extends StatefulWidget {
  final int initial;
  final ValueChanged<int> onChanged;

  const QuantitySelector({
    required this.initial,
    required this.onChanged,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _quantity = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            setState(() => _quantity--);  // chỉ rebuild QuantitySelector
            widget.onChanged(_quantity);
          },
          icon: const Icon(Icons.remove),
        ),
        Text('$_quantity'),
        IconButton(
          onPressed: () {
            setState(() => _quantity++);  // chỉ rebuild QuantitySelector  
            widget.onChanged(_quantity);
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
```

Bây giờ khi user tăng/giảm quantity, **chỉ `QuantitySelector` rebuild** — image carousel, review list, price section hoàn toàn không bị ảnh hưởng.

**Điểm cực kỳ quan trọng**: Private method (`_buildQuantitySelector()`) **KHÔNG tạo rebuild boundary**. Nó chỉ là code organization — khi parent gọi `setState`, method vẫn chạy lại. Chỉ có **class widget riêng** mới tạo được boundary thực sự.

```dart
// ❌ Private method — KHÔNG phải rebuild boundary
Widget _buildQuantitySelector() {
  return Row(...); // vẫn rebuild khi parent setState
}

// ✅ Class riêng — IS rebuild boundary
class QuantitySelector extends StatelessWidget { ... }
```

**b. Reusability**

Khi cùng một UI pattern xuất hiện ở 2+ chỗ:

```dart
// Dùng ở product detail, cart item, wishlist item
class PriceDisplay extends StatelessWidget {
  final double originalPrice;
  final double? discountedPrice;
  final String currency;

  const PriceDisplay({
    required this.originalPrice,
    this.discountedPrice,
    this.currency = 'VND',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final hasDiscount = discountedPrice != null && discountedPrice! < originalPrice;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (hasDiscount) ...[
          Text(
            _formatPrice(originalPrice),
            style: theme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          _formatPrice(hasDiscount ? discountedPrice! : originalPrice),
          style: theme.titleMedium?.copyWith(
            color: hasDiscount 
                ? Theme.of(context).colorScheme.error 
                : null,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) => '${price.toStringAsFixed(0)} $currency';
}
```

**c. Khác biệt về lifecycle / state**

Khi một phần UI có state riêng, animation riêng, hoặc lifecycle riêng — nó **phải** là widget riêng:

```dart
// Image carousel có riêng: PageController, auto-scroll timer, current index
class ProductImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const ProductImageCarousel({required this.imageUrls});

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late final PageController _controller;
  late final Timer _autoScrollTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _autoScrollTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _nextPage(),
    );
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    final next = (_currentIndex + 1) % widget.imageUrls.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.imageUrls.length,
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: widget.imageUrls[i],
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: PageIndicator(
              count: widget.imageUrls.length,
              current: _currentIndex,
            ),
          ),
        ],
      ),
    );
  }
}
```

Nếu để logic này trong God-widget, `dispose` phải track nhiều controller, `initState` phình to, rất dễ leak resource.

**d. Domain / Business boundary**

Review section và Price section thuộc hai domain khác nhau. Dù chúng không reuse ở đâu khác, tách chúng vẫn có giá trị vì **mỗi cái thay đổi vì lý do khác nhau**: review section thay đổi khi requirement về UGC thay đổi, price section thay đổi khi business logic giá thay đổi.

---

## 3. Kết quả sau khi refactor

```dart
// ✅ Screen chỉ còn vai trò ORCHESTRATOR
class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductDetailCubit(productId: productId)..load(),
      child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) => switch (state) {
          ProductDetailLoading() => const _LoadingSkeleton(),
          ProductDetailError(:final message) => ErrorView(message: message),
          ProductDetailLoaded(:final product) => _ProductDetailBody(product: product),
        },
      ),
    );
  }
}

class _ProductDetailBody extends StatelessWidget {
  final Product product;
  const _ProductDetailBody({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.sizeOf(context).width,
            flexibleSpace: ProductImageCarousel(imageUrls: product.images),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductHeader(name: product.name, brand: product.brand),
                  const SizedBox(height: 8),
                  PriceDisplay(
                    originalPrice: product.originalPrice,
                    discountedPrice: product.discountedPrice,
                  ),
                  const SizedBox(height: 16),
                  ExpandableDescription(text: product.description),
                  const SizedBox(height: 16),
                  ReviewSection(productId: product.id),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AddToCartBar(product: product),
    );
  }
}
```

Quan sát kỹ: `_ProductDetailBody` giờ **đọc như mô tả UI bằng ngôn ngữ tự nhiên** — carousel ở trên, header, price, description, review, rồi add-to-cart bar. Ai đọc cũng hiểu layout ngay mà không cần scroll qua 1500 dòng.

---

## 4. Các anti-pattern cần tránh

**a. Over-extraction — tách quá nhỏ**

```dart
// ❌ Vô nghĩa — tách widget chỉ để wrap SizedBox
class SpacerSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox(height: 8);
}
```

Widget này không có logic, không có state, không reuse phức tạp. Dùng `const SizedBox(height: 8)` trực tiếp là đủ. Tách thêm chỉ tạo indirection vô ích.

**b. Tách method thay vì tách widget rồi tưởng đã optimize**

```dart
// ❌ Tưởng đã tách nhưng KHÔNG có rebuild boundary
class ProductScreen extends StatefulWidget { ... }

class _ProductScreenState extends State<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),   // vẫn rebuild khi setState
        _buildBody(),     // vẫn rebuild khi setState
        _buildFooter(),   // vẫn rebuild khi setState
      ],
    );
  }

  Widget _buildHeader() => ...;  // private method, NOT a widget
  Widget _buildBody() => ...;
  Widget _buildFooter() => ...;
}
```

Private method chỉ là **code organization** — hoàn toàn không có performance benefit. Nếu mục đích là rebuild boundary, phải tách thành class.

**c. Truyền quá nhiều params xuống — "prop drilling"**

```dart
// ❌ Prop drilling qua 4 tầng
ProductScreen → ProductBody → ReviewSection → ReviewItem → ReviewAuthor
// ReviewAuthor cần `currentUserId` từ ProductScreen
// → phải truyền qua 3 widget trung gian không cần nó
```

Giải pháp: dùng `InheritedWidget`, `Provider`, hoặc `Bloc` để inject dependency mà không cần truyền tay qua từng tầng. Senior developer biết khi nào prop drilling acceptable (1-2 tầng, ít params) và khi nào cần DI pattern (3+ tầng, nhiều params).

---

## 5. Quy tắc thực hành

Một số heuristic mà senior developer thường áp dụng:

Nếu `build()` method dài hơn ~80-100 dòng, đó là signal cần tách. Nếu một `State` class quản lý hơn 3-4 state variables không liên quan nhau, mỗi nhóm state nên thuộc về widget riêng. Nếu bạn đặt tên method `_buildXxx()` và nó dài hơn 30 dòng, nó gần như chắc chắn nên là widget class riêng. Và cuối cùng — nếu bạn cần scroll để hiểu `build()` method, widget đó quá lớn.

Quan trọng nhất: **mỗi lần tách, hãy tự hỏi "tách vì lý do gì?"** — rebuild boundary, reusability, lifecycle isolation, hay domain boundary. Nếu không trả lời được, có thể chưa cần tách.

Bạn muốn mình đi sâu thêm vào phần nào — ví dụ `const` constructor optimization, `RepaintBoundary` strategy, hay cách structure folder cho widget decomposition trong project lớn?
