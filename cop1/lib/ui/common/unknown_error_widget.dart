import 'package:cop1/common.dart';
import 'package:flutter/material.dart';

/// Generic widget for unknown errors
class UnknownErrorWidget extends StatelessWidget {
  const UnknownErrorWidget({Key? key, required this.callBack}) : super(key: key);
  final void Function(BuildContext context)? callBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(AppLocalizations.of(context)!.unknownError)
          ),
          Center(
              child: ElevatedButton(onPressed: ()=> callBack!(context), child: Text(AppLocalizations.of(context)!.retry))
          )
        ],
      ),
    );
  }
}
