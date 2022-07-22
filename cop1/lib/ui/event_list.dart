import 'dart:io';

import 'package:cop1/utils/cop1_event.dart';
import 'package:cop1/ui/event_tile.dart';
import 'package:flutter/material.dart';

import '../data/api.dart';
import '../data/session_data.dart';

class EventList extends StatefulWidget {
  const EventList({Key? key}) : super(key: key);

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: session(context).events,
        builder: (BuildContext ctxt, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.hasError){
              if (snapshot.error is SocketException){
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  _displayConnectionAlert(ctxt);
                });
                return const Scaffold();
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

  void _displayConnectionAlert(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext alertContext){
          return _buildDialog(alertContext);
        }
    );
  }

  Widget _buildDialog(BuildContext context){
    Widget discardButton = TextButton(
      child: const Text("Ok"),
      onPressed: () {Navigator.of(context).pop();},
    );
    return AlertDialog(
      title: const Text("Impossible de contacter le serveur, vérifiez votre connexion internet."),
      actions: [discardButton],
    );
  }
}
