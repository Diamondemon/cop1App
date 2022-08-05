import 'dart:io';
import 'dart:math';

import 'package:cop1/ui/event_page.dart';
import 'package:cop1/utils/cop1_event.dart';
import 'package:cop1/ui/subscribe_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class EventTile extends StatefulWidget {
  const EventTile({Key? key, required this.event}) : super(key: key);
  final Cop1Event event;

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()=> _openEventPage(context),
      child: Container(
        height: (MediaQuery.of(context).size.height/4)*MediaQuery.of(context).textScaleFactor,
        decoration: BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(color: Theme.of(context).primaryColor, width:3.0)
          ),
        ),
        padding: const EdgeInsets.only(top: 10.0, bottom: 5.0, right:10.0, left:10.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    _buildImage(context),
                    const Spacer(),
                  ]
              )
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Icon(Icons.calendar_month, size: 14),
                        ),
                        TextSpan(
                          text: " Calendrier",
                        ),
                      ],
                    ),
                  ),
                  TextButton(onPressed: widget.event.addToCalendar,
                      child: Text(
                          "${widget.event.date} ${widget.event.hour}",
                          style: const TextStyle(fontSize: 12)
                      )
                  ),
                  const Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Icon(CupertinoIcons.location, size: 14),
                        ),
                        TextSpan(
                          text: " Lieu",
                        ),
                      ],
                    ),
                  ),
                  TextButton(onPressed: widget.event.lookoutLocationOnMaps, child:Text(widget.event.location, style: const TextStyle(fontSize: 12))),
                  const Spacer(),
                  Expanded(flex: 2, child: Center(
                      child: SubscribeButton(event: widget.event),
                    )
                  )
                ]
              )
            )
          ]
        )
      ),
    );
  }

  Widget _buildImage(BuildContext context){
    try {
      return Image.network(widget.event.imageLink, fit: BoxFit.fill, height: MediaQuery.of(context).size.height/7*min(1, MediaQuery.of(context).textScaleFactor));
    }
    on SocketException {
      return const Icon(Icons.image_not_supported);
    }
  }

  void _openEventPage(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EventPage(eventId: widget.event.id)));
  }

}
