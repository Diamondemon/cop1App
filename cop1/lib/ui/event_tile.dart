import 'package:flutter/material.dart';

class EventTile extends StatefulWidget {
  const EventTile({Key? key, required this.event}) : super(key: key);
  final Map<String, dynamic> event;

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height/5,
        decoration: BoxDecoration(
          border: Border.symmetric(horizontal: BorderSide(color: Theme.of(context).primaryColor, width:3.0)
          ),
        ),
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text("Event ${widget.event["id"]} on date ${widget.event["date"]}")
        ),
    );
  }
}
