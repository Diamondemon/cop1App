
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cop1/data/notification_api.dart';

class Cop1Event {
  final int id;
  final String title;
  final String description;
  final String date;
  final String hour;
  final String duration;
  final String location;
  final String imageLink;
  final String url;

  bool get isPast => DateTime.parse("$date $hour").isBefore(DateTime.now());

  Cop1Event(this.id, this.title, this.description, this.date, this.hour, this.duration, this.location, this.imageLink, this.url);

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
        json["id"],
        json["title"]??"Sans titre",
        json["description"]??"Sans description",
        json["date"],
        json["hour"]??"08:00",
        json["duration"]??"01:00",
        json["loc"],
        json["img"]??"",
        json["url"]
    );
  }

  void addToCalendar(){
    final startDate = DateTime.parse("$date $hour");
    final Event event = Event(
      title: title,
      description: title,
      location: location,
      startDate: startDate,
      endDate: startDate.add(Duration(hours:int.parse(duration.split(":")[0]))),
      timeZone: DateTime.now().timeZoneName,
    );
    Add2Calendar.addEvent2Cal(event);
  }

  void scheduleNotifications(){
    //TODO Remove this on prod
    final text = "N'oubliez pas votre évènement COP1 \"$title\" "
        "le $date. Ne pas y aller alors que vous y êtes inscrit peut vous pénaliser!";
    NotificationAPI.scheduleEventNotification(
        id: 10*id+3,
        title: title,
        text: text,
        scheduledDate: DateTime.now().add(const Duration(seconds: 10)),
        payload: "/event/$id"
    );
    if (scheduleHourPriorNotification()) scheduleDayPriorNotification();
  }

  void showImmediateNotification(){
    final text = "N'oubliez pas votre évènement COP1 \"$title\" "
        "le $date à $hour. Ne pas y aller alors que vous y êtes inscrit peut vous pénaliser!";
    final eventDate = DateTime.parse("$date $hour");
    if (DateTime.now().compareTo(eventDate) <= 0) {
      NotificationAPI.showNotif(
          id: 10 * id + 2,
          title: title,
          body: text,
          payload: "/event/$id"
      );
    }
  }

  bool scheduleHourPriorNotification() {
    final text = "N'oubliez pas votre évènement COP1 \"$title\" "
        "le $date à $hour. Ne pas y aller alors que vous y êtes inscrit peut vous pénaliser!";
    final eventDate = DateTime.parse("$date $hour");
    if (DateTime.now().compareTo(eventDate.subtract(const Duration(days: 1))) < 0){
      NotificationAPI.scheduleEventNotification(
          id: 10 * id,
          title: title,
          text: text,
          scheduledDate: DateTime.parse("$date $hour").subtract(
              const Duration(days: 1)),
          payload: "/event/$id"
      );
      return true;
    }
    else {
      showImmediateNotification();
      return false;
    }
  }

  bool scheduleDayPriorNotification(){
    final text = "N'oubliez pas votre évènement COP1 \"$title\" "
        "le $date à $hour. Ne pas y aller alors que vous y êtes inscrit peut vous pénaliser!";
    final eventDate = DateTime.parse("$date $hour");
    if (DateTime.now().compareTo(eventDate.subtract(const Duration(hours: 2))) < 0){
      NotificationAPI.scheduleEventNotification(
          id: 10*id+1,
          title: title,
          text: text,
          scheduledDate: eventDate.subtract(const Duration(hours: 2)),
          payload: "/event/$id"
      );
      return true;
    }
    else {
      showImmediateNotification();
      return false;
    }
  }

  void cancelNotifications(){
    NotificationAPI.cancel(10*id+3);
    NotificationAPI.cancel(10*id+1);
    NotificationAPI.cancel(10*id);
  }

}