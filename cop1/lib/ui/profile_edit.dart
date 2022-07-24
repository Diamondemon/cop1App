import 'dart:developer';
import 'dart:io';

import 'package:cop1/data/session_data.dart';
import 'package:cop1/ui/text_field_widget.dart';
import 'package:cop1/utils/user_profile.dart';
import 'package:flutter/material.dart';

import '../utils/connected_widget_state.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({Key? key}) : super(key: key);

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> implements ConnectedWidgetState {
  String _firstName="";
  String _lastName="";
  String _email="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edition du profil"),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.delete_forever))
        ],
      ),
      body: FutureBuilder(
        future: session(context).user,
        builder: (BuildContext ctxt, AsyncSnapshot<UserProfile?> snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.hasError){
              if (snapshot.error is SocketException){
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                Navigator.of(ctxt).pop();
                ConnectedWidgetState.displayConnectionAlert(ctxt);
                });
                return const Scaffold();
              }
              return Text(snapshot.error.toString());
            }
            else{
              return _buildView(ctxt, snapshot.data!);
            }
          }
          else {
            return const Scaffold();
          }
        }
      ),
    );
  }

  Widget _buildView(BuildContext context, UserProfile user){
    _firstName=user.firstName.value;
    _lastName=user.lastName.value;
    _email=user.email.value;
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            TextFieldWidget(label: "Prénom", text: user.firstName.value, onChanged: (name)=>_firstName=name),
            TextFieldWidget(label: "Nom", text: user.lastName.value, onChanged: (surname)=>_lastName=surname),
            TextFieldWidget(label: "E-mail", text: user.email.value, onChanged: (email)=>_email=email),
            Center( child: ElevatedButton(onPressed: ()=>_saveNewInfo(context), child: const Text("Sauvegarder")))
          ],
        )
    );
  }

  void _saveNewInfo(BuildContext context) async {
    final RegExp mailRE = RegExp(r"^([a-z0-9]{1,}@[a-z0-9]{1,}[.][a-z]{1,})?$");
    log("Email matches: ${mailRE.hasMatch(_email)}");
    if (mailRE.hasMatch(_email)){
      try{
        final bool result = await session(context).modifyUser(_firstName, _lastName, _email);
        if (result && mounted) {
          Navigator.of(context).pop();
          return;
        }
      }
      on SocketException {
        ConnectedWidgetState.displayConnectionAlert(context);
      }

    }
  }
}
