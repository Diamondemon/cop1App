import 'dart:async';
import 'dart:io';

import 'package:cop1/common.dart';
import 'package:cop1/utils/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:hive/hive.dart';
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
  EventConflictError(this.conflictingEvent);
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
    try {
      if (_localUser==null && isConnected && _phoneNumber.isNotEmpty){
        _localUser = UserProfile.fromJSON(await API.getUser(_token));
        _localUser?.scheduleUserNotifications(_events, localizations!);
      }
    }
    on HTTP401Exception {
      disconnectUser();
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
    }
    return _localUser;
  }

  Future<List<Cop1Event>> get events async {
    if (_events.isEmpty){
      await refreshEvents();
    }
    return _events;
  }

  Future<void> refreshEvents() async {
    Map<String, dynamic> json = (await API.events())??{"events":[]};
    _events = (json["events"] as List<dynamic>).map((item){
      return Cop1Event.fromJSON(item);
    }).toList();
  }

  Future<Cop1Event> getEvent(int eventId) async {
    if (_events.isEmpty) await refreshEvents();
    return _events.firstWhere((Cop1Event element) => element.id == eventId);
  }


  /// App preferences
  //static const storage = FlutterSecureStorage();

  /*
  /// A scaffold key, for a drawer menu
  GlobalKey<ScaffoldState> get scaffoldKey{
    return _scaffoldKey;
  }*/

  void disconnectUser(){
    _localUser?.cancelUserNotifications(_events);
    _phoneNumber = "";
    _token = "";
    _localUser = null;
    _connectionListenable.value = false;
    _storeCreds();
  }

  Future<bool> modifyUser(String firstName, String lastName, String email) async {
    _localUser?.firstName.value = firstName;
    _localUser?.lastName.value = lastName;
    _localUser?.email.value = email;
    try{
      final retVal = await API.modifyUser(token, _localUser!);
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
      throw EventConflictError(_events.firstWhere((evt) => evt.id == conflictingId));
    }
    try{
      final subscription = await API.subscribeToEvent(token, event.id);
      if (subscription["success"]){
        _localUser?.subscribeToEvent(event, subscription["barcode"]??"123456");
        event.scheduleNotifications(localizations!);
      }
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
      return;
    }
  }

  void unsubscribe(Cop1Event event){
    API.unsubscribeFromEvent(token, event.id);
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

  void _loadCreds() async {
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
  /*
  /// Stores the ID in the application's preferences.
  void storeID() async{
    await storage.write(key: "id", value: _id.toString());
  }*/

  /*
  /// Defines how to interpret the text in the category database
  void readCategories(String s) async {
    final categBox = await Hive.openBox('Categories');
    if (categBox.isEmpty){
      List<String> lineList = s.split("\n");
      for (String line in lineList) {
        if (line.startsWith("//") || line.isEmpty) continue;
        List<String> catItem = line.replaceAll("\r", "").split(",");
        categBox.add(
          Category(
            name: catItem[0], energy: energyFrom(catItem[1]),
            description: catItem.length==3 ? catItem[2] : "",
          ),
        );
      }
    }

  }*/

  /// Load all the text assets from the data/ folder
  Future<void> loadAssets(BuildContext context) async {
    _loadCreds();
    //loadAsset(context, 'data/database_category.txt').then(readCategories);
  }
}