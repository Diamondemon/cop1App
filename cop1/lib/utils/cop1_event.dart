
class Cop1Event {
  final int id;
  final String title;
  final String date;
  final String location;
  final String imageLink;
  final String url;

  Cop1Event(this.id, this.title, this.date, this.location, this.imageLink, this.url);

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
  // TODO: implement hashCode
  int get hashCode => Object.hash(id, title);

  static Cop1Event fromJSON(Map<String, dynamic> json){
    return Cop1Event(json["id"], json["title"]??"Sans titre", json["date"], json["loc"], json["img"]??"", json["url"]);
  }

}