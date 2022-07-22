import 'package:cop1/data/session_data.dart';
import 'package:cop1/ui/text_field_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                  TextFieldWidget(label: "Code à 6 chiffres", text: "", onChanged: (code){_code = code;} ),
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
    if ((await session(context).getToken(_code)).isNotEmpty){
      Navigator.of(context).popUntil((route)=>route.isFirst);
      return;
    }
  }


  void resendCode(BuildContext context){
    setState((){});
  }
}
