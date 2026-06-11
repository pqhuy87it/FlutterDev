# Build and Maintain Reusable Components & Contribute to Internal Design System Package

Đây là một responsibility rất quan trọng và thể hiện rõ kỳ vọng ở level **Senior**. Mình sẽ phân tích từng khía cạnh.

---

## 1. Reusable Components — Không chỉ là "tách widget ra"

Ở level senior, "reusable" không đơn giản là extract một widget thành class riêng. Nó đòi hỏi tư duy thiết kế API cho component đó.

**Ví dụ thực tế:** Thay vì tạo một `PrimaryButton` cứng nhắc, bạn cần thiết kế một `AppButton` với API linh hoạt:

```dart
// ❌ Junior approach — quá cứng, không mở rộng được
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  // ...
}

// ✅ Senior approach — composable, flexible, theme-aware
class AppButton extends StatelessWidget {
  final Widget child; // không giới hạn chỉ text
  final AppButtonVariant variant; // primary, secondary, ghost, destructive
  final AppButtonSize size; // sm, md, lg
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onPressed;

  // Factory constructors cho các use case phổ biến
  factory AppButton.primary({...});
  factory AppButton.outline({...});
  factory AppButton.icon({required IconData icon, ...});
}
```

**Những nguyên tắc senior cần nắm:**

- **Composition over inheritance**: Dùng `child`/`builder` pattern thay vì tạo hàng chục subclass.
- **Sensible defaults, full overridability**: Mặc định phải hợp lý, nhưng cho phép override khi cần.
- **Theme-aware**: Component phải tự động adapt theo `ThemeData`, không hardcode color/spacing.
- **Accessibility built-in**: `Semantics`, `ExcludeSemantics`, đủ contrast ratio, support screen reader.

---

## 2. "Maintain" — Phần khó nhất mà ít ai nói

Maintain bao gồm:

- **Versioning & backward compatibility**: Khi sửa component, bạn không được break app đang dùng nó. Dùng `@Deprecated` annotation, migration guide, semantic versioning.
- **Regression prevention**: Viết **golden tests** (snapshot tests) cho mỗi component state, **widget tests** cho interaction logic.
- **Documentation**: Mỗi component cần có dartdoc rõ ràng, ví dụ usage, và ideally một **Widgetbook** hoặc **Storybook-like catalog** để team browse visual.

```dart
/// A themed button component from the Design System.
///
/// ### Usage:
/// ```dart
/// AppButton.primary(
///   onPressed: () => doSomething(),
///   child: Text('Submit'),
/// )
/// ```
///
/// See also:
/// - [AppButtonVariant] for available styles
/// - [AppIconButton] for icon-only buttons
class AppButton extends StatelessWidget { ... }
```

---

## 3. Internal Design System Package — Tại sao lại là "package"?

Ở level senior, Design System không nằm chung trong `/lib/widgets/`. Nó được tách thành **một Dart package riêng biệt**, thường nằm trong monorepo hoặc private pub repository.

**Cấu trúc điển hình:**

```
packages/
  design_system/
    lib/
      src/
        tokens/          # spacing, colors, typography, radii
        foundations/      # theme data, breakpoints
        components/       # button, input, card, modal, ...
        patterns/         # form layouts, list tiles, ...
      design_system.dart  # barrel export
    test/
    widgetbook/           # visual catalog
    pubspec.yaml          # versioned independently
    CHANGELOG.md
```

**Tại sao tách package?**

- **Enforce boundary**: App code không thể import internal implementation. Chỉ expose public API.
- **Reuse across projects**: Nếu công ty có nhiều app (customer app, admin app, internal tools), tất cả dùng chung.
- **Independent versioning**: Design System có release cycle riêng, team có thể pin version ổn định.
- **Faster CI**: Chỉ chạy test của package khi package thay đổi.

---

## 4. "Contribute" — Senior không chỉ dùng, mà định hình

Contribute ở đây nghĩa là:

- **Collaborate với Designer**: Review Figma tokens, đảm bảo design token mapping 1:1 giữa Figma và code (`ColorTokens.brandPrimary` ↔ Figma variable).
- **Propose architecture decisions**: Chọn pattern cho theming (ThemeExtension vs. InheritedWidget custom), state trong component (controlled vs. uncontrolled), animation strategy.
- **Code review**: Review PR của các thành viên khác khi họ contribute component mới, đảm bảo consistency.
- **Evangelize adoption**: Giúp team hiểu khi nào dùng Design System component thay vì tự viết, viết migration guide khi có breaking change.

---

## 5. Kỹ năng kỹ thuật cần thiết

| Kỹ năng | Tại sao |
|---|---|
| `ThemeExtension<T>` | Mở rộng theme cho custom tokens |
| Golden / snapshot testing | Đảm bảo visual regression |
| Widgetbook / Catalog | Visual documentation |
| Dart package structure | Tách module đúng cách |
| `CustomPainter`, `RenderObject` | Khi cần component phức tạp vượt quá widget tree |
| Semantic versioning | Quản lý breaking changes |

---

## Tóm lại

Requirement này kỳ vọng senior **không chỉ code feature**, mà phải tư duy ở tầng **platform/infrastructure** — xây dựng nền tảng UI mà cả team dựa vào. Nó đòi hỏi cả kỹ năng kỹ thuật sâu (custom painting, package architecture, testing strategy) lẫn kỹ năng mềm (collaboration với designer, documentation, mentoring team members).

Bạn muốn mình đi sâu hơn vào phần nào không? Ví dụ cách setup Widgetbook, hay cách thiết kế Design Tokens trong Flutter?
