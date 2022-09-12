import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cop1/common.dart';
import 'package:cop1/utils/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import '../utils/cop1_event.dart';

import 'api.dart';

class NoPhoneNumberException implements Exception {
  NoPhoneNumberException();
}

class NotConnectedException implements Exception {
  NotConnectedException();
}

class EventConflictError implements Exception {
  final Cop1Event conflictingEvent;
  final int allowedDelayDays;
  EventConflictError(this.conflictingEvent, this.allowedDelayDays);
}

SessionData session(context) => Provider.of<SessionData>(context, listen: false);

/// Data that is exposed to all the widgets
class SessionData with ChangeNotifier {

  //final GlobalKey<ScaffoldState> _scaffoldKey= GlobalKey<ScaffoldState>();
  String _phoneNumber = "";
  String _token = "";
  UserProfile? _localUser;
  List<Cop1Event> _events = [];
  final ValueNotifier<bool> _connectionListenable = ValueNotifier(false);
  AppLocalizations? localizations;

  String get token => _token;
  String get phoneNumber => _phoneNumber;
  ValueNotifier<bool> get connectionListenable => _connectionListenable;
  bool get isConnected => _token.isNotEmpty;

  Future<UserProfile?> get user async {
    if (_localUser == null) await connectUser();
    return _localUser;
  }

  Future<List<Cop1Event>> get events async {
    if (_events.isEmpty){
      log("Here I am");
      await refreshEvents();
    }
    return _events;
  }

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
  }

  Future<Cop1Event> getEvent(int eventId) async {
    if (_events.isEmpty) await refreshEvents();
    return _events.firstWhere((Cop1Event element) => element.id == eventId);
  }

  /*
  /// A scaffold key, for a drawer menu
  GlobalKey<ScaffoldState> get scaffoldKey{
    return _scaffoldKey;
  }*/

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
      if (_localUser != null) return;
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


  void disconnectUser(){
    _localUser?.cancelUserNotifications(_events);
    _phoneNumber = "";
    _token = "";
    _localUser = null;
    _connectionListenable.value = false;
    _storeCreds();
    storeUser();
  }

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

  Future<void> subscribe(Cop1Event event) async {
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
      return;
    }

    if (subscription["success"]){
      _localUser?.subscribeToEvent(event, subscription["barcode"]??"123456");
      event.scheduleNotifications(localizations!);
    }
  }

  Future<void> unsubscribe(Cop1Event event) async {
    try{
      await API.unsubscribeFromEvent(token, event.id);
    }
    on SocketException {
      rethrow;
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
      return;
    }
    _localUser?.unsubscribeFromEvent(event);
    event.cancelNotifications();
  }

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
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
      return false;
    }
  }

  Future<String> getToken(String code) async {
    if (_phoneNumber.isEmpty) throw NoPhoneNumberException();
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

  Future<void> _loadCreds() async {
    final credBox = await Hive.openBox("Credentials");
    _phoneNumber = credBox.get("phone",defaultValue:  "");
    _token = credBox.get("token",defaultValue:  "");
    if (token.isNotEmpty) _connectionListenable.value = true;
  }


  void _storeCreds() async {
    final credBox = await Hive.openBox("Credentials");
    credBox.put("phone", _phoneNumber);
    credBox.put("token", _token);
  }

  Future<bool> askValidation() async {
    if (_phoneNumber.isEmpty) throw NoPhoneNumberException();
    return await API.askValidation(_phoneNumber);
  }

  /// Async function loading an asset located in [path]
  Future<String> loadAsset(BuildContext context, String path) async {
    return await DefaultAssetBundle.of(context).loadString(path);
  }

  Future<bool> hasMissedEvents() async {
    if (_localUser == null) await connectUser();

    if (_localUser!=null){
      for (int eventId in _localUser!.pastEvents){
        try{
          final json = await API.unscanned(eventId);
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

  /// Load all the text assets from the data/ folder
  Future<void> loadAssets(BuildContext context) async {
    await _loadCreds();
    await loadUser();
    await loadEvents();
    log("$_events");
    log("${_events.isEmpty}");
    try {
      await refreshEvents();
    }
    on SocketException {
      log("Boom");
      log("${_events.isEmpty}");
      return;
    }
  }

  Future<void> loadUser() async{
    final userBox = await Hive.openBox("Credentials");
    _localUser = userBox.get("user");
  }

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

  Future<void> storeUser() async{
    final userBox = await Hive.openBox("Credentials");

    try{
      userBox.put("user", _localUser);
    }
    catch (e, sT) {
      Sentry.captureException(e, stackTrace: sT);
    }
  }


  Future<void> storeEvents() async{
    final eventsBox = await Hive.openBox("Events");

    try{
      eventsBox.put("events", _events);
      log("successfully stored");
    }
    catch (e, sT) {
      Sentry.captureException(e, stackTrace: sT);
    }
  }

}