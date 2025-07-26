import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: const ColorScheme.dark(
    background: Colors.black,
    surface: Colors.black,
    primary: Colors.white,
    secondary: Colors.grey,
  ),
  cardColor: Colors.grey[900],
  dialogBackgroundColor: Colors.black,
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.grey,
    contentTextStyle: TextStyle(color: Colors.white),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    bodySmall: TextStyle(color: Colors.white70),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[850],
      foregroundColor: Colors.white,
    ),
  ),
); 