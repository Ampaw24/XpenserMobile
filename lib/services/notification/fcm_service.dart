import 'dart:async';

import 'package:expenser/core/router/app_router.dart';
import 'package:expenser/models/notification_record.dart';
import 'package:expenser/services/notification/notification_channel.dart';
import 'package:expenser/services/user_profile_service.dart';
import 'package:expenser/viewmodels/notification_history_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService(ref));

class FcmService {
  FcmService(this._ref);

  final Ref _ref;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  StreamSubscription<String>? _tokenRefreshSub;
  Future<void>? _localInit;

  /// Call once after a successful login.
  Future<void> initialize(String uid) async {
    await ensureLocalNotificationsReady();
    await _requestPermission();
    await _registerToken(uid);

    // Token rotations — keep RTDB in sync.
    _tokenRefreshSub = _fcm.onTokenRefresh.listen((token) {
      _saveToken(uid, token);
    });

    // Foreground: FCM does not show UI — we do it via local notifications.
    _foregroundSub = FirebaseMessaging.onMessage.listen(_onForeground);

    // Background tap: app was backgrounded and user tapped a notification.
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // Terminated tap: app was fully closed; check for a pending notification.
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleTap(initial);
  }

  /// Call on logout to stop listening and clean up.
  void dispose() {
    _foregroundSub?.cancel();
    _openedSub?.cancel();
    _tokenRefreshSub?.cancel();
  }

  /// Sets up local notifications once per app run. Safe to call before
  /// [initialize], e.g. when scheduling reminders on a restored session.
  Future<void> ensureLocalNotificationsReady() =>
      _localInit ??= _initLocalNotifications();

  // ---------------------------------------------------------------------------

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotif.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotifTap,
    );

    final android =
        _localNotif
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    // Android 13+ (API 33) requires POST_NOTIFICATIONS at runtime.
    await android?.requestNotificationsPermission();

    // Create the channel (no-op if it already exists).
    await android?.createNotificationChannel(appNotificationChannel);
  }

  Future<void> _requestPermission() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    // Deliver foreground notifications on iOS as banners.
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _registerToken(String uid) async {
    final token = await _fcm.getToken();
    if (token != null) await _saveToken(uid, token);
  }

  Future<void> _saveToken(String uid, String token) async {
    await UserProfileService().updateFcmToken(uid, token);
    debugPrint('════════════════════════════════════════');
    debugPrint('FCM TOKEN: $token');
    debugPrint('════════════════════════════════════════');
  }

  // ---------------------------------------------------------------------------

  void _onForeground(RemoteMessage message) {
    final settings = _ref.read(settingsProvider);
    if (!settings.notificationsEnabled) return;

    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? '';
    final body = notification.body ?? '';
    final route = message.data['route'] as String?;

    _localNotif.show(
      notification.hashCode,
      title,
      body,
      appNotificationDetails(),
      payload: route,
    );

    final record = NotificationRecord(
      id: const Uuid().v4(),
      title: title,
      body: body,
      type: 'fcm',
      route: route,
      createdAt: DateTime.now(),
    );
    _ref.read(notificationHistoryProvider.notifier).add(record);
  }

  void _onLocalNotifTap(NotificationResponse response) {
    final route = response.payload;
    _navigate(route);
  }

  void _handleTap(RemoteMessage message) {
    _navigate(message.data['route'] as String?);
  }

  /// Show a local notification triggered by an in-app action (e.g. creating an
  /// account or savings goal). Persists to Hive + Firebase and respects the
  /// user's notification setting.
  /// Pass a stable [id] to record a one-off event so it can be de-duplicated.
  Future<void> showLocalNotification({
    required String title,
    required String body,
    required String type,
    String? route,
    String? id,
  }) async {
    final settings = _ref.read(settingsProvider);
    if (!settings.notificationsEnabled) return;

    await _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      appNotificationDetails(),
      payload: route,
    );

    final record = NotificationRecord(
      id: id ?? const Uuid().v4(),
      title: title,
      body: body,
      type: type,
      route: route,
      createdAt: DateTime.now(),
    );
    await _ref.read(notificationHistoryProvider.notifier).add(record);
  }

  void _navigate(String? route) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    final destination = _resolveRoute(route);
    context.go(destination);
  }

  String _resolveRoute(String? route) {
    const valid = {
      '/shell/dashboard',
      '/shell/budgets',
      '/shell/transactions',
      '/shell/accounts',
      '/savings',
    };
    if (route != null && valid.contains(route)) return route;
    return '/shell/dashboard';
  }
}
