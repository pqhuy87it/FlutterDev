import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // Lấy FlutterViewController để truy cập vào Flutter engine
          guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
          }

          // 1. Tạo một MethodChannel với tên *giống hệt* bên Dart
          let deviceInfoChannel = FlutterMethodChannel(name: "com.fai.abc/device_info",
                                                       binaryMessenger: controller.binaryMessenger)

          // 2. Đăng ký một trình xử lý (handler) cho các lời gọi từ Dart
          deviceInfoChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // 3. Kiểm tra tên phương thức được gọi
            if call.method == "getDeviceName" {
              // Gọi hàm lấy tên thiết bị và trả kết quả về cho Dart
              self.getDeviceName(result: result)
            } else {
              // Nếu phương thức không được định nghĩa, trả về lỗi
              result(FlutterMethodNotImplemented)
            }
          })
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    // 4. Viết hàm native để thực hiện logic
      private func getDeviceName(result: FlutterResult) {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
          guard let value = element.value as? Int8, value != 0 else { return identifier }
          return identifier + String(UnicodeScalar(UInt8(value)))
        }
        // Trả kết quả thành công về cho Dart
        result(identifier)
      }
}
