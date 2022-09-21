
import 'package:auto_route/annotations.dart';
import 'package:auto_route/empty_router_widgets.dart';
import 'package:cop1/ui/connection/creation_page.dart';
import 'package:cop1/ui/events/event_page.dart';
import 'package:cop1/ui/home_page.dart';
import 'package:cop1/ui/connection/profile_creation_page.dart';
import 'package:cop1/ui/profile/profile_edit_page.dart';
import 'package:cop1/ui/profile/profile_tab.dart';
import 'package:cop1/ui/events/thread_tab.dart';

import '../ui/connection/validation_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Tab,Page,Route',
  routes: <AutoRoute>[
    AutoRoute(
      path: '/',
      name: "MainRouter",
      page: EmptyRouterPage,
      children: [
        AutoRoute(
          path: 'home',
          name: "HomeRouter",
          page: HomePage,
          initial: true,
          children: [
            AutoRoute(
              path: "events",
              name: "EventsRouter",
              page: EmptyRouterPage,
              children: [
                AutoRoute( path: "", page: ThreadTab, initial: true),
                AutoRoute( path: ":eventId", page: EventPage)
              ]
            ),
            AutoRoute(
              path: "profile",
              name: "ProfileRouter",
              page: EmptyRouterPage,
              children: [
                AutoRoute( path: "", page: ProfileTab),
                AutoRoute( path: "edit", page: ProfileEditPage),
                AutoRoute( path: ":eventId", page: EventPage)
              ]
            ),
          ]
        ),
        AutoRoute(
            path: "connection",
            name: "ConnectionRouter",
            page: EmptyRouterPage,
            children: [
              AutoRoute( path: "", page: CreationPage),
              AutoRoute( path: "validation", page: ValidationPage),
              AutoRoute( path: "userCreation", page: ProfileCreationPage),
            ]
        )
      ]
    ),
  ],
)
class $AppRouter {}