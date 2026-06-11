# Sliver-Based Layout — Deep Dive cho Senior Flutter Developer

Sliver là **hệ thống layout chuyên biệt cho scrollable content** trong Flutter. Đây là nền tảng bên dưới mọi `ListView`, `GridView`, `NestedScrollView` — và là thứ senior developer phải master để xây dựng scroll experience phức tạp.

---

## 1. Sliver là gì — Từ gốc rễ

### Box protocol vs Sliver protocol

Flutter có 2 layout protocol hoàn toàn khác nhau:

**Box protocol** (RenderBox) — cái bạn dùng hàng ngày:

```
Parent truyền BoxConstraints(minW, maxW, minH, maxH) xuống
Child trả về Size(width, height)
→ Mọi thứ có kích thước cố định, biết trước
```

**Sliver protocol** (RenderSliver) — dành riêng cho scroll:

```
Parent (viewport) truyền SliverConstraints xuống:
  - scrollOffset: bao nhiêu pixel đã scroll qua sliver này
  - remainingPaintExtent: còn bao nhiêu pixel visible trên viewport
  - crossAxisExtent: chiều rộng viewport
  - overlap: phần bị sliver trước đè lên
  ... và nhiều hơn nữa

Child trả về SliverGeometry:
  - scrollExtent: tổng chiều dài nội dung (kể cả phần ngoài màn hình)
  - paintExtent: bao nhiêu pixel thực sự vẽ trên màn hình
  - layoutExtent: bao nhiêu pixel "chiếm chỗ" cho sliver tiếp theo
  - maxPaintExtent: paint extent tối đa (khi chưa scroll)
  - hasVisualOverflow: có bị crop không
```

Tại sao cần protocol riêng? Vì scrollable content có tính chất đặc biệt: **phần lớn content nằm ngoài màn hình**. Box protocol bắt mỗi child phải layout hoàn chỉnh dù không visible. Sliver protocol cho phép **lazy layout** — chỉ layout phần visible + một buffer nhỏ. ListView 10,000 items chỉ layout ~20 items trên màn hình + vài items buffer ở trên/dưới.

### Kiến trúc Viewport

```
CustomScrollView (widget)
    │
    ▼
Viewport (RenderObject) ← quản lý visible area
    │
    ├── Sliver A (SliverAppBar)      ← nhận SliverConstraints, trả SliverGeometry
    ├── Sliver B (SliverList)         ← nhận SliverConstraints, trả SliverGeometry
    ├── Sliver C (SliverGrid)         ← nhận SliverConstraints, trả SliverGeometry
    └── Sliver D (SliverToBoxAdapter) ← bridge: box widget sống trong sliver world
```

Viewport duyệt qua các sliver **theo thứ tự**, truyền `SliverConstraints` (bao gồm `scrollOffset` tương đối cho mỗi sliver). Mỗi sliver trả `SliverGeometry` cho viewport biết nó chiếm bao nhiêu space. Viewport dùng info này để quyết định:
- Sliver nào visible
- Vẽ sliver ở đâu trên màn hình
- Tổng scroll extent (để tính scrollbar)

---

## 2. CustomScrollView — Orchestrator

`CustomScrollView` là widget cho phép bạn compose nhiều sliver lại:

```dart
CustomScrollView(
  physics: const BouncingScrollPhysics(),
  slivers: [
    // Mỗi item trong list PHẢI là sliver widget
    const SliverAppBar(...),
    SliverList(...),
    SliverGrid(...),
    const SliverToBoxAdapter(child: Footer()),
    const SliverFillRemaining(child: EmptyState()),
  ],
)
```

Tại sao không dùng `ListView` hay `SingleChildScrollView`?

`ListView` thực ra là `CustomScrollView` + 1 `SliverList` bên trong. `SingleChildScrollView` dùng Box protocol — layout **toàn bộ** content rồi mới scroll, không lazy. Khi bạn cần **mix nhiều loại scrollable content** (app bar + list + grid + footer), `CustomScrollView` là cách duy nhất đúng.

### Các built-in sliver quan trọng

