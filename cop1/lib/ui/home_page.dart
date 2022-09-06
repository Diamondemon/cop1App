import 'package:auto_route/auto_route.dart';
import 'package:cop1/data/notification_api.dart';
import 'package:cop1/routes/router.gr.dart';
import 'package:cop1/ui/tabs.dart';
import 'package:cop1/utils/connected_widget_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive/hive.dart';
import 'package:sentry/sentry.dart';

import '../common.dart';
import '../data/session_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    session(context).loadAssets(context).then(
            (_) => FlutterNativeSplash.remove()
    );
    listenNotifications();
    session(context).hasMissedEvents().then((bool hasMissed) {if (hasMissed) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _displayMissedEventAlert(context);
        }
      );
    }});
  }

  Future<void> listenNotifications() async {
    NotificationAPI.onNotifications.stream.listen(
      (String? payload){
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            onClickedNotification(payload);
          }
        );
      }
    );

    final payload = await NotificationAPI.hasLaunchedApp;
    if ( payload !=null){
      NotificationAPI.onNotifications.add(payload);
    }
  }

  void onClickedNotification(String? payload) {
    if (payload != null){
      AutoRouter.of(context).navigateNamed(
        payload,
        onFailure: (NavigationFailure failure)=> Sentry.captureException(failure)
      );
    }
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    session(context).localizations = AppLocalizations.of(context);
    return AutoTabsRouter.tabBar(
        routes: const [
          EventsRouter(),
          ProfileRouter()
        ],
      builder: (ctxt, child, tabController){
          return Scaffold(
            bottomNavigationBar: Material(
              color: Theme.of(ctxt).primaryColor,
              child: TabBar(
                tabs: tabs(ctxt),
                controller: tabController,
              ),
            ),
            body: GestureDetector( // May need SafeArea
              onTap: () => FocusScope.of(ctxt).requestFocus(FocusNode()),
              child: child,
            )
          );
      }

    );
  }

  void _displayMissedEventAlert(BuildContext context) {
    ConnectedWidgetState.displayUnscannedAlert(context);
  }

}
