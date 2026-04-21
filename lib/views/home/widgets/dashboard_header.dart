import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final greeting = _greeting();

    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.06, sh * 0.018, sw * 0.06, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.033,
                    color: Colors.white.withValues(alpha: 0.50),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: sh * 0.004),
                Text(
                  userName.isNotEmpty ? userName : 'Welcome',
                  style: GoogleFonts.montserrat(
                    fontSize: sw * 0.058,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: () {},
            child: Container(
              width: sw * 0.108,
              height: sw * 0.108,
              margin: EdgeInsets.only(right: sw * 0.03),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.13),
                ),
              ),
              child: Icon(
                AppIcons.bell,
                color: Colors.white.withValues(alpha: 0.70),
                size: sw * 0.052,
              ),
            ),
          ),
          // Avatar
          Container(
            width: sw * 0.108,
            height: sw * 0.108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.PRIMARY, AppColors.ACCENT],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.montserrat(
                  fontSize: sw * 0.046,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 🌤';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }
}
