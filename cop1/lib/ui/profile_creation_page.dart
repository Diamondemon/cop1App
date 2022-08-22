import 'package:auto_route/auto_route.dart';
import 'package:cop1/data/session_data.dart';
import 'package:cop1/ui/profile_edit.dart';
import 'package:flutter/material.dart';

import '../common.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({Key? key}) : super(key: key);

  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileCreation),
        leading: BackButton(
          onPressed: (){
            session(context).disconnectUser();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ProfileEdit(onFinished: () => finalizeCreation(context)),
    );
  }

  void finalizeCreation(BuildContext context) async{
    AutoRouter.of(context).pushNamed("/home/profile");
  }

}
