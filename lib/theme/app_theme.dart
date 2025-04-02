import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[200],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[800],
      elevation: 10,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
    ),
  );

  static final darkTheme = ThemeData(
    primarySwatch: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey[900],
      elevation: 10,
      centerTitle: true,
    ),
  );
}