import 'dart:io';

import 'package:cop1/common.dart';
import 'package:cop1/ui/creation_page.dart';
import 'package:cop1/ui/disabled_button.dart';
import 'package:cop1/utils/connected_widget_state.dart';
import 'package:cop1/utils/cop1_event.dart';
import 'package:cop1/utils/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';

import '../data/session_data.dart';

class SubscribeButton extends StatefulWidget {
  const SubscribeButton({Key? key, required this.event}) : super(key: key);
  final Cop1Event event;

  @override
  State<SubscribeButton> createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<SubscribeButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: session(context).connectionListenable,
      builder: (BuildContext listenCtxt, value, _){
        return FutureBuilder(
          future: session(context).user,
          builder: (BuildContext ctxt, snapshot){
            if (snapshot.connectionState == ConnectionState.done){
              if (snapshot.hasError && snapshot.error is! SocketException){
                Sentry.captureException(snapshot.error, stackTrace: snapshot.stackTrace);
                return _buildDisabledButton(ctxt);
              }
              else if (snapshot.data==null){
                return _buildButton(ctxt, false);
              }
              else {
                final UserProfile user = snapshot.data as UserProfile;
                return _buildButton(ctxt, user.isSubscribedTo(widget.event));
              }
            }
            else {
              return DisabledButton(text: AppLocalizations.of(ctxt)!.loading);
            }
          }
        );
      }
    );
  }

  void _toggleParticipation(BuildContext context, bool participate) async {
    SessionData s = session(context);
    if (participate){
      if (!s.isConnected){
        await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext ctxt)=> const CreationPage()));
        if (!s.isConnected) return;
      }
      if (!mounted) return;
      try {
        await s.subscribe(widget.event);
      }
      on EventConflictError catch (e) {
        _showEventConflict(context, e);
      }
      setState((){});
    }
    else {
      s.unsubscribe(widget.event);
      setState((){});
    }
  }

  Widget _buildButton(BuildContext context, bool participated) {
    final String text = widget.event.isPast? AppLocalizations.of(context)!.subButton_past:
      (participated? AppLocalizations.of(context)!.subButton_unSub: AppLocalizations.of(context)!.subButton_sub);
    return RawMaterialButton(
      onPressed: widget.event.isPast? null : ()=>_toggleParticipation(context, !participated),
      fillColor: widget.event.isPast? Theme.of(context).primaryColor.withOpacity(0.5): Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(text, style: Theme.of(context).primaryTextTheme.bodyLarge),
      )
    );
  }

  Widget _buildDisabledButton(BuildContext context){
    final String text = widget.event.isPast? AppLocalizations.of(context)!.subButton_past: AppLocalizations.of(context)!.subButton_sub;
    return RawMaterialButton(
        onPressed: null,
        fillColor: Theme.of(context).primaryColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(text, style: Theme.of(context).primaryTextTheme.bodyLarge),
        )
    );
  }

  void _showEventConflict(BuildContext context, EventConflictError error) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
      ConnectedWidgetState.timedSnackBar(
        child: Text(AppLocalizations.of(context)!.eventConflict(error.conflictingEvent.title, error.allowedDelayDays)),
        action: SnackBarAction(label: AppLocalizations.of(context)!.dismiss, onPressed: (){}),
      ),
    );
  }

}
