import 'package:expenser/core/constants/branding.dart';
import 'package:flutter/material.dart';

/// Semantic color tokens for every screen. Read via `context.palette`
/// instead of branching on brightness or hard-coding colors.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.hero,
    required this.onHero,
    required this.onHeroMuted,
    required this.onHeroSuccess,
    required this.onHeroWarning,
    required this.onHeroDanger,
    required this.success,
    required this.danger,
    required this.warning,
    required this.info,
  });

  /// Page/scaffold background. Neutral in light mode, spruce in dark mode.
  final Color background;

  /// Cards, sheets, dialogs, inputs.
  final Color surface;

  /// Subtle fills: icon tiles, chips, tracks, segmented controls.
  final Color surfaceMuted;
  final Color border;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// Interactive brand color: buttons, links, selected states, focus.
  final Color accent;
  final Color onAccent;

  /// Emphasis card (balance card, profile card, summary banners).
  final Color hero;
  final Color onHero;
  final Color onHeroMuted;

  /// Status colors legible on [hero] in both themes.
  final Color onHeroSuccess;
  final Color onHeroWarning;
  final Color onHeroDanger;

  final Color success;
  final Color danger;
  final Color warning;
  final Color info;

  static const light = AppPalette(
    background: AppBrand.backgroundLight,
    surface: AppBrand.surfaceLight,
    surfaceMuted: AppBrand.surfaceMutedLight,
    border: AppBrand.borderLight,
    textPrimary: AppBrand.textPrimaryLight,
    textSecondary: AppBrand.textSecondaryLight,
    textMuted: AppBrand.textMutedLight,
    accent: AppBrand.tealPrimary,
    onAccent: Colors.white,
    hero: AppBrand.spruceDark,
    onHero: Colors.white,
    onHeroMuted: Color(0xB3FFFFFF),
    onHeroSuccess: AppBrand.mintLight,
    onHeroWarning: Color(0xFFFCD34D),
    onHeroDanger: Color(0xFFFDA4AF),
    success: Color(0xFF059669),
    danger: Color(0xFFE11D48),
    warning: Color(0xFFD97706),
    info: Color(0xFF0284C7),
  );

  static const dark = AppPalette(
    background: AppBrand.backgroundDark,
    surface: AppBrand.surfaceDark,
    surfaceMuted: AppBrand.surfaceDarkElevated,
    border: AppBrand.borderDark,
    textPrimary: AppBrand.textPrimaryDark,
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    accent: AppBrand.mintAccent,
    onAccent: AppBrand.spruceDark,
    hero: AppBrand.surfaceDarkElevated,
    onHero: Colors.white,
    onHeroMuted: Color(0xB3FFFFFF),
    onHeroSuccess: AppBrand.mintLight,
    onHeroWarning: Color(0xFFFCD34D),
    onHeroDanger: Color(0xFFFDA4AF),
    success: Color(0xFF34D399),
    danger: Color(0xFFFB7185),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF38BDF8),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? onAccent,
    Color? hero,
    Color? onHero,
    Color? onHeroMuted,
    Color? onHeroSuccess,
    Color? onHeroWarning,
    Color? onHeroDanger,
    Color? success,
    Color? danger,
    Color? warning,
    Color? info,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      hero: hero ?? this.hero,
      onHero: onHero ?? this.onHero,
      onHeroMuted: onHeroMuted ?? this.onHeroMuted,
      onHeroSuccess: onHeroSuccess ?? this.onHeroSuccess,
      onHeroWarning: onHeroWarning ?? this.onHeroWarning,
      onHeroDanger: onHeroDanger ?? this.onHeroDanger,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      border: mix(border, other.border),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textMuted: mix(textMuted, other.textMuted),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      hero: mix(hero, other.hero),
      onHero: mix(onHero, other.onHero),
      onHeroMuted: mix(onHeroMuted, other.onHeroMuted),
      onHeroSuccess: mix(onHeroSuccess, other.onHeroSuccess),
      onHeroWarning: mix(onHeroWarning, other.onHeroWarning),
      onHeroDanger: mix(onHeroDanger, other.onHeroDanger),
      success: mix(success, other.success),
      danger: mix(danger, other.danger),
      warning: mix(warning, other.warning),
      info: mix(info, other.info),
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