```dart
CustomScrollView(
  slivers: [
    // App bar thu nhỏ khi scroll
    SliverAppBar(expandedHeight: 200, floating: true, pinned: true, ...),

    // List lazy — chỉ build visible items
    SliverList.builder(
      itemCount: 1000,
      itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
    ),

    // Grid lazy
    SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: 100,
      itemBuilder: (ctx, i) => Card(child: Center(child: Text('$i'))),
    ),

    // Box widget đơn lẻ trong sliver context
    const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Section Header', style: TextStyle(fontSize: 24)),
      ),
    ),

    // Chiếm hết remaining space — dùng cho empty state, footer
    const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: Text('No more items')),
    ),

    // Padding cho sliver
    SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(...), // sliver con
    ),
  ],
)
```

---

## 3. SliverPersistentHeader — Sticky & Collapsing Header

Đây là building block cho collapsing toolbar, sticky section header, và nhiều scroll effect phức tạp.

### Cơ chế hoạt động

`SliverPersistentHeader` là sliver có chiều cao thay đổi dựa trên scroll position — co từ `maxExtent` xuống `minExtent` khi user scroll.

```
Chưa scroll:              Scroll một phần:           Scroll hết:
┌──────────────┐          ┌──────────────┐           ┌──────────────┐
│              │          │   Header     │           │  Header (min)│ ← pinned
│   Header     │ max      │              │ giữa      ├──────────────┤
│   (full)     │ extent   ├──────────────┤           │              │
│              │          │              │           │   Content    │
├──────────────┤          │   Content    │           │              │
│   Content    │          │              │           │              │
└──────────────┘          └──────────────┘           └──────────────┘
```

Hai mode:
- `pinned: true` — header co lại nhưng **luôn visible** ở top (giống app bar)
- `floating: true` — header ẩn khi scroll xuống, hiện lại khi scroll lên (giống Chrome address bar)

### SliverPersistentHeaderDelegate

Bạn phải implement delegate — đây là nơi bạn kiểm soát header render ra sao ở mọi trạng thái co/giãn:

```dart
class CollapsibleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final String title;
  final String? backgroundImageUrl;

  CollapsibleHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.title,
    this.backgroundImageUrl,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(covariant CollapsibleHeaderDelegate oldDelegate) {
    return expandedHeight != oldDelegate.expandedHeight
        || collapsedHeight != oldDelegate.collapsedHeight
        || title != oldDelegate.title
        || backgroundImageUrl != oldDelegate.backgroundImageUrl;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // shrinkOffset: bao nhiêu pixel đã co lại
    //   = 0 khi fully expanded
    //   = maxExtent - minExtent khi fully collapsed
    //
    // overlapsContent: header có đang đè lên content bên dưới không
    //   (xảy ra khi pinned và content scroll lên dưới header)

    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    // progress: 0.0 = fully expanded, 1.0 = fully collapsed

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image với parallax
        if (backgroundImageUrl != null)
          Positioned(
            top: -shrinkOffset * 0.4,  // parallax: ảnh scroll chậm hơn
            left: 0,
            right: 0,
            height: maxExtent,
            child: Opacity(
              opacity: 1.0 - progress,
              child: Image.network(backgroundImageUrl!, fit: BoxFit.cover),
            ),
          ),

        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7 * progress),
                ],
              ),
            ),
          ),
        ),

        // Title — di chuyển từ bottom-left (expanded) sang center (collapsed)
        Positioned(
          bottom: 16,
          left: Tween<double>(begin: 16, end: 56).transform(progress),
          right: 16,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: lerpDouble(28, 18, progress),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Back button — luôn hiển thị
        Positioned(
          top: MediaQuery.paddingOf(context).top + 4,
          left: 4,
          child: const BackButton(color: Colors.white),
        ),
      ],
    );
  }
}
```

Sử dụng:

```dart
CustomScrollView(
  slivers: [
    SliverPersistentHeader(
      pinned: true,
      delegate: CollapsibleHeaderDelegate(
        expandedHeight: 300,
        collapsedHeight: kToolbarHeight + MediaQuery.paddingOf(context).top,
        title: 'Restaurant Name',
        backgroundImageUrl: 'https://...',
      ),
    ),
    SliverList.builder(...),
  ],
)
```

### Phân biệt SliverAppBar vs SliverPersistentHeader

