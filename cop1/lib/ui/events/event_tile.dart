import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cop1/utils/cop1_event.dart';
import 'package:cop1/ui/events/subscribe_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';

import '../../common.dart';

/// List Tile to display the most important about an [event]
class EventTile extends StatefulWidget {
  const EventTile({Key? key, required this.event }) : super(key: key);
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
        decoration: BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(color: Theme.of(context).primaryColor, width:3.0)
          ),
        ),
        padding: const EdgeInsets.only(top: 10.0, bottom: 5.0, right:10.0, left:10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.event.title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.start,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildImage(context)
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
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
                      TextButton(
                          onPressed: widget.event.lookoutLocationOnMaps,
                          child:Text(
                              widget.event.location,
                              style: const TextStyle(fontSize: 12)
                          )
                      ),
                      Center(
                        child: SubscribeButton(event: widget.event),
                      )
                    ],
                  )
                ),
              ]
            )
          ]
        )
      ),
    );
  }

  /// Builds the image of the event
  Widget _buildImage(BuildContext context){
    final double imageSize = MediaQuery.of(context).size.width/(2*MediaQuery.of(context).textScaleFactor);
    return CachedNetworkImage(
        imageUrl: widget.event.imageLink,
        width: imageSize,
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

  /// Navigates to a more complete info about the event
  void _openEventPage(BuildContext context){
    AutoRouter.of(context).navigateNamed(
      "${widget.event.id}",
      onFailure: (NavigationFailure failure)=> Sentry.captureException(failure)
    );
  }

  /// Builds a label containing the [text] with a leading [icon]
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
