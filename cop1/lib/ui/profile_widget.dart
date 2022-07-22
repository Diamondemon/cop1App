
import 'dart:developer';

import 'package:cop1/data/user_profile.dart';
import 'package:cop1/ui/event_tile.dart';
import 'package:flutter/material.dart';

import '../data/session_data.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: session(context).user,
        builder: (BuildContext ctxt, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.hasError){
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
        _buildName(user),
        const SizedBox(height: 30),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Vos évènements", style: TextStyle(fontSize: 16))),
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: user.events.length,
          itemBuilder: (
            BuildContext ctxt, int index){
              return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: EventTile(event: user.events.elementAt(index))
              );
            },
        )
      ],
    );
  }

  Widget _buildName(UserProfile user){
    final name = user.name;
    final surname = user.surname;
    final String fullName;
    if (surname == null && name == null){
      fullName = "Utilisateur anonyme";
    }
    else {
      fullName = "${name??""} ${surname??""}";
    }

    return Center(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            fullName,
            style: const TextStyle(fontFamily: "HKGrotesk", fontSize: 24),
          ),
          Text(
            user.email??"Aucun email renseigné",
            style: const TextStyle(color: Colors.grey),
          )
        ]
        )
    );
  }
}

