```dart
String formatNumber(String input) {
  // 1. Tạo một đối tượng RegExp
  // ^    : Bắt đầu chuỗi
  // (\d{3}) : Bắt và nhóm 3 chữ số (Nhóm 1)
  // (\d{4}) : Bắt và nhóm 4 chữ số (Nhóm 2)
  // $    : Kết thúc chuỗi
  // RegExp này đảm bảo chuỗi có *chính xác* 7 chữ số.
  final regex = RegExp(r'^(\d{3})(\d{4})$');

  // 2. Sử dụng replaceAllMapped
  // Nó tìm kiếm chuỗi khớp với regex và cho phép bạn
  // xây dựng chuỗi thay thế dựa trên các nhóm đã bắt.
  String formattedString = input.replaceAllMapped(regex, (Match match) {
    // match.group(1) là '123'
    // match.group(2) là '4567'
    return '${match.group(1)}-${match.group(2)}';
  });

  // 3. Trả về kết quả
  // Nếu chuỗi đầu vào không khớp (ví dụ: '12345'), 
  // replaceAllMapped sẽ không thay thế gì cả, 
  // và chuỗi gốc sẽ được trả về.
  return formattedString;
}

void main() {
  String input = '1234567';
  String result = formatNumber(input);
  print(result); // Output: 123-4567

  String badInput = '12345';
  String badResult = formatNumber(badInput);
  print(badResult); // Output: 12345 (vì không khớp regex)
}
```
<iframe style="width: 100%; height: 500px" src="https://dartpad.dev/?id=b4dde15e880b37782fbfb30ebb33d500?theme=light"></iframe>

```run-dartpad:id=[b4dde15e880b37782fbfb30ebb33d500]:mode-flutter
```
