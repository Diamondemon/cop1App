import 'package:flutter/material.dart';

/// Main colors of the app theme
const Color main1 = Color(0xffdf5f4d);
const Color main2 = Colors.white;

/// Root url of the API
const String apiURL = "https://je222004.rezel.net";

/// Url for privacy policy of the association
const String privacyPolicyUrl = "https://cop1.fr/privacy";

/// Regular Expression to recognize phone numbers
final RegExp phoneNumRE = RegExp(r"^(\+((9[679]|8[035789]|6[789]|5[90]|42|3[578]|2[1-689])|9[0-58]|8[1246]|6[0-6]|5[1-8]|4[013-9]|3[0-469]|2[70]|7|1))|0\s*\-*(\(*\d\)*\-*\s*){9,14}$");

/// Regular Expression to recognize only the start of phoneNumbers
final RegExp numStartRE = RegExp(r"^\+((9[679]|8[035789]|6[789]|5[90]|42|3[578]|2[1-689])|9[0-58]|8[1246]|6[0-6]|5[1-8]|4[013-9]|3[0-469]|2[70]|7|1)");

/// Url of the sentry bug reporting system
const String sentryDsn = 'https://8b058473fa0b49c8b80de9da9a8c08f1@o1402293.ingest.sentry.io/6734401';

/// Capture rate of the code traceback
const double sentryCaptureRate = 1.0;

/// Where to find the logo in the assets folder
const String logoUrl = "assets/Logo CO_P1 512.png";
