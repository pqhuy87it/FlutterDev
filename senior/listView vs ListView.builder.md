# ListView vs ListView.builder — Cơ chế Lazy Loading chi tiết

## 1. Kiến trúc nền tảng: Sliver Protocol

Trước khi so sánh, cần hiểu rằng cả `ListView` và `ListView.builder` đều là **convenience wrapper** bên trên hệ thống **Sliver** của Flutter. Bên trong, chúng tạo ra một `CustomScrollView` chứa một `SliverList`. Điểm khác biệt nằm ở **delegate** mà chúng truyền cho `SliverList`.

```
ListView(children: [...])
  → CustomScrollView
    → SliverList(delegate: SliverChildListDelegate([...]))

ListView.builder(itemBuilder: ...)
  → CustomScrollView
    → SliverList(delegate: SliverChildBuilderDelegate(...))
```

Chính sự khác nhau giữa `SliverChildListDelegate` và `SliverChildBuilderDelegate` tạo ra toàn bộ khác biệt về hiệu năng.

---

## 2. ListView (SliverChildListDelegate) — Eager Rendering

### Cơ chế hoạt động

Khi bạn viết:

```dart
ListView(
  children: [
    ItemWidget(items[0]),
    ItemWidget(items[1]),
    // ... 10,000 items
    ItemWidget(items[9999]),
  ],
)
```

Điều xảy ra **ngay tại thời điểm build**:

**Bước 1 — Widget Creation**: Dart evaluate toàn bộ list literal `[...]`. Tất cả 10,000 `ItemWidget` được **instantiate ngay lập tức** trên bộ nhớ, bất kể user có nhìn thấy hay không. Đây là chi phí đầu tiên — allocation 10,000 widget object.

**Bước 2 — SliverChildListDelegate nhận pre-built list**: Delegate này nhận trực tiếp một `List<Widget>` đã hoàn chỉnh. Nó không có cơ chế "tạo khi cần" — toàn bộ list đã tồn tại.

**Bước 3 — Layout phase (Sliver Protocol)**: `SliverList` thực hiện layout từ đầu viewport. Nó hỏi delegate từng child theo index, tính toán kích thước (thông qua `performLayout`), đặt vị trí, và tiếp tục cho đến khi lấp đầy viewport + cache extent. Dù Sliver Protocol chỉ **layout và paint** các child trong viewport, tất cả widget và element đã tồn tại trước đó rồi.

**Bước 4 — Element Tree**: Flutter tạo **Element** cho mỗi widget. Với `SliverChildListDelegate`, mặc dù sliver protocol có thể trì hoãn việc mount element ở một mức độ nhất định, bản chất là toàn bộ children đã sẵn sàng và framework phải xử lý chúng.

### Hệ quả bộ nhớ

```
10,000 items → 10,000 Widget objects     (heap)
             → 10,000 Element objects    (heap)
             → 10,000 RenderObject       (heap + layout computation)
             → Tất cả State objects nếu là StatefulWidget
```

Dù user chỉ nhìn thấy khoảng 10-15 item trên màn hình, bộ nhớ vẫn phải chứa toàn bộ 10,000 item.

---

## 3. ListView.builder (SliverChildBuilderDelegate) — True Lazy Loading

### Cơ chế hoạt động

```dart
ListView.builder(
  itemCount: 10000,
  itemBuilder: (BuildContext context, int index) {
    return ItemWidget(items[index]);
  },
)
```

**Bước 1 — Không có Widget Creation upfront**: Khác biệt cốt lõi là ở đây **không có list nào được tạo**. Chỉ có một **callback function** (`itemBuilder`) được truyền cho `SliverChildBuilderDelegate`. Tại thời điểm build, chi phí gần như bằng 0 — chỉ là lưu trữ một function reference.

**Bước 2 — Layout phase kích hoạt builder**: Khi `SliverList` thực hiện layout, nó hỏi delegate: "Cho tôi child tại index 0". Lúc này delegate mới gọi `itemBuilder(context, 0)`, widget được tạo, element được mount, render object được layout. Tiếp tục với index 1, 2, 3... cho đến khi lấp đầy viewport + cache extent.

