
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class VaksinNotification {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    var iOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    var settings =
        InitializationSettings(android: android, iOS: iOS, macOS: iOS);
    await notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) async {},
    );
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
            'android_channel', 'Stunt App Android Channel',
            importance: Importance.defaultImportance),
        iOS: DarwinNotificationDetails());
  }

  Future vaksinNotif(
      {int notifID = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
        notifID, title, body, await notificationDetails());
  }

  Future scheduleVaksinNotif(
      {int notifID = 0, String? title, String? body, String? payLoad,required String tanggal}) async {
    DateTime date = DateFormat('yyyy-MM-dd HH:mm').parse(tanggal);
    return notificationsPlugin.zonedSchedule(notifID, title, body,
        tz.TZDateTime.from(date, tz.local), await notificationDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}
