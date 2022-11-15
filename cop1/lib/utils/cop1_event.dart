import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cop1/common.dart';
import 'package:cop1/data/notification_api.dart';
import 'package:hive/hive.dart';
import 'maps_launcher.dart';

part 'cop1_event.g.dart';

/// Class for events organized by COP1
@HiveType(typeId: 0)
class Cop1Event extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final String duration;
  @HiveField(5)
  final String location;
  @HiveField(6)
  final String imageLink;
  @HiveField(7, defaultValue: true)
  bool isAvailable;

  bool get isPast => date.isBefore(DateTime.now());

  Cop1Event(this.id, this.title, this.description, this.date, this.duration, this.location, this.imageLink, this.isAvailable);

  @override
  bool operator ==(Object other){
    if (identical(this, other)){
      return true;
    }
    if (other is int){
      return id == other;
    }
    if (other.runtimeType != runtimeType){
      return false;
    }
    return other is Cop1Event
        && other.id == id;
  }

  @override
  int get hashCode => Object.hash(id, title);

  /// Creates a [Cop1Event] object from the provided [json]
  static Cop1Event fromJSON(Map<String, dynamic> json){
    return Cop1Event(
        int.tryParse(json["id"])??-1,
        json["title"]??"Sans titre",
        json["desc"]??"Sans description",
        DateTime.parse(json["date"]),
        json["duration"]??"01:00",
        json["loc"],
        json["img"]??"",
        json["is_available"]??true
    );
  }

  /// Adds the [Cop1Event] to the phone's agenda
  void addToCalendar(){
    final Event event = Event(
      title: title,
      description: description,
      location: location,
      startDate: date,
      endDate: date.add(Duration(hours:int.parse(duration.split(":")[0]), minutes: int.parse(duration.split(":")[1]))),
      timeZone: DateTime.now().timeZoneName,
    );
    Add2Calendar.addEvent2Cal(event);
  }

  /// Researches the [location] on a maps app
  void lookoutLocationOnMaps(){
    MapsLauncher.launchQuery(location);
  }

  /// Schedules all notifications for the event
  ///
  /// [localizations] are for translation
  void scheduleNotifications(AppLocalizations localizations){
    if (scheduleHourPriorNotification(localizations)) scheduleDayPriorNotification(localizations);
  }

  /// Immediately show a notification for the event
  ///
  /// [localizations] are for translation
  void showImmediateNotification(AppLocalizations localizations){
    final text = localizations.notificationsMessage(title, date, date);
    if (!isPast) {
      NotificationAPI.showNotif(
          id: 10 * id + 2,
          title: title,
          body: text,
          payload: "events/$id"
      );
    }
  }

  /// Schedules a notifications for the event, 2 hours before the [date]
  ///
  /// [localizations] are for translation
  bool scheduleHourPriorNotification(AppLocalizations localizations) {
    final text = localizations.notificationsMessage(title, date, date);
    final notifyDate = date.subtract(const Duration(hours: 2));
    if (DateTime.now().compareTo(notifyDate) < 0){
      NotificationAPI.scheduleEventNotification(
          id: 10 * id,
          title: title,
          text: text,
          scheduledDate: notifyDate,
          payload: "/home/profile/$id"
      );
      return true;
    }
    else {
      showImmediateNotification(localizations);
      return false;
    }
  }

  /// Schedules a notifications for the event, 1 day before the [date]
  ///
  /// [localizations] are for translation
  bool scheduleDayPriorNotification(AppLocalizations localizations){
    final text = localizations.notificationsMessage(title, date, date);
    final notifyDate = date.subtract(const Duration(days: 1));
    if (DateTime.now().compareTo(notifyDate) < 0){
      NotificationAPI.scheduleEventNotification(
          id: 10*id+1,
          title: title,
          text: text,
          scheduledDate: notifyDate,
          payload: "/home/profile/$id"
      );
      return true;
    }
    else {
      showImmediateNotification(localizations);
      return false;
    }
  }

  /// Cancels all notifications related to this event
  void cancelNotifications(){
    NotificationAPI.cancel(10*id+3);
    NotificationAPI.cancel(10*id+1);
    NotificationAPI.cancel(10*id);
  }

}