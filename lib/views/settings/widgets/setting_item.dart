import 'package:expenser/core/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final effectiveIconColor = iconColor ?? AppColors.ACCENT;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: sh * 0.012),
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.042, vertical: sh * 0.016),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(sw * 0.042),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(sw * 0.022),
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(sw * 0.024),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: sw * 0.052,
              ),
            ),
            SizedBox(width: sw * 0.036),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: sh * 0.002),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: sw * 0.030,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: sw * 0.038,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}
