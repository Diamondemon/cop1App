import 'dart:io';

import 'package:cop1/ui/loading_widget.dart';
import 'package:cop1/ui/socket_exception_widget.dart';
import 'package:cop1/ui/unknown_error_widget.dart';
import 'package:cop1/utils/cop1_event.dart';
import 'package:cop1/ui/event_tile.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';

import '../data/session_data.dart';
import '../utils/connected_widget_state.dart';

class EventList extends StatefulWidget {
  const EventList({Key? key}) : super(key: key);

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await _refreshList(context),
      child: FutureBuilder(
        future: session(context).events,
        builder: (BuildContext ctxt, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.hasError){
              if (snapshot.error is SocketException){
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  ConnectedWidgetState.displayConnectionAlert(ctxt);
                });
                return SocketExceptionWidget(callBack: (ctx){_refreshList(ctx);});
              }
              Sentry.captureException(snapshot.error, stackTrace: snapshot.stackTrace);
              return UnknownErrorWidget(callBack: (ctx){_refreshList(ctx);});
            }
            else{
              return _buildListView(ctxt, snapshot.data);
            }
          }
          else {
            return const LoadingWidget();
          }
        }
      ),
    );
  }

  Widget _buildListView(BuildContext context, List<Cop1Event> events) {
    return ListView.builder(
        itemCount: events.length,
        itemBuilder: (BuildContext ctxt, index) {
          return Padding(
              padding: const EdgeInsets.all(5.0),
              child: EventTile(event: events[events.length-index-1])
          );
        }
      );
  }

  Future<void> _refreshList(BuildContext context) async {
    try {
      await session(context).refreshEvents();
      setState((){});
    }
    on SocketException {
      ConnectedWidgetState.displayConnectionAlert(context);
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
    }
  }

}
