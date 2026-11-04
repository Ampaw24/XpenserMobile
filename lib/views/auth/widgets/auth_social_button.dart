import 'package:expenser/core/constants/branding.dart';
import 'package:flutter/material.dart';

/// Full-width pill sign-in button. The [primary] variant is filled with the
/// brand accent and holds the icon in a white badge; the default is a surface
/// button with a hairline border.
class AuthSocialButton extends StatefulWidget {
  const AuthSocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final Widget icon;
  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  State<AuthSocialButton> createState() => _AuthSocialButtonState();
}

class _AuthSocialButtonState extends State<AuthSocialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = (MediaQuery.sizeOf(context).shortestSide * 0.14).clamp(
      kMinInteractiveDimension,
      kMinInteractiveDimension * 1.25,
    );
    final accent = isDark ? AppBrand.mintAccent : AppBrand.tealPrimary;

    final background =
        widget.primary
            ? accent
            : (isDark ? AppBrand.surfaceDark : AppBrand.surfaceLight);
    final foreground =
        widget.primary
            ? (isDark ? AppBrand.spruceDark : Colors.white)
            : (isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight);
    final border =
        widget.primary
            ? BorderSide.none
            : BorderSide(
              color: isDark ? AppBrand.borderDark : AppBrand.borderLight,
            );

    final iconSlot = height * 0.62;

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            if (widget.primary)
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: height * 0.5,
                offset: Offset(0, height * 0.06),
              ),
          ],
        ),
        child: Material(
          color: background,
          shape: StadiumBorder(side: border),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: SizedBox(
              height: height,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: height * 0.19),
                child: Row(
                  children: [
                    _IconBadge(
                      size: iconSlot,
                      filled: widget.primary,
                      child: widget.icon,
                    ),
                    Expanded(
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: height * 0.28,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                    ),
                    SizedBox(width: iconSlot),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.size,
    required this.filled,
    required this.child,
  });

  final double size;
  final bool filled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.24),
      decoration:
          filled
              ? const BoxDecoration(color: Colors.white, shape: BoxShape.circle)
              : null,
      child: FittedBox(child: child),
    );
  }
}
