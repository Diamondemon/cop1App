import 'dart:async';
import 'dart:io';

import 'package:cop1/common.dart';
import 'package:cop1/utils/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import '../utils/cop1_event.dart';

import 'api.dart';

class EventConflictError implements Exception {
  final Cop1Event conflictingEvent;
  final int allowedDelayDays;
  EventConflictError(this.conflictingEvent, this.allowedDelayDays);
}

class FullEventError implements Exception {
  FullEventError();
}

SessionData session(context) => Provider.of<SessionData>(context, listen: false);

/// Data that is exposed to all the widgets
class SessionData with ChangeNotifier {

  String _phoneNumber = "";
  String _token = "";
  int lastTimeSynchronized = 0;
  UserProfile? _localUser;
  List<Cop1Event> _events = [];
  final ValueNotifier<bool> _connectionListenable = ValueNotifier(false);
  final ValueNotifier<bool> _eventsChangedListenable = ValueNotifier(false);
  /// Reference to the Localization API, for proper translation of the messages
  AppLocalizations? localizations;

  String get token => _token;
  String get phoneNumber => _phoneNumber;
  /// Notifies if the [_localUser] has been successfully retrieved
  ValueNotifier<bool> get connectionListenable => _connectionListenable;
  /// Notifies if the [_events] list has been modified
  ValueNotifier<bool> get eventsChangedListenable => _eventsChangedListenable;

  /// Returns whether complete authentication credentials have been provided
  bool get isConnected => _token.isNotEmpty;

  Future<UserProfile?> get user async {
    if (_localUser == null) await connectUser();
    return _localUser;
  }

  Future<List<Cop1Event>> get events async {
    if (_events.isEmpty){
      await refreshEvents();
    }
    return _events;
  }

  /// Refreshes the list of events [events]
  ///
  /// Rethrows any [SocketException]
  Future<void> refreshEvents() async {
    Map<String, dynamic>? json;
    try {
      json = (await API.events())??{"events":[]};
    }
    on SocketException {
      rethrow;
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
    }
    if (json == null) return;

    _events = (json["events"] as List<dynamic>).map((item){
      return Cop1Event.fromJSON(item);
    }).toList();
    storeEvents();
    _localUser?.checkEventsExist(_events);
    eventsChangedListenable.value = !eventsChangedListenable.value;
  }

  /// Returns the event according to its Weezevent [id]
  Future<Cop1Event> getEvent(int eventId) async {
    if (_events.isEmpty) await refreshEvents();
    return _events.firstWhere((Cop1Event element) => element.id == eventId);
  }

  /// Connects the user profile using the [token]
  ///
  /// Rethrows a [SocketException] if the [_localUser] is not initiated.
  /// Disconnects the user if the server returns an 401 "unauthorized" status code.
  Future<void> connectUser() async {
    Map<String,dynamic>? json;
    try {
      if (_localUser==null && isConnected && _phoneNumber.isNotEmpty) {
        json = await API.getUser(_token);
      }
    }
    on HTTP401Exception {
      disconnectUser();
      return;
    }
    on SocketException {
      if (_localUser != null) return; // if there is already a user, do not bother
      rethrow;
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
      return;
    }
    if (json == null) return;
    _localUser = UserProfile.fromJSON(json);
    _localUser?.scheduleUserNotifications(_events, localizations!);
    storeUser();
  }

  /// Disconnects the [_localUser]
  void disconnectUser(){
    _localUser?.cancelUserNotifications(_events);
    _phoneNumber = "";
    _token = "";
    _localUser = null;
    _connectionListenable.value = false;
    _storeCreds();
    storeUser();
  }

  /// Registers the modified user info [firstName], [lastName] and [email]
  ///
  /// Rethrows any [SocketException]
  /// Returns false on any other [Exception]
  /// Disconnects the user if the server returns an 401 "unauthorized" status code.
  Future<bool> modifyUser(String firstName, String lastName, String email) async {
    _localUser?.firstName.value = firstName;
    _localUser?.lastName.value = lastName;
    _localUser?.email.value = email;
    try{
      final retVal = await API.modifyUser(token, _localUser!);
      if (retVal["valid"]) _localUser?.save();
      return retVal["valid"];
    }
    on SocketException {
      rethrow;
    }
    on HTTP401Exception {
      disconnectUser();
      return false;
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
      return false;
    }
  }

  /// Permanently deletes the user profile on the server and on the phone.
  ///
  /// Rethrows any [SocketException] or [Exception]
  Future<void> deleteUser() async {
    try {
      await API.deleteUser(token);
    }
    on SocketException {
      rethrow;
    }
    on Exception{
      rethrow;
    }
    disconnectUser();
  }

  /// Subscribes the [_localUser] to the specified [event] and schedules its notifications
  ///
  /// Throws an [EventConflictError] if the delay between events is not respected
  /// Throws a [FullEventError] if the event is already full.
  /// Rethrows any [SocketException]
  /// Should any other error occur, it is silenced an the app returns false.
  Future<bool> subscribe(Cop1Event event) async {
    final int conflictingId = _localUser!.checkEventConflicts(event, _events);
    if (conflictingId != -1){
      throw EventConflictError(_events.firstWhere((evt) => evt.id == conflictingId), _localUser!.minDelayDays);
    }
    final Map<String, dynamic> subscription;
    try{
      subscription = await API.subscribeToEvent(token, event.id);
    }
    on SocketException {
      rethrow;
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
      return false;
    }

    if (subscription["success"]){
      _localUser?.subscribeToEvent(event, subscription["barcode"]??"123456");
      event.scheduleNotifications(localizations!);
    }
    else {
      switch (subscription["reason"]??""){
        case "LIMITED": {
          verifySynchro();
          throw EventConflictError(event, _localUser!.minDelayDays);
        }
        case "FULL": {
          event.isAvailable = false;
          throw FullEventError();
        }
        default : {
          break;
        }
      }
    }

    return subscription["success"];
  }

