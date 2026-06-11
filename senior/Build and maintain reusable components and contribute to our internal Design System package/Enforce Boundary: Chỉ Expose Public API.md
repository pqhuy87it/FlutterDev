# Enforce Boundary: Chỉ Expose Public API

## 1. Vấn đề thực tế

Giả sử bạn có Design System package với cấu trúc:

```
packages/design_system/lib/
  src/
    tokens/
      colors.dart          → AppColors
      spacing.dart         → AppSpacing
    helpers/
      color_utils.dart     → darken(), lighten(), hexToColor()
      responsive.dart      → breakpointOf()
    components/
      button/
        app_button.dart           → AppButton (public)
        button_style_resolver.dart → ButtonStyleResolver (internal logic)
        button_animation.dart      → ButtonPulseAnimation (internal logic)
      text_field/
        app_text_field.dart        → AppTextField (public)
        input_validator.dart       → InputBorderBuilder (internal logic)
  design_system.dart       → barrel file (export)
```

### ❌ Không có boundary — App dev import bừa

```dart
// Feature code trong app
import 'package:design_system/src/helpers/color_utils.dart';
import 'package:design_system/src/components/button/button_style_resolver.dart';
import 'package:design_system/src/components/button/button_animation.dart';

class ProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dùng trực tiếp internal helper
    final bgColor = darken(AppColors.brand, 0.2);

    // Dùng trực tiếp internal class
    final style = ButtonStyleResolver.resolve(
      variant: AppButtonVariant.primary,
      size: AppButtonSize.md,
      context: context,
    );

    // Dùng trực tiếp internal animation
    return ButtonPulseAnimation(child: Container(/* ... */));
  }
}
```

**Hậu quả:** Tuần sau, Design System team refactor `ButtonStyleResolver` → đổi tên method, đổi params, thay bằng class mới. Kết quả:

```
// 💥 50 files trong app bị break vì import trực tiếp internal class
// Design System team không thể refactor tự do
// Mỗi lần sửa internal → phải check toàn bộ app code
```

---

## 2. Dart Package Visibility — Cơ chế enforcement

Dart có **quy ước mạnh** (và từ Dart 2.19+ có **lint rule chính thức**) về thư mục `src/`:

```
lib/
  src/           ← PRIVATE: chỉ code trong package này được import
    anything.dart

  design_system.dart  ← PUBLIC: file export, app code import từ đây
```

**Quy tắc:** Code bên ngoài package **không được import trực tiếp** bất kỳ file nào trong `lib/src/`. Chỉ được import các file nằm trực tiếp trong `lib/` (barrel files).

```dart
// ✅ Hợp lệ — import barrel file
import 'package:design_system/design_system.dart';

// ❌ Vi phạm — import trực tiếp file trong src/
import 'package:design_system/src/helpers/color_utils.dart';
import 'package:design_system/src/components/button/button_style_resolver.dart';
```

### Enforcement bằng Lint Rule

```yaml
# packages/design_system/analysis_options.yaml
linter:
  rules:
    # Dart built-in: cảnh báo khi import src/ của package khác
    implementation_imports: true  # ← BẬT RULE NÀY
```

Khi app dev vô tình import `src/`:

```
warning: Don't import implementation files from another package.
(implementation_imports at lib/features/product/product_card.dart:3)
```

Nếu muốn **strict hơn** — biến warning thành error để CI fail:

```yaml
# App-level analysis_options.yaml
analyzer:
  errors:
    implementation_imports: error  # ← CI sẽ fail
```

---

## 3. Barrel File — Cánh cổng duy nhất

Barrel file là file duy nhất mà app code được phép import. Nó **chọn lọc** export những gì public:

