import 'package:cop1/ui/events/event_list.dart';
import 'package:flutter/material.dart';

import '../../common.dart';

/// Root tab for the events
class ThreadTab extends StatelessWidget {
  const ThreadTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.newsFeed),
          elevation: 0,
        ),
        body: const EventList()
    );
  }
}
