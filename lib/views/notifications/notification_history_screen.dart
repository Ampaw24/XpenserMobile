import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_empty_state.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/models/notification_record.dart';
import 'package:expenser/viewmodels/notification_history_viewmodel.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationHistoryScreen extends ConsumerStatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  ConsumerState<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState
    extends ConsumerState<NotificationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all as read and sync from Firebase when screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(notificationHistoryProvider.notifier).markAllRead();
      await ref.read(notificationHistoryProvider.notifier).syncFromFirebase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed:
                  () =>
                      ref
                          .read(notificationHistoryProvider.notifier)
                          .markAllRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: BrandWatermarkBackground(
        child: SafeArea(
          child:
              notifications.isEmpty
                  ? const AppEmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'No notifications yet',
                    message:
                        'Activity from accounts and savings\nwill appear here.',
                  )
                  : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      context.contentGutter,
                      context.rs(8),
                      context.contentGutter,
                      context.rs(24),
                    ),
                    itemCount: notifications.length,
                    separatorBuilder:
                        (_, __) => SizedBox(height: context.rs(10)),
                    itemBuilder:
                        (context, index) =>
                            _NotificationTile(record: notifications[index]),
                  ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.record});

  final NotificationRecord record;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isUnread = !record.isRead;

    return AppSurfaceCard(
      padding: EdgeInsets.all(context.rs(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TypeIcon(type: record.type),
          SizedBox(width: context.rs(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.title,
                        style: TextStyle(
                          fontSize: context.rs(14),
                          fontWeight:
                              isUnread ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isUnread
                                  ? palette.textPrimary
                                  : palette.textSecondary,
                        ),
                      ),
                    ),
                    if (isUnread) ...[
                      SizedBox(width: context.rs(8)),
                      Container(
                        width: context.rs(8),
                        height: context.rs(8),
                        decoration: BoxDecoration(
                          color: palette.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: context.rs(4)),
                Text(
                  record.body,
                  style: TextStyle(
                    fontSize: context.rs(13),
                    color: palette.textSecondary,
                  ),
                ),
                SizedBox(height: context.rs(6)),
                Text(
                  _formatTime(record.createdAt),
                  style: TextStyle(
                    fontSize: context.rs(11),
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final icon = switch (type) {
      'account' => Icons.account_balance_wallet_rounded,
      'savings' => Icons.savings_rounded,
      'budget' => Icons.pie_chart_rounded,
      _ => Icons.notifications_rounded,
    };
    final size = context.rs(42);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: palette.accent, size: context.rs(20)),
    );
  }
}
