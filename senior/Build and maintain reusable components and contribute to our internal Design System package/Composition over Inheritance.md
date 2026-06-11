# Composition over Inheritance trong Flutter

## 1. Bắt đầu bằng vấn đề thực tế

Giả sử team cần xây dựng một hệ thống **Card** cho Design System. Có nhiều loại card: card có image, card có action buttons, card có badge, card có header, v.v.

### ❌ Inheritance Approach — Tạo subclass cho mỗi biến thể

```dart
// Base
class AppCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const AppCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
```

Designer yêu cầu thêm biến thể → bạn tạo subclass:

```dart
// Card có hình ảnh phía trên
class ImageCard extends AppCard {
  final String imageUrl;

  const ImageCard({
    super.key,
    required super.title,
    required super.subtitle,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          // ⚠️ Phải copy lại decoration logic từ parent
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(imageUrl, height: 160, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⚠️ Phải copy lại text layout từ parent
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Card có action buttons
class ActionCard extends AppCard {
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  const ActionCard({
    super.key,
    required super.title,
    required super.subtitle,
    required this.onPrimary,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    // ⚠️ Lại copy toàn bộ build() của parent, chỉ thêm buttons
    return Container(/* ... copy paste ... */);
  }
}

// Card có image VÀ action buttons???
class ImageActionCard extends ??? {
  // ⚠️ PROBLEM: Dart chỉ cho single inheritance
  // Kế thừa ImageCard hay ActionCard?
  // → Phải copy code từ cái còn lại
}

// Card có badge?
class BadgeImageActionCard extends ??? {
  // 💀 Class explosion — không thể scale
}
```

**Vấn đề cốt lõi của inheritance:**

```
AppCard
├── ImageCard
├── ActionCard
├── BadgeCard
├── ImageActionCard          ← duplicate logic từ Image + Action
├── BadgeImageCard           ← duplicate logic từ Badge + Image
├── BadgeActionCard          ← duplicate logic từ Badge + Action
├── BadgeImageActionCard     ← 💀
└── ... combinatorial explosion
```

Với **N features**, inheritance tạo ra tối đa **2^N subclass**. 5 features = 32 class. Không thể maintain.

---

## 2. ✅ Composition Approach — Dùng `child` / slot pattern

Thay vì tạo subclass cho mỗi biến thể, bạn thiết kế AppCard như một **container có các slot** mà caller tự quyết định đặt gì vào:

```dart
class AppCard extends StatelessWidget {
  // ---- SLOT: Header area (image, gradient, custom widget, hoặc null) ----
  final Widget? header;

  // ---- SLOT: Body content (bắt buộc) ----
  final Widget child;

  // ---- SLOT: Footer area (buttons, links, hoặc null) ----
  final Widget? footer;

  // ---- SLOT: Overlay (badge, tag, hoặc null) ----
  final Widget? overlay;

  // ---- Configuration ----
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.overlay,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header slot
        if (header != null) header!,

        // Body slot
        Padding(
          padding: padding,
          child: child,
        ),

        // Footer slot
        if (footer != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              padding.left, 0, padding.right, padding.bottom,
            ),
            child: footer!,
          ),
      ],
    );

    final card = Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      clipBehavior: Clip.antiAlias, // để header image được clip theo border radius
      child: onTap != null
          ? InkWell(onTap: onTap, child: cardContent)
          : cardContent,
    );

    // Overlay slot — positioned trên card
    if (overlay != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          Positioned(top: 8, right: 8, child: overlay!),
        ],
      );
    }

    return card;
  }
}
```

### Sử dụng — Tự do tổ hợp mọi biến thể

```dart
// 1. Card đơn giản — chỉ text
AppCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Tiêu đề', style: Theme.of(context).textTheme.titleMedium),
      SizedBox(height: 4),
      Text('Mô tả ngắn', style: Theme.of(context).textTheme.bodyMedium),
    ],
  ),
)

// 2. Card có image header
AppCard(
  header: Image.network(
    'https://example.com/photo.jpg',
    height: 160,
    width: double.infinity,
    fit: BoxFit.cover,
  ),
  child: Text('Beach Resort'),
)

// 3. Card có image + action buttons + badge — KHÔNG CẦN CLASS MỚI
AppCard(
  onTap: () => navigateToDetail(),
  header: Image.network(url, height: 180, fit: BoxFit.cover),
  overlay: Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text('HOT', style: TextStyle(color: Colors.white, fontSize: 12)),
  ),
  footer: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton(onPressed: () {}, child: Text('Bỏ qua')),
      SizedBox(width: 8),
      ElevatedButton(onPressed: () {}, child: Text('Mua ngay')),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('iPhone 16 Pro Max'),
      Text('32.990.000đ', style: TextStyle(fontWeight: FontWeight.bold)),
    ],
  ),
)

// 4. Card với hoàn toàn custom header (video, map, chart, ...)
AppCard(
  header: SizedBox(
    height: 200,
    child: GoogleMap(...), // bất kỳ widget nào cũng được
  ),
  child: Text('Vị trí cửa hàng'),
)
```

