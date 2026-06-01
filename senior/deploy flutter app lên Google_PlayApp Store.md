Chào bạn, việc deploy (đưa ứng dụng lên chợ) là bước cuối cùng và quan trọng nhất. Vì bạn đã có source code hoàn chỉnh (Todo App theo Clean Architecture), dưới đây là hướng dẫn chi tiết từng bước để đưa "đứa con tinh thần" của bạn lên Google Play và App Store.

Quy trình chia làm 3 phần chính: **Chuẩn bị chung**, **Android (Google Play)**, và **iOS (App Store)**.

---

### Phần 1: Chuẩn bị chung (Bắt buộc)

Trước khi build, bạn cần chuẩn bị các tài nguyên sau:

1. **Tài khoản Developer:**
* **Google Play Console:** Phí trọn đời $25 (đóng 1 lần).
* **Apple Developer Program:** Phí duy trì $99/năm (đóng hàng năm).


2. **App Icon:**
* Đừng cắt ảnh thủ công. Hãy dùng gói `flutter_launcher_icons`.
* Thêm vào `pubspec.yaml`, cấu hình đường dẫn ảnh logo của bạn, rồi chạy lệnh:
```bash
dart run flutter_launcher_icons

```




3. **App ID (Bundle ID):**
* Đảm bảo ID này là duy nhất (ví dụ: `com.yourname.todoapp`).
* Sửa trong `android/app/build.gradle` (applicationId) và trong Xcode (Bundle Identifier).



---

### Phần 2: Deploy lên Google Play (Android)

Android yêu cầu bạn phải ký (sign) ứng dụng bằng một chìa khóa điện tử (Keystore).

#### Bước 1: Tạo Upload Keystore

Chạy lệnh sau trên terminal (Windows dùng PowerShell, Mac/Linux dùng Terminal):

**Mac/Linux:**

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

```

**Windows:**

```powershell
keytool -genkey -v -keystore c:\Users\USER_NAME\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

```

*Lưu ý quan trọng:* Hãy nhớ kỹ mật khẩu bạn đặt và cất file `.jks` ở nơi an toàn (Google Drive, v.v.). **Nếu mất file này, bạn sẽ không bao giờ cập nhật được app nữa.**

#### Bước 2: Cấu hình Gradle

1. Tạo file `android/key.properties` (Không được commit file này lên Git):
```properties
storePassword=<mật khẩu store>
keyPassword=<mật khẩu key>
keyAlias=upload
storeFile=<đường dẫn tới file .jks>

```


2. Mở file `android/app/build.gradle`, sửa phần `android { ... }`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ...
        }
    }
}

```



#### Bước 3: Build App Bundle

Google Play hiện nay bắt buộc dùng `.aab` (App Bundle) thay vì `.apk`.

```bash
flutter build appbundle

```

File kết quả sẽ nằm ở: `build/app/outputs/bundle/release/app-release.aab`.

#### Bước 4: Upload lên Console

1. Truy cập [Google Play Console](https://play.google.com/console).
2. Tạo ứng dụng mới -> Điền thông tin (Tên, mô tả, ảnh chụp màn hình).
3. Vào mục **Production** (hoặc Internal Testing nếu muốn test trước).
4. Tạo **New Release** -> Upload file `.aab` vừa build.
5. Hoàn tất các bước khai báo nội dung (Quyền riêng tư, Độ tuổi, v.v.) và bấm **Start Rollout**.

---

### Phần 3: Deploy lên App Store (iOS)

*Yêu cầu bắt buộc:* Bạn phải có máy Mac (Macbook/iMac/Mac Mini) và cài đặt Xcode.

#### Bước 1: Cấu hình Signing trong Xcode

1. Mở file `ios/Runner.xcworkspace` bằng Xcode.
2. Chọn **Runner** (icon màu xanh ở sidebar trái) -> Chọn tab **Signing & Capabilities**.
3. Bấm **Add Account** -> Đăng nhập Apple ID Developer của bạn.
4. Ở mục **Team**, chọn team của bạn.
5. Tích vào **Automatically manage signing** (Xcode sẽ tự tạo Certificate và Profile cho bạn).

#### Bước 2: Cập nhật Version

Trong file `pubspec.yaml` của dự án Flutter:

```yaml
version: 1.0.0+1

```

* `1.0.0`: Là tên phiên bản hiển thị trên Store.
* `+1`: Là mã build (Build Number). **Mỗi lần upload mới lên Store, bạn bắt buộc phải tăng số này lên (ví dụ +2, +3).**

#### Bước 3: Build và Archive

1. Trên menu Xcode, chọn thiết bị là **Any iOS Device (arm64)**.
2. Chọn menu **Product** -> **Archive**.
3. Máy sẽ chạy build (khá lâu). Khi xong, cửa sổ **Organizer** sẽ hiện ra.

#### Bước 4: Upload lên App Store Connect

1. Trong cửa sổ Organizer, chọn bản build vừa xong -> Bấm **Distribute App**.
2. Chọn **App Store Connect** -> **Upload** -> Next liên tục (giữ mặc định).
3. Nếu thành công, Xcode sẽ báo "Uploaded Successfully".

#### Bước 5: Submit để Review

1. Truy cập [App Store Connect](https://appstoreconnect.apple.com).
2. Vào **My Apps** -> Tạo App mới (nếu chưa có).
3. Điền thông tin, ảnh chụp màn hình, chính sách quyền riêng tư.
4. Kéo xuống phần **Build**, chọn bản build bạn vừa upload từ Xcode.
5. Bấm **Add for Review**. (Apple thường duyệt trong 24-48h).

---

### Một số lưu ý quan trọng

1. **Ảnh chụp màn hình (Screenshots):** Cả 2 store đều yêu cầu ảnh chụp màn hình ở nhiều kích thước khác nhau. Bạn nên chạy máy ảo (Emulator/Simulator) để chụp cho đẹp và đúng chuẩn.
2. **Quyền riêng tư (Privacy Policy):** Bạn bắt buộc phải có một đường link dẫn đến trang Chính sách bảo mật (có thể dùng Google Docs hoặc GitHub Pages đơn giản).
3. **TestFlight (iOS):** Trước khi release chính thức, hãy dùng TestFlight (có sẵn trong App Store Connect) để mời bạn bè cài thử. Đây là cách test trên iPhone thật tốt nhất.
4. **Internal Testing (Android):** Tương tự TestFlight, Google Play Console có mục Internal Testing để cài file `.aab` cho tester.

Deploy lần đầu thường sẽ gặp lỗi cấu hình, đây là chuyện bình thường. Nếu gặp lỗi cụ thể nào trong quá trình build, bạn cứ gửi lỗi đó lên đây, mình sẽ hỗ trợ tiếp!
