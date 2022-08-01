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

Future<void> initAll() async {
  await Hive.initFlutter();
  await NotificationAPI.initialize();
}

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initAll().then((_) => runApp(const MyApp()));
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
        home:  const HomePage()
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
    _tabController = TabController(vsync: this, length: tabs.length);

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
    return Scaffold(
      bottomNavigationBar: Material(
        color: Theme.of(context).primaryColor,
        child: TabBar(
          tabs: tabs,
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
