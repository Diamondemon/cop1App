import 'dart:io';

import 'package:cop1/ui/common/loading_widget.dart';
import 'package:cop1/ui/common/socket_exception_widget.dart';
import 'package:cop1/ui/common/unknown_error_widget.dart';
import 'package:cop1/utils/connected_widget_state.dart';
import 'package:cop1/utils/set_notifier.dart';
import 'package:cop1/utils/user_profile.dart';
import 'package:cop1/ui/events/event_tile.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';
import 'package:tuple/tuple.dart';

import '../../common.dart';
import '../../utils/cop1_event.dart';
import '../../data/session_data.dart';

/// Page showing all information about the connected user
class ProfileWidget extends StatefulWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(valueListenable: session(context).eventsChangedListenable, builder:
      (BuildContext ctxt, bool value, _) {
        return FutureBuilder(
          future: getUserAndEvents(ctxt),
          builder: (BuildContext ctx, AsyncSnapshot<Tuple2<UserProfile?, List<Cop1Event>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                if (snapshot.error is SocketException) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ConnectedWidgetState.displayConnectionAlert(ctx);
                  });
                  return SocketExceptionWidget(callBack: (ct) {
                    setState(() {});
                  });
                }
                Sentry.captureException( snapshot.error, stackTrace: snapshot.stackTrace);
                return UnknownErrorWidget(callBack: (ct) {
                  setState(() {});
                });
              }
              else if (snapshot.hasData) {
                if (snapshot.data!.item1 == null) {
                  return const LoadingWidget();
                }
                return _buildListView(ctx, snapshot.data!.item1!, snapshot.data!.item2);
              }
              else {
                return UnknownErrorWidget(callBack: (ct) {
                  setState(() {});
                });
              }
            }
            else {
              return const LoadingWidget();
            }
          }
        );
      }
    );
  }

  /// Builds a list view displaying all [events]  that the [user] is subscribed to.
  Widget _buildListView(BuildContext context, UserProfile user, List<Cop1Event> events){
    return ListView(
      children: [
        const SizedBox(height: 30),
        _buildMainInfo(context, user),
        const SizedBox(height: 30),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(AppLocalizations.of(context)!.nextEvents, style: const TextStyle(fontSize: 16))),
        _buildEventsList(context, user.events, events),
        const SizedBox(height: 20,),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(AppLocalizations.of(context)!.pastEvents, style: const TextStyle(fontSize: 16))),
        _buildEventsList(context, user.pastEvents, events),
        const SizedBox(height: 20,),
        Center(
          child: ElevatedButton(onPressed: session(context).disconnectUser, child: Text(AppLocalizations.of(context)!.disconnect)),
        ),
        const SizedBox(height: 20,),
      ],
    );
  }

  /// Builds a list view displaying the provided [subEvents]
  ///
  /// [events] is a resource to know what to display
  Widget _buildEventsList(BuildContext context, SetNotifier<int> subEvents, List<Cop1Event> events){
    return ValueListenableBuilder(
        valueListenable: subEvents,
        builder: (BuildContext cntxt, Set<int> evts, _) {
          final List<int> sortedSubbed;
          try {
            sortedSubbed = evts.toList()
              ..sort((int a, int b){
                return - events.firstWhere((event) => event.id == a).date.compareTo(events.firstWhere((event) => event.id == b).date);
              });
          }
          catch (e, sT){
            Sentry.captureException(e, stackTrace: sT);
            return Container();
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: evts.length,
            itemBuilder:
              (BuildContext ctxt, int index) {
                return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: EventTile(
                      event: events.firstWhere((element) => (element.id == sortedSubbed.elementAt(index))),
                    )
                );
              },
          );
        }
    );
  }

  /// Builds the most important information about the [user]
  Widget _buildMainInfo(BuildContext context, UserProfile user) {
    return Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildName(context, user),
              _buildEmail(context, user),
            ]
        )
    );
  }

  Widget _buildName(BuildContext context, UserProfile user){
    return ValueListenableBuilder(valueListenable: user.firstName, builder:
      (BuildContext firstNameContext, String firstName, _) {
        return ValueListenableBuilder(valueListenable: user.lastName, builder:
          (BuildContext lastNameContext, String lastName, _) {
            final String fullName;
            if (lastName.isEmpty && firstName.isEmpty){
              fullName = "Utilisateur anonyme";
            }
            else {
              fullName = "$firstName $lastName";
            }
            return Text(
              fullName,
              style: const TextStyle(fontFamily: "HKGrotesk", fontSize: 24),
            );
          }
        );
      }
    );
  }

  Widget _buildEmail(BuildContext context, UserProfile user){
    return ValueListenableBuilder(valueListenable: user.email, builder:
      (BuildContext emailContext, String email, _) {
        return Text(
          email.isEmpty? "Aucun email renseigné" : email,
          style: const TextStyle(color: Colors.grey),
        );
      }
    );
  }

  /// Gets both the user and the list of events
  Future<Tuple2<UserProfile?, List<Cop1Event>>> getUserAndEvents (BuildContext context) async {
    SessionData s = session(context);
    return Tuple2(await s.user, await s.events);
  }

}

