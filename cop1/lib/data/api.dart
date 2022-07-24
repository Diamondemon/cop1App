import 'dart:convert';
import 'dart:io';

import 'package:cop1/constants.dart' show apiURL;
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class HTTP409Exception implements Exception {
  final String? detail;
  HTTP409Exception([this.detail]);

  @override
  String toString() => "HTTP Status Code 409: $detail";
}

class API {

  static Future<bool> createAccount(String phoneNumber) async{
    String request = "$apiURL/account/create";
    Map<String, String> data = {"phone": phoneNumber};
    try {
      Map<String, dynamic> retVal = await _post(request, data);
      return retVal["valid"];
    }
    on HTTP409Exception {
      rethrow;
    }
    on SocketException {
      rethrow;
    }
    on Exception catch (e){
      dev.log("Boom Error $e");
      return false;
    }
  }

  static Future<bool> askValidation(String phoneNumber) async{
    String request = "$apiURL/account/ask_validation";
    Map<String, String> data = {"phone": phoneNumber};
    try {
      Map<String, dynamic> retVal = await _post(request, data);
      return retVal['valid'];
    }
    on SocketException {
      rethrow;
    }
    on Exception catch (e){
      dev.log("Boom Error $e");
      return false;
    }
  }

  static Future<String> getToken(String phoneNumber, String code) async{
    String request = "$apiURL/account/login";
    Map<String, String> data = {"phone": phoneNumber, "code": code};
    try {
      Map<String, dynamic> retVal = await _post(request, data);
      return retVal["token"]["access_token"];
    }
    on SocketException {
      rethrow;
    }
    on Exception catch (e){
      dev.log("Boom Error $e");
      throw Exception();
    }
  }

  static Future<Map<String, dynamic>> getUser(String token){
    String request = "$apiURL/account/me";
    Map<String,String> headers = {"bearer":token};
    try {
      return _get(request, headers);
    }
    on SocketException {
      rethrow;
    }
    on Exception {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteUser(String token){
    String request = "$apiURL/account/me";
    Map<String,String> headers = {"bearer":token};
    try {
      return _delete(request, headers);
    }
    on SocketException {
      rethrow;
    }
    on Exception {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> subscribeToEvent(String token, int id){
    String request = "$apiURL/events/subscribe/$id";
    Map<String,String> headers = {"bearer":token};
    try {
      return _post(request,{}, headers);
    }
    on SocketException {
      rethrow;
    }
    on Exception {
      rethrow;
    }

  }

  static Future<Map<String, dynamic>> unsubscribeFromEvent(String token, int id){
    String request = "$apiURL/events/subscribe/$id";
    Map<String,String> headers = {"bearer":token};
    try {
      return _delete(request, headers);
    }
    on SocketException {
      rethrow;
    }
    on Exception {
      rethrow;
    }

  }

  static Future<Map<String, dynamic>?> events() async {
    String request = "$apiURL/events";
    try {
      Map<String, dynamic> retVal = await _get(request);
      //dev.log("Event List: $retVal");
      return retVal;
    }
    on SocketException {
      rethrow;
    }
    on Exception catch (e){
      dev.log("Boom Error $e");
      return null;
    }
  }

  /// Fetch a json object from the distant server
  static Future<Map<String, dynamic>> _post(String url, Map<String, dynamic> data, [Map<String, String>? headers]) async {
    final response = await http
        .post(Uri.parse(url), headers: {"accept": "application/json", "Content-Type": "application/json", ...?headers}, body: jsonEncode(data));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body);
    } else if (response.statusCode == 409){
      throw HTTP409Exception(jsonDecode(response.body)["detail"]);
    }
    else {
      throw Exception('Error ${response.statusCode} on $url');
    }
  }

  /// Fetch a json object from the distant server
  static Future<Map<String, dynamic>> _get(String url, [Map<String, String>? headers]) async {
    final response = await http
        .get(Uri.parse(url), headers: {"accept": "application/json", ...?headers});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body);

    } else if (response.statusCode == 409){
      throw HTTP409Exception(jsonDecode(response.body)["detail"]);
    }
    else {
      throw Exception('Error ${response.statusCode} on $url');
    }
  }

  /// Fetch a json object from the distant server
  static Future<Map<String, dynamic>> _delete(String url, [Map<String, String>? headers]) async {
    final response = await http
        .delete(Uri.parse(url), headers: {"accept": "application/json", ...?headers});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body);

    } else if (response.statusCode == 409){
      throw HTTP409Exception(jsonDecode(response.body)["detail"]);
    }
    else {
      throw Exception('Error ${response.statusCode} on $url');
    }
  }

}