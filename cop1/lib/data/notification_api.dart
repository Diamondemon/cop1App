import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_init;
import 'package:timezone/timezone.dart' as tz;

class NotificationAPI {
 static final _notifications = FlutterLocalNotificationsPlugin();
 static late final tz.Location _location;

 static Future<bool?> initialize() async {
   const android = AndroidInitializationSettings('@mipmap/ic_launcher');
   const iOS = IOSInitializationSettings();
   const initSettings = InitializationSettings(android: android, iOS: iOS);
   tz_init.initializeTimeZones();
   final locationName = await FlutterNativeTimezone.getLocalTimezone();
   _location = tz.getLocation(locationName);
   tz.setLocalLocation(_location);
   return await _notifications.initialize(initSettings);
 }

 static Future _notificationDetails() async {
   return const NotificationDetails(
     android: AndroidNotificationDetails(
       'C0P1',
       'COP1 channel',
       channelDescription: 'Notification channel for COP1 events.',
       importance: Importance.max,
       styleInformation: BigTextStyleInformation('')
     ),
     iOS: IOSNotificationDetails(),
   );
 }

 static Future<void> showNotif({
  int id=0,
   String? title,
   String? body,
   String? payload,
}) async => _notifications.show(id, title, body, await _notificationDetails(), payload: payload);

 static Future<void> scheduleEventNotification({
   int id=0,
   required String title,
   required String text,
   required DateTime scheduledDate,
   String? payload,
 }) async {
   return _notifications.zonedSchedule(
       id,
       title,
       text ,
       tz.TZDateTime.from(scheduledDate, _location),
       await _notificationDetails(),
       androidAllowWhileIdle: true,
       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
       payload: payload
   );
 }

 static void cancel(int id) => _notifications.cancel(id);

 static void cancelAll() => _notifications.cancelAll();

}