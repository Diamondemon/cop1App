
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

}