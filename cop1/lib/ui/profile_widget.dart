import 'dart:io';

import 'package:cop1/ui/loading_widget.dart';
import 'package:cop1/ui/socket_exception_widget.dart';
import 'package:cop1/ui/unknown_error_widget.dart';
import 'package:cop1/utils/connected_widget_state.dart';
import 'package:cop1/utils/set_notifier.dart';
import 'package:cop1/utils/user_profile.dart';
import 'package:cop1/ui/event_tile.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';
import 'package:tuple/tuple.dart';

import '../common.dart';
import '../utils/cop1_event.dart';
import '../data/session_data.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: getUserAndEvents(context),
        builder: (BuildContext ctxt, AsyncSnapshot<Tuple2<UserProfile?, List<Cop1Event>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.hasError){
              if (snapshot.error is SocketException){
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ConnectedWidgetState.displayConnectionAlert(ctxt);
                });
                return SocketExceptionWidget(callBack: (ctx){setState(() {});});
              }
              Sentry.captureException(snapshot.error, stackTrace: snapshot.stackTrace);
              return UnknownErrorWidget(callBack: (ctx){setState(() {});});
            }
            else if (snapshot.hasData){
              if (snapshot.data!.item1 == null) {
                return const LoadingWidget();
              }
              return _buildListView(ctxt, snapshot.data!.item1!, snapshot.data!.item2);
            }
            else {
              return UnknownErrorWidget(callBack: (ctx){setState(() {});});
            }
          }
          else {
            return const LoadingWidget();
          }
        }
    );
  }

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

  Widget _buildEventsList(BuildContext context, SetNotifier<int> subEvents, List<Cop1Event> events){
    return ValueListenableBuilder(
        valueListenable: subEvents,
        builder: (BuildContext cntxt, Set<int> evts, _) {
          final List<int> sortedSubbed = evts.toList()
              ..sort((int a, int b){
            return - events.firstWhere((event) => event.id == a).date.compareTo(events.firstWhere((event) => event.id == b).date);
          });
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

  Future<Tuple2<UserProfile?, List<Cop1Event>>> getUserAndEvents (BuildContext context) async {
    SessionData s = session(context);
    return Tuple2(await s.user, await s.events);
  }

}

