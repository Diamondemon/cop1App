import 'package:cop1/utils/cop1_event.dart';
import 'package:cop1/utils/set_notifier.dart';
import 'package:flutter/foundation.dart';

class UserProfile{
  ValueNotifier<String> firstName=ValueNotifier("");
  ValueNotifier<String> lastName=ValueNotifier("");
  final String _phoneNumber;
  ValueNotifier<String> email=ValueNotifier("");
  final bool _isAdmin;
  SetNotifier<Cop1Event> events = SetNotifier();

  String get phoneNumber => _phoneNumber;
  bool get isAdmin =>_isAdmin;

  UserProfile(this._phoneNumber, [this._isAdmin = false]);

  void subscribeToEvent(Cop1Event event){
    events.add(event);
    event.scheduleNotifications();
  }

  void unsubscribeFromEvent(int id){
    Cop1Event toRemove = events.firstWhere((event) => event.id == id);
    toRemove.cancelNotifications();
    events.remove(toRemove);
  }

  bool isSubscribedToId(int id){
    return events.any((item){return item.id == id;});
  }

  bool isSubscribedTo(Cop1Event event){
    return events.contains(event);
  }

  static UserProfile fromJSON(Map<String, dynamic> json){
    final user = UserProfile(json["phone"]);
    user.firstName.value = json["first_name"];
    user.lastName.value = json["last_name"];
    user.email.value = json["email"];
    for (var item in json["events"]) {
      user.subscribeToEvent(Cop1Event.fromJSON(item));
    }
    return user;
  }

  @override
  String toString(){
    return "User $firstName.value $lastName.value, identified by phone number $phoneNumber.\nMail: $email.value\nSubscribed to events $events";
  }

  void scheduleUserNotifications(){
    for (Cop1Event element in events) {
      element.cancelNotifications();
      element.scheduleNotifications();
    }
  }

}