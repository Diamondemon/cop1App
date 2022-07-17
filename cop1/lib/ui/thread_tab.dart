import 'package:cop1/ui/event_list.dart';
import 'package:flutter/material.dart';

class ThreadTab extends StatelessWidget {
  const ThreadTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
          title: const Text("Évènements"),
        ),
        body: const EventList()
    );
  }
}
