Okay, mình sẽ build từ đầu một `AppButton` hoàn chỉnh với factory constructors.

## Vấn đề cốt lõi: Tại sao cần Factory Constructor ở đây?

Factory constructor cho phép tạo **named entry points** với các preset khác nhau, nhưng tất cả đều return cùng một `AppButton` instance. Team chỉ cần gọi `AppButton.primary(...)` mà không cần nhớ phải set những param nào.

## Full Implementation

```dart
import 'package:flutter/material.dart';

// ============================================
// 1. ENUMS — Định nghĩa các variant và size
// ============================================

enum AppButtonVariant { primary, secondary, outline, ghost, destructive }

enum AppButtonSize { sm, md, lg }

// ============================================
// 2. MAIN CLASS
// ============================================

class AppButton extends StatelessWidget {
  final Widget child;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onPressed;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? width; // null = hug content, double.infinity = full width

  // ---- Primary constructor (đầy đủ mọi param) ----
  const AppButton({
    super.key,
    required this.child,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.isDisabled = false,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
  });

  // ============================================
  // 3. FACTORY CONSTRUCTORS
  // ============================================

  /// Nút chính — dùng cho CTA (Call To Action)
  /// ```dart
  /// AppButton.primary(
  ///   onPressed: () => submit(),
  ///   child: Text('Xác nhận'),
  /// )
  /// ```
  factory AppButton.primary({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    AppButtonSize size = AppButtonSize.md,
    Widget? prefixIcon,
    Widget? suffixIcon,
    double? width,
  }) {
    return AppButton(
      key: key,
      variant: AppButtonVariant.primary, // ← preset cố định
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      onPressed: onPressed,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      width: width,
      child: child,
    );
  }

  /// Nút phụ — ít nổi bật hơn primary
  factory AppButton.secondary({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    AppButtonSize size = AppButtonSize.md,
    Widget? prefixIcon,
    double? width,
  }) {
    return AppButton(
      key: key,
      variant: AppButtonVariant.secondary,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      onPressed: onPressed,
      prefixIcon: prefixIcon,
      width: width,
      child: child,
    );
  }

  /// Nút viền — cho các action ít quan trọng
  factory AppButton.outline({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    AppButtonSize size = AppButtonSize.md,
    double? width,
  }) {
    return AppButton(
      key: key,
      variant: AppButtonVariant.outline,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      onPressed: onPressed,
      width: width,
      child: child,
    );
  }

  /// Nút nguy hiểm — xoá, huỷ, v.v.
  factory AppButton.destructive({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    bool isLoading = false,
    AppButtonSize size = AppButtonSize.md,
    double? width,
  }) {
    return AppButton(
      key: key,
      variant: AppButtonVariant.destructive,
      size: size,
      isLoading: isLoading,
      onPressed: onPressed,
      width: width,
      child: child,
    );
  }

  // ============================================
  // 4. STYLE RESOLUTION — Dựa trên variant + size
  // ============================================

  /// Lấy style tương ứng với variant hiện tại
  _AppButtonStyle _resolveStyle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return switch (variant) {
      AppButtonVariant.primary => _AppButtonStyle(
        background: colors.primary,
        foreground: colors.onPrimary,
        border: BorderSide.none,
      ),
      AppButtonVariant.secondary => _AppButtonStyle(
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
        border: BorderSide.none,
      ),
      AppButtonVariant.outline => _AppButtonStyle(
        background: Colors.transparent,
        foreground: colors.primary,
        border: BorderSide(color: colors.outline),
      ),
      AppButtonVariant.ghost => _AppButtonStyle(
        background: Colors.transparent,
        foreground: colors.primary,
        border: BorderSide.none,
      ),
      AppButtonVariant.destructive => _AppButtonStyle(
        background: colors.error,
        foreground: colors.onError,
        border: BorderSide.none,
      ),
    };
  }

  /// Lấy padding + font size theo size
  _AppButtonDimensions _resolveDimensions() {
    return switch (size) {
      AppButtonSize.sm => _AppButtonDimensions(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        fontSize: 12,
        iconSize: 14,
        loaderSize: 14,
        borderRadius: 6,
      ),
      AppButtonSize.md => _AppButtonDimensions(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        fontSize: 14,
        iconSize: 18,
        loaderSize: 16,
        borderRadius: 8,
      ),
      AppButtonSize.lg => _AppButtonDimensions(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        fontSize: 16,
        iconSize: 20,
        loaderSize: 18,
        borderRadius: 10,
      ),
    };
  }

  // ============================================
  // 5. BUILD
  // ============================================

  bool get _isInteractive => !isDisabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(context);
    final dimensions = _resolveDimensions();

    final effectiveForeground = isDisabled
        ? style.foreground.withValues(alpha: 0.5)
        : style.foreground;

    final effectiveBackground = isDisabled
        ? style.background.withValues(alpha: 0.5)
        : style.background;

    Widget buttonChild = DefaultTextStyle.merge(
      style: TextStyle(
        color: effectiveForeground,
        fontSize: dimensions.fontSize,
        fontWeight: FontWeight.w600,
      ),
      child: IconTheme.merge(
        data: IconThemeData(
          color: effectiveForeground,
          size: dimensions.iconSize,
        ),
        child: Row(
          mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox.square(
                  dimension: dimensions.loaderSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: effectiveForeground,
                  ),
                ),
              )
            else if (prefixIcon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: prefixIcon!,
              ),
            // Dùng Flexible để text có thể ellipsis nếu quá dài
            Flexible(child: child),
            if (suffixIcon != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: suffixIcon!,
              ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: _isInteractive,
      child: SizedBox(
        width: width,
        child: Material(
          color: effectiveBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dimensions.borderRadius),
            side: style.border,
          ),
          child: InkWell(
            onTap: _isInteractive ? onPressed : null,
            borderRadius: BorderRadius.circular(dimensions.borderRadius),
            child: Padding(
              padding: dimensions.padding,
              child: buttonChild,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// 6. INTERNAL DATA CLASSES (private)
// ============================================

class _AppButtonStyle {
  final Color background;
  final Color foreground;
  final BorderSide border;

  const _AppButtonStyle({
    required this.background,
    required this.foreground,
    required this.border,
  });
}

class _AppButtonDimensions {
  final EdgeInsets padding;
  final double fontSize;
  final double iconSize;
  final double loaderSize;
  final double borderRadius;

  const _AppButtonDimensions({
    required this.padding,
    required this.fontSize,
    required this.iconSize,
    required this.loaderSize,
    required this.borderRadius,
  });
}
```

## Cách sử dụng

```dart
// CTA chính
AppButton.primary(
  onPressed: () => controller.submit(),
  child: Text('Đăng ký ngay'),
)

// Full width + loading
AppButton.primary(
  onPressed: () => controller.submit(),
  isLoading: true,
  width: double.infinity,
  child: Text('Đang xử lý...'),
)

// Outline + prefix icon
AppButton.outline(
  onPressed: () => controller.goBack(),
  size: AppButtonSize.sm,
  prefixIcon: Icon(Icons.arrow_back),
  child: Text('Quay lại'),
)

// Destructive
AppButton.destructive(
  onPressed: () => showDeleteConfirmation(),
  child: Text('Xoá tài khoản'),
)

// Dùng primary constructor trực tiếp khi cần custom hoàn toàn
AppButton(
  variant: AppButtonVariant.ghost,
  size: AppButtonSize.lg,
  onPressed: () {},
  child: Text('Custom'),
)
```

## Tại sao cách này tốt hơn ở level Senior?

**Factory constructor vs. Subclass:**

```dart
// ❌ Subclass approach — mỗi variant một class → class explosion
class PrimaryButton extends AppButton { ... }
class SecondaryButton extends AppButton { ... }
class OutlineButton extends AppButton { ... }
// 5 variants × 3 sizes = quản lý rất nhiều class

// ✅ Factory approach — một class duy nhất, nhiều entry points
AppButton.primary(...)   // chỉ là shorthand cho AppButton(variant: primary)
AppButton.secondary(...) // cùng class, cùng logic, khác preset
```

**Factory constructor vs. Static method:**

```dart
// static method KHÔNG THỂ dùng const và không enforce return type
static AppButton primary(...) => AppButton(...); // works nhưng...

// factory constructor là PHẦN CỦA constructor family
// → IDE hiển thị cùng nhóm khi gõ "AppButton."
// → Dart analyzer hiểu đây là constructor, không phải method
factory AppButton.primary(...) => AppButton(...); // ✅ idiomatic Dart
```

Điểm mấu chốt: factory constructor **lock variant** lại (user không cần biết `AppButtonVariant` enum), nhưng vẫn cho phép tuỳ chỉnh mọi thứ khác như `size`, `isLoading`, `prefixIcon`. Đây là pattern **"opinionated defaults, full flexibility"** — signature thinking của senior developer.