`SliverAppBar` thực ra dùng `SliverPersistentHeader` bên trong — nó là convenience wrapper với Material Design behavior built-in (leading, actions, flexibleSpace...). Khi SliverAppBar không đủ customization, bạn dùng `SliverPersistentHeader` trực tiếp với delegate tự viết.

---

## 4. SliverLayoutBuilder — Reactive Sliver

`SliverLayoutBuilder` cho phép bạn **đọc SliverConstraints** và quyết định build widget gì dựa trên scroll state hiện tại. Đây là `LayoutBuilder` của sliver world.

```dart
SliverLayoutBuilder(
  builder: (context, constraints) {
    // constraints là SliverConstraints
    // constraints.scrollOffset — bao nhiêu pixel đã scroll qua sliver này
    // constraints.remainingPaintExtent — còn bao nhiêu pixel visible
    // constraints.viewportMainAxisExtent — chiều cao viewport
    // constraints.overlap — phần bị sliver trước đè lên
    // constraints.crossAxisExtent — chiều rộng viewport

    final scrolled = constraints.scrollOffset;
    final viewportHeight = constraints.viewportMainAxisExtent;

    // Ví dụ: thay đổi layout dựa trên vị trí scroll
    if (scrolled > 200) {
      return SliverList.builder(
        itemBuilder: (ctx, i) => CompactListItem(data: items[i]),
        itemCount: items.length,
      );
    }

    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (ctx, i) => GridCard(data: items[i]),
      itemCount: items.length,
    );
  },
)
```

**Lưu ý quan trọng**: `SliverLayoutBuilder` rebuild mỗi khi constraints thay đổi (tức là mỗi khi scroll). Nếu builder tạo widget nặng, sẽ gây jank. Dùng cho logic đơn giản hoặc kết hợp với `const` widget.

### Use case thực tế: Adaptive sliver

```dart
SliverLayoutBuilder(
  builder: (context, constraints) {
    final crossAxis = constraints.crossAxisExtent;

    // Tablet/Desktop: grid 3 cột
    if (crossAxis > 900) {
      return SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => ProductCard(item: items[i]),
      );
    }

    // Tablet: grid 2 cột
    if (crossAxis > 600) {
      return SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => ProductCard(item: items[i]),
      );
    }

    // Mobile: list
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => ProductListTile(item: items[i]),
    );
  },
)
```

---

## 5. Scroll Effect phức tạp — Parallax

Parallax là effect mà background di chuyển chậm hơn foreground, tạo cảm giác chiều sâu.

### Cách 1 — Trong SliverPersistentHeaderDelegate

Đã demo ở section 3. Dòng quan trọng:

```dart
top: -shrinkOffset * 0.4,  // ảnh di chuyển bằng 40% tốc độ scroll
```

`shrinkOffset` tăng khi scroll lên → ảnh di chuyển lên nhưng chậm hơn content → parallax.

### Cách 2 — Parallax cho mỗi item trong SliverList

Bài toán phức tạp hơn: mỗi item trong list có background image parallax riêng. Cần biết vị trí của item relative to viewport.

```dart
class ParallaxListItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final GlobalKey _backgroundKey = GlobalKey();

  ParallaxListItem({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background với parallax via Flow
            Flow(
              delegate: _ParallaxFlowDelegate(
                scrollable: Scrollable.of(context),
                listItemContext: context,
                backgroundImageKey: _backgroundKey,
              ),
              children: [
                Image.network(
                  imageUrl,
                  key: _backgroundKey,
                  width: double.infinity,
                  height: 300, // lớn hơn container để có room cho parallax
                  fit: BoxFit.cover,
                ),
              ],
            ),
            // Foreground content
            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 8)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParallaxFlowDelegate extends FlowDelegate {
  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  _ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);
  //         ^^^^^^^^^^^^^^^^^^^^^^^^^
  //   repaint mỗi khi scroll position thay đổi
  //   KHÔNG rebuild widget — chỉ repaint (nhanh hơn nhiều)

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(width: constraints.maxWidth);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Tìm vị trí item trên viewport
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
      Offset.zero,
      ancestor: scrollableBox,
    );

    // Tính parallax offset
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction = (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);

    final backgroundSize = (backgroundImageKey.currentContext!.findRenderObject() as RenderBox).size;
    final listItemSize = listItemBox.size;
    final maxVerticalShift = backgroundSize.height - listItemSize.height;

    // Paint background với offset dựa trên vị trí scroll
    context.paintChild(
      0,
      transform: Matrix4.translationValues(
        0,
        -maxVerticalShift * scrollFraction,
        0,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable
        || listItemContext != oldDelegate.listItemContext
        || backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}
```

