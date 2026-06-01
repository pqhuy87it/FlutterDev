Chào bạn, để làm đa ngôn ngữ (Internationalization - viết tắt là **i18n**) trong Flutter, cách "chính đạo" và chuẩn nhất hiện nay là sử dụng gói `flutter_localizations` kết hợp với tính năng sinh code tự động (Code Generation).

Cách này giúp bạn **Type-safe** (gõ code nó tự gợi ý key, không sợ gõ sai chính tả như dùng String cứng).

Dưới đây là quy trình 5 bước chuẩn để thực hiện.

---

### Bước 1: Thêm thư viện vào `pubspec.yaml`

Bạn cần thêm `flutter_localizations` và gói `intl`.

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations: # Thư viện chính
    sdk: flutter
  intl: ^0.18.1 # Hỗ trợ định dạng ngày tháng, số tiền...

flutter:
  generate: true # BẬT tính năng tự động sinh code

```

---

### Bước 2: Tạo file cấu hình `l10n.yaml`

Tạo một file tên là `l10n.yaml` nằm ngay **thư mục gốc** của dự án (ngang hàng với `pubspec.yaml`). File này chỉ đường cho Flutter biết file dịch nằm ở đâu.

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart

```

---

### Bước 3: Tạo các file ngôn ngữ (`.arb`)

Tạo thư mục `lib/l10n`. Sau đó tạo các file `.arb` (Application Resource Bundle - bản chất giống JSON).

**1. File tiếng Anh (`lib/l10n/app_en.arb`):**

```json
{
  "helloWorld": "Hello World!",
  "welcome": "Welcome {name}",
  "@welcome": {
    "description": "Chào hỏi người dùng kèm tên",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}

```

**2. File tiếng Việt (`lib/l10n/app_vi.arb`):**

```json
{
  "helloWorld": "Xin chào thế giới!",
  "welcome": "Chào mừng {name}"
}

```

*Lưu ý:* Sau khi tạo xong, hãy chạy lệnh `flutter pub get` hoặc bấm Run (nếu dùng IDE) để Flutter tự động sinh ra file `app_localizations.dart` trong thư mục ẩn `.dart_tool`.

---

### Bước 4: Cấu hình `MaterialApp`

Vào file `main.dart`, bạn cần khai báo để app biết phải dùng bộ dịch nào.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import file tự sinh

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter i18n Demo',
      
      // 1. Khai báo các delegate (bộ xử lý dịch)
      localizationsDelegates: const [
        AppLocalizations.delegate, // Delegate của app mình
        GlobalMaterialLocalizations.delegate, // Dịch sẵn các widget của Material (VD: nút Cancel/OK)
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // 2. Khai báo các ngôn ngữ hỗ trợ
      supportedLocales: const [
        Locale('en'), // Tiếng Anh
        Locale('vi'), // Tiếng Việt
      ],
      
      // 3. (Tuỳ chọn) Thiết lập ngôn ngữ mặc định hoặc logic chọn ngôn ngữ
      locale: const Locale('vi'), // Ví dụ ép cứng tiếng Việt để test

      home: const MyHomePage(),
    );
  }
}

```

---

### Bước 5: Sử dụng trong Widget

Bây giờ bạn có thể gọi text ra ở bất cứ đâu bằng `AppLocalizations.of(context)!`.

```dart
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mẹo: Tạo biến ngắn gọn để đỡ phải gõ dài
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helloWorld)), // "Xin chào thế giới!"
      body: Center(
        child: Column(
          children: [
            // Truyền tham số vào chuỗi
            Text(l10n.welcome("Huy")), // "Chào mừng Huy"
          ],
        ),
      ),
    );
  }
}

```

---

### Mẹo nâng cao: Thay đổi ngôn ngữ động (Switch Language)

Để người dùng bấm nút đổi ngôn ngữ (Anh <-> Việt), bạn cần kết hợp với **State Management** (như Riverpod mà bạn đang dùng).

1. **Tạo Provider quản lý Locale:**

```dart
// locale_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('vi'); // Mặc định là Tiếng Việt
});

```

2. **Gắn vào `MaterialApp`:**

```dart
class MyApp extends ConsumerWidget { // Dùng ConsumerWidget của Riverpod
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider); // Lắng nghe thay đổi

    return MaterialApp(
      locale: currentLocale, // Cập nhật vào đây
      localizationsDelegates: AppLocalizations.localizationsDelegates, // Cách viết tắt
      supportedLocales: AppLocalizations.supportedLocales,
      // ...
    );
  }
}

```

3. **Nút bấm đổi ngôn ngữ:**

```dart
ElevatedButton(
  onPressed: () {
    // Đổi sang tiếng Anh
    ref.read(localeProvider.notifier).state = const Locale('en');
  },
  child: const Text("Switch to English"),
)

```

### Tổng kết

1. **Cài đặt:** Thêm `flutter_localizations`, cấu hình `l10n.yaml`.
2. **Tạo nội dung:** Viết file `.arb` (Anh, Việt...).
3. **Tích hợp:** Khai báo trong `MaterialApp`.
4. **Sử dụng:** `AppLocalizations.of(context)!.myKey`.

Nếu bạn dùng **VS Code**, mình khuyên bạn cài Extension tên là **"Flutter Intl"**. Nó sẽ tự động chạy lệnh sinh code mỗi khi bạn lưu file `.arb`, giúp tiết kiệm rất nhiều thời gian.
