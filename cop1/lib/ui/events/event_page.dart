import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cop1/constants.dart';
import 'package:cop1/data/session_data.dart';
import 'package:cop1/ui/common/loading_widget.dart';
import 'package:cop1/ui/common/unknown_error_widget.dart';
import 'package:cop1/utils/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sentry/sentry.dart';

import '../../common.dart';
import '../../utils/cop1_event.dart';

/// Page containing complete information about the event identified by [eventId]
class EventPage extends StatefulWidget {
  const EventPage({Key? key, @PathParam() required this.eventId}) : super(key: key);
  final int eventId;

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext ctxt) {
    return FutureBuilder(
      future: session(ctxt).getEvent(widget.eventId),
      builder: (context, AsyncSnapshot<Cop1Event> snapshot){
        if (snapshot.connectionState == ConnectionState.done){
          if (snapshot.hasError && snapshot.error is! SocketException){
            Sentry.captureException(snapshot.error, stackTrace: snapshot.stackTrace);
            return UnknownErrorWidget(callBack: (ctx){setState(() {});});
          }
          else if (snapshot.data==null){
            Sentry.captureMessage("Snapshot data is null for event id ${widget.eventId}");
            return UnknownErrorWidget(callBack: (ctx){setState(() {});});
          }
          else {
            return _buildScaffold(context, snapshot.data!);
          }
        }
        else {
          return const LoadingWidget();
        }
      },
    );
  }

  /// Builds the page with a [Scaffold]
  Widget _buildScaffold(BuildContext context, Cop1Event event){
    return Scaffold(
        appBar: AppBar(
          title: Text(event.title),
          actions: session(context).isConnected? [_buildQRCodeButton(context)] : [],
          leading: const AutoLeadingButton(),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
          child: _buildListView(context, event),
        )
    );
  }

  /// Builds all the information in a [ListView]
  Widget _buildListView(BuildContext context, Cop1Event event){
    return ListView(
      children: [
        Text(event.title, style: Theme.of(context).textTheme.headlineSmall,),
        const SizedBox(height: 10,),
        _buildImage(context, event),
        const SizedBox(height: 10,),
        _buildIconText(context, Icons.calendar_month, " ${AppLocalizations.of(context)!.calendar}"),
        TextButton(onPressed: event.addToCalendar,
            child: Text(
                DateFormat.yMEd(AppLocalizations.of(context)!.localeName).add_jm().format(event.date),
                style: const TextStyle(fontSize: 12)
            )
        ),
        _buildIconText(context, CupertinoIcons.location, " ${AppLocalizations.of(context)!.place}"),
        TextButton(onPressed: event.lookoutLocationOnMaps, child:Text(event.location, style: const TextStyle(fontSize: 12))),
        _buildIconText(context, CupertinoIcons.timer, " ${AppLocalizations.of(context)!.duration}"),
        Padding(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(event.duration)
        ),
        const SizedBox(height: 10,),
        _buildIconText(context, CupertinoIcons.info, " ${AppLocalizations.of(context)!.complemInfo}"),
        const SizedBox(height: 5,),
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

  /// Builds the image of the event
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

  /// Builds the button in the top [AppBar], to display the QR Code of the registration, if any
  Widget _buildQRCodeButton(BuildContext context){
    return FutureBuilder(
      future: session(context).user,
      builder: (BuildContext context, AsyncSnapshot<UserProfile?> snapshot){
        if (snapshot.connectionState == ConnectionState.done){
          if (snapshot.hasError && snapshot.error is! SocketException){
            Sentry.captureException(snapshot.error, stackTrace: snapshot.stackTrace);
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
                onPressed: ()=>_displayQRCodeAlert(context, user.barcodes[widget.eventId]!),
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

  /// Displays the QR Code containing the [code]
  void _displayQRCodeAlert(BuildContext context, String code){
    showDialog(
        context: context,
        builder:
          (BuildContext alertContext){
            return _buildQRCodeAlert(alertContext, code);
          });
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

  /// Builds the QR Code identifying the user to Weezevent with [code]
  Dialog _buildQRCodeAlert(BuildContext context, String code){
    return Dialog(
      child: SizedBox(
        height: MediaQuery.of(context).size.width*0.8,
        width: MediaQuery.of(context).size.width*0.8,
        child: QrImage(
          data: code,
          version: QrVersions.auto,
          embeddedImage: const AssetImage(logoUrl),
          embeddedImageStyle: QrEmbeddedImageStyle(
            size: Size(MediaQuery.of(context).size.width*0.1, MediaQuery.of(context).size.width*0.1)
          ),
        )
      )
    );
  }
}
