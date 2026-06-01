Chào bạn, **Code-splitting** (Phân tách mã) là một kỹ thuật tối ưu hóa hiệu năng cực kỳ quan trọng, đặc biệt là khi ứng dụng của bạn ngày càng "phình to" về kích thước.

Nếu ví ứng dụng của bạn là một **cuốn bách khoa toàn thư dày 1000 trang**:

* **Không có Code-splitting:** Người dùng phải tải về và cầm cả cuốn sách 1000 trang trên tay ngay từ đầu, dù họ chỉ muốn đọc trang đầu tiên. -> **Tải lâu, tốn RAM.**
* **Có Code-splitting:** Người dùng chỉ nhận trang bìa và mục lục. Khi họ muốn đọc chương "Lịch sử", hệ thống mới đưa cho họ 50 trang về lịch sử. -> **Tải nhanh, nhẹ máy.**

Trong Flutter, khái niệm này hoạt động khác nhau tùy vào nền tảng (Web hay Mobile). Dưới đây là giải thích chi tiết.

---

### 1. Code-splitting trong Flutter Web (Quan trọng nhất) 🌐

Đây là nơi Code-splitting tỏa sáng nhất.

**Vấn đề:**
Mặc định, khi build Flutter Web, toàn bộ code Dart của bạn sẽ được biên dịch thành một file Javascript khổng lồ duy nhất là `main.dart.js`. Người dùng phải tải xong file này thì web mới hiện lên. Nếu file này nặng 5MB, người dùng mạng yếu sẽ thấy màn hình trắng rất lâu.

**Giải pháp:**
Flutter hỗ trợ cơ chế **Deferred Loading** (Tải trì hoãn). Nó cho phép bạn tách một thư viện (library) hoặc một màn hình (page) ra khỏi file chính. File đó chỉ được tải về khi người dùng thực sự cần dùng đến nó.

**Cách thực hiện:**

Sử dụng từ khóa `deferred as` khi import.

```dart
// 1. Import với từ khóa 'deferred as'
import 'pages/heavy_complex_page.dart' deferred as heavyPage;

// 2. Hàm chuyển màn hình
void navigateToHeavyPage(BuildContext context) async {
  // 3. Gọi lệnh tải thư viện (Lúc này trình duyệt mới tải file .js về)
  await heavyPage.loadLibrary();

  // 4. Sau khi tải xong thì mới dùng được
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => heavyPage.HeavyComplexPage()),
  );
}

```

**Kết quả:**
Thay vì 1 file `main.dart.js` (5MB), bạn sẽ có:

* `main.dart.js` (1MB - chỉ chứa màn hình Home).
* `main.dart.js_1.part.js` (4MB - chứa HeavyPage, chỉ tải khi bấm nút).

---

### 2. Code-splitting trong Flutter Mobile (Android) 📱

Trên Mobile, khái niệm này được gọi là **Deferred Components** (Các thành phần bị trì hoãn).

**Vấn đề:**
Google Play Store giới hạn kích thước file cài đặt ban đầu. Bạn muốn app có nhiều tính năng nhưng file tải về phải nhỏ để tăng lượt tải.

**Giải pháp:**
Flutter hỗ trợ build ra định dạng `.aab` (Android App Bundle) với các module động (Dynamic Feature Modules).

* Người dùng cài App: Chỉ tải module gốc (Base module).
* Khi người dùng bấm vào tính năng "Quét AR" (nặng 50MB): App sẽ âm thầm tải module đó từ Google Play về và cài đặt bổ sung.

**Lưu ý:**

* Tính năng này hiện chủ yếu hỗ trợ tốt trên **Android**.
* Cấu hình phức tạp hơn Web rất nhiều (cần can thiệp vào Native Android, file `build.gradle` và cấu hình trên Google Play Console).
* iOS chưa hỗ trợ cơ chế tương tự một cách chính thống từ Flutter (iOS có *On-Demand Resources* nhưng việc tích hợp với Flutter Dart code còn hạn chế).

---

### 3. Khi nào nên dùng Code-splitting?

Không phải lúc nào chia nhỏ cũng tốt. Bạn nên cân nhắc:

| Nên dùng ✅ | Không nên dùng ❌ |
| --- | --- |
| **Flutter Web:** Hầu như luôn luôn nên dùng nếu app có nhiều màn hình. | **App Mobile nhỏ:** Nếu app chỉ vài chục MB, việc tách ra làm phức tạp hóa vấn đề không cần thiết. |
| **Tính năng ít dùng:** Ví dụ trang "Admin Dashboard" chỉ 1% user vào xem -> Tách nó ra để 99% user kia không phải tải thừa. | **Tính năng cốt lõi:** Màn hình Home, Login, Feed... những thứ user vào là thấy ngay thì phải để ở module chính. |
| **Thư viện nặng:** Tích hợp bộ Editor ảnh, xử lý PDF nặng nề. | **Widget nhỏ:** Tách một cái Button hay Text ra thì công sức quản lý còn tốn hơn hiệu quả mang lại. |

---

### 4. Code mẫu thực tế: Lazy Loading Widget

Dưới đây là cách tạo một Widget tự động tải code khi cần hiển thị (thường dùng cho Web):

```dart
import 'package:flutter/material.dart';
// Import trì hoãn
import 'complex_widget.dart' deferred as box;

class LazyLoadWidget extends StatefulWidget {
  const LazyLoadWidget({super.key});

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  // Biến kiểm tra xem đã tải xong thư viện chưa
  late Future<void> _libraryFuture;

  @override
  void initState() {
    super.initState();
    // Bắt đầu tải ngay khi Widget được khởi tạo
    _libraryFuture = box.loadLibrary();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _libraryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Tải xong -> Hiển thị Widget từ thư viện deferred
          return box.ComplexWidget();
        }
        // Đang tải -> Hiển thị Loading
        return const CircularProgressIndicator();
      },
    );
  }
}

```

### Tóm lại

1. **Code-splitting** là chia nhỏ ứng dụng để tải từng phần theo nhu cầu.
2. Trên **Flutter Web**: Dùng từ khóa `deferred as`. Đây là kỹ thuật bắt buộc để web load nhanh.
3. Trên **Flutter Mobile**: Dùng **Deferred Components** (Android) để giảm dung lượng file cài đặt trên Store.

Bạn có đang phát triển Flutter Web không? Nếu có, mình có thể hướng dẫn kỹ hơn về cách tối ưu file `main.dart.js` để load siêu nhanh!
