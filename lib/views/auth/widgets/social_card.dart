import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialCard extends StatelessWidget {
  const SocialCard({
    super.key,
    required this.icon,
    required this.label,
    required this.press,
  });

  final Widget icon;
  final String label;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return GestureDetector(
      onTap: press,
      child: Container(
        height: sh * 0.068,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.035),
          border: Border.all(color: Colors.grey.shade200, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: sw * 0.055,
              height: sw * 0.055,
              child: icon,
            ),
            SizedBox(width: sw * 0.04),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: sw * 0.04,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
