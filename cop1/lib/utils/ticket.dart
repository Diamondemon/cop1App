
class Ticket {
  final int id;
  final int eventId;
  final String name;
  bool isAvailable;

  Ticket(this.id, this.eventId, this.name, this.isAvailable);

  Ticket.fromJSON(this.eventId, Map<String, dynamic> json) :
        id = json["id"],
        name = json["name"],
        isAvailable = json["available"]
  ;

}