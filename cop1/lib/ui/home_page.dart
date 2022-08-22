
import 'package:auto_route/auto_route.dart';
import 'package:cop1/routes/router.gr.dart';
import 'package:cop1/ui/tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive/hive.dart';

import '../common.dart';
import '../data/session_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabsLength);

    session(context).loadAssets(context).then(
            (_) => FlutterNativeSplash.remove()
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    session(context).localizations = AppLocalizations.of(context);
    return AutoTabsScaffold(
        routes: const [
          EventsRouter(),
          ProfileRouter()
        ],
      bottomNavigationBuilder: (ctxt, tabsRouter){
        return Material(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            tabs: tabs(context),
            controller: _tabController,
            onTap: tabsRouter.setActiveIndex,
          )
        );
      },
    );
  }
}
