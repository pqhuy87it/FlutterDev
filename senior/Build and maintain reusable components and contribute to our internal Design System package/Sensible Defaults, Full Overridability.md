# Sensible Defaults, Full Overridability

## 1. Vấn đề thực tế

Khi xây Design System, bạn phải phục vụ **hai nhóm người dùng cùng lúc**:

- **90% use cases**: Dev muốn dùng nhanh, không cần config gì nhiều → cần **defaults hợp lý**
- **10% use cases**: Dev cần tuỳ biến sâu cho edge case → cần **override được mọi thứ**

Nếu thiếu defaults → mỗi lần dùng phải truyền 15 params → không ai muốn dùng. Nếu không cho override → gặp edge case là phải fork component hoặc viết từ đầu → Design System mất giá trị.

---

## 2. Ví dụ xấu — Hai thái cực

### ❌ Quá nhiều bắt buộc (No defaults)

```dart
// Dev phải truyền TẤT CẢ mỗi lần dùng — cực kỳ mệt
class AppTextField extends StatelessWidget {
  final String labelText;           // bắt buộc
  final TextStyle labelStyle;       // bắt buộc — sao không tự lấy từ theme?
  final Color borderColor;          // bắt buộc — sao không tự lấy từ theme?
  final double borderRadius;        // bắt buộc — sao phải truyền?
  final EdgeInsets contentPadding;  // bắt buộc — sao phải truyền?
  final Color cursorColor;          // bắt buộc — thực sự cần?
  final TextEditingController controller; // bắt buộc
  final bool obscureText;           // bắt buộc — mặc định false là đủ
  // ...

  const AppTextField({
    required this.labelText,
    required this.labelStyle,       // 😤 mỗi lần dùng đều phải set
    required this.borderColor,      // 😤
    required this.borderRadius,     // 😤
    required this.contentPadding,   // 😤
    required this.cursorColor,      // 😤
    required this.controller,
    required this.obscureText,      // 😤 99% trường hợp là false
  });
}

// Call site — quá dài, quá mệt, dev sẽ copy-paste sai
AppTextField(
  labelText: 'Email',
  labelStyle: TextStyle(fontSize: 14, color: Colors.grey),  // lặp lại ở mọi nơi
  borderColor: Color(0xFFE0E0E0),                           // lặp lại
  borderRadius: 8,                                           // lặp lại
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // lặp lại
  cursorColor: Colors.blue,                                  // lặp lại
  controller: _emailController,
  obscureText: false,                                        // 99% là false
)
```

### ❌ Quá cứng nhắc (No overridability)

```dart
// Mọi thứ đều hardcode — không thể tuỳ biến
class AppTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;

  const AppTextField({
    required this.labelText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      // 🔒 Mọi thứ hardcode cứng
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: 14, color: Colors.grey), // không đổi được
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),                // không đổi được
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(fontSize: 16),      // không đổi được
      cursorColor: Colors.blue,            // không đổi được
      keyboardType: TextInputType.text,    // không đổi được → nhập số thì sao?
      maxLines: 1,                         // không đổi được → textarea thì sao?
    );
  }
}

// Khi cần nhập password → không có cách nào set obscureText
// Khi cần textarea → không có cách nào set maxLines
// Khi cần search field → không có cách nào thêm prefix icon
// → Dev bypass Design System, tự viết TextField riêng → mất consistency
```

---

## 3. ✅ Cách làm đúng — Layer by Layer

Mình sẽ build một `AppTextField` hoàn chỉnh theo nguyên tắc **"dễ dùng ngay, tuỳ biến sâu khi cần"**.

### Tầng 1: Design Tokens — Single source of truth

