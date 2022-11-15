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

/// Class to handle the API of cop1
class API {

  static final client = http.Client();

  /// Request an account creation associated to [phoneNumber]
  ///
  /// Throw a [SocketException] if the server is somehow unreachable.
  /// Relays any [HTTP409Exception] happening.
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

  /// Request a validation SMS for the account associated to [phoneNumber]
  ///
  /// Throw a [SocketException] if the server is somehow unreachable.
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

  /// Sends both [phoneNumber] and [code] to the server, to request the associated token.
  ///
  /// Throw a [SocketException] if the server is somehow unreachable.
  /// Relays any other [Exception] happening.
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

  /// Retrieves the user associated to the connection [token]
  ///
  /// Throw a [SocketException] if the server is somehow unreachable.
  /// Relays any other [Exception] happening.
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

  /// Modify the user associated with the [token], according to the new profile [user]
  ///
  /// Throw a [SocketException] if the server is somehow unreachable.
  /// Relays any other [Exception] happening.
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

  /// Deletes the account associated to the [token]
  ///
  /// Throw a [SocketException] if the server is somehow unreachable.
  /// Relays any other [Exception] happening.
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

  /// Subscribes the account associated to the [token] to the event n°[eventId] using the ticket n°[ticketId]
  ///
  /// Throw a [SocketException] if the server is somehow unreachable.
  /// Relays any other [Exception] happening.
  static Future<Map<String, dynamic>> subscribeToEvent(String token, int eventId, int ticketId) async {
    String request = "$apiURL/events/subscribe/$eventId/$ticketId";
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

  /// Unsubscribes the account associated to the [token] from the event n°[id]
  ///
  /// Throw a [SocketException] if the server is somehow unreachable.
  /// Relays any other [Exception] happening.
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

  /// Gets the list of COP1 events
  ///
  /// Throw a [SocketException] if the server is somehow unreachable.
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

  /// Retrieves all the tickets associated to the event n°[eventId]
  static Future<List<dynamic>?> tickets(int eventId, [Duration timeLimit = const Duration(seconds: 5)]) async {
    String request = "$apiURL/events/billets/$eventId";
    try {
      List<dynamic> retVal = await _get(request, null, timeLimit);
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

  /// Checks if the account associated to the [token] has missed event n°[eventId]
  ///
  /// Throw a [SocketException] if the server is somehow unreachable.
  static Future<Map<String, dynamic>?> unscanned(String token,int eventId) async {
    String request = "$apiURL/unscanned/$eventId";
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

  /// Sends [data] to the distant server at [url], providing [headers] if necessary.
  ///
  /// Throws a [HTTP401Exception] in case of 401 errors, a [HTTP409Exception] for 409 code errors,
  /// and a simple [Exception] in case any other status code than 200, 401 and 409 is returned.
  /// Will throw a [TimeoutError] if the request takes longer than [timeLimit].
  static Future<dynamic> _post(String url, Map<String, dynamic> data, [Map<String, String>? headers, Duration timeLimit = const Duration(seconds: 15)]) async {
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

  /// Fetches a json object from the distant server at [url] without providing data but the [headers].
  ///
  /// Throws a [HTTP401Exception] in case of 401 errors, a [HTTP409Exception] for 409 code errors,
  /// and a simple [Exception] in case any other status code than 200, 401 and 409 is returned.
  /// Will throw a [TimeoutError] if the request takes longer than [timeLimit].
  static Future<dynamic> _get(String url, [Map<String, String>? headers, Duration timeLimit = const Duration(seconds: 15)]) async {
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

  /// Deletes an object of the distant server
  ///
  /// Throws a [HTTP401Exception] in case of 401 errors, a [HTTP409Exception] for 409 code errors,
  /// and a simple [Exception] in case any other status code than 200, 401 and 409 is returned.
  /// Will throw a [TimeoutError] if the request takes longer than [timeLimit].
  static Future<dynamic> _delete(String url, [Map<String, String>? headers, Duration timeLimit = const Duration(seconds: 15)]) async {
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
      throw Exception('Error ${response.statusCode} on $url. Detail: ${response.body}');
    }
  }

}