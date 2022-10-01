
import 'package:flutter/material.dart';

import '../common.dart';

const Duration _snackBarDisplayDuration = Duration(milliseconds: 4000);

/// Static class for alerts
class ConnectedWidgetState {

  /// Displays a [SnackBar] to warn the user that the server is unreachable.
  static void displayConnectionAlert(BuildContext context){
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
      ConnectedWidgetState.timedSnackBar(
        child: Text(AppLocalizations.of(context)!.connectionErrorMessage),
        action: SnackBarAction(label: AppLocalizations.of(context)!.dismiss, onPressed: (){}),
      ),
    );
  }

  /// Displays a [SnackBar] to report a server error to the user.
  static void displayServerErrorAlert(BuildContext context){
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        ConnectedWidgetState.timedSnackBar(
          child: Text(AppLocalizations.of(context)!.serverErrorMessage),
          action: SnackBarAction(label: AppLocalizations.of(context)!.dismiss, onPressed: (){}),
        ),
      );
  }

  /// Displays a [SnackBar] to tell the user the event named [title] is full.
  static void displayFullEventAlert(BuildContext context, String title){
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        ConnectedWidgetState.timedSnackBar(
          child: Text(AppLocalizations.of(context)!.fullEventMessage(title)),
          action: SnackBarAction(label: AppLocalizations.of(context)!.dismiss, onPressed: (){}),
        ),
      );
  }

  /// Displays a [SnackBar] to warn the user that they missed an event.
  static void displayUnscannedAlert(BuildContext context){
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        ConnectedWidgetState.timedSnackBar(
          child: Text(AppLocalizations.of(context)!.missedEventMessage),
          action: SnackBarAction(label: AppLocalizations.of(context)!.dismiss, onPressed: (){}),
        ),
      );
  }

  ///  Displays an [AlertDialog] with [title] and [text] inside
  static Future<bool?> displayYesNoDialog(BuildContext context, String title, String text) async {
    return await showDialog(
        context: context,
        builder: (BuildContext alertContext){
          return _buildYesNoDialog(alertContext, title, text);
        }
    );
  }

  /// Builds an [AlertDialog] with [title] and [text] inside
  static AlertDialog _buildYesNoDialog(BuildContext context, String title, String text){
    return AlertDialog(
      title: Text(title),
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

  /// Creates a SnackBar which disappears after the [duration]
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