import 'package:flutter/material.dart';

class SocketExceptionWidget extends StatelessWidget {
  const SocketExceptionWidget({Key? key, required this.callBack}) : super(key: key);
  final void Function(BuildContext context) callBack; 

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("On dirait que le serveur distant n'est pas joignable. Vérifiez votre connexion internet ou réessayez plus tard.")
          ),
          Center(
            child: ElevatedButton(onPressed: ()=> callBack(context), child: const Text("Réessayer"))
          )
        ]
    );
  }
}
