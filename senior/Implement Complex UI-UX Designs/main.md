# Implement Complex UI/UX Designs trong Flutter — Góc nhìn Senior

Đây là một trong những kỳ vọng cốt lõi với senior Flutter developer: biến design phức tạp thành code chất lượng production, đảm bảo 3 trụ cột — **responsiveness, accessibility, cross-platform consistency**. Mình sẽ phân tích từng phần.

---

## 1. Responsiveness — Adaptive & Responsive Layout

Ở level senior, responsiveness không chỉ là "co giãn được" mà là **thiết kế hệ thống layout có chiến lược**.

**a. Phân biệt Responsive vs Adaptive**

Responsive là UI co giãn liên tục theo kích thước (fluid). Adaptive là UI thay đổi layout hoàn toàn khi vượt qua breakpoint. Senior developer cần biết khi nào dùng cái nào — và thường là kết hợp cả hai.

**b. Các kỹ thuật cụ thể**

`MediaQuery` là công cụ cơ bản nhất, nhưng senior developer sẽ tránh gọi `MediaQuery.of(context)` tràn lan vì nó gây rebuild không cần thiết. Thay vào đó:

- Dùng `MediaQuery.sizeOf(context)` hoặc `MediaQuery.viewInsetsOf(context)` (Flutter 3.10+) để chỉ listen đúng property cần thiết, giảm unnecessary rebuild.
- Dùng `LayoutBuilder` khi cần responsive theo **parent constraint** thay vì screen size — đây là điểm nhiều mid-level hay nhầm.
- `FractionallySizedBox`, `Flex`, `Expanded`, `Flexible` — hiểu rõ cách `flex factor` hoạt động trong `Row`/`Column` và khi nào nên dùng `IntrinsicHeight`/`IntrinsicWidth` (cùng trade-off performance của chúng).

**c. Breakpoint system**

Senior developer thường xây dựng một breakpoint system riêng:

```dart
enum ScreenType { mobile, tablet, desktop }

ScreenType getScreenType(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w < 600) return ScreenType.mobile;
  if (w < 1200) return ScreenType.tablet;
  return ScreenType.desktop;
}
```

Kết hợp với pattern như `ResponsiveBuilder` hoặc dùng package `responsive_framework` khi project lớn. Điều quan trọng là **breakpoint phải được define ở một chỗ duy nhất** và consistent xuyên suốt app.

**d. Text scaling**

Không hardcode font size mà dùng `Theme.of(context).textTheme` kết hợp xử lý `MediaQuery.textScaleFactorOf(context)` — đặc biệt quan trọng khi user set font lớn ở system settings. Senior developer sẽ test app ở text scale 1.0, 1.5, 2.0 để đảm bảo layout không bị vỡ.

---

## 2. Accessibility (a11y) — Không phải "nice to have"

Đây là phần nhiều developer bỏ qua nhất, nhưng với senior thì đây là **non-negotiable**.

**a. Semantics tree**

Flutter render UI qua 3 tree: Widget → Element → RenderObject. Nhưng còn tree thứ 4 ít người chú ý: **Semantics tree** — đây là thứ screen reader (TalkBack/VoiceOver) đọc.

Mỗi widget có thể contribute vào semantics tree. Khi widget tự vẽ bằng `CustomPaint` hoặc dùng `GestureDetector` trên `Container`, nó **mặc định invisible với screen reader**. Senior developer phải wrap bằng `Semantics` widget:

```dart
Semantics(
  label: 'Nút thêm vào giỏ hàng',
  button: true,
  child: GestureDetector(
    onTap: _addToCart,
    child: CustomCartIcon(),
  ),
)
```

**b. Các checklist cụ thể**

- **Focus management**: Đảm bảo `FocusTraversalGroup` và `FocusTraversalOrder` hợp lý — user dùng keyboard/switch control phải navigate được logic.
- **Contrast ratio**: Tối thiểu 4.5:1 cho text thường, 3:1 cho text lớn (WCAG AA). Senior developer integrate check này vào design review.
- **Touch target**: Minimum 48x48 dp theo Material guidelines. Dùng `SizedBox` hoặc `padding` để đảm bảo, đặc biệt với icon button nhỏ.
- **excludeFromSemantics**: Biết khi nào dùng — ví dụ decorative image không cần screen reader đọc.
- **SemanticsService.announce()**: Dùng để thông báo dynamic content change (snackbar, loading state) cho screen reader.

