import 'dart:math' as math;
import 'dart:ui';

import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_motion.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The visual style and semantic meaning of an [AppFeedbackDialog].
enum AppDialogType { success, error, warning, confirm, info }

/// A modern, fully responsive, animated feedback dialog for Xpenser.
///
/// Features:
/// - Smooth entrance with backdrop blur and elastic scale-in.
/// - Specialized animated vector icon (animated checkmark, drawing X, bouncing warning/help).
/// - Pulsing ambient halo behind the badge.
/// - Semantic colors tied to [AppPalette].
/// - Full responsiveness across small phones, tablets, foldables, and landscape mode.
/// - Dynamic button layout (auto-switching between side-by-side Row and vertical Column based on text length & font scale).
/// - Auto-scrolling on compact heights to prevent render overflow errors.
/// - Tactile haptic feedback.
class AppFeedbackDialog extends StatefulWidget {
  const AppFeedbackDialog({
    super.key,
    required this.type,
    required this.title,
    this.message,
    this.customContent,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.isDestructive = false,
    this.icon,
    this.showCloseButton = false,
  });

  final AppDialogType type;
  final String title;
  final String? message;
  final Widget? customContent;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final bool isDestructive;
  final IconData? icon;
  final bool showCloseButton;

  @override
  State<AppFeedbackDialog> createState() => _AppFeedbackDialogState();
}

