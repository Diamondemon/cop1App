
class Cop1Event {
  final int id;
  final String title;
  final String date;
  final String location;
  final String imageLink;

  Cop1Event(this.id, this.title, this.date, this.location, this.imageLink);

  @override
  bool operator ==(Object other){
    if (identical(this, other)){
      return true;
    }
    if (other.runtimeType != runtimeType){
      return false;
    }
    return other is Cop1Event
        && other.id == id;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(id, title);

}