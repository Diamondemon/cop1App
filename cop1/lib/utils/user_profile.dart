import 'package:cop1/common.dart';
import 'package:cop1/utils/cop1_event.dart';
import 'package:cop1/utils/set_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';


@HiveType(typeId: 2)
class UserProfile extends HiveObject{

  @HiveField(0)
  ValueNotifier<String> firstName=ValueNotifier("");
  @HiveField(1)
  ValueNotifier<String> lastName=ValueNotifier("");
  @HiveField(2)
  final String _phoneNumber;
  @HiveField(3)
  ValueNotifier<String> email=ValueNotifier("");
  @HiveField(4)
  SetNotifier<int> events = SetNotifier();
  @HiveField(5)
  SetNotifier<int> pastEvents = SetNotifier();
  @HiveField(6)
  Map<int, String> barcodes = {};
  @HiveField(7)
  int minDelayDays = 0;

  String get phoneNumber => _phoneNumber;

  UserProfile(this._phoneNumber);

  void subscribeToEvent(Cop1Event event, String barcode){
    if (!event.isPast){
      events.add(event.id);
      barcodes[event.id]=barcode;
    }
  }

  int checkEventConflicts(Cop1Event newEvent, List<Cop1Event> allEvents){
    final DateTime newDayStart = DateTime(newEvent.date.year, newEvent.date.month, newEvent.date.day);
    final int conflictingId = [...events, ...pastEvents].firstWhere(
      (eventId) {
        final Cop1Event event = allEvents.firstWhere((evt) => evt.id == eventId);
        final DateTime dayStart = DateTime(event.date.year, event.date.month, event.date.day);
        final int deltaDays = (dayStart.difference(newDayStart).inDays).abs();
        if (deltaDays <= minDelayDays) return true;
        return false;
      },
      orElse: ()=>-1,
    );

    return conflictingId;
  }

  void unsubscribeFromEvent(Cop1Event event){
    int toRemove = events.firstWhere((eventId) => eventId == event.id);
    events.remove(toRemove);
  }

  bool isSubscribedToId(int id){
    return events.contains(id);
  }

  bool isSubscribedTo(Cop1Event event){
    return events.contains(event.id);
  }

  static UserProfile fromJSON(Map<String, dynamic> json){
    final user = UserProfile(json["phone"]);
    user.firstName.value = json["first_name"];
    user.lastName.value = json["last_name"];
    user.email.value = json["email"];
    user.minDelayDays = json["min_event_delay_days"];
    for (var item in (json["events"] as List).reversed) {
      final Cop1Event event = Cop1Event.fromJSON(item);
      if (event.isPast){
        user.pastEvents.add(event.id);
      }
      else {
        user.subscribeToEvent(event, item["barcode"]);
      }
    }
    return user;
  }

  @override
  String toString(){
    return "User ${firstName.value} ${lastName.value}, identified by phone number $phoneNumber.\nMail: ${email.value}\nSubscribed to events $events";
  }

  void scheduleUserNotifications(List<Cop1Event> evts, AppLocalizations localizations){
    cancelUserNotifications(evts);
    for (Cop1Event element in evts) {
      if (events.contains(element.id)) element.scheduleNotifications(localizations);
    }
  }

  void cancelUserNotifications(List<Cop1Event> evts){
    for (Cop1Event element in evts){
      if (events.contains(element.id)) element.cancelNotifications();
    }
  }

}


class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 2;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      fields[2] as String,
    )
      ..firstName = fields[0] as ValueNotifier<String>
      ..lastName = fields[1] as ValueNotifier<String>
      ..email = fields[3] as ValueNotifier<String>
      ..events = SetNotifier.fromList((fields[4] as List).cast<int>())
      ..pastEvents = SetNotifier.fromList((fields[5] as List).cast<int>())
      ..barcodes = (fields[6] as Map).cast<int, String>()
      ..minDelayDays = fields[7] as int;
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.firstName)
      ..writeByte(1)
      ..write(obj.lastName)
      ..writeByte(2)
      ..write(obj._phoneNumber)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.events.toList())
      ..writeByte(5)
      ..write(obj.pastEvents.toList())
      ..writeByte(6)
      ..write(obj.barcodes)
      ..writeByte(7)
      ..write(obj.minDelayDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserProfileAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}