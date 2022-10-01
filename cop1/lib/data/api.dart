import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cop1/constants.dart' show apiURL;
import 'package:cop1/utils/user_profile.dart';
import 'package:http/http.dart' as http;
import 'package:sentry/sentry.dart';


class HTTP409Exception implements Exception {
  final String? detail;
  HTTP409Exception([this.detail]);

  @override
  String toString() => "HTTP Status Code 409: $detail";
}

class HTTP401Exception implements Exception {
  final String? detail;
  HTTP401Exception([this.detail]);

  @override
  String toString() => "HTTP Status Code 401: $detail";
}

class API {

  static final client = http.Client();

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
    on TimeoutException {
      throw const SocketException("Server is unreachable.");
    }
    on SocketException {
      rethrow;
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
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
    on TimeoutException {
      throw const SocketException("Server is unreachable.");
    }
    on SocketException {
      rethrow;
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
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
    on TimeoutException {
      throw const SocketException("Server is unreachable.");
    }
    on SocketException {
      rethrow;
    }
    on Exception {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUser(String token) async {
    String request = "$apiURL/account/me";
    Map<String,String> headers = {"bearer":token};
    try {
      return await _get(request, headers);
    }
    on TimeoutException {
      throw const SocketException("Server is unreachable.");
    }
    on SocketException {
      rethrow;
    }
    on HTTP401Exception {
      rethrow;
    }
    on Exception {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> modifyUser(String token, UserProfile user) async {
    String request = "$apiURL/account/me";
    Map<String,String> headers = {"bearer":token};
    Map<String,String> data = {"first_name":user.firstName.value, "last_name": user.lastName.value, "email": user.email.value};
    try {
      return await _post(request, data, headers);
    }
    on TimeoutException {
      throw const SocketException("Server is unreachable.");
    }
    on SocketException {
      rethrow;
    }
    on HTTP401Exception {
      rethrow;
    }
    on Exception {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteUser(String token) async {
    String request = "$apiURL/account/me";
    Map<String,String> headers = {"bearer":token};
    try {
      return await _delete(request, headers);
    }
    on TimeoutException {
      throw const SocketException("Server is unreachable.");
    }
    on SocketException {
      rethrow;
    }
    on HTTP401Exception {
      rethrow;
    }
    on Exception {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> subscribeToEvent(String token, int id) async {
    String request = "$apiURL/events/subscribe/$id";
    Map<String,String> headers = {"bearer":token};
    try {
      return await _post(request,{}, headers);
    }
    on TimeoutException {
      throw const SocketException("Server is unreachable.");
    }
    on SocketException {
      rethrow;
    }
    on Exception {
      rethrow;
    }

  }

  /// Unsubscribe the user from an event
  static Future<Map<String, dynamic>> unsubscribeFromEvent(String token, int id) async {
    String request = "$apiURL/events/subscribe/$id";
    Map<String,String> headers = {"bearer":token};
    try {
      return await _delete(request, headers);
    }
    on TimeoutException {
      throw const SocketException("Server is unreachable.");
    }
    on SocketException {
      rethrow;
    }
    on Exception {
      rethrow;
    }
  }

  /// Get the list of COP1 events
  static Future<Map<String, dynamic>?> events([Duration timeLimit = const Duration(seconds: 5)]) async {
    String request = "$apiURL/events";
    try {
      Map<String, dynamic> retVal = await _get(request, null, timeLimit);
      return retVal;
    }
    on TimeoutException {
      throw const SocketException("Server is unreachable.");
    }
    on SocketException {
      rethrow;
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
      return null;
    }
  }

  /// Get the list of COP1 events
  static Future<Map<String, dynamic>?> unscanned(String token,int id) async {
    String request = "$apiURL/unscanned/$id";
    try {
      Map<String, dynamic> retVal = await _get(request, {"bearer": token});
      return retVal;
    }
    on TimeoutException {
      throw const SocketException("Server is unreachable.");
    }
    on SocketException {
      rethrow;
    }
    catch (e, sT){
      Sentry.captureException(e, stackTrace: sT);
      return null;
    }
  }

  /// Send data to the distant server
  static Future<Map<String, dynamic>> _post(String url, Map<String, dynamic> data, [Map<String, String>? headers, Duration timeLimit = const Duration(seconds: 15)]) async {
    final response = await client
        .post(Uri.parse(url), headers: {"accept": "application/json", "Content-Type": "application/json", ...?headers}, body: jsonEncode(data), encoding: Encoding.getByName("UTF-8")).timeout(timeLimit);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body);
    } else if (response.statusCode == 409){
      throw HTTP409Exception(jsonDecode(response.body)["detail"]);
    }
    else if (response.statusCode == 401){
      throw HTTP401Exception(jsonDecode(response.body)["detail"]);
    }
    else {
      throw Exception('Error ${response.statusCode} on $url. Detail: ${jsonDecode(response.body)["detail"]}');
    }
  }

  /// Fetch a json object from the distant server without providing data
  static Future<Map<String, dynamic>> _get(String url, [Map<String, String>? headers, Duration timeLimit = const Duration(seconds: 15)]) async {
    final response = await http
        .get(Uri.parse(url), headers: {"accept": "application/json", ...?headers}).timeout(timeLimit);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body);

    } else if (response.statusCode == 409){
      throw HTTP409Exception(jsonDecode(response.body)["detail"]);
    }
    else if (response.statusCode == 401){
      throw HTTP401Exception(jsonDecode(response.body)["detail"]);
    }
    else {
      throw Exception('Error ${response.statusCode} on $url. Detail: ${jsonDecode(response.body)["detail"]}');
    }
  }

  /// Delete an object of the distant server
  static Future<Map<String, dynamic>> _delete(String url, [Map<String, String>? headers, Duration timeLimit = const Duration(seconds: 15)]) async {
    final response = await http
        .delete(Uri.parse(url), headers: {"accept": "application/json", ...?headers}, encoding: Encoding.getByName("UTF-8")).timeout(timeLimit);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return jsonDecode(response.body);

    }
    else if (response.statusCode == 409){
      throw HTTP409Exception(jsonDecode(response.body)["detail"]);
    }
    else if (response.statusCode == 401){
      throw HTTP401Exception(jsonDecode(response.body)["detail"]);
    }
    else {
      throw Exception('Error ${response.statusCode} on $url. Detail: ${jsonDecode(response.body)["detail"]}');
    }
  }

}