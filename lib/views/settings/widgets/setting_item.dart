import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:flutter/material.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Defaults to `palette.accent`; pass `palette.danger` for destructive rows.
  final Color? iconColor;

  /// Defaults to `palette.surface`.
  final Color? backgroundColor;

  /// Defaults to a chevron.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final effectiveIconColor = iconColor ?? palette.accent;

    return Padding(
      padding: EdgeInsets.only(bottom: context.rs(10)),
      child: AppSurfaceCard(
        onTap: onTap,
        color: backgroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: context.rs(14),
          vertical: context.rs(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.rs(9)),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  effectiveIconColor.withValues(alpha: 0.10),
                  palette.surfaceMuted,
                ),
                borderRadius: BorderRadius.circular(context.rs(12)),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: context.rs(20),
              ),
            ),
            SizedBox(width: context.rs(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.rs(15),
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  SizedBox(height: context.rs(2)),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.rs(12.5),
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.rs(8)),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: context.rs(14),
                  color: palette.textMuted,
                ),
          ],
        ),
      ),
    );
  }
}
