
import 'package:flutter/material.dart';

class ConnectedWidgetState {
  static void displayConnectionAlert(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext alertContext){
          return _buildAlertDialog(alertContext, "Impossible de contacter le serveur, vérifiez votre connexion internet.");
        }
    );
  }

  static Future<bool> displayYesNoDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext alertContext){
          return _buildYesNoDialog(alertContext, "Cela supprimera définitivement votre compte.");
        }
    );
  }

  static AlertDialog _buildYesNoDialog(BuildContext context, String text){
    return AlertDialog(
      title: const Text("Êtes-vous sûr(e)?"),
      actions: [
        TextButton(
          onPressed: (){Navigator.of(context).pop(false);},
          child: const Text("Annuler"),
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