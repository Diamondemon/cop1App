import 'dart:developer';

import 'package:cop1/ui/creation_page.dart';
import 'package:cop1/ui/profile_widget.dart';
import 'package:flutter/material.dart';

import '../data/session_data.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {

  @override
  void initState(){
    super.initState();
    if (!session(context).isConnected){
      WidgetsBinding.instance
          .addPostFrameCallback((_) => Navigator.of(context).push(MaterialPageRoute(builder: (buildContext){return const CreationPage();})));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profil Utilisateur"),
          elevation: 0,
        ),
        body: session(context).isConnected? const ProfileWidget() : _buildNoProfile(),
    );
  }

  Widget _buildNoProfile(){
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          "Veuillez vous inscrire pour avoir un profil utilisateur."
        )
      )
    );
  }
}
