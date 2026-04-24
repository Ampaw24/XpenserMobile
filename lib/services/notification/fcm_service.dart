import 'dart:async';

import 'package:expenser/services/user_profile_service.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/core/router/app_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService(ref));

/// Android notification channel used for all app notifications.
const _channel = AndroidNotificationChannel(
  'xpenser_general',
  'Xpenser Notifications',
  description: 'Budget alerts, savings updates and reminders',
  importance: Importance.high,
);

class FcmService {
  FcmService(this._ref);

  final Ref _ref;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Call once after a successful login.
  Future<void> initialize(String uid) async {

    await _initLocalNotifications();
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

    // Create the Android channel (no-op if it already exists).
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
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
  }

  // ---------------------------------------------------------------------------

  void _onForeground(RemoteMessage message) {
    final settings = _ref.read(settingsProvider);
    if (!settings.notificationsEnabled) return;

    final notification = message.notification;
    if (notification == null) return;

    _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['route'],
    );
  }

  void _onLocalNotifTap(NotificationResponse response) {
    final route = response.payload;
    _navigate(route);
  }

  void _handleTap(RemoteMessage message) {
    _navigate(message.data['route'] as String?);
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
