import 'dart:io';

import 'package:cop1/data/session_data.dart';
import 'package:cop1/ui/profile_creation_page.dart';
import 'package:cop1/ui/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../utils/connected_widget_state.dart';

class ValidationPage extends StatefulWidget {
  const ValidationPage({Key? key}) : super(key: key);
  @override
  State<ValidationPage> createState() => _ValidationPageState();
}

class _ValidationPageState extends State<ValidationPage> {
  @override
  void initState(){
    super.initState();
  }
  String _code="";
  @override
  Widget build(BuildContext context) {
    return _buildEntryPage(context);
  }

  Widget _buildEntryPage(BuildContext context){
    final SessionData s = session(context);
    return Scaffold(
        appBar: AppBar(
          title:const Text("Code de vérification"),
        ),
        body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Un code a été renvoyé au ${s.phoneNumber}. Veuillez le renseigner ci-dessous.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20,),
                  TextFieldWidget(label: "Code à 6 chiffres",
                    text: "",
                    onChanged: (code){_code = code;},
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: ()=>resendCode(context),
                          child: const Text('Renvoyer'),
                        ),
                        ElevatedButton(
                          onPressed: ()=>finalizeConnection(context),
                          child: const Text('Valider'),
                        ),
                      ]
                  )
                ],
              ),
            )
        )
    );
  }

  void finalizeConnection(BuildContext context) async{
    try {
      if ((await session(context).getToken(_code)).isNotEmpty){
        if ((await session(context).user)!.firstName.value.isEmpty){
          await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>const ProfileCreationPage()));
        }
        else {
          Navigator.of(context).popUntil((route)=>route.isFirst);
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


  void resendCode(BuildContext context) async {
    try {
      await session(context).askValidation();
      setState((){});
    }
    on SocketException {
      ConnectedWidgetState.displayConnectionAlert(context);
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
    }
  }
}