```dart
/// Không hardcode giá trị trong component.
/// Tập trung tất cả vào tokens để dễ thay đổi global.
class AppTokens {
  // Spacing
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;

  // Radii
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;

  // Duration
  static const Duration animFast = Duration(milliseconds: 150);
}

/// Tokens dành riêng cho TextField,
/// extend từ ThemeExtension để có thể override per-theme.
class AppTextFieldTheme extends ThemeExtension<AppTextFieldTheme> {
  final TextStyle? labelStyle;
  final TextStyle? inputStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? fillColor;
  final double? borderRadius;
  final EdgeInsets? contentPadding;

  const AppTextFieldTheme({
    this.labelStyle,
    this.inputStyle,
    this.hintStyle,
    this.errorStyle,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
  });

  /// Giá trị mặc định — dùng khi không ai override
  factory AppTextFieldTheme.fallback() {
    return const AppTextFieldTheme(
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      inputStyle: TextStyle(fontSize: 16),
      hintStyle: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
      errorStyle: TextStyle(fontSize: 12, color: Color(0xFFD32F2F)),
      borderColor: Color(0xFFE0E0E0),
      focusedBorderColor: Color(0xFF1976D2),
      errorBorderColor: Color(0xFFD32F2F),
      fillColor: Color(0xFFFAFAFA),
      borderRadius: AppTokens.radiusMd,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTokens.spacingLg,
        vertical: AppTokens.spacingMd,
      ),
    );
  }

  // Required by ThemeExtension
  @override
  AppTextFieldTheme copyWith({/* tất cả params */}) { /* ... */ }

  @override
  AppTextFieldTheme lerp(AppTextFieldTheme? other, double t) { /* ... */ }
}
```

### Tầng 2: Component — Defaults thông minh, mọi thứ overridable

```dart
class AppTextField extends StatelessWidget {
  // ======== REQUIRED — chỉ những gì THỰC SỰ bắt buộc ========
  final String label;

  // ======== CORE — có defaults hợp lý ========
  final TextEditingController? controller;  // null → tự quản lý internal
  final String? hintText;
  final String? errorText;
  final bool obscureText;           // default: false
  final bool enabled;               // default: true
  final bool readOnly;              // default: false
  final int maxLines;               // default: 1
  final TextInputType keyboardType; // default: .text
  final TextInputAction? textInputAction;

  // ======== SLOTS — composition cho phần phức tạp ========
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefix;   // widget nằm trước text (VD: country code)
  final Widget? suffix;   // widget nằm sau text (VD: unit label)

  // ======== CALLBACKS ========
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final GestureTapCallback? onTap;

  // ======== OVERRIDES — cho 10% edge cases ========
  // Tất cả nullable → null nghĩa là "dùng default từ theme"
  final TextStyle? labelStyle;
  final TextStyle? inputStyle;
  final TextStyle? hintStyle;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? fillColor;
  final double? borderRadius;
  final EdgeInsets? contentPadding;
  final InputDecoration? decorationOverride; // escape hatch cuối cùng

  const AppTextField({
    super.key,
    // Required
    required this.label,
    // Core với defaults
    this.controller,
    this.hintText,
    this.errorText,
    this.obscureText = false,        // ← sensible default
    this.enabled = true,             // ← sensible default
    this.readOnly = false,           // ← sensible default
    this.maxLines = 1,               // ← sensible default
    this.keyboardType = TextInputType.text, // ← sensible default
    this.textInputAction,
    // Slots
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    // Callbacks
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    // Overrides (tất cả nullable)
    this.labelStyle,
    this.inputStyle,
    this.hintStyle,
    this.borderColor,
    this.focusedBorderColor,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
    this.decorationOverride,
  });

  @override
  Widget build(BuildContext context) {
    // ---- Resolve: instance override → theme → fallback ----
    final themeExt = Theme.of(context).extension<AppTextFieldTheme>();
    final fallback = AppTextFieldTheme.fallback();

    // Mỗi property đi qua 3 tầng ưu tiên:
    //   1. Instance override (truyền trực tiếp vào widget)
    //   2. Theme extension (set ở MaterialApp level)
    //   3. Hardcoded fallback (luôn có giá trị)
    final resolvedLabelStyle =
        labelStyle ?? themeExt?.labelStyle ?? fallback.labelStyle!;
    final resolvedInputStyle =
        inputStyle ?? themeExt?.inputStyle ?? fallback.inputStyle!;
    final resolvedHintStyle =
        hintStyle ?? themeExt?.hintStyle ?? fallback.hintStyle!;
    final resolvedBorderColor =
        borderColor ?? themeExt?.borderColor ?? fallback.borderColor!;
    final resolvedFocusedBorderColor =
        focusedBorderColor ?? themeExt?.focusedBorderColor ?? fallback.focusedBorderColor!;
    final resolvedFillColor =
        fillColor ?? themeExt?.fillColor ?? fallback.fillColor!;
    final resolvedRadius =
        borderRadius ?? themeExt?.borderRadius ?? fallback.borderRadius!;
    final resolvedPadding =
        contentPadding ?? themeExt?.contentPadding ?? fallback.contentPadding!;

    final hasError = errorText != null && errorText!.isNotEmpty;

    // ---- Build decoration ----
    final effectiveBorderColor = hasError
        ? (themeExt?.errorBorderColor ?? fallback.errorBorderColor!)
        : resolvedBorderColor;

    // decorationOverride là "escape hatch" — nếu có thì bỏ qua tất cả logic trên
    final decoration = decorationOverride ??
        InputDecoration(
          labelText: label,
          labelStyle: resolvedLabelStyle,
          hintText: hintText,
          hintStyle: resolvedHintStyle,
          errorText: errorText,
          errorStyle: themeExt?.errorStyle ?? fallback.errorStyle,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          prefix: prefix,
          suffix: suffix,
          filled: true,
          fillColor: enabled ? resolvedFillColor : resolvedFillColor.withValues(alpha: 0.5),
          contentPadding: resolvedPadding,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(resolvedRadius),
            borderSide: BorderSide(color: effectiveBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(resolvedRadius),
            borderSide: BorderSide(color: effectiveBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(resolvedRadius),
            borderSide: BorderSide(color: resolvedFocusedBorderColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(resolvedRadius),
            borderSide: BorderSide(
              color: themeExt?.errorBorderColor ?? fallback.errorBorderColor!,
            ),
          ),
        );

    return TextField(
      controller: controller,
      decoration: decoration,
      style: resolvedInputStyle,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      onTap: onTap,
    );
  }
}
```

