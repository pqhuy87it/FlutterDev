Chào bạn, làm việc với **Flavors** (hoặc Environments) là kỹ năng bắt buộc khi làm dự án thực tế để tách biệt các môi trường như **Development (Dev)**, **Staging (UAT)**, và **Production (Prod)**.

Việc này giúp bạn cài được 3 app cùng lúc trên một điện thoại (ví dụ: "App Dev", "App Staging", "App Xịn") với API, icon và cấu hình khác nhau.

Có 2 cách để làm việc này:

1. **Cách thủ công (Manual):** Hiểu sâu về bản chất.
2. **Cách dùng Tool (Automated):** Nhanh, chuẩn, ít lỗi (Khuyên dùng).

Dưới đây là hướng dẫn chi tiết.

---

### Cách 1: Sử dụng thư viện `flutter_flavorizr` (Khuyên dùng 🚀)

Cấu hình Flavors thủ công trên iOS (Xcode) cực kỳ phức tạp và dễ lỗi. Thư viện này sẽ tự động sửa `build.gradle` (Android) và `Schemes/xcconfig` (iOS) cho bạn.

#### Bước 1: Thêm vào `pubspec.yaml` (dev_dependencies)

```yaml
dev_dependencies:
  flutter_flavorizr: ^2.2.3

```

#### Bước 2: Cấu hình trong `pubspec.yaml` (hoặc tạo file `flavorizr.yaml` riêng)

Thêm đoạn cấu hình này vào cuối file:

```yaml
flavorizr:
  app:
    android:
      flavorDimensions: "flavor"
    ios:
      bundleId: "com.example.app" # Bundle ID gốc
  flavors:
    dev:
      app:
        name: "My App Dev"
      android:
        applicationId: "com.example.app.dev" # ID riêng cho dev
      ios:
        bundleId: "com.example.app.dev"
    prod:
      app:
        name: "My App"
      android:
        applicationId: "com.example.app"
      ios:
        bundleId: "com.example.app"

```

#### Bước 3: Chạy lệnh khởi tạo

```bash
dart run flutter_flavorizr

```

Lệnh này sẽ tự động:

* Tạo file `main_dev.dart`, `main_prod.dart`.
* Tạo các Schemes trong iOS và Product Flavors trong Android.
* Tạo icon app riêng cho từng môi trường (nếu bạn cấu hình thêm).

---

### Cách 2: Cấu hình Thủ công (Để hiểu bản chất)

Nếu bạn muốn tự tay làm hoặc dự án đã có sẵn cấu hình phức tạp, hãy làm theo các bước sau:

#### 1. Phần Flutter (Dart Side)

Bạn cần tạo các điểm đầu vào (Entry Points) khác nhau.

* `lib/main_dev.dart`
* `lib/main_prod.dart`

**Tạo file cấu hình (AppConfig):**

```dart
// lib/app_config.dart
enum Flavor { dev, prod }

class AppConfig {
  final Flavor flavor;
  final String apiBaseUrl;
  final String appName;

  static late AppConfig instance;

  AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appName,
  }) {
    instance = this;
  }
}

```

**File `lib/main_dev.dart`:**

```dart
import 'package:flutter/material.dart';
import 'app_config.dart';
import 'main.dart'; // File chứa widget MyApp

void main() {
  AppConfig(
    flavor: Flavor.dev,
    apiBaseUrl: "https://dev-api.example.com",
    appName: "App Dev",
  );
  
  runApp(const MyApp());
}

```

---

#### 2. Phần Android (Gradle)

Mở file `android/app/build.gradle`.

Tìm khối `android { ... }` và thêm:

```gradle
android {
    // ...
    
    // 1. Khai báo dimension
    flavorDimensions "default"

    // 2. Định nghĩa các flavors
    productFlavors {
        dev {
            dimension "default"
            applicationIdSuffix ".dev" // ID sẽ là com.example.app.dev
            resValue "string", "app_name", "App Dev" // Tên hiển thị
        }
        prod {
            dimension "default"
            // Không có suffix -> ID gốc
            resValue "string", "app_name", "My App"
        }
    }
}

```

*Lưu ý:* Bạn cần sửa `AndroidManifest.xml` đoạn `android:label="@string/app_name"` để nó nhận tên động từ Gradle.

---

#### 3. Phần iOS (Xcode - Phức tạp nhất)

Bạn cần tạo **Schemes** và **Configurations**.

1. **Mở Xcode:** `ios/Runner.xcworkspace`.
2. **Tạo Configurations:**
* Vào Project `Runner` -> Tab **Info**.
* Phần **Configurations**, nhân bản `Debug` thành `Debug-dev`, `Debug-prod`. Làm tương tự với `Release`.


3. **Tạo Schemes:**
* Vào menu **Product** -> **Scheme** -> **Manage Schemes**.
* Tạo Scheme mới tên là `dev` và `prod`.
* Edit Scheme `dev`: Chỉnh **Run** -> **Build Configuration** thành `Debug-dev`. Chỉnh **Archive** thành `Release-dev`.


4. **Chỉnh Bundle ID và Display Name:**
* Vào Target `Runner` -> Tab **Build Settings**.
* Tìm **Product Bundle Identifier**.
* Mở mũi tên ra, set ID riêng cho từng cấu hình (ví dụ `Debug-dev` là `com.example.app.dev`).
* Làm tương tự với **Product Name** (hoặc sửa trong `Info.plist` key `Bundle Display Name` thành `$(PRODUCT_NAME)`).



---

### Cách chạy (Running)

Sau khi cấu hình xong (bằng Tool hoặc Thủ công), bạn chạy lệnh sau:

**Chạy môi trường Dev:**

```bash
flutter run --flavor dev -t lib/main_dev.dart

```

**Chạy môi trường Prod:**

```bash
flutter run --flavor prod -t lib/main_prod.dart

```

**Build file APK/IPA:**

```bash
flutter build apk --flavor prod -t lib/main_prod.dart

```

### Mẹo Pro: Xử lý icon khác nhau

Để mỗi flavor có một icon khác nhau (giúp Tester dễ phân biệt đâu là bản Dev, đâu là bản Prod), bạn dùng thư viện **`flutter_launcher_icons`**.

Tạo file `flutter_launcher_icons-dev.yaml`:

```yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/icons/icon-dev.png"

```

Sau đó chạy lệnh:

```bash
dart run flutter_launcher_icons:main -f flutter_launcher_icons-dev.yaml

```

### Tóm tắt

1. **Flavors** giúp tách môi trường Dev/Prod.
2. Nên dùng **`flutter_flavorizr`** để tự động hóa việc setup Android/iOS cho đỡ đau đầu.
3. Tạo file `main_dev.dart` và `main_prod.dart` để cấu hình API Url riêng biệt.
4. Luôn dùng tham số `--flavor` khi chạy lệnh terminal.
