import 'package:cop1/data/cop1_event.dart';
import 'package:cop1/data/user_profile.dart';
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
    return FutureBuilder(
      future: session(context).user,
      builder: (BuildContext ctxt, snapshot){
        if (snapshot.connectionState == ConnectionState.done){
          if (snapshot.hasError){
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

  void _toggleParticipation(BuildContext context, bool participate) async {
    if (participate){

    }
    else {

    }
  }

  Widget _buildButton(BuildContext context, bool participated) {
    return RawMaterialButton(
      onPressed: ()=>_toggleParticipation(context, !participated),
      fillColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(participated? "Je me retire": "Je m'inscris", style: Theme.of(context).primaryTextTheme.bodyLarge),
      )
    );
  }

}
