//import 'dart:developer';
import 'dart:io';

import 'package:cop1/ui/creation_page.dart';
//import 'package:cop1/ui/subscription_page.dart';
import 'package:cop1/utils/cop1_event.dart';
import 'package:cop1/utils/user_profile.dart';
import 'package:flutter/material.dart';

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
                return Text(snapshot.error.toString());
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
              return const Scaffold();
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
      await s.subscribe(widget.event);
      setState((){});
    }
    else {
      s.unsubscribe(widget.event.id);
      setState((){});
    }
  }

  Widget _buildButton(BuildContext context, bool participated) {
    final String text = widget.event.isPast? "Passé": (participated? "Je me retire": "Je m'inscris");
    return RawMaterialButton(
      onPressed: widget.event.isPast? (){} : ()=>_toggleParticipation(context, !participated),
      fillColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(text, style: Theme.of(context).primaryTextTheme.bodyLarge),
      )
    );
  }

}
