import 'package:flutter/material.dart';

class Themes {
  static Color backgroundColor = const Color(0xFF2C2C2C);
  static Color foregroundColor = const Color(0xFF9E9E9E);
}

ThemeData get customTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.grey,
      appBarTheme: AppBarTheme(
          backgroundColor: Themes.backgroundColor,
          titleTextStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Themes.foregroundColor)),
      scaffoldBackgroundColor: Themes.backgroundColor,
      textTheme: TextTheme(
        labelLarge: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: Themes.foregroundColor),
        labelMedium: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w300,
            color: Themes.foregroundColor),
        labelSmall: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w300,
            color: Themes.foregroundColor),
        titleLarge: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Themes.foregroundColor),
        titleMedium: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Themes.foregroundColor),
        titleSmall: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: Themes.foregroundColor),
        bodyLarge: const TextStyle(fontSize: 12),
        bodyMedium: const TextStyle(fontSize: 10),
        bodySmall: const TextStyle(fontSize: 9),
      ),
    );
