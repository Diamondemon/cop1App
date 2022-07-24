import 'dart:developer';

import 'package:cop1/ui/creation_page.dart';
import 'package:cop1/ui/profile_edit.dart';
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
          .addPostFrameCallback((_) {
            _launchConnection();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: session(context).connectionListenable,
      builder: (BuildContext ctxt, bool value, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Profil Utilisateur"),
            elevation: 0,
            actions: value ? [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                ),
                onPressed: () async {
                  await Navigator.of(ctxt).push(MaterialPageRoute(builder:
                    (BuildContext buildContext) => const ProfileEdit()));
                  },
              ),
            ] : [],
          ),
          body: value
              ? const ProfileWidget()
              : _buildNoProfile(),
        );
      }
    );
  }

  Widget _buildNoProfile(){
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "Veuillez vous inscrire pour avoir un profil utilisateur."
            ),
            ElevatedButton(onPressed: _launchConnection, child: const Text("Me connecter")),
          ]
        )
      )
    );
  }

  void _launchConnection() async{
    await Navigator.of(context).push(MaterialPageRoute(builder: (buildContext){return const CreationPage();}));
    if (mounted) setState((){});
  }
}
