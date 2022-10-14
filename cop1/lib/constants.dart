import 'package:flutter/material.dart';

const Color main1 = Color(0xffdf5f4d);
const Color main2 = Colors.white;
const Color darkTextColor = Colors.black;
const Color disabledTextColor = Colors.grey;
const Color lightTextColor = Colors.white;

const Color radioButtonColor = Colors.blue;

const String apiURL = "https://je222004.rezel.net"; // root url of the API
const String privacyPolicyUrl = "https://cop1.fr/privacy"; // url for privacy policy of the association

final RegExp phoneNumRE = RegExp(r"^(\+((9[679]|8[035789]|6[789]|5[90]|42|3[578]|2[1-689])|9[0-58]|8[1246]|6[0-6]|5[1-8]|4[013-9]|3[0-469]|2[70]|7|1))|0\s*\-*(\(*\d\)*\-*\s*){9,14}$");
final RegExp numStartRE = RegExp(r"^\+((9[679]|8[035789]|6[789]|5[90]|42|3[578]|2[1-689])|9[0-58]|8[1246]|6[0-6]|5[1-8]|4[013-9]|3[0-469]|2[70]|7|1)");

const String sentryDsn = 'https://8b058473fa0b49c8b80de9da9a8c08f1@o1402293.ingest.sentry.io/6734401';
const double sentryCaptureRate = 1.0;

const String logoUrl = "assets/Logo CO_P1 512.png";
