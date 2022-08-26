import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cop1/ui/profile_edit.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../common.dart';
import '../data/session_data.dart';
import '../utils/connected_widget_state.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileEdit),
        actions: [
          IconButton(onPressed: () => _deleteUserForever(context), icon: const Icon(Icons.delete_forever))
        ],
      ),
      body: const ProfileEdit(),
    );
  }

  void _deleteUserForever(BuildContext context) async {
    if (await ConnectedWidgetState.displayYesNoDialog(
        context, AppLocalizations.of(context)!.deletionConfirm,
        AppLocalizations.of(context)!.deletionConfirm_text
    ) ?? false)
    {
      try {
        await session(context).deleteUser();
      }
      on SocketException{
        ConnectedWidgetState.displayConnectionAlert(context);
        return;
      }
      catch (e, sT){
        Sentry.captureException(e, stackTrace: sT);
        return;
      }
      if (mounted) AutoRouter.of(context).pop();
    }
  }
}
