
class UserProfile{
  String? name;
  String? surname;
  final String _phoneNumber;
  String? email;
  final bool _isAdmin;
  Set<int> events = <int>{};

  String get phoneNumber => _phoneNumber;
  bool get isAdmin =>_isAdmin;

  UserProfile(this._phoneNumber, [this._isAdmin = false]);

  void subscribeToEvent(int id){
    events.add(id);
  }

  void unsubscribeFromEvent(int id){
    events.remove(id);
  }

  static UserProfile fromJSON(Map<String, dynamic> json){
    final user = UserProfile(json["phone"]!);
    for (var item in json["events"]) {
      user.subscribeToEvent(item["id"]);
    }
    return user;
  }

  @override
  String toString(){
    return "User $name $surname, identified by phone number $phoneNumber.\nMail: $email\nSubscribed to events $events";
  }

}