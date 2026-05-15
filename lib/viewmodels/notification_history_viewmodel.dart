import 'package:expenser/data/repositories/notification_repository.dart';
import 'package:expenser/models/notification_record.dart';
import 'package:expenser/services/firebase_user_data_service.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationHistoryNotifier extends Notifier<List<NotificationRecord>> {
  @override
  List<NotificationRecord> build() {
    return ref.read(notificationRepositoryProvider).getAll();
  }

  /// Saves a new notification to Hive + Firebase and refreshes state.
  Future<void> add(NotificationRecord record) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.add(record);
    state = repo.getAll();
    _mirror((svc, uid) => svc.saveNotification(uid, record));
  }

  /// Marks all notifications as read locally + on Firebase.
  Future<void> markAllRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllRead();
    state = repo.getAll();
    _syncAllToFirebase();
  }

  /// Fetches from Firebase, merges with local cache (adds any missing records).
  Future<void> syncFromFirebase() async {
    final uid = ref.read(settingsProvider).uid;
    if (uid == null) return;

    try {
      final remote = await ref
          .read(firebaseUserDataServiceProvider)
          .fetchNotifications(uid);

      final repo = ref.read(notificationRepositoryProvider);
      final localIds = repo.getAll().map((r) => r.id).toSet();
      for (final r in remote) {
        if (!localIds.contains(r.id)) await repo.add(r);
      }
      state = repo.getAll();
    } catch (e) {
      debugPrint('Notification sync error: $e');
    }
  }

  int get unreadCount =>
      ref.read(notificationRepositoryProvider).unreadCount;

  void _syncAllToFirebase() {
    final uid = ref.read(settingsProvider).uid;
    if (uid == null) return;
    final svc = ref.read(firebaseUserDataServiceProvider);
    for (final r in state) {
      svc.saveNotification(uid, r).catchError((_) => null);
    }
  }

  void _mirror(
    Future<void> Function(FirebaseUserDataService svc, String uid) fn,
  ) {
    final uid = ref.read(settingsProvider).uid;
    if (uid == null) return;
    fn(ref.read(firebaseUserDataServiceProvider), uid)
        .catchError((e) => debugPrint('RTDB notification: $e'));
  }
}

final notificationHistoryProvider =
    NotifierProvider<NotificationHistoryNotifier, List<NotificationRecord>>(
      NotificationHistoryNotifier.new,
    );

/// Derived provider — unread count for the bell badge.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationHistoryProvider);
  return notifications.where((n) => !n.isRead).length;
});
