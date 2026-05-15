import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/models/notification_record.dart';
import 'package:expenser/viewmodels/notification_history_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final notifications = ref.watch(notificationHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.montserrat(
            fontSize: sw * 0.046,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(notificationHistoryProvider.notifier).markAllRead(),
              child: Text(
                'Mark all read',
                style: GoogleFonts.inter(
                  fontSize: sw * 0.032,
                  color: AppColors.ACCENT,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _EmptyState(sw: sw, sh: sh)
          : ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sh * 0.012,
              ),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.07),
              ),
              itemBuilder: (context, index) =>
                  _NotificationTile(record: notifications[index], sw: sw, sh: sh),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.record,
    required this.sw,
    required this.sh,
  });

  final NotificationRecord record;
  final double sw;
  final double sh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.03,
        vertical: sh * 0.016,
      ),
      decoration: BoxDecoration(
        color: record.isRead
            ? Colors.transparent
            : AppColors.ACCENT.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TypeIcon(type: record.type, sw: sw),
          SizedBox(width: sw * 0.034),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.title,
                        style: GoogleFonts.inter(
                          fontSize: sw * 0.037,
                          fontWeight: record.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (!record.isRead)
                      Container(
                        width: sw * 0.020,
                        height: sw * 0.020,
                        decoration: const BoxDecoration(
                          color: AppColors.ACCENT,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: sh * 0.004),
                Text(
                  record.body,
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.033,
                    color: Colors.white.withValues(alpha: 0.60),
                  ),
                ),
                SizedBox(height: sh * 0.006),
                Text(
                  _formatTime(record.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.028,
                    color: Colors.white.withValues(alpha: 0.38),
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

// ─────────────────────────────────────────────────────────────────────────────

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type, required this.sw});

  final String type;
  final double sw;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      'account' => (Icons.account_balance_wallet_rounded, const Color(0xFF2196F3)),
      'savings' => (Icons.savings_rounded, const Color(0xFF4CAF50)),
      _ => (Icons.notifications_rounded, AppColors.ACCENT),
    };

    return Container(
      width: sw * 0.108,
      height: sw * 0.108,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: sw * 0.050),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.sw, required this.sh});

  final double sw;
  final double sh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: sw * 0.18,
            color: Colors.white.withValues(alpha: 0.18),
          ),
          SizedBox(height: sh * 0.020),
          Text(
            'No notifications yet',
            style: GoogleFonts.montserrat(
              fontSize: sw * 0.044,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.40),
            ),
          ),
          SizedBox(height: sh * 0.008),
          Text(
            'Activity from accounts and savings\nwill appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: sw * 0.033,
              color: Colors.white.withValues(alpha: 0.28),
            ),
          ),
        ],
      ),
    );
  }
}
