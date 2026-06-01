Chào bạn, **Visibility** trong Flutter là một widget cực kỳ hữu ích giúp bạn kiểm soát việc **Ẩn** hoặc **Hiện** một widget con mà không cần dùng đến các cấu trúc điều kiện phức tạp (như `if-else`).

Hãy tưởng tượng `Visibility` giống như một **chiếc áo tàng hình**:

* Khi mặc áo (`visible: false`): Bạn không nhìn thấy nó, nhưng nó có thể vẫn đứng đó chiếm chỗ, hoặc biến mất hoàn toàn tùy cách bạn cấu hình.
* Khi cởi áo (`visible: true`): Nó hiện ra bình thường.

Dưới đây là giải thích chi tiết về cách dùng và các "bí mật" của nó.

---

### 1. Cách sử dụng cơ bản

Cách dùng đơn giản nhất là bọc widget bạn muốn ẩn/hiện vào trong `Visibility` và thay đổi tham số `visible`.

```dart
bool _isVisible = true;

Visibility(
  visible: _isVisible, // true = hiện, false = ẩn
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
    child: const Text("Tôi đang hiện!"),
  ),
)

```

**Mặc định:** Khi `visible: false`, widget con sẽ bị thay thế bởi một `SizedBox.shrink()` (một hộp kích thước 0x0). Nghĩa là nó biến mất hoàn toàn khỏi giao diện và không chiếm diện tích.

---

### 2. Các thuộc tính nâng cao (Quan trọng ⭐)

Sức mạnh thực sự của `Visibility` nằm ở việc bạn có thể tùy chỉnh hành vi khi nó bị ẩn.

#### A. `replacement` (Vật thế thân)

Khi ẩn đi, bạn muốn hiển thị cái gì thay thế? Mặc định là không gì cả, nhưng bạn có thể thay bằng một dòng chữ "Đang ẩn" hoặc một icon.

```dart
Visibility(
  visible: false,
  replacement: const Text("Đã bị ẩn rồi!"), // Hiện cái này khi visible = false
  child: Container(...),
)

```

#### B. `maintainSize` (Giữ chỗ - Ghost Mode)

Bạn muốn widget ẩn đi nhưng **vẫn chiếm diện tích** (để bố cục không bị nhảy/xô lệch)?

* Ví dụ: Bạn có 3 nút bấm hàng ngang. Khi ẩn nút giữa, bạn muốn 2 nút kia vẫn đứng yên chứ không dồn vào nhau.

```dart
Visibility(
  visible: false,
  maintainSize: true,      // Vẫn giữ kích thước cũ
  maintainAnimation: true, // Bắt buộc phải true nếu dùng maintainSize
  maintainState: true,     // Bắt buộc phải true nếu dùng maintainSize
  child: Container(width: 50, height: 50, color: Colors.red),
)

```

*Kết quả: Bạn sẽ thấy một khoảng trắng 50x50 ở đó.*

#### C. `maintainState` (Giữ trạng thái)

Khi ẩn đi, bạn có muốn widget giữ lại dữ liệu đang nhập dở không?

* Nếu `maintainState: false` (mặc định): Widget bị hủy (dispose). Text nhập trong ô Input sẽ mất.
* Nếu `maintainState: true`: Widget vẫn sống ngầm. Khi hiện lại, Text vẫn còn nguyên.

---

### 3. So sánh Visibility với các cách ẩn khác

Đây là câu hỏi phỏng vấn và kiến thức thực tế rất quan trọng. Khi nào dùng cái nào?

| Phương pháp | Code ví dụ | Đặc điểm | Khi nào dùng? |
| --- | --- | --- | --- |
| **Dùng `if**` | `if (show) Widget()` | **Xóa hoàn toàn** khỏi cây Widget. Tiết kiệm tài nguyên nhất. State bị mất. | Khi muốn ẩn hoàn toàn và không cần giữ lại dữ liệu (VD: Ẩn banner quảng cáo). |
| **Visibility (Mặc định)** | `Visibility(visible: show, ...)` | Giống `if`, nhưng viết gọn hơn trong cây widget lồng nhau. Có thể thay thế bằng `replacement`. | Khi muốn ẩn hiện linh hoạt, code dễ đọc. |
| **Visibility (MaintainSize)** | `Visibility(maintainSize: true, ...)` | Ẩn hình ảnh nhưng **giữ chỗ trống**. Không nhận sự kiện click. | Khi muốn giữ bố cục (layout) ổn định, không bị giật khi ẩn hiện. |
| **Opacity** | `Opacity(opacity: 0.0, ...)` | Widget vẫn được vẽ (nhưng trong suốt). **Vẫn nhận sự kiện click**. Tốn tài nguyên vẽ. | Khi cần làm hiệu ứng mờ dần (Animation Fade) hoặc muốn nút tàng hình vẫn bấm được. |
| **Offstage** | `Offstage(offstage: true, ...)` | Widget bị đẩy ra khỏi màn hình nhưng vẫn được tính toán kích thước và giữ State. | Khi cần đo kích thước widget trước khi hiện, hoặc ẩn tạm thời mà cần giữ nguyên trạng thái phức tạp. |

---

### 4. Tóm tắt lời khuyên

1. Nếu muốn **tiết kiệm RAM/CPU** nhất: Hãy dùng `if` hoặc `Visibility` mặc định (vì nó hủy widget con).
2. Nếu muốn **giao diện không bị nhảy** (giữ khoảng trống): Hãy dùng `Visibility` với `maintainSize: true`.
3. Nếu muốn **hiệu ứng mờ dần**: Hãy dùng `AnimatedOpacity` hoặc `Opacity`.

`Visibility` là công cụ cân bằng nhất: Vừa có thể hoạt động như `if` (xóa bỏ), vừa có thể hoạt động như `Opacity` (giữ chỗ) tùy vào cách bạn cấu hình.
