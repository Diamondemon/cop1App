import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cop1/ui/event_page.dart';
import 'package:cop1/utils/cop1_event.dart';
import 'package:cop1/ui/subscribe_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../common.dart';


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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded (
              flex: 0,
              child: Text(
                widget.event.title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.start,
              )
            ),
            Expanded(
                child:Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            _buildIconText(context, Icons.calendar_month, " ${AppLocalizations.of(context)!.calendar}"),
                            TextButton(
                                onPressed: widget.event.addToCalendar,
                                child: Text(
                                    DateFormat.yMEd(AppLocalizations.of(context)!.localeName).add_jm().format(widget.event.date),
                                    style: const TextStyle(fontSize: 12)
                                )
                            ),
                            _buildIconText(context, CupertinoIcons.location, " ${AppLocalizations.of(context)!.place}"),
                            TextButton(onPressed: widget.event.lookoutLocationOnMaps, child:Text(widget.event.location, style: const TextStyle(fontSize: 12))),
                            const Spacer(),
                            Expanded(flex: 2, child: Center(
                              child: SubscribeButton(event: widget.event),
                            )
                            ),
                          ]
                      )
                  )
                ]
            ))
          ]
        )
      ),
    );
  }

  Widget _buildImage(BuildContext context){
    final double imageSize = MediaQuery.of(context).size.height/7*min(1, MediaQuery.of(context).textScaleFactor);
    return CachedNetworkImage(
        imageUrl: widget.event.imageLink,
        height: imageSize,
        fit: BoxFit.fill,
        progressIndicatorBuilder: (BuildContext context, String url, DownloadProgress? progress){
          return Center(
              child: CircularProgressIndicator(value: progress?.progress),
          );
        },
        errorWidget: (BuildContext context, String url, error){
          return Center(
                  child: Icon(Icons.image_not_supported, size: imageSize,)
          );
        },
    );
  }

  void _openEventPage(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EventPage(eventId: widget.event.id)));
  }


  Widget _buildIconText(BuildContext context, final IconData icon, final String text) {
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Icon(icon, size: 14),
          ),
          TextSpan(
            text: text,
          ),
        ],
      ),
    );
  }

}
