import 'package:flutter/material.dart';

class DisabledButton extends StatelessWidget {
  const DisabledButton({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: null,
      child: Text(text)
    );
  }
}
