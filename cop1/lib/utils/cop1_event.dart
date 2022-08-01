
import 'package:add_2_calendar/add_2_calendar.dart';

class Cop1Event {
  final int id;
  final String title;
  final String date;
  final String hour;
  final String duration;
  final String location;
  final String imageLink;
  final String url;

  Cop1Event(this.id, this.title, this.date, this.hour, this.duration, this.location, this.imageLink, this.url);

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

}