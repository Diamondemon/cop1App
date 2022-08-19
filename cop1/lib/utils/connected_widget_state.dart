
import 'package:flutter/material.dart';

import '../common.dart';

class ConnectedWidgetState {
  static void displayConnectionAlert(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext alertContext){
          return _buildAlertDialog(alertContext, AppLocalizations.of(context)!.connectionErrorMessage);
        }
    );
  }

  static Future<bool> displayYesNoDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext alertContext){
          return _buildYesNoDialog(alertContext, AppLocalizations.of(context)!.deletionConfirm_text);
        }
    );
  }

  static AlertDialog _buildYesNoDialog(BuildContext context, String text){
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.deletionConfirm),
      actions: [
        TextButton(
          onPressed: (){Navigator.of(context).pop(false);},
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: (){Navigator.of(context).pop(true);},
          child: const Text("Ok")
        )
      ],
      content: Text(text),
    );
  }

  static Widget _buildAlertDialog(BuildContext context, String text){
    Widget discardButton = TextButton(
      child: const Text("Ok"),
      onPressed: () {Navigator.of(context).pop();},
    );
    return AlertDialog(
      title: Text(text),
      actions: [discardButton],
    );
  }
}