import 'dart:io';

import 'package:cop1/data/session_data.dart';
import 'package:cop1/ui/text_field_widget.dart';
import 'package:cop1/ui/validation_page.dart';
import 'package:flutter/material.dart';


import '../utils/connected_widget_state.dart';

class CreationPage extends StatefulWidget {
  const CreationPage({Key? key}) : super(key: key);

  @override
  State<CreationPage> createState() => _CreationPageState();
}

class _CreationPageState extends State<CreationPage> {
  String phoneNumber="";
  final RegExp phoneNumRE = RegExp(r"^(\+33\s?)|0[67]([0-9]{2}\s?){4}\s*$");
  final RegExp numStartRE = RegExp(r"^\+33");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:const Text("Connexion"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Pour vous identifier, veuillez rentrer votre numéro de téléphone.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20,),
                TextFieldWidget(label: "Numéro de Téléphone",
                  text: "",
                  hintText: "+33 6 XX XX XX XX",
                  onChanged: (phone){phoneNumber = phone;},
                  keyboardType: TextInputType.phone,
                  regEx: phoneNumRE,
                  errorText: "Numéro de téléphone non valide.",
                ),
                ElevatedButton(
                  onPressed: ()=>goToValidation(context),
                  child: const Text('Valider'),
                )
              ],
            ),
          )
        )
    );
  }

  void goToValidation(BuildContext context) async {
    if (phoneNumRE.hasMatch(phoneNumber)){
      try{
        if (!numStartRE.hasMatch(phoneNumber)){
          phoneNumber = phoneNumber.replaceFirst("0", "+33");
        }
        phoneNumber = phoneNumber.replaceAll(" ", "");
        if (await session(context).setPhoneNumber(phoneNumber)){
          if (await session(context).askValidation()) {
            Navigator.push(context, MaterialPageRoute(builder: (cntxt)=> const ValidationPage()));
          }
        }
      }
      on SocketException {
        ConnectedWidgetState.displayConnectionAlert(context);
      }

    }
  }
}

