import 'package:cop1/common.dart';
import 'package:cop1/utils/cop1_event.dart';
import 'package:cop1/utils/set_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class UserProfile{
  ValueNotifier<String> firstName=ValueNotifier("");
  ValueNotifier<String> lastName=ValueNotifier("");
  final String _phoneNumber;
  ValueNotifier<String> email=ValueNotifier("");
  SetNotifier<int> events = SetNotifier();
  SetNotifier<int> pastEvents = SetNotifier();
  Map<int, String> barcodes = {};
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
    final int conflictingId = events.firstWhere(
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
    for (var item in json["events"]) {
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
    return "User $firstName.value $lastName.value, identified by phone number $phoneNumber.\nMail: $email.value\nSubscribed to events $events";
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