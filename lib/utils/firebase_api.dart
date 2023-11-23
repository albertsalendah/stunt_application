// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stunt_application/custom_widget/navigation_bar.dart';
import 'package:stunt_application/pages/Konsultasi/konsultasi.dart';

import '../main.dart';
import '../pages/Konsultasi/konsultasi_api.dart';

KonsultasiAPI api = KonsultasiAPI();
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final senderID = message.data['senderID'];
  final receiverID = message.data['receiverID'];
  api.getLatestMessageFromServer(senderID: senderID, receiverID: receiverID);
  // print('Title : ${message.notification?.title}');
  // print('Body : ${message.notification?.body}');
  // print('Payload : ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _local_notifications = FlutterLocalNotificationsPlugin();
  final _androidChannel = const AndroidNotificationChannel(
      'android_channel', 'Stunt App Android Channel',
      description: 'Stunt App Notification',
      importance: Importance.defaultImportance);

  Future<String?> getTokenFCM() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    return fcmToken;
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState
        ?.pushNamed(Navigationbar.route, arguments: message);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    //local notifiacation
    FirebaseMessaging.onMessage.listen((event) {
      final notification = event.notification;
      if (notification == null) return;
      final notificationData = event.data;

      final senderID = notificationData['senderID'];
      final receiverID = notificationData['receiverID'];
      api.getLatestMessageFromServer(
          senderID: senderID, receiverID: receiverID);
      _local_notifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
                _androidChannel.id, _androidChannel.name,
                icon: '@drawable/ic_launcher'),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: jsonEncode(event.toMap()));
    });
  }

  Future initLocalNotification() async {
    var iOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    var settings =
        InitializationSettings(android: android, iOS: iOS, macOS: iOS);
    await _local_notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        final message = RemoteMessage.fromMap(jsonDecode(details.payload!));
        handleMessage(message);
      },
    );
    final platform = _local_notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }
}
