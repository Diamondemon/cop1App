import 'package:flutter/material.dart';

const Color main1 = Color(0xffdf5f4d);
const Color main2 = Colors.white;
const Color darkTextColor = Colors.black;
const Color disabledTextColor = Colors.grey;
const Color lightTextColor = Colors.white;

const Color radioButtonColor = Colors.blue;

const String apiURL = "http://192.168.155.203:8000"; // root url of the API

const String sentryDsn = 'https://6c7c9a6f8392454f819e2e39856caf40@o1363652.ingest.sentry.io/6656629';
const double sentryCaptureRate = 1.0;

BoxDecoration buttonDecoration() => const BoxDecoration(
  color: Colors.black12,
  border: Border(
    top: BorderSide(color: Colors.black, width: 2),
    bottom: BorderSide(color: Colors.black, width: 6),
    left: BorderSide(color: Colors.black, width: 2),
    right: BorderSide(color: Colors.black, width: 2),
  ),
);
