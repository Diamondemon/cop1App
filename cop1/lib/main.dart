import 'package:cop1/app_theme.dart';
import 'package:cop1/data/notification_api.dart';
import 'package:cop1/ui/profile_tab.dart';
import 'package:cop1/ui/tabs.dart';
import 'package:cop1/ui/thread_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'data/session_data.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> initAll() async {
  await Hive.initFlutter();
  await NotificationAPI.initialize();
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://6c7c9a6f8392454f819e2e39856caf40@o1363652.ingest.sentry.io/6656629';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 0.5;
    },
    appRunner: () => runApp(const MyApp())
  );
  //await initializeDateFormatting(); not needed if added flutter_localizations
}

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initAll();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return ChangeNotifierProvider(
      create: (context) => SessionData(),
      child:MaterialApp(
        title: 'COP1',
        theme: AppTheme.themeData,
        home:  const HomePage(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales
      ),
    );
  }
}

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
    return Scaffold(
      bottomNavigationBar: Material(
        color: Theme.of(context).primaryColor,
        child: TabBar(
          tabs: tabs(context),
          controller: _tabController,
        ),
      ),
      body: GestureDetector( // May need SafeArea
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: TabBarView(
          controller: _tabController,
          children: const <Widget>[
            ThreadTab(),
            ProfileTab(),
          ],
        ),
      ),
    );
  }
}
