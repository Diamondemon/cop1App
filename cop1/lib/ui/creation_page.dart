import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cop1/data/session_data.dart';
import 'package:cop1/ui/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


import '../common.dart';
import '../utils/connected_widget_state.dart';

class CreationPage extends StatefulWidget {
  const CreationPage({Key? key}) : super(key: key);

  @override
  State<CreationPage> createState() => _CreationPageState();
}

class _CreationPageState extends State<CreationPage> {
  String phoneNumber="";
  bool _rgpdChecked=false;
  final RegExp phoneNumRE = RegExp(r"^(\+33\s?)|0[67]([0-9]{2}\s?){4}\s*$");
  final RegExp numStartRE = RegExp(r"^\+33");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:Text(AppLocalizations.of(context)!.connection),
          leading: const AutoLeadingButton(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.connectionMessage,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20,),
                TextFieldWidget(label: AppLocalizations.of(context)!.phoneNumber,
                  text: "",
                  hintText: "+33 6 XX XX XX XX",
                  onChanged: (phone){phoneNumber = phone;},
                  keyboardType: TextInputType.phone,
                  regEx: phoneNumRE,
                  errorText: AppLocalizations.of(context)!.invalidPhoneNumber,
                ),
                CheckboxListTile(
                  title: Text(AppLocalizations.of(context)!.rgdpDisclaimer),
                  value: _rgpdChecked,
                  onChanged: (bool? value){
                    setState(() {
                      _rgpdChecked = value??false;
                    });
                  }),
                ElevatedButton(
                  onPressed: ()=>goToValidation(context),
                  child: Text(AppLocalizations.of(context)!.validate),
                )
              ],
            ),
          )
        )
    );
  }

  void goToValidation(BuildContext context) async {
    if (phoneNumRE.hasMatch(phoneNumber) && _rgpdChecked){
      try{
        if (!numStartRE.hasMatch(phoneNumber)){
          phoneNumber = phoneNumber.replaceFirst("0", "+33");
        }
        phoneNumber = phoneNumber.replaceAll(" ", "");
        if (await session(context).setPhoneNumber(phoneNumber)){
          if (await session(context).askValidation()) {
            AutoRouter.of(context).pushNamed(
              'validation',
              onFailure: (NavigationFailure failure)=> Sentry.captureException(failure)
            );
          }
        }
      }
      on SocketException {
        ConnectedWidgetState.displayConnectionAlert(context);
      }
      catch (e, sT){
        Sentry.captureException(e, stackTrace: sT);
      }
    }
  }
}

