import 'dart:io';

import 'package:cop1/utils/cop1_event.dart';
import 'package:cop1/ui/event_tile.dart';
import 'package:flutter/material.dart';

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
                return _buildListView(ctxt, []);
              }
              return Text(snapshot.error.toString());
            }
            else{
              return _buildListView(ctxt, snapshot.data);
            }
          }
          else {
            return const Scaffold();
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
              child: EventTile(event: events[index])
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
  }

}
