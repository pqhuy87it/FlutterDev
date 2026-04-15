package com.example.binding_android_native_code

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build // Import lớp Build để lấy thông tin hệ điều hành
class MainActivity : FlutterActivity() {
    // 1. Khai báo tên channel, phải *giống hệt* bên Dart
    private val CHANNEL = "com.fai.abc/os_info"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 2. Tạo một MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            // 3. Kiểm tra tên phương thức được gọi từ Dart
            if (call.method == "getOSVersion") {
                // Lấy phiên bản SDK của Android
                val sdkVersion = "SDK ${Build.VERSION.SDK_INT}"
                // Trả kết quả thành công về cho Dart
                result.success(sdkVersion)
            } else {
                // Nếu phương thức không được định nghĩa, trả về lỗi
                result.notImplemented()
            }
        }
    }
}
