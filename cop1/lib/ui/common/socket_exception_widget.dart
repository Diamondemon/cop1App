import 'package:cop1/common.dart';
import 'package:flutter/material.dart';

/// Widget to display if the server is completely unreachable
class SocketExceptionWidget extends StatelessWidget {
  const SocketExceptionWidget({Key? key, required this.callBack}) : super(key: key);
  final void Function(BuildContext context) callBack; 

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(AppLocalizations.of(context)!.socketExceptionWidgetMessage)
          ),
          Center(
            child: ElevatedButton(onPressed: ()=> callBack(context), child: Text(AppLocalizations.of(context)!.retry))
          )
        ]
    );
  }
}
