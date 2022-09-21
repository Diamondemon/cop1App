// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i10;
import 'package:auto_route/empty_router_widgets.dart' as _i1;
import 'package:flutter/material.dart' as _i11;

import '../ui/connection/creation_page.dart' as _i7;
import '../ui/event_page.dart' as _i4;
import '../ui/home_page.dart' as _i2;
import '../ui/connection/profile_creation_page.dart' as _i9;
import '../ui/profile_edit_page.dart' as _i6;
import '../ui/profile_tab.dart' as _i5;
import '../ui/thread_tab.dart' as _i3;
import '../ui/connection/validation_page.dart' as _i8;

class AppRouter extends _i10.RootStackRouter {
  AppRouter([_i11.GlobalKey<_i11.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i10.PageFactory> pagesMap = {
    MainRouter.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.EmptyRouterPage());
    },
    HomeRouter.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i2.HomePage());
    },
    ConnectionRouter.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.EmptyRouterPage());
    },
    EventsRouter.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.EmptyRouterPage());
    },
    ProfileRouter.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.EmptyRouterPage());
    },
    ThreadTabRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i3.ThreadTab());
    },
    EventPageRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<EventPageRouteArgs>(
          orElse: () =>
              EventPageRouteArgs(eventId: pathParams.getInt('eventId')));
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i4.EventPage(key: args.key, eventId: args.eventId));
    },
    ProfileTabRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i5.ProfileTab());
    },
    ProfileEditPageRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i6.ProfileEditPage());
    },
    CreationPageRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i7.CreationPage());
    },
    ValidationPageRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i8.ValidationPage());
    },
    ProfileCreationPageRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i9.ProfileCreationPage());
    }
  };

  @override
  List<_i10.RouteConfig> get routes => [
        _i10.RouteConfig(MainRouter.name, path: '/', children: [
          _i10.RouteConfig('#redirect',
              path: '',
              parent: MainRouter.name,
              redirectTo: 'home',
              fullMatch: true),
          _i10.RouteConfig(HomeRouter.name,
              path: 'home',
              parent: MainRouter.name,
              children: [
                _i10.RouteConfig(EventsRouter.name,
                    path: 'events',
                    parent: HomeRouter.name,
                    children: [
                      _i10.RouteConfig(ThreadTabRoute.name,
                          path: '', parent: EventsRouter.name),
                      _i10.RouteConfig(EventPageRoute.name,
                          path: ':eventId', parent: EventsRouter.name)
                    ]),
                _i10.RouteConfig(ProfileRouter.name,
                    path: 'profile',
                    parent: HomeRouter.name,
                    children: [
                      _i10.RouteConfig(ProfileTabRoute.name,
                          path: '', parent: ProfileRouter.name),
                      _i10.RouteConfig(ProfileEditPageRoute.name,
                          path: 'edit', parent: ProfileRouter.name),
                      _i10.RouteConfig(EventPageRoute.name,
                          path: ':eventId', parent: ProfileRouter.name)
                    ])
              ]),
          _i10.RouteConfig(ConnectionRouter.name,
              path: 'connection',
              parent: MainRouter.name,
              children: [
                _i10.RouteConfig(CreationPageRoute.name,
                    path: '', parent: ConnectionRouter.name),
                _i10.RouteConfig(ValidationPageRoute.name,
                    path: 'validation', parent: ConnectionRouter.name),
                _i10.RouteConfig(ProfileCreationPageRoute.name,
                    path: 'userCreation', parent: ConnectionRouter.name)
              ])
        ])
      ];
}

/// generated route for
/// [_i1.EmptyRouterPage]
class MainRouter extends _i10.PageRouteInfo<void> {
  const MainRouter({List<_i10.PageRouteInfo>? children})
      : super(MainRouter.name, path: '/', initialChildren: children);

  static const String name = 'MainRouter';
}

/// generated route for
/// [_i2.HomePage]
class HomeRouter extends _i10.PageRouteInfo<void> {
  const HomeRouter({List<_i10.PageRouteInfo>? children})
      : super(HomeRouter.name, path: 'home', initialChildren: children);

  static const String name = 'HomeRouter';
}

/// generated route for
/// [_i1.EmptyRouterPage]
class ConnectionRouter extends _i10.PageRouteInfo<void> {
  const ConnectionRouter({List<_i10.PageRouteInfo>? children})
      : super(ConnectionRouter.name,
            path: 'connection', initialChildren: children);

  static const String name = 'ConnectionRouter';
}

/// generated route for
/// [_i1.EmptyRouterPage]
class EventsRouter extends _i10.PageRouteInfo<void> {
  const EventsRouter({List<_i10.PageRouteInfo>? children})
      : super(EventsRouter.name, path: 'events', initialChildren: children);

  static const String name = 'EventsRouter';
}

/// generated route for
/// [_i1.EmptyRouterPage]
class ProfileRouter extends _i10.PageRouteInfo<void> {
  const ProfileRouter({List<_i10.PageRouteInfo>? children})
      : super(ProfileRouter.name, path: 'profile', initialChildren: children);

  static const String name = 'ProfileRouter';
}

/// generated route for
/// [_i3.ThreadTab]
class ThreadTabRoute extends _i10.PageRouteInfo<void> {
  const ThreadTabRoute() : super(ThreadTabRoute.name, path: '');

  static const String name = 'ThreadTabRoute';
}

/// generated route for
/// [_i4.EventPage]
class EventPageRoute extends _i10.PageRouteInfo<EventPageRouteArgs> {
  EventPageRoute({_i11.Key? key, required int eventId})
      : super(EventPageRoute.name,
            path: ':eventId',
            args: EventPageRouteArgs(key: key, eventId: eventId),
            rawPathParams: {'eventId': eventId});

  static const String name = 'EventPageRoute';
}

class EventPageRouteArgs {
  const EventPageRouteArgs({this.key, required this.eventId});

  final _i11.Key? key;

  final int eventId;

  @override
  String toString() {
    return 'EventPageRouteArgs{key: $key, eventId: $eventId}';
  }
}

/// generated route for
/// [_i5.ProfileTab]
class ProfileTabRoute extends _i10.PageRouteInfo<void> {
  const ProfileTabRoute() : super(ProfileTabRoute.name, path: '');

  static const String name = 'ProfileTabRoute';
}

/// generated route for
/// [_i6.ProfileEditPage]
class ProfileEditPageRoute extends _i10.PageRouteInfo<void> {
  const ProfileEditPageRoute() : super(ProfileEditPageRoute.name, path: 'edit');

  static const String name = 'ProfileEditPageRoute';
}

/// generated route for
/// [_i7.CreationPage]
class CreationPageRoute extends _i10.PageRouteInfo<void> {
  const CreationPageRoute() : super(CreationPageRoute.name, path: '');

  static const String name = 'CreationPageRoute';
}

/// generated route for
/// [_i8.ValidationPage]
class ValidationPageRoute extends _i10.PageRouteInfo<void> {
  const ValidationPageRoute()
      : super(ValidationPageRoute.name, path: 'validation');

  static const String name = 'ValidationPageRoute';
}

/// generated route for
/// [_i9.ProfileCreationPage]
class ProfileCreationPageRoute extends _i10.PageRouteInfo<void> {
  const ProfileCreationPageRoute()
      : super(ProfileCreationPageRoute.name, path: 'userCreation');

  static const String name = 'ProfileCreationPageRoute';
}
