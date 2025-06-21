// utils/theme.dart
import 'package:flutter/material.dart';

class AppThemes {
  static final List<ThemeData> themes = [
    // Thème Nature Premium
    ThemeData(
      colorScheme: ColorScheme.light(
        primary: Color(0xFF2E7D32),
        secondary: Color(0xFF7CB342),
        surface: Colors.white,
        shadow: Color(0xFFF5F5F6),
      ),
      scaffoldBackgroundColor: Color(0xFFF5F5F6),
      cardTheme: CardThemeData(
        elevation: 3,
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black12,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF2E7D32),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(  // Previously headline6
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(  // Previously bodyText1
          fontSize: 14,
          height: 1.5,
        ),
        bodyMedium: TextStyle(  // Previously bodyText2
          fontSize: 12,
          color: Colors.grey[700],
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF2E7D32),
        elevation: 4,
      ),
    ),

    // Thème Bleu Professionnel
    ThemeData(
      colorScheme: ColorScheme.light(
        primary: Color(0xFF1976D2),
        secondary: Color(0xFF42A5F5),
        surface: Colors.white,
        shadow: Color(0xFFF5F7FA),
      ),
      // ... (same structure with updated text theme names)
    ),

    // Thème Sombre Élégant
    ThemeData(
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFBB86FC),
        secondary: Color(0xFF03DAC6),
        surface: Color(0xFF121212),
        shadow: Color(0xFF1E1E1E),
      ),
      // ... (same structure with updated text theme names)
    ),
  ];
}