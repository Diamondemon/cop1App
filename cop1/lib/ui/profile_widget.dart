
import 'dart:io';

import 'package:cop1/utils/connected_widget_state.dart';
import 'package:cop1/utils/user_profile.dart';
import 'package:cop1/ui/event_tile.dart';
import 'package:flutter/material.dart';

import '../utils/cop1_event.dart';
import '../data/session_data.dart';

class ProfileWidget extends StatelessWidget implements ConnectedWidgetState{
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: session(context).user,
        builder: (BuildContext ctxt, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.hasError){
              if (snapshot.error is SocketException){
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ConnectedWidgetState.displayConnectionAlert(ctxt);
                });
                return const Scaffold();
              }
              return Text(snapshot.error.toString());
            }
            else{
              return _buildListView(ctxt, snapshot.data!);
            }
          }
          else {
            return const Scaffold();
          }
        }
    );
  }

  Widget _buildListView(BuildContext context, UserProfile user){
    return ListView(
      children: [
        const SizedBox(height: 30),
        _buildMainInfo(context, user),
        const SizedBox(height: 30),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Vos évènements", style: TextStyle(fontSize: 16))),
        ValueListenableBuilder(
          valueListenable: user.events,
          builder: (BuildContext cntxt, Set<Cop1Event> events, _) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: events.length,
              itemBuilder:
                  (BuildContext ctxt, int index) {
                return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: EventTile(event: events.elementAt(index))
                );
              },
            );
          }
        ),
        const SizedBox(height: 30,),
        Center(
          child: ElevatedButton(onPressed: session(context).disconnectUser, child: const Text("Me déconnecter")),
        )

      ],
    );
  }

  Widget _buildMainInfo(BuildContext context, UserProfile user) {
    return Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildName(context, user),
              _buildEmail(context, user),
            ]
        )
    );
  }

  Widget _buildName(BuildContext context, UserProfile user){
    return ValueListenableBuilder(valueListenable: user.firstName, builder:
      (BuildContext firstNameContext, String firstName, _) {
        return ValueListenableBuilder(valueListenable: user.lastName, builder:
          (BuildContext lastNameContext, String lastName, _) {
            final String fullName;
            if (lastName.isEmpty && firstName.isEmpty){
              fullName = "Utilisateur anonyme";
            }
            else {
              fullName = "$firstName $lastName";
            }
            return Text(
              fullName,
              style: const TextStyle(fontFamily: "HKGrotesk", fontSize: 24),
            );
          }
        );
      }
    );
  }

  Widget _buildEmail(BuildContext context, UserProfile user){
    return ValueListenableBuilder(valueListenable: user.email, builder:
      (BuildContext emailContext, String email, _) {
        return Text(
          email.isEmpty? "Aucun email renseigné" : email,
          style: const TextStyle(color: Colors.grey),
        );
      }
    );
  }
}

