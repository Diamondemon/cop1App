import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cop1/common.dart';
import 'package:cop1/data/notification_api.dart';
import 'maps_launcher.dart';

class Cop1Event {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final String duration;
  final String location;
  final String imageLink;

  bool get isPast => date.isBefore(DateTime.now());

  Cop1Event(this.id, this.title, this.description, this.date, this.duration, this.location, this.imageLink);

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

  static Cop1Event fromJSON(Map<String, dynamic> json){
    return Cop1Event(
        int.tryParse(json["id"])??-1,
        json["title"]??"Sans titre",
        json["desc"]??"Sans description",
        DateTime.parse(json["date"]),
        json["duration"]??"01:00",
        json["loc"],
        json["img"]??"",
    );
  }

  void addToCalendar(){
    final Event event = Event(
      title: title,
      description: title,
      location: location,
      startDate: date,
      endDate: date.add(Duration(hours:int.parse(duration.split(":")[0]))),
      timeZone: DateTime.now().timeZoneName,
    );
    Add2Calendar.addEvent2Cal(event);
  }

  void lookoutLocationOnMaps(){
    MapsLauncher.launchQuery(location);
  }

  void scheduleNotifications(AppLocalizations localizations){
    if (scheduleHourPriorNotification(localizations)) scheduleDayPriorNotification(localizations);
  }

  void showImmediateNotification(AppLocalizations localizations){
    final text = localizations.notificationsMessage(title, date, date);
    if (!isPast) {
      NotificationAPI.showNotif(
          id: 10 * id + 2,
          title: title,
          body: text,
          payload: "/event/$id"
      );
    }
  }

  bool scheduleHourPriorNotification(AppLocalizations localizations) {
    final text = localizations.notificationsMessage(title, date, date);
    final notifyDate = date.subtract(const Duration(hours: 2));
    if (DateTime.now().compareTo(notifyDate) < 0){
      NotificationAPI.scheduleEventNotification(
          id: 10 * id,
          title: title,
          text: text,
          scheduledDate: notifyDate,
          payload: "/event/$id"
      );
      return true;
    }
    else {
      showImmediateNotification(localizations);
      return false;
    }
  }

  bool scheduleDayPriorNotification(AppLocalizations localizations){
    final text = localizations.notificationsMessage(title, date, date);
    final notifyDate = date.subtract(const Duration(days: 1));
    if (DateTime.now().compareTo(notifyDate) < 0){
      NotificationAPI.scheduleEventNotification(
          id: 10*id+1,
          title: title,
          text: text,
          scheduledDate: notifyDate,
          payload: "/event/$id"
      );
      return true;
    }
    else {
      showImmediateNotification(localizations);
      return false;
    }
  }

  void cancelNotifications(){
    NotificationAPI.cancel(10*id+3);
    NotificationAPI.cancel(10*id+1);
    NotificationAPI.cancel(10*id);
  }

}