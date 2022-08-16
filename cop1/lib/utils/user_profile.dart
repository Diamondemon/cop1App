import 'package:cop1/utils/cop1_event.dart';
import 'package:cop1/utils/set_notifier.dart';
import 'package:flutter/foundation.dart';

class UserProfile{
  ValueNotifier<String> firstName=ValueNotifier("");
  ValueNotifier<String> lastName=ValueNotifier("");
  final String _phoneNumber;
  ValueNotifier<String> email=ValueNotifier("");
  final bool _isAdmin;
  SetNotifier<int> events = SetNotifier();
  SetNotifier<int> pastEvents = SetNotifier();
  Map<int, String> barcodes = {};

  String get phoneNumber => _phoneNumber;
  bool get isAdmin =>_isAdmin;

  UserProfile(this._phoneNumber, [this._isAdmin = false]);

  void subscribeToEvent(Cop1Event event, String barcode){
    if (!event.isPast){
      events.add(event.id);
      barcodes[event.id]=barcode;
      event.scheduleNotifications();
    }
  }

  void unsubscribeFromEvent(Cop1Event event){
    int toRemove = events.firstWhere((eventId) => eventId == event.id);
    event.cancelNotifications();
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
    for (var item in json["events"]) {
      final Cop1Event event = Cop1Event.fromJSON(item);
      if (event.isPast){
        user.pastEvents.add(event.id);
      }
      else {
        //TODO fix this
        user.subscribeToEvent(event, item["barcode"]);
      }
    }
    return user;
  }

  @override
  String toString(){
    return "User $firstName.value $lastName.value, identified by phone number $phoneNumber.\nMail: $email.value\nSubscribed to events $events";
  }

  void scheduleUserNotifications(List<Cop1Event> evts){
    cancelUserNotifications(evts);
    for (Cop1Event element in evts) {
      if (events.contains(element.id)) element.scheduleNotifications();
    }
  }

  void cancelUserNotifications(List<Cop1Event> evts){
    for (Cop1Event element in evts){
      if (events.contains(element.id)) element.cancelNotifications();
    }
  }

}