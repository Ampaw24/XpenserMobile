import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/viewmodels/notification_history_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
    required this.profilePicUrl,
  });

  final String userName;
  final String profilePicUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final greeting = _greeting();
    final unread = ref.watch(unreadNotificationCountProvider);

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
          // Notification bell with unread badge
          GestureDetector(
            onTap: () => context.push('/notifications'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
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
                if (unread > 0)
                  Positioned(
                    top: -sw * 0.008,
                    right: sw * 0.022,
                    child: Container(
                      padding: EdgeInsets.all(sw * 0.012),
                      constraints: BoxConstraints(minWidth: sw * 0.044),
                      decoration: const BoxDecoration(
                        color: AppColors.ACCENT,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: sw * 0.022,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Avatar
          Container(
            width: sw * 0.108,
            height: sw * 0.108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(profilePicUrl),
                fit: BoxFit.cover,
              ),
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