**Tại sao dùng `Flow` thay vì `Transform` thường?**

`Flow` chỉ **repaint** khi position thay đổi — không **relayout**. `Transform` widget cũng skip relayout nhưng phải rebuild widget tree. Flow + `FlowDelegate(repaint: scrollable.position)` bypass widget rebuild hoàn toàn — chỉ paint ở vị trí mới. Đây là approach tối ưu nhất cho scroll-driven animation.

---

## 6. Sticky Section Headers

Bài toán: list với section headers (A, B, C...) — header stick ở top khi scroll và bị đẩy đi khi header tiếp theo đến.

### Cách 1 — Nhiều SliverPersistentHeader pinned

```dart
CustomScrollView(
  slivers: [
    for (final section in sections) ...[
      SliverPersistentHeader(
        pinned: true,
        delegate: _SectionHeaderDelegate(title: section.title),
      ),
      SliverList.builder(
        itemCount: section.items.length,
        itemBuilder: (ctx, i) => ListTile(title: Text(section.items[i])),
      ),
    ],
  ],
)

class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  _SectionHeaderDelegate({required this.title});

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48; // không co giãn — fixed height

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 48,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SectionHeaderDelegate old) => title != old.title;
}
```

Đây là cách đơn giản nhất. Flutter tự xử lý "header này đẩy header kia" vì `Viewport` biết vị trí mỗi pinned sliver và offset chúng accordingly.

### Vấn đề: Overlap detection

Khi pinned header A đang stick ở top và header B scroll lên gần → B đẩy A lên trên. Nhưng `overlapsContent` parameter chỉ cho biết header **đang** overlap hay không, không cho biết **sắp** overlap. Nếu cần animation transition (ví dụ header A fade out khi B đến gần), bạn cần tính toán thêm:

```dart
@override
Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
  // shrinkOffset > 0 nghĩa là header đang bị push lên bởi content/header khác
  // Dùng giá trị này để animate opacity, elevation...
  final pushProgress = (shrinkOffset / maxExtent).clamp(0.0, 1.0);

  return AnimatedContainer(
    duration: Duration.zero, // instant — driven by scroll, not time
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      boxShadow: overlapsContent
          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
          : null,
    ),
    // ...
  );
}
```

---

## 7. Custom Sliver — Khi built-in không đủ

Giống như Custom RenderObject cho box layout, bạn có thể viết Custom Sliver khi cần layout algorithm hoàn toàn mới trong scroll context.

### Ví dụ: SliverPersistentHeader tự scale children

Bài toán: header có child widget mà khi collapse, child **scale down** thay vì bị crop.

