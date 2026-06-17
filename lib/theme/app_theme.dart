import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors (darker, high-contrast)
  static const Color primary = Color(0xFF0D47A1);      // أزرق أغمق جدًا
  static const Color secondary = Color(0xFFFF8F00);    // ذهبي أغمق ومشبع
  static const Color accent = Color(0xFF1B5E20);       // أخضر أعمق
  static const Color error = Color(0xFFC62828);        // أحمر داكن

  // Neutral Colors
  static const Color background = Color.fromARGB(255, 252, 253, 255);   // خلفية رمادية داكنة نسبياً
  static const Color surface = Color(0xFFF2F4F8);      // سطح خفيف لكن متباين
  static const Color textPrimary = Color(0xFF071133);  // لون النص الأساسي - تقريباً أسود أزرق
  static const Color textSecondary = Color(0xFF37474F); // لون النص الثانوي - داكن

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF071133)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get defaultShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.28),
      blurRadius: 18,
      spreadRadius: 4,
      offset: const Offset(0, 6),
    ),
  ];

  // Typography - استخدام خطوط عصرية وحديثة
  static TextTheme get textTheme => TextTheme(
    displayLarge: GoogleFonts.almarai(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: textPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.almarai(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -0.5,
    ),
    displaySmall: GoogleFonts.almarai(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    headlineMedium: GoogleFonts.almarai(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    titleLarge: GoogleFonts.almarai(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    titleMedium: GoogleFonts.notoSansArabic(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textSecondary,
    ),
    titleSmall: GoogleFonts.notoSansArabic(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textSecondary,
    ),
    bodyLarge: GoogleFonts.notoSansArabic(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.notoSansArabic(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.notoSansArabic(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textSecondary,
    ),
    labelLarge: GoogleFonts.almarai(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        error: error,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
      ),
      
      textTheme: textTheme,

      // Component Themes
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.almarai(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shadowColor: Colors.black.withOpacity(0.24),
          textStyle: GoogleFonts.almarai(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: textSecondary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: GoogleFonts.notoSansArabic(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.notoSansArabic(
          color: textSecondary.withOpacity(0.6),
          fontSize: 14,
        ),
      ),
    );
  }
}