  /// Unsubscribes the user from the [event]
  ///
  /// Rethrows all [SocketException]
  /// Returns false on any [Exception]
  Future<bool> unsubscribe(Cop1Event event) async {
    bool successful = false;
    try{
      successful = (await API.unsubscribeFromEvent(token, event.id))["success"]??true;
    }
    on SocketException {
      rethrow;
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
      return false;
    }
    if (!successful) return successful;

    event.isAvailable = false;
    _localUser?.unsubscribeFromEvent(event);
    event.cancelNotifications();
    return successful;
  }

  /// Sets the [_phoneNumber] to [phoneNumber] if the server accepts if
  ///
  /// Rethrows any [SocketException]
  Future<bool> setPhoneNumber(phoneNumber) async{
    try {
      _phoneNumber = phoneNumber;
      return await API.createAccount(phoneNumber);
    }
    on HTTP409Exception catch(e){
      if (e.detail=="Username already exists"){
        return true;
      }
      _phoneNumber = "";
      return false;
    }
    on SocketException {
      rethrow;
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
      return false;
    }
  }

  /// Retrieves the [_token] from the distant server, using [_phoneNumber] and the provided [code]
  ///
  /// Rethrows any [SocketException]
  Future<String> getToken(String code) async {
    try {
      _token = await API.getToken(_phoneNumber, code);
    }
    on SocketException {
      rethrow;
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
    }
    if (token.isNotEmpty) _connectionListenable.value = true;
    _storeCreds();
    return _token;
  }

  /// Loads the connection credentials stored in the [Hive] database
  Future<void> _loadCreds() async {
    final credBox = await Hive.openBox("Credentials");
    _phoneNumber = credBox.get("phone",defaultValue:  "");
    _token = credBox.get("token",defaultValue:  "");
    if (token.isNotEmpty) _connectionListenable.value = true;
  }

  /// Stores the connection credentials in the [Hive] database
  void _storeCreds() async {
    final credBox = await Hive.openBox("Credentials");
    credBox.put("phone", _phoneNumber);
    credBox.put("token", _token);
  }

  /// Asks for a validation code SMS to [_phoneNumber]
  Future<bool> askValidation() async {
    return await API.askValidation(_phoneNumber);
  }

  /// Asks for a validation code SMS
  Future<bool> hasMissedEvents() async {
    if (_localUser == null) await connectUser();

    if (_localUser!=null){
      for (int eventId in _localUser!.pastEvents){
        try{
          final json = await API.unscanned(_token, eventId);
          if (!json!["scanned"]){
            return true;
          }
        }
        on SocketException {
          rethrow;
        }
        catch (e, sT){
          Sentry.captureException(e, stackTrace: sT);
          return false;
        }
      }
    }
    return false;
  }

  /// Loads all the needed assets and information store in the [Hive] database
  Future<void> loadAssets(BuildContext context) async {
    await _loadCreds();
    await loadUser();
    await loadEvents();
    try {
      await refreshEvents();
    }
    on SocketException {
      return;
    }
  }

  /// Loads the user stored in the [Hive] database
  Future<void> loadUser() async{
    final userBox = await Hive.openBox("Credentials");
    _localUser = userBox.get("user");

    await verifySynchro();
  }

  /// Loads the events list stored in the [Hive] database
  Future<void> loadEvents() async{
    Box<dynamic>? eventsBox;
    try{
      eventsBox = await Hive.openBox("Events");
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
    }
    if (eventsBox==null) return;
    try {
      _events = (eventsBox.get("events", defaultValue: []) as List).cast<Cop1Event>();
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
    }
  }

  /// Stores the [_localUser] in the [Hive] database
  Future<void> storeUser() async{
    final userBox = await Hive.openBox("Credentials");

    try{
      userBox.put("user", _localUser);
    }
    catch (e, sT) {
      Sentry.captureException(e, stackTrace: sT);
    }
  }

  /// Stores the [_events] list in the [Hive] database
  Future<void> storeEvents() async{
    final eventsBox = await Hive.openBox("Events");

    try{
      eventsBox.put("events", _events);
    }
    catch (e, sT) {
      Sentry.captureException(e, stackTrace: sT);
    }
  }

  /// Verifies every 24 hours if the delay between two events allowed to the user has changed.
  Future<void> verifySynchro() async {
    final userBox = await Hive.openBox("Credentials");
    if (_localUser != null){
      lastTimeSynchronized = userBox.get("lastTimeSynchronized", defaultValue: 0);
      final int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime-lastTimeSynchronized >= Duration.millisecondsPerDay){
        lastTimeSynchronized = currentTime;
        try {
          final json = await API.getUser(_token);
          if (json["min_event_delay_days"]!=null){
            _localUser?.minDelayDays = json["min_event_delay_days"];
            userBox.put("lastTimeSynchronized", lastTimeSynchronized);
            storeUser();
          }
        }
        on Exception {
          return;
        }
      }
    }
  }

}