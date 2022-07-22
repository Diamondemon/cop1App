import 'dart:async';
import 'dart:developer';

import 'package:cop1/utils/user_profile.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../utils/cop1_event.dart';

import 'api.dart';
//import 'dart:developer' as developer;


class NoPhoneNumberException implements Exception {
  NoPhoneNumberException();
}

class NotConnectedException implements Exception {
  NotConnectedException();
}

// Syntax for call:
// Provider.of<SessionData>(context, listen: false).var or
// Provider.of<SessionData>(context, listen: false).fun()

SessionData session(context) => Provider.of<SessionData>(context, listen: false);

/// Data that is exposed to all the widgets
class SessionData with ChangeNotifier {

  //final GlobalKey<ScaffoldState> _scaffoldKey= GlobalKey<ScaffoldState>();
  String _phoneNumber = "";
  String _token = "";
  UserProfile? _localUser;
  List<Cop1Event> _events = [];
  final ValueNotifier<bool> _connectionListenable = ValueNotifier(false);

  String get token => _token;
  String get phoneNumber => _phoneNumber;
  ValueNotifier<bool> get connectionListenable => _connectionListenable;

  Future<UserProfile?> get user async {
    if (_localUser==null && isConnected && _phoneNumber.isNotEmpty){
      _localUser = UserProfile.fromJSON(await API.getUser(_token));
    }
    return _localUser;
  }

  Future<List<Cop1Event>> get events async {
    if (_events.isEmpty){
      Map<String, dynamic> json = (await API.events())??{"events":[]};
      _events = (json["events"] as List<dynamic>).map((item){
        return Cop1Event.fromJSON(item);
      }
      ).toList();
    }
    return _events;
  }

  bool get isConnected => _token.isNotEmpty;

  /// App preferences
  //static const storage = FlutterSecureStorage();

  /*
  /// A scaffold key, for a drawer menu
  GlobalKey<ScaffoldState> get scaffoldKey{
    return _scaffoldKey;
  }*/

  void disconnectUser(){
    _phoneNumber = "";
    _token = "";
    _localUser = null;
    _connectionListenable.value = false;
  }

  void subscribe(Cop1Event event){
    API.subscribeToEvent(token, event.id);
    _localUser?.subscribeToEvent(event);
  }

  void unsubscribe(int id){
    API.unsubscribeFromEvent(token, id);
    _localUser?.unsubscribeFromEvent(id);
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
  }

  Future<String> getToken(String code) async {
    if (_phoneNumber.isEmpty) throw NoPhoneNumberException();
    _token = await API.getToken(_phoneNumber, code);
    if (token.isNotEmpty) _connectionListenable.value = true;
    return _token;
  }

  void _loadToken() async {

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
  /*
  /// Reads the Index contained in the preferences of the app.
  /// If none is found, save the default value.
  Future<void> loadIndex() async {
    String? stringIndex = await storage.read(key: "currentMatchIndex");
    if (stringIndex==null){
      storeIndex();
    }
    else {
      currentMatchIndex = int.parse(stringIndex);
    }
  }*/

  /// Load all the text assets from the data/ folder
  Future<void> loadAssets(BuildContext context) async {
    _loadToken();
    //loadAsset(context, 'data/database_category.txt').then(readCategories);
  }
}