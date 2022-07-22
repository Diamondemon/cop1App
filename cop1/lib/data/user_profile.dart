
import 'package:cop1/data/cop1_event.dart';

class UserProfile{
  String? name;
  String? surname;
  final String _phoneNumber;
  String? email;
  final bool _isAdmin;
  Set<Cop1Event> events = {};

  String get phoneNumber => _phoneNumber;
  bool get isAdmin =>_isAdmin;

  UserProfile(this._phoneNumber, [this._isAdmin = false]);

  void subscribeToEvent(Cop1Event event){
    events.add(event);
  }

  void unsubscribeFromEvent(int id){
    events.remove(id);
  }

  bool isSubscribedToId(int id){
    return events.any((item){return item.id == id;});
  }

  bool isSubscribedTo(Cop1Event event){
    return events.contains(event);
  }

  static UserProfile fromJSON(Map<String, dynamic> json){
    final user = UserProfile(json["phone"]!);
    for (var item in json["events"]) {
      user.subscribeToEvent(Cop1Event.fromJSON(item));
    }
    return user;
  }

  @override
  String toString(){
    return "User $name $surname, identified by phone number $phoneNumber.\nMail: $email\nSubscribed to events $events";
  }

}