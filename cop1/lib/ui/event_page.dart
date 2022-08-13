import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cop1/data/session_data.dart';
import 'package:cop1/utils/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
        child: _buildListView(context, event),
      )

    );
  }

    Widget _buildListView(BuildContext context, Cop1Event event){
      return ListView(
        children: [
          Text(event.title, style: Theme.of(context).textTheme.headlineSmall,),
          const SizedBox(height: 10,),
          _buildImage(context, event),
          const SizedBox(height: 10,),
          _buildIconText(context, Icons.calendar_month, " Calendrier"),
          TextButton(onPressed: event.addToCalendar,
              child: Text(
                  //TODO make locale dynamic
                  DateFormat.yMEd("fr").add_jm().format(event.date),
                  style: const TextStyle(fontSize: 12)
              )
          ),
          _buildIconText(context, CupertinoIcons.location, " Lieu"),
          TextButton(onPressed: event.lookoutLocationOnMaps, child:Text(event.location, style: const TextStyle(fontSize: 12))),
          _buildIconText(context, CupertinoIcons.timer, " Durée"),
          Padding(padding: const EdgeInsets.all(5),
            child: Text(event.duration)
          ),
          _buildIconText(context, CupertinoIcons.info, " Informations complémentaires"),
          Padding(
            padding: const EdgeInsets.only(top:5, left: 10, right: 10),
            child: Text(
                event.description,
              textAlign: TextAlign.justify,
            ),
          )
        ],
      );
    }

  Widget _buildImage(BuildContext context, Cop1Event event){
    return CachedNetworkImage(
      imageUrl: event.imageLink,
      fit: BoxFit.fill,
      progressIndicatorBuilder: (BuildContext context, String url, DownloadProgress? progress){
        return Center(
          child: CircularProgressIndicator(value: progress?.progress),
        );
      },
      errorWidget: (BuildContext context, String url, error){
        return const Center(
            child: Icon(Icons.image_not_supported)
        );
      },
    );
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
            if (user.isSubscribedToId(widget.eventId)){
              return IconButton(
                icon: const Icon(Icons.qr_code),
                onPressed: ()=>_displayQRCodeAlert(context, "12345"),
              );
            }
            else {
              return Container();
            }
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
