import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final _noti = FlutterLocalNotificationsPlugin();

  static Future init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _noti.initialize(settings);
  }

  static Future show(String title, String body) async {
    const android = AndroidNotificationDetails(
      'focuz_channel',
      'Pomodoro Timer',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: android);

    await _noti.show(0, title, body, details);
  }

  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      // Android 13+ requires POST_NOTIFICATIONS runtime permission.
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final iosImpl = _noti
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }
}
