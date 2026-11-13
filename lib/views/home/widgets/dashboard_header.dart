import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/viewmodels/notification_history_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greeting = _greeting();
    final unread = ref.watch(unreadNotificationCountProvider);

    final titleColor = isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight;
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : AppBrand.textSecondaryLight;
    final btnBg = isDark ? AppBrand.surfaceDark : Colors.white;
    final btnBorder = isDark ? AppBrand.borderDark : AppBrand.borderLight;
    final btnIconColor = isDark ? Colors.white : AppBrand.textPrimaryLight;

    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.05, 12, sw * 0.05, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: subtitleColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userName.isNotEmpty ? userName : 'Welcome',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    letterSpacing: -0.3,
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: btnBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: btnBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: AppIcons.bell,
                      color: btnIconColor,
                      size: 20,
                    ),
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppBrand.backgroundDark : Colors.white,
                          width: 1.5,
                        ),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        unread > 99 ? '99+' : unread.toString(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
