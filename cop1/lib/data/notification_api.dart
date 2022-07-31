import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class NotificationAPI {
 static final _notifications = FlutterLocalNotificationsPlugin();

 static Future<bool?> initialize() async {
   const android = AndroidInitializationSettings('@mipmap/ic_launcher');
   const iOS = IOSInitializationSettings();
   const initSettings = InitializationSettings(android: android, iOS: iOS);
   return await _notifications.initialize(initSettings);
 }

 static Future _notificationDetails() async {
   return const NotificationDetails(
     android: AndroidNotificationDetails(
       'channel id',
       'channel name',
       channelDescription: 'channel description',
       importance: Importance.defaultImportance,
     ),
     iOS: IOSNotificationDetails(),
   );
 }

 static Future showNotif({
  int id=0,
   String? title,
   String? body,
   String? payload,
}) async => _notifications.show(id, title, body, await _notificationDetails(), payload: payload);

}