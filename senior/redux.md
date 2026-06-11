Chào bạn, **Redux** là một kiến trúc quản lý trạng thái (State Management) cực kỳ nổi tiếng. Nó xuất thân từ thế giới Web (ReactJS) và được cộng đồng mang sang Flutter.

Nếu bạn thích sự **chặt chẽ, kỷ luật và luồng dữ liệu một chiều**, Redux là một lựa chọn thú vị.

Dưới đây là giải thích chi tiết về Redux trong Flutter.

---

### 1. Nguyên lý cốt lõi: "Luồng dữ liệu một chiều"

Trong Redux, mọi thứ đi theo một vòng tròn khép kín và chỉ đi theo một chiều duy nhất (Unidirectional Data Flow). Điều này giúp bạn kiểm soát hoàn toàn việc: **Tại sao** state thay đổi và **khi nào** nó thay đổi.

Công thức toán học của Redux rất đơn giản:


---

### 2. Ba thành phần chính (The Trinity)

Để dùng Redux, bạn phải thiết lập 3 thành phần sau:

#### A. Store (Kho chứa duy nhất)

* Là nơi lưu trữ **toàn bộ** trạng thái của ứng dụng (Single Source of Truth).
* Khác với Provider hay BLoC có thể có nhiều instances, Redux thường chỉ có **1 Store duy nhất** cho cả App.
* Store là "bất khả xâm phạm", bạn không thể sửa trực tiếp dữ liệu trong Store (ví dụ: `store.count = 5` là cấm kỵ).

#### B. Action (Mệnh lệnh)

* Là một object mô tả **chuyện gì vừa xảy ra**.
* Nó chỉ chứa thông tin, không chứa logic xử lý.
* Ví dụ: `ActionIncrement`, `ActionLoginSuccess`, `ActionUpdateUser`.

#### C. Reducer (Máy chế biến)

* Đây là một **Hàm thuần túy (Pure Function)**.
* Nhiệm vụ: Nhận vào `State cũ` + `Action` -> Trả về `State mới`.
* **Tuyệt đối không:** Gọi API, lưu Database hay thực hiện các tác vụ ngẫu nhiên (random) trong Reducer. Reducer chỉ tính toán logic dựa trên input.

---

### 3. Quy trình hoạt động (Workflow)

Hãy hình dung quy trình khi người dùng bấm nút "Tăng điểm":

1. **View (UI):** Người dùng bấm nút `+`.
2. **Dispatch:** View gửi một `Action` (ví dụ: `IncrementAction`) vào Store.
3. **Reducer:** Store gọi Reducer. Reducer thấy Action là Increment -> Nó lấy điểm cũ cộng thêm 1 -> Tạo ra State mới.
4. **Store:** Cập nhật State mới vào kho.
5. **View (UI):** Store báo cho UI biết "Dữ liệu đổi rồi nha". UI tự vẽ lại (rebuild) với điểm số mới.

---

### 4. Code ví dụ: Ứng dụng đếm số

Để dùng Redux trong Flutter, bạn cần gói `flutter_redux` và `redux`.

**Bước 1: Định nghĩa Action**

```dart
// Các hành động có thể xảy ra
enum CounterActions { Increment, Decrement }

```

**Bước 2: Định nghĩa Reducer**

```dart
// Hàm xử lý logic: Nhận state cũ và action, trả về int mới
int counterReducer(int state, dynamic action) {
  if (action == CounterActions.Increment) {
    return state + 1;
  }
  return state;
}

```

**Bước 3: Khởi tạo Store và gắn vào App**

```dart
void main() {
  // Tạo kho chứa với giá trị khởi tạo là 0
  final store = Store<int>(counterReducer, initialState: 0);

  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<int> store;
  // ... constructor ...

  @override
  Widget build(BuildContext context) {
    // StoreProvider bao bọc cả app để cung cấp Store xuống dưới
    return StoreProvider<int>(
      store: store,
      child: MaterialApp(home: CounterPage()),
    );
  }
}

```

**Bước 4: Sử dụng ở UI (StoreConnector)**

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // StoreConnector dùng để kết nối UI với Store
        child: StoreConnector<int, String>(
          converter: (store) => store.state.toString(),
          builder: (context, count) {
            return Text("Số đếm: $count");
          },
        ),
      ),
      floatingActionButton: StoreConnector<int, VoidCallback>(
        converter: (store) {
          // Trả về một hàm để UI gọi khi bấm nút
          return () => store.dispatch(CounterActions.Increment);
        },
        builder: (context, callback) {
          return FloatingActionButton(
            onPressed: callback, // Khi bấm -> Dispatch Action
            child: Icon(Icons.add),
          );
        },
      ),
    );
  }
}

```

---

### 5. Middleware (Xử lý bất đồng bộ - API)

Vì **Reducer** là hàm đồng bộ (chạy xong ngay), nên nếu bạn muốn gọi API (chờ 2s mới có kết quả), bạn không thể viết trong Reducer.

Bạn phải dùng **Middleware** (lớp trung gian).

* Action đi qua Middleware trước khi đến Reducer.
* Middleware chặn Action lại -> Gọi API -> Có kết quả -> Bắn tiếp một Action khác (ví dụ `ActionLoadSuccess`) vào Reducer.
* Thư viện phổ biến: `redux_thunk`.

---

### 6. Ưu và Nhược điểm

| Ưu điểm | Nhược điểm |
| --- | --- |
| **Dễ đoán (Predictable):** State chỉ thay đổi qua Action và Reducer, không có thay đổi ngầm. | **Nhiều Code (Boilerplate):** Bạn phải viết rất nhiều file (Action, Reducer, State, Store) cho một tính năng nhỏ. |
| **Dễ Debug:** Bạn có thể log lại toàn bộ lịch sử Action để biết user đã làm gì (Time travel debugging). | **Cồng kềnh:** Với các app nhỏ, Redux là "dùng dao mổ trâu giết gà". |
| **Cấu trúc chặt chẽ:** Phù hợp cho team lớn, code của ai cũng theo chuẩn giống nhau. | **Độ dốc học tập:** Khái niệm Middleware, Reducer, Pure Function hơi khó hiểu với người mới. |

---

### 7. Khi nào nên dùng Redux trong Flutter?

Thực tế hiện nay, **Redux không còn là lựa chọn số 1** cho Flutter (bị BLoC, Riverpod, Provider lấn lướt). Tuy nhiên, bạn nên dùng Redux khi:

1. Bạn hoặc team của bạn chuyển từ React Native/ReactJS sang và đã quá quen thuộc với Redux.
2. Ứng dụng cực kỳ phức tạp, cần lưu vết lịch sử người dùng chi tiết.
3. Bạn thích phong cách lập trình hàm (Functional Programming) tuyệt đối.

### Bước tiếp theo

Nếu bạn mới bắt đầu học State Management, mình khuyên bạn nên thử **Provider** hoặc **Riverpod** trước vì chúng "Flutter-native" hơn và ít code thừa hơn Redux.

Bạn có muốn mình so sánh Redux với BLoC hoặc Riverpod không?
