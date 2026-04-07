import 'package:flutter/material.dart';

class AppTheme {
  // Primary custom colors based on existing design language
  static const Color primaryGreen = Color(0xFF1B8A4E);
  static const Color secondaryGreen = Color(0xFF27AE60);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: Colors.grey.shade50,
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryGreen,
      surface: Colors.white,
      onSurface: Colors.black87,
      surfaceContainerHighest: Colors.grey.shade100, // equivalent to typical shade100
      outline: Colors.grey.shade200,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    cardColor: Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey.shade400,
    ),
    textTheme: TextTheme(
      titleLarge: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      titleMedium: const TextStyle(color: Color(0xFF0D3320), fontWeight: FontWeight.bold), 
      bodyLarge: const TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.grey.shade600),
      labelSmall: TextStyle(color: Colors.grey.shade400),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: primaryGreen,
      secondary: secondaryGreen,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white,
      surfaceContainerHighest: const Color(0xFF2C2C2C), // typically for subtle shade
      outline: Colors.white24,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    cardColor: const Color(0xFF1E1E1E),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A1A),
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.white54,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), 
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      labelSmall: TextStyle(color: Colors.white38),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