So sánh trực quan:

```
INHERITANCE:                    COMPOSITION:
──────────────                  ─────────────
Mỗi combo = 1 class mới        1 class duy nhất, N slot
                               
AppCard                         AppCard
├── ImageCard                     ├── header: Widget?   ← bất kỳ widget
├── ActionCard                    ├── child: Widget     ← bất kỳ widget
├── BadgeCard                     ├── footer: Widget?   ← bất kỳ widget
├── ImageActionCard               └── overlay: Widget?  ← bất kỳ widget
├── BadgeImageCard               
├── BadgeActionCard              Tổ hợp = vô hạn, class = 1
├── BadgeImageActionCard         
└── ... 2^N class               
```

---

## 3. Builder Pattern — Khi `child` chưa đủ

Đôi khi component cần **truyền data ngược lại** cho caller để caller quyết định render gì. Lúc này dùng **builder** (một callback trả về Widget):

### Ví dụ: Expandable Card

```dart
// Typedef cho rõ ràng
typedef AppCardHeaderBuilder = Widget Function(
  BuildContext context,
  bool isExpanded,        // ← data mà component cung cấp cho caller
  VoidCallback toggle,    // ← action mà component cung cấp
);

class ExpandableCard extends StatefulWidget {
  final AppCardHeaderBuilder headerBuilder;
  final Widget child;
  final bool initiallyExpanded;

  const ExpandableCard({
    super.key,
    required this.headerBuilder,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late final AnimationController _controller;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header — caller quyết định render gì,
          // nhưng COMPONENT cung cấp isExpanded + toggle
          widget.headerBuilder(context, _isExpanded, _toggle),

          // Animated body
          ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Align(
                heightFactor: _heightFactor.value,
                alignment: Alignment.topCenter,
                child: child,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Sử dụng:

```dart
ExpandableCard(
  // Builder nhận isExpanded và toggle từ component
  // Caller TỰ QUYẾT ĐỊNH UI trông như nào
  headerBuilder: (context, isExpanded, toggle) {
    return ListTile(
      title: Text('Chi tiết đơn hàng'),
      subtitle: isExpanded ? Text('Bấm để thu gọn') : null,
      trailing: AnimatedRotation(
        turns: isExpanded ? 0.5 : 0,
        duration: Duration(milliseconds: 250),
        child: Icon(Icons.expand_more),
      ),
      onTap: toggle,
    );
  },
  child: Column(
    children: [
      Text('Mã đơn: #12345'),
      Text('Tổng tiền: 500.000đ'),
    ],
  ),
)
```

---

## 4. Khi nào dùng `child` vs `builder`?

```
┌────────────────────────────────────────────────────────────┐
│              Caller cần data từ component không?           │
│                                                            │
│   KHÔNG                              CÓ                    │
│   → dùng child: Widget              → dùng builder         │
│                                                            │
│   Ví dụ:                            Ví dụ:                 │
│   AppCard(                           ListView.builder(     │
│     header: Image(...),  ← caller      itemBuilder:        │
│     child: Text(...),      tự biết       (ctx, index) {    │
│   )                        cần gì         ← component      │
│                                           truyền index     │
│                                           cho caller       │
│                                         },                 │
│                                       )                    │
│                                                            │
│   AppButton(                         ExpandableCard(       │
│     prefixIcon: Icon(...),             headerBuilder:      │
│     child: Text('OK'),                   (ctx, isExpanded, │
│   )                                       toggle) { ... }  │
│                                       )                    │
└────────────────────────────────────────────────────────────┘
```

| Pattern | Dùng khi | Ví dụ trong Flutter SDK |
|---|---|---|
| `child: Widget` | Caller biết đủ thông tin để tạo widget | `Container`, `Card`, `Padding` |
| `builder: Widget Function(...)` | Component cần truyền state/data cho caller | `ListView.builder`, `AnimatedBuilder`, `ValueListenableBuilder` |
| `children: List<Widget>` | Nhiều child cùng loại, thứ tự quan trọng | `Column`, `Row`, `Stack` |

---

## 5. Tổng kết tư duy Senior

Khi thiết kế một component cho Design System, câu hỏi đầu tiên không phải *"component này cần những biến thể nào?"* mà là:

> **"Component này chịu trách nhiệm về cái gì, và cái gì nên để caller quyết định?"**

Ví dụ với `AppCard`: Card chịu trách nhiệm **layout, shadow, border radius, tap effect**. Còn **nội dung bên trong** (image, text, buttons, badge) là việc của caller. Vậy → dùng slot composition.

Đây chính là nguyên tắc **Open-Closed Principle** — component mở cho mở rộng (caller truyền bất kỳ widget nào) nhưng đóng cho sửa đổi (không cần sửa source code của AppCard khi có biến thể mới).
