import 'package:hive_flutter/hive_flutter.dart';

part 'notification_record.g.dart';

@HiveType(typeId: 7)
class NotificationRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final String type; // 'account' | 'savings' | 'fcm'

  @HiveField(4)
  final String? route;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final bool isRead;

  NotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.route,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type,
    if (route != null) 'route': route,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };

  factory NotificationRecord.fromMap(Map<String, dynamic> map) =>
      NotificationRecord(
        id: map['id'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        type: map['type'] as String,
        route: map['route'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        isRead: map['isRead'] as bool? ?? false,
      );

  NotificationRecord copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    String? route,
    DateTime? createdAt,
    bool? isRead,
  }) => NotificationRecord(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    type: type ?? this.type,
    route: route ?? this.route,
    createdAt: createdAt ?? this.createdAt,
    isRead: isRead ?? this.isRead,
  );
}
