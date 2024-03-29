import 'package:auto_route/auto_route.dart';
import 'package:cop1/data/session_data.dart';
import 'package:cop1/ui/profile/profile_edit.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';

import '../../common.dart';

/// Page to create a user profile
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
            session(context).deleteUser();
            AutoRouter.of(context).pop();
          },
        ),
      ),
      body: ProfileEdit(onFinished: finalizeCreation),
    );
  }

  /// Finalizes the creation of the user
  void finalizeCreation(BuildContext context) async{
    AutoRouter.of(context).navigateNamed(
      "/home/profile",
      onFailure: (NavigationFailure failure)=> Sentry.captureException(failure)
    );
  }

}
