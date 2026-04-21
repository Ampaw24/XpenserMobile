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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    final horizontalPadding = _getHorizontalPadding(screenWidth);
    final verticalPadding = _getVerticalPadding(screenHeight);
    final iconSize = _getIconSize(screenWidth);
    final titleFontSize = _getTitleFontSize(screenWidth);
    final subtitleFontSize = _getSubtitleFontSize(screenWidth);
    final borderRadius = _getBorderRadius(screenWidth);
    final iconPadding = _getIconPadding(screenWidth);
    final spacing = _getSpacing(screenWidth);
    final bottomMargin = _getBottomMargin(screenHeight);

    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: Material(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: isLargeScreen ? 12 : (isTablet ? 10 : 8),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.blue).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(iconPadding),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? Colors.blue[600],
                    size: iconSize,
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: isTablet ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey[600],
                        ),
                        maxLines: isTablet ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: _getArrowIconSize(screenWidth),
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getHorizontalPadding(double w) => w > 900 ? 24 : w > 600 ? 20 : 16;
  double _getVerticalPadding(double h) => h > 800 ? 20 : h > 600 ? 16 : 14;
  double _getIconSize(double w) => w > 900 ? 28 : w > 600 ? 26 : 22;
  double _getTitleFontSize(double w) => w > 900 ? 18 : w > 600 ? 17 : 16;
  double _getSubtitleFontSize(double w) => w > 900 ? 15 : w > 600 ? 14 : 13;
  double _getBorderRadius(double w) => w > 900 ? 20 : w > 600 ? 18 : 16;
  double _getIconPadding(double w) => w > 900 ? 14 : w > 600 ? 12 : 10;
  double _getSpacing(double w) => w > 900 ? 20 : w > 600 ? 18 : 16;
  double _getBottomMargin(double h) => h > 800 ? 16 : h > 600 ? 14 : 12;
  double _getArrowIconSize(double w) => w > 900 ? 20 : w > 600 ? 18 : 16;
}