```dart
// packages/design_system/lib/design_system.dart
// ═══════════════════════════════════════════════
// Đây là PUBLIC API duy nhất của package
// Mọi thứ KHÔNG có ở đây = PRIVATE = không ai được dùng
// ═══════════════════════════════════════════════

// ---- Tokens ----
export 'src/tokens/colors.dart';         // AppColors
export 'src/tokens/spacing.dart';        // AppSpacing
export 'src/tokens/typography.dart';     // AppTypography

// ---- Theme ----
export 'src/theme/app_theme.dart';       // AppTheme, AppTextFieldTheme, ...

// ---- Components ----
export 'src/components/button/app_button.dart';
// ⛔ KHÔNG export button_style_resolver.dart
// ⛔ KHÔNG export button_animation.dart

export 'src/components/text_field/app_text_field.dart';
// ⛔ KHÔNG export input_validator.dart

export 'src/components/card/app_card.dart';
export 'src/components/dialog/app_dialog.dart';
export 'src/components/badge/app_badge.dart';

// ---- Enums mà app cần biết ----
export 'src/components/button/app_button_variant.dart'; // AppButtonVariant, AppButtonSize
```

### Kết quả — App code chỉ thấy những gì được phép

```dart
// Trong app code
import 'package:design_system/design_system.dart';

// ✅ Có thể dùng — đã được export
AppButton.primary(onPressed: () {}, child: Text('OK'));
AppTextField(label: 'Email');
AppColors.brand;
AppSpacing.md;
AppButtonVariant.primary;

// ❌ Không thể dùng — không được export
ButtonStyleResolver.resolve(...);   // compile error: undefined
ButtonPulseAnimation(...);          // compile error: undefined
darken(color, 0.2);                // compile error: undefined
InputBorderBuilder(...);           // compile error: undefined
```

---

## 4. `show` / `hide` — Kiểm soát chi tiết hơn

Khi một file chứa **cả public lẫn internal** class, dùng `show` / `hide` để lọc:

```dart
// Ví dụ: app_button.dart chứa cả AppButton và _ButtonInternalHelper
// Nhưng vì _ButtonInternalHelper dùng underscore prefix → đã private ở Dart level

// Ví dụ thực tế hơn: file chứa nhiều class, chỉ muốn export một số
// src/components/dialog/app_dialog.dart chứa:
//   - AppDialog           → public
//   - DialogTransition    → public (dùng cho custom animation)
//   - DialogLayoutHelper  → internal

// Barrel file:
export 'src/components/dialog/app_dialog.dart'
    show AppDialog, DialogTransition;
    // DialogLayoutHelper không được export → app code không thấy

// Hoặc ngược lại:
export 'src/components/dialog/app_dialog.dart'
    hide DialogLayoutHelper;
    // export tất cả TRỪ DialogLayoutHelper
```

---

## 5. Multi-layer barrel — Package lớn

Khi Design System phình to, một barrel file quá dài. Tách thành **sub-barrels**:

```
packages/design_system/lib/
  src/
    tokens/...
    components/
      button/...
      text_field/...
      card/...
      dialog/...
      bottom_sheet/...
      // ... 30+ components

  // ---- Sub-barrels (optional, cho import có chọn lọc) ----
  tokens.dart
  components.dart
  theme.dart

  // ---- Main barrel (import tất cả) ----
  design_system.dart
```

```dart
// lib/tokens.dart — sub-barrel cho tokens
export 'src/tokens/colors.dart';
export 'src/tokens/spacing.dart';
export 'src/tokens/typography.dart';
export 'src/tokens/radii.dart';

// lib/components.dart — sub-barrel cho components
export 'src/components/button/app_button.dart';
export 'src/components/button/app_button_variant.dart';
export 'src/components/text_field/app_text_field.dart';
export 'src/components/card/app_card.dart';
export 'src/components/dialog/app_dialog.dart' show AppDialog, DialogTransition;
// ...

// lib/theme.dart — sub-barrel cho theme extensions
export 'src/theme/app_theme.dart';
export 'src/theme/app_text_field_theme.dart';
export 'src/theme/app_button_theme.dart';

// lib/design_system.dart — main barrel, re-export tất cả
export 'tokens.dart';
export 'components.dart';
export 'theme.dart';
```

App code giờ có **hai lựa chọn**:

```dart
// Cách 1: Import tất cả (tiện, nhưng namespace lớn)
import 'package:design_system/design_system.dart';

// Cách 2: Import theo category (tree-shake friendly, rõ ràng hơn)
import 'package:design_system/tokens.dart';
import 'package:design_system/components.dart';
```

---

## 6. Ví dụ thực tế: Refactor không break app

Đây là lý do chính tại sao boundary quan trọng:

### Trước refactor

```dart
// src/components/button/button_style_resolver.dart (INTERNAL)
class ButtonStyleResolver {
  static ButtonStyle resolve({
    required AppButtonVariant variant,
    required AppButtonSize size,
    required BuildContext context,
  }) {
    // ... logic phức tạp ...
  }
}
```

### Sau refactor — đổi hoàn toàn implementation

```dart
// ĐỔI TÊN FILE
// src/components/button/button_theme_builder.dart (INTERNAL)

// ĐỔI TÊN CLASS
class ButtonThemeBuilder {
  final BuildContext context;

  // ĐỔI TỪ static method SANG instance method
  ButtonThemeBuilder(this.context);

  // ĐỔI API HOÀN TOÀN
  ButtonStyle build(AppButtonVariant variant, [AppButtonSize? size]) {
    size ??= AppButtonSize.md;
    // ... logic mới, tốt hơn ...
  }
}
```

```dart
// src/components/button/app_button.dart cập nhật internal import
// TRƯỚC:
// final style = ButtonStyleResolver.resolve(variant: ..., size: ..., context: ...);

// SAU:
// final style = ButtonThemeBuilder(context).build(variant, size);
```

**Kết quả:**

```
APP CODE: KHÔNG THAY ĐỔI GÌ CẢ
─────────────────────────────────
// Vẫn hoạt động y hệt, vì app chỉ dùng public API
AppButton.primary(
  onPressed: () => submit(),
  child: Text('Gửi'),
)

// App code không biết và KHÔNG CẦN BIẾT rằng
// bên trong đã đổi từ ButtonStyleResolver sang ButtonThemeBuilder
```

Nếu **không có boundary**, mọi file trong app import `ButtonStyleResolver` sẽ **break ngay lập tức**.

---

## 7. `@visibleForTesting` — Ngoại lệ có kiểm soát

Đôi khi cần test internal class từ bên ngoài `src/`. Dart cung cấp annotation:

```dart
// src/components/button/button_theme_builder.dart
import 'package:meta/meta.dart';

@visibleForTesting // ← chỉ test code được import, app code thì warning
class ButtonThemeBuilder {
  // ...
}
```

Và tạo một **test-only barrel**:

```dart
// lib/testing.dart — CHỈ DÙNG TRONG TEST
/// Exports internal classes for unit testing.
/// ⚠️ DO NOT import this in production code.
export 'src/components/button/button_theme_builder.dart';
export 'src/helpers/color_utils.dart';
```

```dart
// Trong test file
import 'package:design_system/testing.dart'; // ✅ OK cho test

// Trong app code
import 'package:design_system/testing.dart'; // ⚠️ Lint warning
```

---

## 8. Tổng kết

```
                    ┌────────────────────────────────┐
                    │          APP CODE              │
                    │                                │
                    │  import 'design_system.dart';  │
                    └───────────────┬────────────────┘
                                    │
                         chỉ thấy public API
                                    │
                    ┌───────────────▼────────────────┐
                    │     design_system.dart         │
                    │     (barrel file)              │
                    │                                │
                    │  export AppButton              │
                    │  export AppTextField           │
                    │  export AppColors              │
                    │  export AppSpacing             │
                    │                                │
                    │  ⛔ ButtonStyleResolver        │
                    │  ⛔ ButtonPulseAnimation       │
                    │  ⛔ InputBorderBuilder         │
                    │  ⛔ darken() / lighten()       │
                    └───────────────┬────────────────┘
                                    │
                         boundary (src/)
                                    │
                    ┌───────────────▼────────────────┐
                    │          lib/src/              │
                    │                                │
                    │  Tự do refactor bên trong      │
                    │  Đổi tên, đổi API, xoá class   │
                    │  → App code KHÔNG bị ảnh hưởng │
                    └────────────────────────────────┘
```

Nói ngắn gọn, boundary tạo ra một **contract** giữa Design System team và App team: "Các bạn chỉ dùng những gì chúng tôi export. Đổi lại, chúng tôi cam kết những thứ đã export sẽ ổn định, có versioning, có changelog. Còn bên trong `src/`, chúng tôi được tự do refactor bất kỳ lúc nào mà không làm phiền ai."
