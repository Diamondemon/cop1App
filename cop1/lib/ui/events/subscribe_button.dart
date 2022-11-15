import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cop1/common.dart';
import 'package:cop1/ui/common/disabled_button.dart';
import 'package:cop1/ui/events/ticket_picker.dart';
import 'package:cop1/utils/connected_widget_state.dart';
import 'package:cop1/utils/cop1_event.dart';
import 'package:cop1/utils/user_profile.dart';
import 'package:cop1/data/session_data.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';

/// Button to subscribe and unsubscribe from an event
class SubscribeButton extends StatefulWidget {
  const SubscribeButton({Key? key, required this.event, this.ticketId = -1}) : super(key: key);
  final Cop1Event event;
  final int ticketId;

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

  /// Changes the user's participation in the direction of [participate]
  void _toggleParticipation(BuildContext context, bool participate) async {
    SessionData s = session(context);
    if (participate){
      if (!s.isConnected){
        await AutoRouter.of(context).navigateNamed(
          '/connection',
          onFailure: (NavigationFailure failure)=> Sentry.captureException(failure)
        );
        if (!s.isConnected) return;
      }
      if (!mounted) return;

      if (widget.ticketId == -1){
        showDialog(context: context,
        builder: (BuildContext alertContext){
          return TicketPicker.buildTicketDialog(context, widget.event);
        });
      }
      else {
        try {
          if (!await s.subscribe(widget.event)){
            ConnectedWidgetState.displayServerErrorAlert(context);
            return;
          }
        }
        on SocketException {
          ConnectedWidgetState.displayConnectionAlert(context);
          return;
        }
        on EventConflictError catch (e) {
          _showEventConflict(context, e);
          return;
        }
        on FullEventError {
          ConnectedWidgetState.displayFullEventAlert(context, widget.event.title);
        }
      }

    }
    else {
      try {
        if (!await s.unsubscribe(widget.event)){
          ConnectedWidgetState.displayServerErrorAlert(context);
          return;
        }
      }
      on SocketException {
        ConnectedWidgetState.displayConnectionAlert(context);
        return;
      }
    }
    setState((){});
  }

  /// Builds a button depending on the state of the event
  ///
  /// [participate] is to know in what direction to toggle the participation
  Widget _buildButton(BuildContext context, bool participated) {
    final String text = widget.event.isAvailable? (widget.event.isPast? AppLocalizations.of(context)!.subButton_past:
        (participated? AppLocalizations.of(context)!.subButton_unSub: AppLocalizations.of(context)!.subButton_sub)):
      AppLocalizations.of(context)!.full;
    return RawMaterialButton(
      onPressed: (widget.event.isPast | !widget.event.isAvailable)? null : ()=>_toggleParticipation(context, !participated),
      fillColor: (widget.event.isPast | !widget.event.isAvailable)? Theme.of(context).primaryColor.withOpacity(0.5): Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(text, style: Theme.of(context).primaryTextTheme.bodyLarge),
      )
    );
  }

  /// Builds an unusable button
  Widget _buildDisabledButton(BuildContext context){
    final String text = widget.event.isAvailable?
      widget.event.isPast? AppLocalizations.of(context)!.subButton_past: AppLocalizations.of(context)!.subButton_sub :
      AppLocalizations.of(context)!.full;
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

  /// Shows something in case the event of the [widget] is conflicting with the conflicting [Cop1Event]
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
