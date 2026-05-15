import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/models/notification_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationRepository {
  Box<NotificationRecord> get _box =>
      HiveService.box<NotificationRecord>(HiveService.notifications);

  List<NotificationRecord> getAll() {
    final records = _box.values.toList();
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  Future<void> add(NotificationRecord record) =>
      _box.put(record.id, record);

  Future<void> markAllRead() async {
    final updates = {
      for (final r in _box.values.where((r) => !r.isRead))
        r.id: r.copyWith(isRead: true),
    };
    if (updates.isNotEmpty) await _box.putAll(updates);
  }

  Future<void> delete(String id) => _box.delete(id);

  Future<void> clear() => _box.clear();

  int get unreadCount => _box.values.where((r) => !r.isRead).length;
}

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (_) => NotificationRepository(),
);
