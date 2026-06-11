Chào bạn, **Lazy Loading** (Tải lười/Tải chậm) là kỹ thuật tối ưu hóa hiệu năng quan trọng nhất khi làm việc với danh sách dữ liệu lớn.

Thay vì tải 1.000 dòng dữ liệu và vẽ 1.000 cái widget cùng một lúc (khiến app bị đơ, tốn RAM), Lazy Loading chỉ tải và vẽ **những gì đang hiển thị trên màn hình**. Khi người dùng cuộn xuống, dữ liệu mới tiếp tục được tải thêm.

Trong Flutter, chúng ta áp dụng Lazy Loading ở 3 cấp độ:

1. **Lazy Building (UI):** Chỉ vẽ widget khi cần thiết.
2. **Lazy Fetching (Data):** Cuộn đến đâu gọi API đến đó (Infinite Scroll).
3. **Lazy Image:** Chỉ tải ảnh khi ảnh lọt vào khung hình.

Dưới đây là hướng dẫn chi tiết từng loại.

---

### 1. Lazy Building (Tối ưu UI) - Cơ bản nhất

Đây là cấp độ đầu tiên mà mọi lập trình viên Flutter phải biết.

* **Cách sai (Eager Loading):** Dùng `ListView(children: [...])` hoặc `Column`. Nó sẽ vẽ toàn bộ danh sách ngay lập tức, dù danh sách có 1000 item và user chưa nhìn thấy item thứ 10.
* **Cách đúng (Lazy Loading):** Dùng constructor `.builder`.

**Ví dụ:**

```dart
// Cách này sẽ chỉ vẽ (render) các item đang nằm trong màn hình điện thoại
ListView.builder(
  itemCount: 10000, // Danh sách cực lớn
  itemBuilder: (context, index) {
    print('Đang vẽ item thứ: $index'); // Bạn sẽ thấy log chỉ chạy khi cuộn tới
    return ListTile(
      title: Text('Item $index'),
    );
  },
)

```

*Cơ chế:* Khi item cuộn ra khỏi màn hình, Flutter sẽ hủy (dispose) nó và dùng bộ nhớ đó để vẽ item mới sắp xuất hiện.

---

### 2. Lazy Fetching (Tối ưu Dữ liệu - Infinite Scroll)

Đây là cái mọi người thường hỏi nhất: **"Làm sao để cuộn xuống đáy thì tải thêm trang 2, trang 3 từ API?"** (Pagination).

Quy trình thực hiện thủ công như sau:

1. Dùng `ScrollController` để lắng nghe hành động cuộn.
2. Kiểm tra nếu vị trí cuộn (`pixels`) chạm tới đáy (`maxScrollExtent`).
3. Gọi API lấy thêm dữ liệu và nạp vào List.

**Code mẫu triển khai thủ công:**

```dart
class InfiniteScrollPage extends StatefulWidget {
  @override
  _InfiniteScrollPageState createState() => _InfiniteScrollPageState();
}

class _InfiniteScrollPageState extends State<InfiniteScrollPage> {
  final ScrollController _scrollController = ScrollController();
  List<String> _items = List.generate(20, (index) => "Item $index"); // Dữ liệu ban đầu
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự kiện cuộn
    _scrollController.addListener(() {
      // Nếu vị trí hiện tại >= vị trí tối đa (đáy) VÀ không đang load
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent && !_isLoading) {
        _loadMoreData();
      }
    });
  }

  Future<void> _loadMoreData() async {
    setState(() {
      _isLoading = true; // Hiện loading
    });

    // Giả lập gọi API mất 2 giây
    await Future.delayed(Duration(seconds: 2));
    final newItems = List.generate(10, (index) => "New Item ${_items.length + index}");

    setState(() {
      _items.addAll(newItems); // Nối dữ liệu mới vào list cũ
      _isLoading = false; // Tắt loading
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Nhớ hủy controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lazy Loading Data")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Gắn controller vào đây
              itemCount: _items.length + 1, // +1 để dành chỗ cho cái vòng loading ở đáy
              itemBuilder: (context, index) {
                // Nếu là item cuối cùng -> Vẽ vòng quay Loading
                if (index == _items.length) {
                  return _isLoading 
                      ? Center(child: CircularProgressIndicator()) 
                      : SizedBox.shrink();
                }
                return ListTile(title: Text(_items[index]));
              },
            ),
          ),
        ],
      ),
    );
  }
}

```

---

### 3. Lazy Image (Tối ưu hình ảnh)

Tải 100 tấm ảnh từ mạng cùng lúc sẽ làm app bị giật lag và tốn băng thông 4G của user. Bạn chỉ nên tải ảnh khi user cuộn tới đó.

* **Giải pháp:** Sử dụng thư viện **`cached_network_image`** (thư viện quốc dân).

```yaml
dependencies:
  cached_network_image: ^3.3.0

```

**Cách dùng:**

```dart
CachedNetworkImage(
  imageUrl: "https://example.com/image.jpg",
  // Widget hiển thị trong lúc chờ tải (Lazy placeholder)
  placeholder: (context, url) => CircularProgressIndicator(),
  // Widget hiển thị nếu lỗi
  errorWidget: (context, url, error) => Icon(Icons.error),
)

```

*Lợi ích:* Nó tự động xử lý việc chỉ tải khi hiển thị, và quan trọng là nó **lưu Cache** vào máy. Lần sau mở lại app không cần tải lại nữa.

---

### 4. Mẹo nâng cao: Sử dụng thư viện chuyên dụng

Việc tự code `ScrollController` như mục số 2 khá vất vả (phải xử lý lỗi, xử lý refresh, xử lý trang trống...).

Trong dự án thực tế, mình khuyên bạn nên dùng thư viện **`infinite_scroll_pagination`**. Nó bao gói toàn bộ logic phức tạp giúp code sạch hơn nhiều.

**Ví dụ logic với thư viện:**

```dart
// Bạn chỉ cần định nghĩa logic: "Trang này cần lấy gì?"
_pagingController.addPageRequestListener((pageKey) {
  _fetchPage(pageKey);
});

// Thư viện tự lo việc hiển thị loading, error, "No more items", v.v...
PagedListView<int, Post>(
  pagingController: _pagingController,
  builderDelegate: PagedChildBuilderDelegate<Post>(
    itemBuilder: (context, item, index) => PostWidget(item),
  ),
);

```

### Tóm tắt

1. **Luôn dùng `ListView.builder**` thay vì `ListView` cho danh sách động.
2. **Dùng `ScrollController**` để phát hiện đáy trang và gọi API tải thêm (Pagination).
3. **Dùng `cached_network_image**` để tải ảnh thông minh.

Bạn muốn mình hướng dẫn kỹ hơn về phần nào (ví dụ: cách kết hợp Riverpod với Infinite Scroll)?