class _AppFeedbackDialogState extends State<AppFeedbackDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    HapticFeedback.lightImpact();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _resolveAccentColor(AppPalette palette) {
    switch (widget.type) {
      case AppDialogType.success:
        return palette.success;
      case AppDialogType.error:
        return palette.danger;
      case AppDialogType.warning:
        return palette.warning;
      case AppDialogType.confirm:
        return widget.isDestructive ? palette.danger : palette.accent;
      case AppDialogType.info:
        return palette.info;
    }
  }

  String _defaultPrimaryText() {
    switch (widget.type) {
      case AppDialogType.success:
        return 'Done';
      case AppDialogType.error:
        return 'Dismiss';
      case AppDialogType.warning:
        return 'Understood';
      case AppDialogType.confirm:
        return widget.isDestructive ? 'Delete' : 'Confirm';
      case AppDialogType.info:
        return 'Got it';
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = _resolveAccentColor(palette);
    final primaryLabel = widget.primaryButtonText ?? _defaultPrimaryText();
    final hasSecondary =
        widget.secondaryButtonText != null ||
        widget.type == AppDialogType.confirm;
    final secondaryLabel = widget.secondaryButtonText ?? 'Cancel';

    // Responsive metrics
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isCompactHeight = screenSize.height < 520;
    final isCompactWidth = screenSize.width < 340;
    final textScale = mediaQuery.textScaler.scale(14) / 14;

    // Dynamically stack buttons if screen is narrow, accessibility font size is high,
    // or button labels are long.
    final shouldStackButtons =
        isCompactWidth ||
        textScale > 1.25 ||
        primaryLabel.length > 13 ||
        secondaryLabel.length > 13;

    // Constrain width responsively (never wider than screen margins, capped for tablets/desktop)
    final maxDialogWidth = math
        .min(context.rs(380), screenSize.width - (context.rs(16) * 2))
        .clamp(280.0, 440.0);

    // Constrain height to avoid any overflow in landscape or small screens
    final maxDialogHeight = screenSize.height * (isCompactHeight ? 0.94 : 0.85);

    final verticalPadding = isCompactHeight ? context.rs(16) : context.rs(26);
    final horizontalPadding = isCompactWidth ? context.rs(16) : context.rs(22);
    final spacing = isCompactHeight ? context.rs(10) : context.rs(18);
    final buttonSpacing = isCompactHeight ? context.rs(16) : context.rs(22);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: math.max(
          context.rs(16),
          (screenSize.width - maxDialogWidth) / 2,
        ),
        vertical: context.rs(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxDialogWidth,
          maxHeight: maxDialogHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(context.rs(24)),
            border: Border.all(
              color: palette.border.withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: accent.withValues(alpha: 0.08),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.rs(24)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Subtle ambient glow behind icon at top of dialog
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: isCompactHeight ? context.rs(70) : context.rs(110),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accent.withValues(alpha: 0.12),
                          palette.surface.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Close button if requested
                if (widget.showCloseButton)
                  Positioned(
                    top: context.rs(8),
                    right: context.rs(8),
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: palette.textMuted,
                        size: context.rs(20),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                // Responsive scrollable content: Prevents render overflow under any screen size or orientation
                SafeArea(
                  minimum: EdgeInsets.all(context.rs(4)),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      verticalPadding,
                      horizontalPadding,
                      verticalPadding,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Animated badge with halo & drawing icon
                        Center(
                          child: _AnimatedDialogBadge(
                            type: widget.type,
                            accentColor: accent,
                            customIcon: widget.icon,
                            isCompact: isCompactHeight,
                          ),
                        ),
                        SizedBox(height: spacing),

                        // Cascading animated content
                        FadeTransition(
                          opacity: _contentFade,
                          child: SlideTransition(
                            position: _contentSlide,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:
                                        isCompactHeight
                                            ? context.rs(17)
                                            : context.rs(19),
                                    fontWeight: FontWeight.w700,
                                    color: palette.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                if (widget.message != null) ...[
                                  SizedBox(height: context.rs(6)),
                                  Text(
                                    widget.message!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize:
                                          isCompactHeight
                                              ? context.rs(13)
                                              : context.rs(14),
                                      fontWeight: FontWeight.w400,
                                      color: palette.textSecondary,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                                if (widget.customContent != null) ...[
                                  SizedBox(height: context.rs(12)),
                                  widget.customContent!,
                                ],
                                SizedBox(height: buttonSpacing),

                                // Responsive Action buttons
                                if (hasSecondary)
                                  if (shouldStackButtons)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _PrimaryButton(
                                          accent: accent,
                                          label: primaryLabel,
                                          height: context.rs(46),
                                          onPressed: () {
                                            HapticFeedback.mediumImpact();
                                            if (widget.onPrimaryPressed !=
                                                null) {
                                              widget.onPrimaryPressed!();
                                            } else {
                                              Navigator.of(context).pop(true);
                                            }
                                          },
                                        ),
                                        SizedBox(height: context.rs(8)),
                                        _SecondaryButton(
                                          palette: palette,
                                          label: secondaryLabel,
                                          height: context.rs(44),
                                          onPressed: () {
                                            HapticFeedback.selectionClick();
                                            if (widget.onSecondaryPressed !=
                                                null) {
                                              widget.onSecondaryPressed!();
                                            } else {
                                              Navigator.of(context).pop(false);
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  else
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _SecondaryButton(
                                            palette: palette,
                                            label: secondaryLabel,
                                            height: context.rs(46),
                                            onPressed: () {
                                              HapticFeedback.selectionClick();
                                              if (widget.onSecondaryPressed !=
                                                  null) {
                                                widget.onSecondaryPressed!();
                                              } else {
                                                Navigator.of(
                                                  context,
                                                ).pop(false);
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(width: context.rs(10)),
                                        Expanded(
                                          child: _PrimaryButton(
                                            accent: accent,
                                            label: primaryLabel,
                                            height: context.rs(46),
                                            onPressed: () {
                                              HapticFeedback.mediumImpact();
                                              if (widget.onPrimaryPressed !=
                                                  null) {
                                                widget.onPrimaryPressed!();
                                              } else {
                                                Navigator.of(context).pop(true);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                else
                                  _PrimaryButton(
                                    accent: accent,
                                    label: primaryLabel,
                                    height: context.rs(48),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      if (widget.onPrimaryPressed != null) {
                                        widget.onPrimaryPressed!();
                                      } else {
                                        Navigator.of(context).pop(true);
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A responsive, styled primary button inside the dialog.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.accent,
    required this.label,
    required this.height,
    required this.onPressed,
  });

  final Color accent;
  final String label;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: Size(double.infinity, height),
        padding: EdgeInsets.symmetric(horizontal: context.rs(12)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.rs(14)),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: context.rs(14),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A responsive, styled secondary/cancel button inside the dialog.
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.palette,
    required this.label,
    required this.height,
    required this.onPressed,
  });

  final AppPalette palette;
  final String label;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.textSecondary,
        side: BorderSide(color: palette.border, width: 1.2),
        backgroundColor: palette.surfaceMuted,
        minimumSize: Size(double.infinity, height),
        padding: EdgeInsets.symmetric(horizontal: context.rs(12)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.rs(14)),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: context.rs(14),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The animated circular badge at the top of the dialog.
class _AnimatedDialogBadge extends StatefulWidget {
  const _AnimatedDialogBadge({
    required this.type,
    required this.accentColor,
    this.customIcon,
    this.isCompact = false,
  });

  final AppDialogType type;
  final Color accentColor;
  final IconData? customIcon;
  final bool isCompact;

  @override
  State<_AnimatedDialogBadge> createState() => _AnimatedDialogBadgeState();
}

class _AnimatedDialogBadgeState extends State<_AnimatedDialogBadge>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _scaleAnim;
  late final Animation<double> _haloScale;
  late final Animation<double> _haloFade;
  late final Animation<double> _vectorProgress;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    );

    _haloScale = Tween<double>(begin: 0.8, end: 1.35).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
      ),
    );

    _haloFade = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _vectorProgress = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.28, 0.95, curve: Curves.easeInOutCubic),
    );

    // Gentle wobble for errors
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -3.5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3.5, end: 3.5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 3.5, end: -2.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 2.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.55, 0.95, curve: Curves.easeInOut),
      ),
    );

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.isCompact ? context.rs(56) : context.rs(72);
    final innerSize = widget.isCompact ? context.rs(46) : context.rs(60);
    final iconDimension = widget.isCompact ? context.rs(22) : context.rs(28);

    return AnimatedBuilder(
      animation: Listenable.merge([_entranceCtrl, _pulseCtrl]),
      builder: (context, _) {
        final continuousPulse = 1.0 + (_pulseCtrl.value * 0.06);

        Widget iconWidget;
        if (widget.customIcon != null) {
          iconWidget = Icon(
            widget.customIcon,
            color: Colors.white,
            size: iconDimension,
          );
        } else {
          switch (widget.type) {
            case AppDialogType.success:
              iconWidget = CustomPaint(
                size: Size(iconDimension, iconDimension),
                painter: _AnimatedCheckPainter(
                  progress: _vectorProgress.value,
                  color: Colors.white,
                ),
              );
              break;
            case AppDialogType.error:
              iconWidget = Transform.translate(
                offset: Offset(_shakeAnim.value, 0),
                child: CustomPaint(
                  size: Size(iconDimension * 0.9, iconDimension * 0.9),
                  painter: _AnimatedCrossPainter(
                    progress: _vectorProgress.value,
                    color: Colors.white,
                  ),
                ),
              );
              break;
            case AppDialogType.warning:
              iconWidget = Transform.scale(
                scale: 0.85 + (0.15 * _vectorProgress.value),
                child: Icon(
                  Icons.priority_high_rounded,
                  color: Colors.white,
                  size: iconDimension * 1.15,
                ),
              );
              break;
            case AppDialogType.confirm:
              iconWidget = Transform.scale(
                scale: 0.85 + (0.15 * _vectorProgress.value),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: Colors.white,
                  size: iconDimension * 1.15,
                ),
              );
              break;
            case AppDialogType.info:
              iconWidget = Transform.scale(
                scale: 0.85 + (0.15 * _vectorProgress.value),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: iconDimension * 1.15,
                ),
              );
              break;
          }
        }

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Entrance blast halo
              if (_haloFade.value > 0.01)
                Transform.scale(
                  scale: _haloScale.value,
                  child: Container(
                    width: innerSize,
                    height: innerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentColor.withValues(
                        alpha: _haloFade.value,
                      ),
                    ),
                  ),
                ),

              // Soft continuous breathing ring
              Transform.scale(
                scale: continuousPulse,
                child: Container(
                  width: innerSize + context.rs(10),
                  height: innerSize + context.rs(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accentColor.withValues(alpha: 0.14),
                  ),
                ),
              ),

              // Solid animated badge with gradient & shadow
              Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.accentColor,
                        Color.lerp(widget.accentColor, Colors.black, 0.15) ??
                            widget.accentColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.38),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(child: iconWidget),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter that draws an animated checkmark path.
class _AnimatedCheckPainter extends CustomPainter {
  const _AnimatedCheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2.6, size.width * 0.12)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Normalized coordinates for checkmark
    final p1 = Offset(size.width * 0.22, size.height * 0.52);
    final p2 = Offset(size.width * 0.44, size.height * 0.72);
    final p3 = Offset(size.width * 0.80, size.height * 0.28);

    final leg1Len = (p2 - p1).distance;
    final leg2Len = (p3 - p2).distance;
    final totalLen = leg1Len + leg2Len;
    final currentDist = totalLen * progress;

    path.moveTo(p1.dx, p1.dy);

    if (currentDist <= leg1Len) {
      final t = currentDist / leg1Len;
      final currentPoint = Offset.lerp(p1, p2, t)!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      path.lineTo(p2.dx, p2.dy);
      final t = (currentDist - leg1Len) / leg2Len;
      final currentPoint = Offset.lerp(p2, p3, t.clamp(0.0, 1.0))!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_AnimatedCheckPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// Custom painter that draws an animated X cross.
class _AnimatedCrossPainter extends CustomPainter {
  const _AnimatedCrossPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2.5, size.width * 0.12)
          ..strokeCap = StrokeCap.round;

    final inset = size.width * 0.16;
    final p1Start = Offset(inset, inset);
    final p1End = Offset(size.width - inset, size.height - inset);

    final p2Start = Offset(size.width - inset, inset);
    final p2End = Offset(inset, size.height - inset);

    // First diagonal (progress 0.0 -> 0.55)
    final t1 = (progress / 0.55).clamp(0.0, 1.0);
    final cur1 = Offset.lerp(p1Start, p1End, t1)!;
    canvas.drawLine(p1Start, cur1, paint);

    // Second diagonal (progress 0.45 -> 1.0)
    if (progress > 0.45) {
      final t2 = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);
      final cur2 = Offset.lerp(p2Start, p2End, t2)!;
      canvas.drawLine(p2Start, cur2, paint);
    }
  }

  @override
  bool shouldRepaint(_AnimatedCrossPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// Programmatic helper functions to display animated customized dialogs.
abstract final class AppDialogs {
  /// Shows an animated success dialog.
  static Future<bool?> showSuccess(
    BuildContext context, {
    required String title,
    String? message,
    String buttonText = 'Done',
    VoidCallback? onConfirm,
    Widget? customContent,
    bool barrierDismissible = true,
  }) {
    return _show<bool>(
      context,
      barrierDismissible: barrierDismissible,
      builder:
          (dialogContext) => AppFeedbackDialog(
            type: AppDialogType.success,
            title: title,
            message: message,
            customContent: customContent,
            primaryButtonText: buttonText,
            onPrimaryPressed: () {
              if (onConfirm != null) onConfirm();
              Navigator.of(dialogContext).pop(true);
            },
          ),
    );
  }

  /// Shows an animated error / failure dialog.
  static Future<bool?> showError(
    BuildContext context, {
    required String title,
    String? message,
    String buttonText = 'Dismiss',
    VoidCallback? onConfirm,
    String? secondaryButtonText,
    VoidCallback? onSecondary,
    Widget? customContent,
    bool barrierDismissible = true,
  }) {
    return _show<bool>(
      context,
      barrierDismissible: barrierDismissible,
      builder:
          (dialogContext) => AppFeedbackDialog(
            type: AppDialogType.error,
            title: title,
            message: message,
            customContent: customContent,
            primaryButtonText: buttonText,
            onPrimaryPressed: () {
              if (onConfirm != null) onConfirm();
              Navigator.of(dialogContext).pop(true);
            },
            secondaryButtonText: secondaryButtonText,
            onSecondaryPressed:
                secondaryButtonText != null
                    ? () {
                      if (onSecondary != null) onSecondary();
                      Navigator.of(dialogContext).pop(false);
                    }
                    : null,
          ),
    );
  }

  /// Shows an animated warning dialog.
  static Future<bool?> showWarning(
    BuildContext context, {
    required String title,
    String? message,
    String buttonText = 'Understood',
    VoidCallback? onConfirm,
    String? secondaryButtonText,
    VoidCallback? onSecondary,
    Widget? customContent,
    bool barrierDismissible = true,
  }) {
    return _show<bool>(
      context,
      barrierDismissible: barrierDismissible,
      builder:
          (dialogContext) => AppFeedbackDialog(
            type: AppDialogType.warning,
            title: title,
            message: message,
            customContent: customContent,
            primaryButtonText: buttonText,
            onPrimaryPressed: () {
              if (onConfirm != null) onConfirm();
              Navigator.of(dialogContext).pop(true);
            },
            secondaryButtonText: secondaryButtonText,
            onSecondaryPressed:
                secondaryButtonText != null
                    ? () {
                      if (onSecondary != null) onSecondary();
                      Navigator.of(dialogContext).pop(false);
                    }
                    : null,
          ),
    );
  }

  /// Shows an animated confirmation dialog.
  ///
  /// Returns `true` if confirmed, and `false` or `null` if cancelled/dismissed.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
    Widget? customContent,
    bool barrierDismissible = true,
  }) async {
    final result = await _show<bool>(
      context,
      barrierDismissible: barrierDismissible,
      builder:
          (dialogContext) => AppFeedbackDialog(
            type: AppDialogType.confirm,
            title: title,
            message: message,
            customContent: customContent,
            primaryButtonText: confirmText,
            secondaryButtonText: cancelText,
            isDestructive: isDestructive,
            icon: icon,
            onPrimaryPressed: () => Navigator.of(dialogContext).pop(true),
            onSecondaryPressed: () => Navigator.of(dialogContext).pop(false),
          ),
    );
    return result ?? false;
  }

  /// Shows an animated informational dialog.
  static Future<bool?> showInfo(
    BuildContext context, {
    required String title,
    String? message,
    String buttonText = 'Got it',
    VoidCallback? onConfirm,
    Widget? customContent,
    bool barrierDismissible = true,
  }) {
    return _show<bool>(
      context,
      barrierDismissible: barrierDismissible,
      builder:
          (dialogContext) => AppFeedbackDialog(
            type: AppDialogType.info,
            title: title,
            message: message,
            customContent: customContent,
            primaryButtonText: buttonText,
            onPrimaryPressed: () {
              if (onConfirm != null) onConfirm();
              Navigator.of(dialogContext).pop(true);
            },
          ),
    );
  }

  /// Internal presentation method using [showGeneralDialog] with backdrop blur
  /// and spring scale/fade transition.
  static Future<T?> _show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    final isReducedMotion = AppMotion.reduced(context);

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.52),
      transitionDuration:
          isReducedMotion ? Duration.zero : const Duration(milliseconds: 320),
      pageBuilder: (dialogContext, _, __) => builder(dialogContext),
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        if (isReducedMotion) return child;

        final curvedScale = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        final curvedFade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 4.5 * animation.value,
            sigmaY: 4.5 * animation.value,
          ),
          child: FadeTransition(
            opacity: curvedFade,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.82, end: 1.0).animate(curvedScale),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