---

## 4. Call site — Sự khác biệt rõ rệt

```dart
// ═══════════════════════════════════════
// 90% CASES — Dùng defaults, cực kỳ ngắn
// ═══════════════════════════════════════

// Đơn giản nhất — chỉ cần label
AppTextField(label: 'Họ và tên')

// Email
AppTextField(
  label: 'Email',
  hintText: 'you@example.com',
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icon(Icons.email_outlined),
)

// Password
AppTextField(
  label: 'Mật khẩu',
  obscureText: true,
  suffixIcon: IconButton(
    icon: Icon(Icons.visibility_off),
    onPressed: toggleVisibility,
  ),
)

// Search
AppTextField(
  label: 'Tìm kiếm',
  prefixIcon: Icon(Icons.search),
  suffixIcon: IconButton(
    icon: Icon(Icons.clear),
    onPressed: () => controller.clear(),
  ),
)

// Textarea
AppTextField(
  label: 'Ghi chú',
  maxLines: 5,
  hintText: 'Nhập ghi chú...',
)

// ═══════════════════════════════════════
// 10% CASES — Override khi cần
// ═══════════════════════════════════════

// Override border color cho dark section
AppTextField(
  label: 'Coupon',
  borderColor: Colors.white54,           // ← override cụ thể
  focusedBorderColor: Colors.amberAccent, // ← override cụ thể
  fillColor: Colors.white10,              // ← override cụ thể
  inputStyle: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 4),
)

// Escape hatch — hoàn toàn custom decoration
AppTextField(
  label: 'Special',
  decorationOverride: InputDecoration(
    // tự do 100%, bỏ qua mọi logic resolve
    // dùng khi Design System không cover được edge case
  ),
)
```

---

## 5. Hệ thống 3 tầng ưu tiên — Cốt lõi của pattern

```
Mỗi property được resolve qua 3 tầng:

┌─────────────────────────────────────────────────────────┐
│  Ưu tiên 1: Instance Override                           │
│  AppTextField(borderColor: Colors.red)                  │
│  → Khi DEV cần override cho MỘT chỗ cụ thể              │
│                                                         │
│  ↓ nếu null                                             │
├─────────────────────────────────────────────────────────┤
│  Ưu tiên 2: ThemeExtension                              │
│  Theme(extensions: [AppTextFieldTheme(borderColor: ..)])│
│  → Khi TEAM muốn thay đổi cho TOÀN APP                  │
│                                                         │
│  ↓ nếu null                                             │
├─────────────────────────────────────────────────────────┤
│  Ưu tiên 3: Hardcoded Fallback                          │
│  AppTextFieldTheme.fallback()                           │
│  → Giá trị an toàn, LUÔN có, không bao giờ null         │
└─────────────────────────────────────────────────────────┘
```