**Bước 3 — Cache Extent**: Flutter duy trì một vùng buffer trên và dưới viewport gọi là `cacheExtent` (mặc định 250 pixel logical). Các item trong vùng này được build sẵn nhưng chưa paint, để khi user scroll sẽ không thấy blank:

```
 ┌─────────────────────┐
 │   Cache Extent       │  ← 250px: built nhưng chưa paint
 │   (%.above viewport) │
 ├─────────────────────┤
 │                     │
 │   VIEWPORT          │  ← Phần user nhìn thấy
 │   (visible items)   │     Built + Painted
 │                     │
 ├─────────────────────┤
 │   Cache Extent       │  ← 250px: built nhưng chưa paint
 │   (below viewport)  │
 └─────────────────────┘

 Tất cả items ngoài vùng này → KHÔNG TỒN TẠI trong memory
```

**Bước 4 — Scroll triggers build/dispose cycle**: Khi user scroll xuống:

```
Scroll xuống →
  Item mới lộ ra ở dưới → itemBuilder(context, newIndex) được gọi
                        → Widget + Element + RenderObject được tạo

  Item cũ ra khỏi cache extent phía trên → Element bị deactivate
                                         → RenderObject bị detach
                                         → Widget eligible cho GC
```

Đây là vòng đời liên tục: **tạo mới ở đầu scroll → hủy ở đuôi scroll**. Tại bất kỳ thời điểm nào, số lượng widget sống trong bộ nhớ chỉ bằng **viewport items + cache extent items**.

### Hệ quả bộ nhớ

```
10,000 items nhưng viewport hiển thị 15 items, cache extent thêm ~10 items:

→ ~25 Widget objects
→ ~25 Element objects
→ ~25 RenderObject
→ 9,975 items KHÔNG chiếm bộ nhớ gì
```

---

## 4. So sánh trực tiếp qua một ví dụ cụ thể

Giả sử: 5,000 items, mỗi item là một `Card` chứa `Image` + `Text`. Viewport chứa 12 items, cache extent chứa thêm 8 items (4 trên + 4 dưới).

| Tiêu chí | `ListView` | `ListView.builder` |
|---|---|---|
| **Widgets tạo lúc build** | 5,000 | 0 (chỉ lưu callback) |
| **Widgets tồn tại runtime** | 5,000 | ~20 (12 visible + 8 cached) |
| **Thời gian first frame** | Chậm — phải instantiate 5,000 widget | Nhanh — chỉ build ~20 widget |
| **RAM usage** | Cao, tỷ lệ thuận với item count | Gần như cố định, không phụ thuộc item count |
| **Scroll performance** | Mượt (đã build sẵn hết) | Mượt (build on-demand rất nhanh) |
| **GC pressure** | Thấp (không tạo/hủy liên tục) | Cao hơn (liên tục tạo/hủy widget khi scroll) |

Điểm đáng chú ý: `ListView` có scroll performance lý thuyết tốt vì mọi thứ đã sẵn sàng, nhưng trên thực tế lượng memory lớn gây GC pause dài hơn, nên tổng thể `ListView.builder` vẫn mượt hơn với danh sách lớn.

---

## 5. Cơ chế tái sử dụng Element — Keep Alive & Key

### Element Recycling

Flutter **không** tái sử dụng element theo kiểu RecyclerView (Android) hay cell reuse (iOS). Khi item scroll ra khỏi cache extent, element bị **deactivate và dispose hoàn toàn**. Khi scroll ngược lại, `itemBuilder` được gọi lại, tạo widget mới, element mới.

Đây là điểm khác biệt quan trọng so với native platform. Flutter chọn cách tiếp cận này vì widget creation trong Dart rất rẻ (lightweight object allocation), và immutable widget tree đơn giản hóa logic framework đáng kể.

### AutomaticKeepAliveClientMixin

