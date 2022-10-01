import 'package:flutter/material.dart';

import 'constants.dart';

/// Application theme for the whole app
class AppTheme {
  static const Color _bg1 = main2;
  static const Color _accent1 = main1;
  /// Dark theme not implemented
  static bool isDark = false;

  /// Creates the theme for the app
  static ThemeData get themeData {
    /// Create a TextTheme and ColorScheme, that we can use to generate ThemeData
    TextTheme txtTheme = (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.copyWith();
    Color? txtColor = txtTheme.bodyText1?.color;
    txtTheme = txtTheme.apply(fontFamily: "HKGrotesk-Bold");
    txtTheme = txtTheme.copyWith(
        bodySmall: TextStyle( // for text
            fontFamily: "Raleway",
            color: txtTheme.bodySmall?.color,
            fontSize: txtTheme.bodySmall?.fontSize,
        ),
        bodyLarge:  const TextStyle( // for labels
            fontFamily: "Raleway",
            color: Color(0xffffffff),
        ),
        bodyMedium:  TextStyle( // for TabBar Icons
            fontFamily: "Raleway",
            color:txtTheme.bodyMedium?.color,
            fontSize: txtTheme.bodyMedium?.fontSize,
        ),
    );

    ColorScheme colorScheme = ColorScheme(
      // Decide how you want to apply your own custom them, to the MaterialApp
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: _accent1,
        secondary: _accent1,
        background: _bg1,
        surface: _bg1,
        onBackground: txtColor ??  _accent1,
        onSurface: txtColor ?? _accent1,
        onError: _accent1,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        error: Colors.blue.shade400);

    /// Now that we have ColorScheme and TextTheme, we can create the ThemeData
    ThemeData t = ThemeData.from(textTheme: txtTheme, colorScheme: colorScheme)
    // We can also add on some extra properties that ColorScheme seems to miss
        .copyWith(highlightColor: _accent1, toggleableActiveColor: _accent1, primaryTextTheme: txtTheme,
    appBarTheme: const AppBarTheme(elevation:0),
      snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.background.withOpacity(0.95),
          contentTextStyle: txtTheme.bodyMedium
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colorScheme.primary, linearTrackColor: Colors.transparent),
    );
    /// Return the themeData which MaterialApp can now use
    return t;
  }
}