**c. Testing a11y**

Flutter có `flutter test --accessibility` và package `accessibility_tools` overlay trực tiếp lên app để highlight vấn đề. Senior developer tích hợp vào CI/CD.

---

## 3. Cross-Platform Consistency — "Write once" không có nghĩa "Test once"

Flutter chạy trên iOS, Android, Web, macOS, Windows, Linux. Senior developer hiểu rằng **consistent không có nghĩa identical** — mà là đảm bảo trải nghiệm đúng kỳ vọng trên mỗi platform.

**a. Platform-aware UI**

Dùng `Platform.isIOS`, `Platform.isAndroid` hoặc tốt hơn là `Theme.of(context).platform` để quyết định behavior:

- iOS user kỳ vọng swipe-back navigation, `CupertinoPageRoute` transition. Android user quen Material transition.
- Date picker, dialog, scroll physics — mỗi platform có convention riêng. `ScrollPhysics` mặc định của Flutter đã handle (BouncingScrollPhysics trên iOS, ClampingScrollPhysics trên Android), nhưng custom scroll phải tự xử lý.

Senior developer thường tạo **platform-adaptive widget layer**:

```dart
Widget adaptiveDialog({required Widget child}) {
  if (Platform.isIOS) return CupertinoAlertDialog(...);
  return AlertDialog(...);
}
```

Hoặc dùng pattern phức tạp hơn với `PlatformWidget` abstract class.

**b. Rendering differences**

Đây là phần "pain" thực sự:

- **Font rendering**: System font khác nhau giữa platform. San Francisco (iOS) vs Roboto (Android) — cùng font size nhưng visual weight khác nhau. Senior developer dùng `.letterSpacing`, `.height` trong `TextStyle` để fine-tune.
- **Pixel density**: `devicePixelRatio` khác nhau → asset phải cung cấp đủ 1x, 2x, 3x. Dùng SVG (`flutter_svg`) khi có thể để tránh vấn đề này.
- **Web-specific**: Flutter Web render qua CanvasKit hoặc HTML renderer. CanvasKit pixel-perfect nhưng nặng (~2MB). HTML renderer nhẹ hơn nhưng text rendering khác biệt. Senior developer chọn renderer phù hợp với use case và hiểu trade-off.
- **Safe area**: Notch, dynamic island (iOS), camera cutout (Android), status bar height — tất cả phải handle qua `SafeArea` và `MediaQuery.viewPaddingOf(context)`.

**c. Input paradigm**

Trên mobile là touch. Trên desktop/web là mouse + keyboard. Senior developer phải xử lý:

- Hover state (chỉ desktop/web) — dùng `MouseRegion` hoặc `InkWell` với `hoverColor`.
- Keyboard shortcut — dùng `Shortcuts` + `Actions` widget.
- Right-click context menu trên desktop.
- Scroll behavior: mouse wheel vs touch scroll vs trackpad.

---

## 4. Kiến trúc code cho complex UI

Senior developer không chỉ "làm được" mà phải làm **maintainable**:

- **Tách UI thành small, reusable widget** — mỗi widget nên có single responsibility. Tránh widget God-class hàng nghìn dòng.
- **Custom RenderObject**: Khi `Stack`, `Row`, `Column` không đủ — senior developer biết khi nào cần viết custom layout bằng `MultiChildRenderObjectWidget`. Ví dụ: circular layout, overlapping card layout phức tạp.
- **CustomPainter & Canvas API**: Cho animation phức tạp, chart, custom shape — hiểu `shouldRepaint`, dùng `RepaintBoundary` để isolate repaint area.
- **Sliver-based layout**: Hiểu sâu `CustomScrollView`, `SliverPersistentHeader`, `SliverLayoutBuilder` cho scroll effect phức tạp (parallax, sticky header, collapsing toolbar).

---

## Tổng kết

Với senior Flutter developer, "implement complex UI/UX" nghĩa là:

Bạn không chỉ biến Figma thành pixel — bạn xây dựng một **hệ thống UI có khả năng scale**, chạy mượt trên mọi device, accessible cho mọi user, và consistent trên mọi platform. Bạn hiểu trade-off của từng quyết định kỹ thuật và biết khi nào cần dùng giải pháp đơn giản, khi nào cần custom sâu.

Bạn muốn mình đi sâu hơn vào phần nào — ví dụ Sliver internals, custom RenderObject, hay testing strategy cho responsive UI?
