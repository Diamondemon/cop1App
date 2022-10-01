import 'package:flutter/material.dart';
import '../common.dart';

TextStyle tabStyle([double? fontSize]) => TextStyle(
  fontSize: fontSize,
);

/// The 2 tabs of the main tab view
List<Tab> tabs(BuildContext context) {
  return <Tab>[
    Tab(
        icon: const Icon(Icons.house),
        child: Text(AppLocalizations.of(context)!.newsFeed_title, style: tabStyle(10.0), maxLines: 2, textAlign: TextAlign.center,)),
    Tab(
        icon: const Icon(Icons.person),
        child: Text(AppLocalizations.of(context)!.userProfile_title, style: tabStyle(10.0), maxLines: 2, textAlign: TextAlign.center,)),
  ];
}