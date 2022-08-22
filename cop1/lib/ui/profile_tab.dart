import 'package:auto_route/auto_route.dart';
import 'package:cop1/ui/profile_widget.dart';
import 'package:flutter/material.dart';

import '../common.dart';
import '../data/session_data.dart';

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
            _launchConnection();
      });
    }
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
                  await AutoRouter.of(ctxt).pushNamed("edit");
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
            ElevatedButton(onPressed: _launchConnection, child: Text(AppLocalizations.of(context)!.connect)),
          ]
        )
      )
    );
  }

  void _launchConnection() async{
    await AutoRouter.of(context).pushNamed('/connection', includePrefixMatches: true);
    if (mounted) setState((){});
  }
}
