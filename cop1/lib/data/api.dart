import 'dart:convert';

import 'package:cop1/constants.dart' show apiURL;
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class API {

  static Future<void> createAccount(String phoneNumber) async{
    String request = "$apiURL/account/create";
    Map<String, String> data = {"phone": phoneNumber};
    try {
      Map<String, dynamic> retVal = await _post(request, data);
      dev.log("Account created? ${retVal['valid']}");
    }
    on Exception catch (e){
      dev.log("Boom Error $e");
    }
  }

  static Future<Map<String, dynamic>?> events() async {
    String request = "$apiURL/events";
    try {
      Map<String, dynamic> retVal = await _get(request);
      //dev.log("Event List: $retVal");
      return retVal;
    }
    on Exception catch (e){
      dev.log("Boom Error $e");
      return null;
    }
  }

  /// Fetch a json object from the distant server
  static Future<Map<String, dynamic>> _post(String url, Map<String, dynamic> data) async {
    final response = await http
        .post(Uri.parse(url), headers: {"accept": "application/json", "Content-Type": "application/json"}, body: jsonEncode(data));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body);
    } else if (response.statusCode == 409){
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Status code 409');
    }
    else {
      throw Exception('Error ${response.statusCode} on $url');
    }
  }

  /// Fetch a json object from the distant server
  static Future<Map<String, dynamic>> _get(String url) async {
    final response = await http
        .get(Uri.parse(url), headers: {"accept": "application/json"});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body);
    }
    else {
      throw Exception('Error ${response.statusCode} on $url');
    }
  }
}