```dart
class SliverScalingHeader extends SingleChildRenderObjectWidget {
  final double maxExtent;
  final double minExtent;

  const SliverScalingHeader({
    required this.maxExtent,
    required this.minExtent,
    required Widget child,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSliverScalingHeader(
      maxExtent: maxExtent,
      minExtent: minExtent,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSliverScalingHeader renderObject,
  ) {
    renderObject
      ..maxExtent = maxExtent
      ..minExtent = minExtent;
  }
}

class _RenderSliverScalingHeader extends RenderSliverSingleBoxAdapter {
  double _maxExtent;
  double _minExtent;

  _RenderSliverScalingHeader({
    required double maxExtent,
    required double minExtent,
  })  : _maxExtent = maxExtent,
       _minExtent = minExtent;

  double get maxExtent => _maxExtent;
  set maxExtent(double value) {
    if (_maxExtent == value) return;
    _maxExtent = value;
    markNeedsLayout();
  }

  double get minExtent => _minExtent;
  set minExtent(double value) {
    if (_minExtent == value) return;
    _minExtent = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final scrollOffset = constraints.scrollOffset;
    final paintExtent = (_maxExtent - scrollOffset).clamp(_minExtent, _maxExtent);
    final progress = ((paintExtent - _minExtent) / (_maxExtent - _minExtent))
        .clamp(0.0, 1.0);

    // Layout child ở max size — ta sẽ scale nó trong paint
    child?.layout(
      constraints.asBoxConstraints(
        maxExtent: _maxExtent,
      ),
      parentUsesSize: true,
    );

    // Báo viewport: tôi chiếm bao nhiêu space
    geometry = SliverGeometry(
      scrollExtent: _maxExtent,          // tổng chiều dài logical
      paintExtent: paintExtent,           // bao nhiêu pixel visible
      maxPaintExtent: _maxExtent,         // max visible (khi chưa scroll)
      layoutExtent: paintExtent,          // space dành cho sliver tiếp theo
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || geometry!.paintExtent == 0) return;

    final progress = ((geometry!.paintExtent - _minExtent) / (_maxExtent - _minExtent))
        .clamp(0.0, 1.0);

    // Scale child dựa trên progress
    final scale = lerpDouble(0.6, 1.0, progress)!;

    context.pushTransform(
      needsCompositing,
      offset,
      Matrix4.identity()
        ..translate(
          child!.size.width * (1 - scale) / 2,  // center horizontally
          child!.size.height * (1 - scale) / 2,  // center vertically
        )
        ..scale(scale, scale),
      (context, offset) {
        context.paintChild(child!, offset);
      },
    );
  }
}
```

### SliverGeometry — Hiểu đúng mỗi field

Đây là phần critical nhất khi viết custom sliver:

```dart
geometry = SliverGeometry(
  // Tổng chiều dài nội dung — dùng để tính scrollbar position
  // Giữ nguyên dù scroll bao nhiêu
  scrollExtent: 500.0,

  // Bao nhiêu pixel thực sự VISIBLE trên màn hình
  // Giảm dần khi scroll → 0 khi hoàn toàn ngoài viewport
  paintExtent: 300.0,

  // Bao nhiêu pixel "chiếm chỗ" — sliver tiếp theo bắt đầu sau layoutExtent
  // Thường = paintExtent, nhưng có thể < paintExtent
  // Ví dụ: pinned header có layoutExtent = 0 (không chiếm chỗ content)
  //         nhưng paintExtent > 0 (vẫn visible)
  layoutExtent: 300.0,

  // Paint extent tối đa có thể — khi chưa scroll
  maxPaintExtent: 500.0,

  // Có phần nào bị clip bởi viewport không
  hasVisualOverflow: true,
);
```

Mối quan hệ giữa `paintExtent` và `layoutExtent` là key insight:

```
Normal sliver:    paintExtent = layoutExtent = phần visible
Pinned header:    paintExtent > 0, layoutExtent = 0
                  → vẫn hiện nhưng không đẩy content xuống
Parallax bg:      paintExtent > layoutExtent
                  → phần paint tràn ra ngoài vùng layout
```

---

## 8. NestedScrollView — Nested Scroll Coordination

Khi bạn có scrollable bên trong scrollable (ví dụ TabBarView với mỗi tab là ListView, và header collapse khi scroll bất kỳ tab nào):

```dart
NestedScrollView(
  headerSliverBuilder: (context, innerBoxIsScrolled) {
    return [
      SliverAppBar(
        expandedHeight: 200,
        pinned: true,
        forceElevated: innerBoxIsScrolled, // elevation khi inner scroll
        flexibleSpace: const FlexibleSpaceBar(title: Text('Profile')),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Posts'), Tab(text: 'Likes')],
        ),
      ),
    ];
  },
  body: TabBarView(
    controller: _tabController,
    children: [
      _PostsList(),   // mỗi tab có scroll riêng
      _LikesList(),
    ],
  ),
)
```

`NestedScrollView` giải quyết coordination giữa **outer scroll** (header) và **inner scroll** (tab content). Khi user scroll xuống, outer scroll xử lý trước (collapse header). Khi header đã collapse hết, inner scroll tiếp quản. Khi scroll ngược lên, inner scroll về đầu trước, rồi outer scroll expand header.

### Gotcha quan trọng

