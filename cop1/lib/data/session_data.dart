import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
//import 'dart:developer' as developer;


// Syntax for call:
// Provider.of<SessionData>(context, listen: false).var or
// Provider.of<SessionData>(context, listen: false).fun()

SessionData session(context) => Provider.of<SessionData>(context, listen: false);

/// Data that is exposed to all the widgets
class SessionData with ChangeNotifier {

  //final GlobalKey<ScaffoldState> _scaffoldKey= GlobalKey<ScaffoldState>();

  /// App preferences
  //static const storage = FlutterSecureStorage();

  /*
  /// A scaffold key, for a drawer menu
  GlobalKey<ScaffoldState> get scaffoldKey{
    return _scaffoldKey;
  }*/

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
    //loadAsset(context, 'data/database_category.txt').then(readCategories);
  }
}