
import 'package:flutter/material.dart';

class ConnectedWidgetState {
  static void displayConnectionAlert(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext alertContext){
          return _buildDialog(alertContext);
        }
    );
  }

  static Widget _buildDialog(BuildContext context){
    Widget discardButton = TextButton(
      child: const Text("Ok"),
      onPressed: () {Navigator.of(context).pop();},
    );
    return AlertDialog(
      title: const Text("Impossible de contacter le serveur, vérifiez votre connexion internet."),
      actions: [discardButton],
    );
  }
}