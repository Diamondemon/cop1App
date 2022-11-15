import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz_init;
import 'package:timezone/timezone.dart' as tz;

/// Class to manage the app notifications scheduling
class NotificationAPI {
  static final _notifications = FlutterLocalNotificationsPlugin();
  /// Stream used to add a reaction to opening the app through a notification
  static final onNotifications = BehaviorSubject<String?>();
  static late final tz.Location _location;

  /// Tells if the app has been launched through clicking a notification
  static Future<String?> get hasLaunchedApp async => (await _notifications.getNotificationAppLaunchDetails())?.payload;

  /// Initializes all the notifications API
  static Future<bool?> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = IOSInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: iOS);
    tz_init.initializeTimeZones();
    final locationName = await FlutterNativeTimezone.getLocalTimezone();
    _location = tz.getLocation(locationName);
    tz.setLocalLocation(_location);
    return await _notifications.initialize(
      initSettings,
      onSelectNotification: onSelectNotification
    );
  }

  /// Adds a notification to react to, by providing the [payload]
  static void onSelectNotification(String? payload){
    onNotifications.add(payload);
  }

  /// Returns details about the notification channel for the app
  static NotificationDetails _notificationDetails() {
     return const NotificationDetails(
      android: AndroidNotificationDetails(
        'C0P1',
        'COP1 channel',
        channelDescription: 'Notification channel for COP1 events.',
        importance: Importance.max, // Enables the banner display and the sounds for the notifications
        styleInformation: BigTextStyleInformation('') // To have all the text visible
      ),
      iOS: IOSNotificationDetails(),
    );
  }

  /// Immediately shows a notification with [title], [body].
  ///
  /// [payload] provides information to the notification API if the app launched through clicking the notification
  /// [id] is used to identify the notification to the operating system.
  static Future<void> showNotif({
    int id=0,
    String? title,
    String? body,
    String? payload,
  }) async {
     if ((await NotificationPermissions.getNotificationPermissionStatus()) == PermissionStatus.denied) return;
      _notifications.show(id, title, body, _notificationDetails(), payload: payload);
  }

  /// Schedules a notification with [title] and [text] as the body, on the [scheduledDate]
  ///
  /// [payload] provides information to the notification API if the app launched through clicking the notification.
  /// [id] is used to identify the notification to the operating system.
  static Future<void> scheduleEventNotification({
    int id=0,
    required String title,
    required String text,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if ((await NotificationPermissions.getNotificationPermissionStatus()) == PermissionStatus.denied) return;
    return _notifications.zonedSchedule(
       id,
       title,
       text ,
       tz.TZDateTime.from(scheduledDate, _location),
       _notificationDetails(),
       androidAllowWhileIdle: true,
       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
       payload: payload
    );
  }

  /// Cancels the notification identified by [id]
  static void cancel(int id) => _notifications.cancel(id);

  /// Cancels all notifications from this app
  static void cancelAll() => _notifications.cancelAll();

}