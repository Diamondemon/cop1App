import 'package:cop1/utils/cop1_event.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

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

 static Future scheduleEventNotification({required Cop1Event event}) async {
   final text = "N'oubliez pas votre évènement COP1 \"${event.title}\" "
       "le ${event.date}. Ne pas y aller alors que vous y êtes inscrit peut vous pénaliser!";
   return _notifications.zonedSchedule(
       10*event.id,
       event.title,
       text , 
       tz.TZDateTime.from(DateTime.parse(event.date), tz.getLocation(DateTime.now().timeZoneName)),
       await _notificationDetails(),
       androidAllowWhileIdle: true,
       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
       payload: "Hello there"
   );
 }

}