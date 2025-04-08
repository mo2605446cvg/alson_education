import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? darkTheme : lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  static final lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.grey[200],
    cardColor: Colors.white,
    textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black87)),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.blue, foregroundColor: Colors.white),
  );

  static final darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    cardColor: Colors.grey[800],
    textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white70)),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.blue, foregroundColor: Colors.white),
  );
}
