import 'dart:io';

import 'package:cop1/ui/profile_edit.dart';
import 'package:flutter/material.dart';

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
    if (await ConnectedWidgetState.displayYesNoDialog(context)){
      try {
        await session(context).deleteUser();
      }
      on SocketException {
        ConnectedWidgetState.displayConnectionAlert(context);
        return;
      }
      if (mounted) Navigator.of(context).pop();
    }
  }
}
