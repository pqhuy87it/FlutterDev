Chào bạn, **Singleton** là một trong những Design Pattern (Mẫu thiết kế) phổ biến nhất, nhưng cũng gây tranh cãi nhất.

Hiểu đơn giản: **Singleton** đảm bảo rằng một Class chỉ có **DUY NHẤT MỘT** instance (một bản thể) tồn tại trong suốt vòng đời của ứng dụng và cung cấp một điểm truy cập toàn cục (global access) đến nó.

Hãy tưởng tượng: Singleton giống như **Tổng thống** của một quốc gia. Chỉ có một người tại một thời điểm, và bất kỳ ai (người dân, bộ trưởng) khi nhắc đến "Tổng thống" đều đang nói về cùng một người đó.

Dưới đây là hướng dẫn chi tiết từ cách viết code đến ưu nhược điểm.

---

### 1. Tại sao cần dùng Singleton?

Bạn sẽ cần Singleton cho những tài nguyên mà việc tạo ra nó tốn kém, hoặc cần sự đồng nhất dữ liệu trên toàn app:

1. **Quản lý Cấu hình (Configuration):** App settings chỉ nên có 1 bản duy nhất.
2. **Database Connection:** Kết nối SQLite/Realm thường chỉ cần mở 1 lần và dùng chung.
3. **API Client (Dio/Http):** Cấu hình Base URL, Timeout một lần và tái sử dụng.
4. **Logging:** Ghi log tập trung.
5. **Socket:** Kết nối thời gian thực.

---

### 2. Cách triển khai Singleton chuẩn trong Dart

Dart hỗ trợ Singleton cực kỳ thanh lịch nhờ từ khóa `factory`. Dưới đây là mẫu code chuẩn mực (Standard Pattern):

```dart
class MyService {
  // 1. Tạo một biến static private để lưu instance duy nhất
  // 'static' nghĩa là biến này thuộc về class, không thuộc về object.
  static final MyService _instance = MyService._internal();

  // 2. Private Constructor
  // Dấu gạch dưới '_' đảm bảo không ai có thể gọi 'new MyService()' từ bên ngoài
  MyService._internal() {
    print("Khởi tạo MyService lần đầu tiên!");
    // Khởi tạo các biến, kết nối database ở đây...
  }

  // 3. Factory Constructor
  // Khi bạn gọi MyService(), nó sẽ không tạo mới mà trả về _instance đã có
  factory MyService() {
    return _instance;
  }

  // --- Các hàm nghiệp vụ ---
  void doSomething() {
    print("Đang làm việc...");
  }
}

```

**Cách sử dụng:**

```dart
void main() {
  // Lần gọi 1: Nó sẽ chạy constructor _internal
  var s1 = MyService(); 
  
  // Lần gọi 2: Nó trả về instance cũ, KHÔNG chạy lại _internal
  var s2 = MyService();

  // Kiểm tra: True (Vì s1 và s2 là cùng một object)
  print(s1 == s2); 
}

```

---

### 3. Cách 2: Singleton đơn giản (Static Field)

Cách này ngắn gọn hơn, thường dùng khi bạn không cần `factory constructor`.

```dart
class AuthManager {
  // Private constructor để chặn việc khởi tạo bên ngoài
  AuthManager._(); 

  // Instance public để truy cập trực tiếp
  static final AuthManager instance = AuthManager._();

  String? currentUser;

  void login(String user) {
    currentUser = user;
  }
}

// Cách dùng:
void main() {
  AuthManager.instance.login("UserA");
  print(AuthManager.instance.currentUser); // UserA
}

```

---

### 4. Ưu và Nhược điểm (Cần cân nhắc kỹ)

Mặc dù tiện lợi, nhưng Singleton thường bị gọi là **"Anti-pattern"** (Mẫu thiết kế nên tránh) nếu lạm dụng.

| Ưu điểm (👍) | Nhược điểm (👎) |
| --- | --- |
| **Tiết kiệm tài nguyên:** Chỉ tạo object 1 lần (đỡ tốn RAM). | **Khó Test:** Vì nó là Global state, các bài Unit Test dễ bị ảnh hưởng lẫn nhau (test A đổi dữ liệu singleton, làm test B sai). |
| **Truy cập dễ dàng:** Gọi được ở bất cứ đâu (`Class.instance`). | **Ẩn giấu sự phụ thuộc:** Một class dùng Singleton bên trong hàm `build` sẽ khó biết nó phụ thuộc vào cái gì nếu chỉ nhìn bên ngoài. |
| **Đồng bộ trạng thái:** Dữ liệu được chia sẻ nhất quán. | **Khó mở rộng:** Sau này nếu bạn muốn đổi từ "1 Database" sang "2 Database", bạn phải sửa lại toàn bộ code. |

---

### 5. Giải pháp thay thế hiện đại: Dependency Injection (DI)

Trong các dự án Flutter chuyên nghiệp, người ta hạn chế dùng Singleton thô (như mục 2 và 3) mà chuyển sang dùng **Service Locator** hoặc **Provider**.

Công cụ phổ biến nhất là **`GetIt`**. Nó hoạt động giống Singleton nhưng linh hoạt hơn và dễ test hơn.

**Ví dụ dùng GetIt (Khuyên dùng):**

1. Cài đặt: `flutter pub add get_it`
2. Thiết lập:

```dart
import 'package:get_it/get_it.dart';

// Tạo đối tượng quản lý toàn cục
final getIt = GetIt.instance;

void setupLocator() {
  // Đăng ký Singleton (Lazy: chỉ khởi tạo khi dùng đến)
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
}

```

3. Sử dụng:

```dart
void main() {
  setupLocator(); // Chạy 1 lần lúc khởi động app
  runApp(MyApp());
}

class MyWidget extends StatelessWidget {
  // Lấy instance ra dùng (giống hệt Singleton nhưng dễ quản lý hơn)
  final dbService = getIt<DatabaseService>(); 

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

```

### Tóm tắt lời khuyên

1. **Dùng Singleton thuần** (Factory pattern) cho những thứ cực kỳ cơ bản và không thay đổi logic (như `Logger`, `AppConfig`).
2. **Dùng GetIt** (Service Locator) cho các Service quan trọng (API, Database, Auth) để dễ viết Unit Test và quản lý vòng đời.
3. **Tuyệt đối không** dùng Singleton để truyền dữ liệu giữa 2 màn hình (hãy dùng Arguments hoặc State Management như Provider/Bloc/Riverpod).