**Tại sao cần 3 tầng?**

- **Tầng 3 (Fallback)**: Đảm bảo component **không bao giờ crash** dù không config gì. Dev mới vào team gọi `AppTextField(label: 'Name')` là chạy ngay.
- **Tầng 2 (Theme)**: Khi rebrand hoặc support dark mode, chỉ cần thay `AppTextFieldTheme` trong `ThemeData` → tất cả TextField trong app đổi theo, **zero code change** ở call site.
- **Tầng 1 (Instance)**: Cho trường hợp đặc biệt — một màn hình có background tối cần border sáng hơn, chỉ override chỗ đó.

```dart
// Tầng 2 — Set global theme, áp dụng toàn app
MaterialApp(
  theme: ThemeData(
    extensions: [
      AppTextFieldTheme(
        borderColor: Color(0xFFBDBDBD),
        focusedBorderColor: Color(0xFF6200EE),  // brand color
        fillColor: Color(0xFFF5F5F5),
        borderRadius: 12,                        // team thích bo tròn hơn
      ),
    ],
  ),
)

// Tầng 2 — Dark theme, override khác
MaterialApp(
  darkTheme: ThemeData.dark().copyWith(
    extensions: [
      AppTextFieldTheme(
        borderColor: Color(0xFF424242),
        focusedBorderColor: Color(0xFFBB86FC),
        fillColor: Color(0xFF1E1E1E),
        borderRadius: 12,
      ),
    ],
  ),
)
// → Mọi AppTextField tự động adapt, KHÔNG cần sửa bất kỳ call site nào
```

---

## 6. Escape Hatch — Lưới an toàn cuối cùng

Dù thiết kế tốt đến đâu, sẽ luôn có edge case không lường trước. Senior developer cần cung cấp **escape hatch** — một cách để bypass hoàn toàn logic của component:

```dart
class AppTextField extends StatelessWidget {
  // ...tất cả params ở trên...

  /// Escape hatch: nếu set thì BỎ QUA toàn bộ logic resolve
  /// decoration ở trên, dùng trực tiếp decoration này.
  ///
  /// ⚠️ Chỉ dùng khi Design System không cover được use case.
  /// Nếu thấy dùng nhiều, hãy mở issue để mở rộng component.
  final InputDecoration? decorationOverride;
}
```

**Quy tắc:**

- Escape hatch phải có `@Deprecated`-style warning trong doc: *"Nếu bạn dùng cái này nhiều, hãy báo Design System team"*
- Track usage qua lint rule hoặc code review → nếu quá nhiều chỗ dùng escape hatch cho cùng một lý do → đó là signal cần mở rộng component API

---

## 7. Checklist cho Senior khi thiết kế API

```
Với MỖI property trong component, tự hỏi:

□ Có giá trị mặc định hợp lý không?
  → CÓ  → để optional với default value
  → KHÔNG (mỗi nơi dùng khác nhau) → required

□ 90% use case có cần set nó không?
  → KHÔNG → nullable, default null, resolve từ theme
  → CÓ    → có mặt trong constructor nhưng có default

□ Có thể thay đổi global qua theme không?
  → CÓ  → đưa vào ThemeExtension
  → KHÔNG (chỉ per-instance) → chỉ cần param thường

□ Cần escape hatch không?
  → Component phức tạp (TextField, Dialog) → CÓ
  → Component đơn giản (Badge, Divider)   → KHÔNG cần
```

---

## Tóm lại

Nguyên tắc này nói về việc **tôn trọng thời gian của đồng đội**: 90% thời gian họ chỉ cần viết `AppTextField(label: 'Email')` và mọi thứ đã đẹp, đã đúng brand, đã accessible. Nhưng 10% thời gian khi họ gặp edge case, họ không bị *kẹt* — luôn có cách override từ nhẹ (một param) đến nặng (escape hatch), mà không cần fork component hay bỏ Design System.
