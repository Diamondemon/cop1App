import 'dart:io';

import 'package:cop1/data/session_data.dart';
import 'package:cop1/utils/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../utils/cop1_event.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key, required this.eventId}) : super(key: key);
  final int eventId;

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    final Cop1Event event = session(context).getEvent(widget.eventId);
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: session(context).isConnected? [_buildQRCodeButton(context)] : [],
      ),
      body: ListView(
          children: [
            Text(event.title, style: Theme.of(context).textTheme.headlineSmall,),
            _buildImage(context, event),
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
            TextButton(onPressed: event.addToCalendar,
                child: Text(
                    "${event.date} ${event.hour}",
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
            TextButton(onPressed: event.lookoutLocationOnMaps, child:Text(event.location, style: const TextStyle(fontSize: 12))),
            const Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Icon(CupertinoIcons.timer, size: 14),
                  ),
                  TextSpan(
                    text: " Durée",
                  ),
                ],
              ),
            ),
            Text(event.duration),
            const Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Icon(CupertinoIcons.info, size: 14),
                  ),
                  TextSpan(
                    text: " Informations complémentaires",
                  ),
                ],
              ),
            ),
            Text(event.description),
          ],
        ),
    );
  }


  Widget _buildImage(BuildContext context, Cop1Event event){
    try {
      return Image.network(event.imageLink, fit: BoxFit.fill);
    }
    on SocketException {
      return const Icon(Icons.image_not_supported);
    }
  }


  Widget _buildQRCodeButton(BuildContext context){
    return FutureBuilder(
      future: session(context).user,
      builder: (BuildContext context, AsyncSnapshot<UserProfile?> snapshot){
        if (snapshot.connectionState == ConnectionState.done){
          if (snapshot.hasError && snapshot.error is! SocketException){
            //return Text(snapshot.error.toString());
            return Container();
          }
          else if (snapshot.data==null){
            return Container();
          }
          else {
            final UserProfile user = snapshot.data as UserProfile;
            return IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: ()=>_displayQRCodeAlert(context, "12345"),
            );
          }
        }
        else {
          return Container();
        }
      }
    );
  }

  void _displayQRCodeAlert(BuildContext context, String code){
    showDialog(
        context: context,
        builder:
          (BuildContext alertContext){
            return _buildQRCodeAlert(alertContext, code);
          });
  }


  Dialog _buildQRCodeAlert(BuildContext context, String code){
    return Dialog(
      child: SizedBox(
        height: MediaQuery.of(context).size.width*0.8,
        width: MediaQuery.of(context).size.width*0.8,
        child: QrImage(
          data: code,
          version: QrVersions.auto,
          embeddedImage: const AssetImage("assets/Logo CO_P1 512.png"),
          embeddedImageStyle: QrEmbeddedImageStyle(
            size: Size(MediaQuery.of(context).size.width*0.1, MediaQuery.of(context).size.width*0.1)
          ),
        )
      )
    );
  }
}
