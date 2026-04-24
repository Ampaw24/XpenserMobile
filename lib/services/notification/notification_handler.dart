import 'package:expenser/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Must be a top-level function — FCM invokes it in an isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // System tray notification is shown automatically by FCM for notification
  // payloads. Data-only payloads can be processed here if needed.
}
