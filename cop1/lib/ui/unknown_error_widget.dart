import 'package:flutter/material.dart';

class UnknownErrorWidget extends StatelessWidget {
  const UnknownErrorWidget({Key? key, required this.callBack}) : super(key: key);
  final void Function(BuildContext context)? callBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("Il vient de se passer une erreur inconnue. Nous vous prions de nous excuser pour le désagrément, nous étudions le problème.")
          ),
          Center(
              child: ElevatedButton(onPressed: ()=> callBack!(context), child: const Text("Réessayer"))
          )
        ],
      ),
    );
  }
}
