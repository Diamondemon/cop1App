
import 'package:cop1/data/user_profile.dart';
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
        _buildName(user)
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

    return Column(
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
    );
  }
}

