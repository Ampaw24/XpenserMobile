import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomLoginButton extends StatelessWidget {
  const CustomLoginButton({super.key, required this.context, required this.icon, required this.iconColor, required this.label, required this.backgroundColor, required this.textColor, required this.width, required this.height, required this.onPressed});
   final BuildContext context;
    final IconData icon;
    final Color iconColor;
    final String label;
    final Color backgroundColor;
    final Color textColor;
    final double width;
    final double height;
    final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
     final isSmallScreen = MediaQuery.of(context).size.width < 360;
   return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 8 : 12,
          ),
        ),
        icon: FaIcon(icon, color: iconColor, size: isSmallScreen ? 16 : 18),
        label: Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

  