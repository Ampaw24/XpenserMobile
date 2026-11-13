import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/widgets/user_avatar.dart';
import 'package:expenser/viewmodels/notification_history_viewmodel.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
    required this.photoUrl,
  });

  final String userName;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final firstName = userName.trim().split(RegExp(r'\s+')).first;

    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Open profile',
          child: GestureDetector(
            onTap: () => context.go('/shell/settings'),
            child: UserAvatar(
              name: userName,
              photoUrl: photoUrl,
              diameter: context.rs(46),
            ),
          ),
        ),
        SizedBox(width: context.rs(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingLine(period: _DayPeriod.now()),
              SizedBox(height: context.rs(2)),
              Text(
                firstName.isEmpty ? 'Welcome back' : firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.rs(20),
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: context.palette.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: context.rs(12)),
        const _HeaderActions(),
      ],
    );
  }
}

enum _DayPeriod {
  morning('Good morning', AppIcons.morning, Color(0xFFF59E0B)),
  afternoon('Good afternoon', AppIcons.afternoon, Color(0xFFF97316)),
  evening('Good evening', AppIcons.evening, Color(0xFF818CF8));

  const _DayPeriod(this.greeting, this.icon, this.tint);

  final String greeting;
  final IconData icon;
  final Color tint;

  static _DayPeriod now() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return morning;
    if (hour >= 12 && hour < 17) return afternoon;
    return evening;
  }
}

class _GreetingLine extends StatelessWidget {
  const _GreetingLine({required this.period});

  final _DayPeriod period;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HugeIcon(icon: period.icon, color: period.tint, size: context.rs(15)),
        SizedBox(width: context.rs(5)),
        Flexible(
          child: Text(
            period.greeting,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: context.rs(13),
              fontWeight: FontWeight.w500,
              color: context.palette.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderActions extends ConsumerWidget {
  const _HeaderActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);
    final iconColor = context.palette.textPrimary;

    return Container(
      padding: EdgeInsets.all(context.rs(4)),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(context.rs(28)),
        border: Border.all(color: context.palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HeaderIconButton(
            icon: AppIcons.search,
            color: iconColor,
            tooltip: 'Search transactions',
            onTap: () => context.go('/shell/transactions'),
          ),
          _HeaderIconButton(
            icon: AppIcons.bell,
            color: iconColor,
            tooltip: 'Notifications',
            showBadge: unread > 0,
            onTap: () => context.push('/notifications'),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final size = context.rs(40);
    final dotSize = context.rs(8);

    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: size / 2,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              HugeIcon(icon: icon, color: color, size: context.rs(21)),
              if (showBadge)
                Positioned(
                  top: size * 0.24,
                  right: size * 0.26,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: context.palette.danger,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.palette.surface,
                        width: context.rs(1.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
