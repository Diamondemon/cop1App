import 'package:cop1/data/cop1_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cop1/maps_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'dart:developer' as developer;

class EventTile extends StatefulWidget {
  const EventTile({Key? key, required this.event}) : super(key: key);
  final Cop1Event event;

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height/4,
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
                    Image.network(widget.event.imageLink, fit: BoxFit.fill, height: MediaQuery.of(context).size.height/7),
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
                      TextButton(onPressed: () => _addToCalendar(widget.event.date), child:Text(widget.event.date)),
                      const Spacer(),
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
                      TextButton(onPressed: _lookOnMaps, child:Text(widget.event.location)),
                      const Spacer(),
                      Center(
                        child: RawMaterialButton(
                          onPressed: _participate,
                          fillColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text("Je m'inscris", style: Theme.of(context).primaryTextTheme.bodyLarge),
                        ),
                      )
                    ]
                  )
              )
            ]
        )
    );
  }

  void _participate(){

  }

  void _addToCalendar(String date){
    final Event event = Event(
      title: widget.event.title,
      description: widget.event.title,
      location: widget.event.location,
      startDate: DateTime.parse(date),
      endDate: DateTime.parse(date),
    );
    Add2Calendar.addEvent2Cal(event);
  }

  void _lookOnMaps(){
    MapsLauncher.launchQuery(widget.event.location);
  }

}
