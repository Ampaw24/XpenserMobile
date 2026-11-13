import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/theme/app_motion.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const fontFamily = 'Inter';

  static ThemeData get light =>
      _build(brightness: Brightness.light, palette: AppPalette.light);
  static ThemeData get dark =>
      _build(brightness: Brightness.dark, palette: AppPalette.dark);

  static ThemeData _build({
    required Brightness brightness,
    required AppPalette palette,
  }) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: palette.accent,
      onPrimary: palette.onAccent,
      primaryContainer:
          isDark ? const Color(0xFF0F3E3C) : const Color(0xFFCCFBF1),
      onPrimaryContainer: isDark ? AppBrand.mintLight : AppBrand.spruceDark,
      secondary: AppBrand.mintAccent,
      onSecondary: AppBrand.spruceDark,
      secondaryContainer:
          isDark ? const Color(0xFF114C49) : const Color(0xFFE6FFFA),
      onSecondaryContainer: isDark ? Colors.white : AppBrand.spruceDark,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      onSurfaceVariant: palette.textSecondary,
      surfaceContainerHighest: palette.surfaceMuted,
      error: palette.danger,
      onError: Colors.white,
      outline: palette.border,
      outlineVariant: palette.border,
    );

    final base = isDark ? ThemeData.dark() : ThemeData.light();
    final textTheme = _textTheme(base.textTheme, palette);
    final controlRadius = BorderRadius.circular(14);
    final borderlessField = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    );
    final buttonTextStyle = const TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      pageTransitionsTheme: AppMotion.pageTransitionsTheme,
      fontFamily: fontFamily,
      colorScheme: scheme,
      textTheme: textTheme,
      extensions: [palette],
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      cardColor: palette.surface,
      dividerColor: palette.border,
      iconTheme: IconThemeData(color: palette.textPrimary),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: palette.border),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.onAccent,
          disabledBackgroundColor: palette.surfaceMuted,
          disabledForegroundColor: palette.textMuted,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: controlRadius),
          textStyle: buttonTextStyle,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.onAccent,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: controlRadius),
          textStyle: buttonTextStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.accent,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: palette.border),
          shape: RoundedRectangleBorder(borderRadius: controlRadius),
          textStyle: buttonTextStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.accent,
          textStyle: buttonTextStyle.copyWith(fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceMuted,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: borderlessField,
        enabledBorder: borderlessField,
        disabledBorder: borderlessField,
        focusedBorder: borderlessField.copyWith(
          borderSide: BorderSide(color: palette.accent, width: 1.5),
        ),
        errorBorder: borderlessField.copyWith(
          borderSide: BorderSide(color: palette.danger),
        ),
        focusedErrorBorder: borderlessField.copyWith(
          borderSide: BorderSide(color: palette.danger, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          color: palette.textMuted,
        ),
        errorStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          color: palette.danger,
        ),
        prefixIconColor: palette.textSecondary,
        suffixIconColor: palette.textSecondary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceMuted,
        selectedColor: palette.accent.withValues(alpha: 0.14),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: palette.textPrimary,
        ),
        side: BorderSide(color: palette.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: palette.border,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.textSecondary,
        textColor: palette.textPrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: palette.surface,
        showDragHandle: true,
        dragHandleColor: palette.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: palette.textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.hero,
        actionTextColor: AppBrand.mintAccent,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: palette.onHero,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? palette.onAccent
                  : palette.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? palette.accent
                  : palette.surfaceMuted,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.accent,
        linearTrackColor: palette.surfaceMuted,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.accent,
        foregroundColor: palette.onAccent,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, AppPalette palette) {
    TextStyle style(double size, FontWeight weight, Color color) => TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
    );

    return base
        .apply(
          fontFamily: fontFamily,
          bodyColor: palette.textPrimary,
          displayColor: palette.textPrimary,
        )
        .copyWith(
          headlineLarge: style(
            28,
            FontWeight.w700,
            palette.textPrimary,
          ).copyWith(letterSpacing: -0.5),
          headlineMedium: style(
            24,
            FontWeight.w700,
            palette.textPrimary,
          ).copyWith(letterSpacing: -0.4),
          headlineSmall: style(20, FontWeight.w600, palette.textPrimary),
          titleLarge: style(18, FontWeight.w600, palette.textPrimary),
          titleMedium: style(16, FontWeight.w600, palette.textPrimary),
          titleSmall: style(14, FontWeight.w600, palette.textPrimary),
          bodyLarge: style(15, FontWeight.w400, palette.textPrimary),
          bodyMedium: style(13, FontWeight.w400, palette.textSecondary),
          bodySmall: style(11, FontWeight.w400, palette.textSecondary),
          labelLarge: style(14, FontWeight.w600, palette.textPrimary),
        );
  }
}
