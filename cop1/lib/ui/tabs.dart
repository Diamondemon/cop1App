import 'package:flutter/material.dart';
import '../constants.dart';

TextStyle tabStyle([double? fontSize]) => TextStyle(
  color: lightTextColor,
  fontSize: fontSize,
);

/// The 5 tabs of the main tab view
List<Tab> tabs = <Tab>[
  /*Tab(
      icon: const Icon(Icons.scoreboard, color: main2),
      child: Text('Scores', style: tabStyle(10.0))),*/
  Tab(
      icon: const Icon(Icons.house),
      child: Text('Actualités', style: tabStyle(10.0), maxLines: 2, textAlign: TextAlign.center,)),
  Tab(
      icon: const Icon(Icons.person),
      child: Text('Profil', style: tabStyle(10.0), maxLines: 2, textAlign: TextAlign.center,)),
];

/// Nicknames for the tabs so that we don't have to remember their index
Map<String, int> tabIndex = {
  'match': 0, 'current match': 0,
  'score': 1, 'scores': 1,
  'new': 2, 'new impro': 2,
  'preparation': 3, 'all matches': 3,
  'database': 4,
};

/// Switches to the tab defined by a nickname [s]
///
/// Tab nicknames are defined in the [tabIndex] map in tabs.dart.
void switchToTab(TabController tabController, String s) {
  int? i = tabIndex[s.toLowerCase()];
  if (i != null) tabController.animateTo(i);
}