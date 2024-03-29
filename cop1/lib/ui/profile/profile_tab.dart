import 'package:auto_route/auto_route.dart';
import 'package:cop1/ui/profile/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';

import '../../common.dart';
import '../../data/session_data.dart';

/// Tab for all widgets about the user
class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {

  @override
  void initState(){
    super.initState();
    if (!session(context).isConnected){
      WidgetsBinding.instance
          .addPostFrameCallback((_) {
            _launchConnection(context);
      });
    }
  }

  @override
  void dispose(){
    Sentry.captureMessage("Profile Tab gets destroyed!");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: session(context).connectionListenable,
      builder: (BuildContext ctxt, bool value, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(ctxt)!.userProfile),
            elevation: 0,
            actions: value ? [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                ),
                onPressed: () async {
                  await AutoRouter.of(ctxt).navigateNamed(
                    "edit",
                    onFailure: (NavigationFailure failure)=> Sentry.captureException(failure)
                  );
                },
              ),
            ] : [],
          ),
          body: value
              ? const ProfileWidget()
              : _buildNoProfile(ctxt),
        );
      }
    );
  }

  /// Builds the proper view when there is no connected user
  Widget _buildNoProfile(BuildContext context){
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                AppLocalizations.of(context)!.loggedOutMessage
            ),
            ElevatedButton(onPressed: () => _launchConnection(context), child: Text(AppLocalizations.of(context)!.connect)),
          ]
        )
      )
    );
  }

  /// Navigates to the connection widgets
  void _launchConnection(BuildContext context) async{
    await AutoRouter.of(context).navigateNamed(
      '/connection/',
      onFailure: (NavigationFailure failure)=> Sentry.captureException(failure)
    );
    if (mounted) setState((){});
  }
}
