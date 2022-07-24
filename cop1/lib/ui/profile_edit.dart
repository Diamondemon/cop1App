import 'package:cop1/ui/text_field_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({Key? key}) : super(key: key);

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edition du profil"),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.delete_forever))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            TextFieldWidget(label: "Prénom", text: "", onChanged: (_){}),
            TextFieldWidget(label: "Nom", text: "", onChanged: (_){}),
            TextFieldWidget(label: "E-mail", text: "", onChanged: (_){}),
            Center( child: ElevatedButton(onPressed: (){}, child: const Text("Sauvegarder")))
          ],
        )
      )
    );
  }
}
