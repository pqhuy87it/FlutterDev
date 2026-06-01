Chào bạn, **FutureBuilder** là một Widget cực kỳ hữu ích và phổ biến trong Flutter, giúp bạn giải quyết bài toán kinh điển: **"Làm sao để vẽ giao diện khi dữ liệu chưa tải xong?"**

Hãy tưởng tượng `FutureBuilder` giống như một **"Người quản lý phòng chờ"**:

1. Bạn đưa cho nó một phiếu hẹn (Future).
2. Trong lúc chờ (đang tải), nó hiển thị icon quay vòng.
3. Khi có kết quả (xong), nó hiển thị dữ liệu.
4. Nếu có sự cố (lỗi), nó hiển thị thông báo lỗi.

Dưới đây là giải thích chi tiết về cách hoạt động và sử dụng.

---

### 1. Tại sao cần FutureBuilder?

Trong Flutter, hàm `build()` vẽ giao diện chạy theo cơ chế **Đồng bộ (Synchronous)** - nghĩa là nó phải vẽ xong ngay lập tức.
Tuy nhiên, việc lấy dữ liệu từ Internet (API) hoặc đọc file lại là **Bất đồng bộ (Asynchronous)** - mất vài giây mới xong.

Nếu bạn viết code kiểu này sẽ bị lỗi ngay:

```dart
// SAI: Build không thể chờ Future
Widget build(context) {
  var data = await getDataFromApi(); // Lỗi: await không dùng được trong hàm build
  return Text(data);
}

```

=> **FutureBuilder** sinh ra để làm cầu nối. Nó tự động lắng nghe cái `Future`, và mỗi khi trạng thái của `Future` thay đổi, nó sẽ tự vẽ lại (rebuild) giao diện tương ứng.

---

### 2. Cấu trúc của FutureBuilder

Nó có 2 tham số quan trọng nhất:

1. **`future`**: Cái tác vụ bất đồng bộ mà bạn muốn theo dõi (Ví dụ: `fetchUser()`).
2. **`builder`**: Một hàm quy định giao diện sẽ hiển thị như thế nào tại từng thời điểm. Hàm này cung cấp biến **`snapshot`**.

**Snapshot là gì?**
`snapshot` (AsyncSnapshot) là một "bản chụp" trạng thái hiện tại của Future. Nó chứa thông tin:

* `snapshot.connectionState`: Trạng thái kết nối (Đang chờ, đã xong...).
* `snapshot.data`: Dữ liệu trả về (nếu thành công).
* `snapshot.error`: Lỗi trả về (nếu thất bại).
* `snapshot.hasData`: Kiểm tra nhanh xem có dữ liệu chưa.

---

### 3. Ví dụ Code chuẩn (Copy dùng được ngay)

Giả sử bạn có một hàm giả lập lấy dữ liệu mất 2 giây:

```dart
// Hàm giả lập API
Future<String> layDuLieuTuServer() async {
  await Future.delayed(const Duration(seconds: 2));
  // return "Dữ liệu quan trọng"; // Trường hợp thành công
  throw Exception("Mất mạng rồi!"); // Trường hợp lỗi
}

```

Và đây là cách dùng `FutureBuilder`:

```dart
FutureBuilder<String>(
  future: layDuLieuTuServer(), // 1. Truyền Future vào
  builder: (context, snapshot) { // 2. Xử lý giao diện dựa trên snapshot
    
    // Trường hợp 1: Đang tải (Waiting)
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator(); // Hiện vòng quay
    }

    // Trường hợp 2: Có lỗi (Error)
    if (snapshot.hasError) {
      return Text("Lỗi: ${snapshot.error}");
    }

    // Trường hợp 3: Có dữ liệu (Done & Success)
    if (snapshot.hasData) {
      return Text("Kết quả: ${snapshot.data}");
    }

    // Trường hợp mặc định (ít khi vào đây)
    return const Text("Không có dữ liệu");
  },
)

```

---

### 4. Các trạng thái ConnectionState

Bạn cần kiểm tra `snapshot.connectionState` để biết Future đang ở giai đoạn nào:

* **`none`**: Future là null hoặc chưa bắt đầu.
* **`waiting`**: Future đang chạy (đang tải).
* **`active`**: (Chỉ dùng cho Stream, Future ít gặp) Đang có dữ liệu đẩy về dần dần.
* **`done`**: Future đã hoàn thành (có thể thành công hoặc thất bại).

---

### 5. "Cái bẫy" chết người khi dùng FutureBuilder (Lưu ý quan trọng ⭐)

Một sai lầm 90% người mới mắc phải là gọi hàm tạo Future **trực tiếp** trong thuộc tính `future`.

**Sai lầm:**

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getApiData(), // SAI: Mỗi lần build lại gọi API một lần
      builder: ...,
    );
  }
}

```

**Hậu quả:**
Mỗi khi bạn bấm `setState` (ví dụ bấm nút like, mở drawer, bàn phím hiện lên), hàm `build` chạy lại -> `getApiData()` chạy lại -> App tải lại dữ liệu từ đầu liên tục -> **Lag, tốn Data, Spam Server**.

**Cách sửa (Đúng):**
Bạn phải gọi hàm lấy dữ liệu trong `initState` và lưu nó vào một biến, sau đó truyền biến đó vào FutureBuilder.

```dart
class MyScreen extends StatefulWidget { ... }

class _MyScreenState extends State<MyScreen> {
  // 1. Tạo biến để lưu Future
  late Future<String> _myFuture;

  @override
  void initState() {
    super.initState();
    // 2. Gọi hàm 1 lần duy nhất ở đây
    _myFuture = getApiData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _myFuture, // 3. Dùng biến đã lưu
      builder: ...,
    );
  }
}

```

### Tóm tắt

* **FutureBuilder** giúp vẽ UI cho dữ liệu bất đồng bộ (Async).
* Nó hoạt động dựa trên **Snapshot** (Waiting -> Error/Data).
* Nên xử lý đủ 3 trường hợp: **Loading**, **Error**, **Data**.
* **Tuyệt đối** lưu Future vào biến ở `initState`, đừng gọi hàm trực tiếp trong `build`.
