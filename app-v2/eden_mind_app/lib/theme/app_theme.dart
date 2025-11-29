import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EdenMindTheme {
  static const Color primaryColor = Color(0xFFA3A7F4); // Updated primary
  static const Color secondaryColor = Color(0xFFF9D5A2); // New secondary
  static const Color backgroundColor = Color(0xFFF7F8FD); // Lighter background
  static const Color surfaceColor = Colors.white;
  static const Color textColor = Color(0xFF12141D); // Darker text for contrast
  static const Color subTextColor = Color(0xFFA1A4B2);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
      ),
      useMaterial3: true,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: textColor),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: subTextColor),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        hintStyle: GoogleFonts.poppins(color: subTextColor),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 50),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
