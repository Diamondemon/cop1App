
import 'package:flutter/material.dart';

import '../common.dart';

const Duration _snackBarDisplayDuration = Duration(milliseconds: 4000);

class ConnectedWidgetState {
  static void displayConnectionAlert(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext alertContext){
          return _buildAlertDialog(alertContext, AppLocalizations.of(context)!.connectionErrorMessage);
        }
    );
  }

  static Future<bool?> displayYesNoDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext alertContext){
          return _buildYesNoDialog(alertContext, AppLocalizations.of(context)!.deletionConfirm_text);
        }
    );
  }

  static AlertDialog _buildYesNoDialog(BuildContext context, String text){
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.deletionConfirm),
      actions: [
        TextButton(
          onPressed: (){Navigator.of(context).pop(false);},
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: (){Navigator.of(context).pop(true);},
          child: const Text("Ok")
        )
      ],
      content: Text(text),
    );
  }

  static Widget _buildAlertDialog(BuildContext context, String text){
    Widget discardButton = TextButton(
      child: const Text("Ok"),
      onPressed: () {Navigator.of(context).pop();},
    );
    return AlertDialog(
      title: Text(text),
      actions: [discardButton],
    );
  }

  static SnackBar timedSnackBar({
    Key? key,
    required Widget child,
    Color? backgroundColor,
    double? elevation,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? width,
    ShapeBorder? shape,
    SnackBarBehavior? behavior,
    SnackBarAction? action,
    Duration duration = _snackBarDisplayDuration,
    Animation<double>? animation,
    void Function()? onVisible,
    DismissDirection dismissDirection = DismissDirection.down,
    Clip clipBehavior = Clip.hardEdge
  }){
    return SnackBar(
      key: key,
      backgroundColor: backgroundColor,
      elevation: elevation,
      margin: margin,
      padding: padding,
      width: width,
      shape: shape,
      behavior: behavior,
      action: action,
      duration: duration,
      animation: animation,
      onVisible: onVisible,
      dismissDirection: dismissDirection,
      clipBehavior: clipBehavior,
      content: ListView(
        shrinkWrap: true,
        children: [
         child,
         const SizedBox(height: 5.0),
         TweenAnimationBuilder(
             tween: Tween<double>(begin: duration.inMilliseconds *1.0, end: 0),
             duration: duration,
             builder: (BuildContext context, double progress, _) {
               return LinearProgressIndicator(
                 value: progress/duration.inMilliseconds,
               );
             })
       ],
      ),
    );
  }

}