Khi cần giữ state của item dù đã scroll ra khỏi viewport (ví dụ: form input, video playback position):

```dart
class _ItemState extends State<ItemWidget>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true; // Giữ element sống

  @override
  Widget build(BuildContext context) {
    super.build(context); // Bắt buộc gọi
    return TextField(); // State không bị mất khi scroll
  }
}
```

Khi `wantKeepAlive = true`, `SliverList` giữ element trong một **keep-alive bucket** thay vì dispose. Element không còn participate trong layout/paint (tiết kiệm GPU) nhưng vẫn chiếm bộ nhớ. Dùng quá nhiều keep-alive trên danh sách lớn thì bản chất quay lại giống `ListView` — mất lợi thế lazy loading.

### addAutomaticKeepAlives & addRepaintBoundaries

`ListView.builder` mặc định bật hai tham số:

```dart
ListView.builder(
  addAutomaticKeepAlives: true,   // Wrap mỗi child trong AutomaticKeepAlive
  addRepaintBoundaries: true,     // Wrap mỗi child trong RepaintBoundary
)
```

`addAutomaticKeepAlives: true` cho phép child opt-in keep alive thông qua mixin. `addRepaintBoundaries: true` isolate mỗi item trong repaint boundary riêng, nên khi một item thay đổi (ví dụ animation), chỉ item đó repaint, không ảnh hưởng hàng xóm. Trong trường hợp danh sách toàn item tĩnh đơn giản, tắt cả hai có thể giảm nhẹ overhead:

```dart
ListView.builder(
  addAutomaticKeepAlives: false,
  addRepaintBoundaries: false,
  // Nhẹ hơn một chút cho list đơn giản
)
```

---

## 6. cacheExtent — Điều chỉnh vùng buffer

```dart
ListView.builder(
  cacheExtent: 500, // Mặc định 250 (pixel)
  itemBuilder: ...
)
```

Tăng `cacheExtent` nghĩa là pre-build nhiều item hơn ngoài viewport, giúp scroll mượt hơn nhưng tốn thêm memory. Giảm `cacheExtent` tiết kiệm memory nhưng user có thể thấy blank space khi scroll nhanh.

Quyết định tăng hay giảm phụ thuộc vào độ phức tạp của item. Nếu mỗi item build nhanh (chỉ text), `cacheExtent` nhỏ là đủ. Nếu mỗi item nặng (image decode, layout phức tạp), tăng `cacheExtent` để pre-build trước khi user nhìn thấy.

---

## 7. Khi nào dùng cái nào

**Dùng `ListView(children: [...])`** khi số lượng children nhỏ và cố định (dưới 20-30), mỗi child có type khác nhau (không phải danh sách đồng nhất), và bạn cần layout đơn giản kiểu Column nhưng scrollable. Bản chất nó giống `SingleChildScrollView` + `Column` nhưng tiện hơn.

**Dùng `ListView.builder`** cho mọi trường hợp danh sách có kích thước lớn hoặc không xác định trước, dữ liệu từ API với pagination, và bất cứ khi nào item count có thể tăng theo thời gian.

**Dùng `ListView.separated`** khi cần separator giữa các item — nó cũng dùng `SliverChildBuilderDelegate` nên có cùng lợi ích lazy loading, nhưng thêm `separatorBuilder` cho divider/spacing.

**Dùng `ListView.custom`** khi cần tùy biến delegate (ví dụ implement `findChildIndexCallback` cho hiệu năng reorder, hoặc custom child lifecycle management).

---

## Tóm lại

Khác biệt cốt lõi không nằm ở "cái nào scroll tốt hơn" mà ở **thời điểm widget được tạo**: `ListView` tạo tất cả ngay lập tức (eager), `ListView.builder` tạo theo nhu cầu (lazy). Với danh sách lớn, sự khác biệt này quyết định app chạy mượt hay crash vì OOM. Senior cần hiểu rõ cơ chế sliver delegate bên dưới để đưa ra quyết định đúng đắn, không chỉ dùng theo thói quen.
