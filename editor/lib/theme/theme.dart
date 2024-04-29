import 'package:flutter/material.dart';

ThemeData get customTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.grey,
      appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2C),
          titleTextStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
      scaffoldBackgroundColor: const Color(0xFF2C2C2C),
      textTheme: const TextTheme(
        labelLarge: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w300, color: Colors.grey),
        labelMedium: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w300, color: Colors.grey),
        labelSmall: TextStyle(
            fontSize: 8, fontWeight: FontWeight.w300, color: Colors.grey),
        titleLarge: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
        titleMedium: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey),
        titleSmall: TextStyle(
            fontSize: 8, fontWeight: FontWeight.w600, color: Colors.grey),
        bodyLarge: TextStyle(fontSize: 12),
        bodyMedium: TextStyle(fontSize: 10),
        bodySmall: TextStyle(fontSize: 9),
      ),
    );