`NestedScrollView` dùng `SliverOverlapAbsorber` + `SliverOverlapInjector` internally. Nếu bạn build custom layout tương tự, bạn cần hiểu mechanism này:

```dart
// Inner scrollable cần biết: "header đang overlap bao nhiêu?"
// để padding content không bị che bởi pinned header

NestedScrollView(
  headerSliverBuilder: (context, innerBoxIsScrolled) {
    return [
      SliverOverlapAbsorber(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        sliver: SliverAppBar(pinned: true, ...),
      ),
    ];
  },
  body: Builder(
    builder: (context) {
      return CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList.builder(...),
        ],
      );
    },
  ),
)
```

`SliverOverlapAbsorber` đo phần overlap (pinned header height). `SliverOverlapInjector` inject padding tương ứng vào inner scrollable. Nếu thiếu → content bị che bởi header.

---

## 9. Performance Considerations

### Lazy building

`SliverList.builder` và `SliverGrid.builder` chỉ build item khi nó sắp visible (trong `cacheExtent`). Default `cacheExtent` = 250 logical pixels ngoài viewport. Tăng `cacheExtent` để pre-build nhiều item hơn (smoother scroll nhưng tốn memory):

```dart
CustomScrollView(
  cacheExtent: 500, // pre-build items trong 500px ngoài viewport
  slivers: [...],
)
```

### Avoid SliverToBoxAdapter cho large content

```dart
// ❌ Layout TOÀN BỘ Column trước khi scroll
SliverToBoxAdapter(
  child: Column(
    children: List.generate(1000, (i) => ListTile(title: Text('$i'))),
  ),
)

// ✅ Lazy — chỉ build visible items
SliverList.builder(
  itemCount: 1000,
  itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
)
```

`SliverToBoxAdapter` dùng Box protocol — child phải layout hoàn chỉnh. Nó chỉ nên dùng cho single widget nhỏ (header text, button, divider), không phải cho list content.

### Keep-alive cho expensive items

Khi item scroll ra khỏi viewport, Flutter **destroy** nó (gọi dispose). Scroll ngược → build lại từ đầu. Nếu item expensive (heavy image, complex layout):

```dart
SliverList.builder(
  itemCount: items.length,
  itemBuilder: (ctx, i) {
    return KeepAlive(
      keepAlive: true,  // giữ lại trong memory khi scroll ra ngoài
      child: ExpensiveWidget(data: items[i]),
    );
  },
)

class KeepAlive extends StatefulWidget {
  final bool keepAlive;
  final Widget child;
  const KeepAlive({required this.keepAlive, required this.child});

  @override
  State<KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context); // bắt buộc gọi khi dùng AutomaticKeepAliveClientMixin
    return widget.child;
  }
}
```

Trade-off: giữ alive → tốn memory. Senior developer chỉ dùng cho item thực sự expensive và có số lượng giới hạn (ví dụ: 5 tab trong TabBarView), không dùng cho list 1000 items.

---

## 10. Debug Slivers

```dart
// Xem SliverConstraints và SliverGeometry trong console
import 'package:flutter/rendering.dart';

// Bật debug logging cho sliver layout
debugPrintBeginFrameBanner = true;
debugPrintEndFrameBanner = true;
```

Trong Flutter DevTools, Widget Inspector hiển thị sliver tree. Chọn một sliver → xem `SliverGeometry` (scrollExtent, paintExtent, layoutExtent...) realtime khi scroll. Đây là cách tốt nhất để debug custom sliver.

---

## Tổng kết mental model

Sliver system là abstraction layer cho scrollable content. Viewport là conductor, mỗi sliver là musician — viewport truyền SliverConstraints ("bạn đang ở đâu trong scroll"), sliver trả SliverGeometry ("tôi chiếm bao nhiêu space"). Kết hợp chúng trong `CustomScrollView` tạo ra scroll experience phức tạp mà `ListView` hay `SingleChildScrollView` không thể. Senior developer hiểu protocol này đủ sâu để biết khi nào dùng built-in sliver, khi nào custom delegate, và khi nào viết custom sliver từ đầu.

Bạn muốn mình đi sâu thêm vào phần nào — ví dụ custom SliverChildDelegate cho infinite scroll, scroll-to-index implementation, hay coordinate animation với scroll position?
