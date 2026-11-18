import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Android notification channel used for all app notifications.
const appNotificationChannel = AndroidNotificationChannel(
  'xpenser_general',
  'Xpenser Notifications',
  description: 'Budget alerts, savings updates and reminders',
  importance: Importance.high,
);

NotificationDetails appNotificationDetails() => NotificationDetails(
  android: AndroidNotificationDetails(
    appNotificationChannel.id,
    appNotificationChannel.name,
    channelDescription: appNotificationChannel.description,
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/launcher_icon',
  ),
  iOS: const DarwinNotificationDetails(),
);
