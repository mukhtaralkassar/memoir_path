import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF1B5E20); // Dark green
  static const Color secondaryColor = Color(0xFF388E3C); // Medium green
  static const Color accentColor = Color(0xFF4CAF50); // Light green
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color successColor = Color(0xFF4CAF50);
  
  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color shadowColor = Color(0x1F000000);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceColor, Color(0xFFF8F8F8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Typography
  static TextStyle get heading1 => GoogleFonts.cairo(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );

  static TextStyle get heading2 => GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle get heading3 => GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static TextStyle get subtitle1 => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get subtitle2 => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get body1 => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get body2 => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get caption => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textHint,
    height: 1.4,
  );

  static TextStyle get button => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textOnPrimary,
    height: 1.2,
  );

  static TextStyle get price => GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: primaryColor,
    height: 1.2,
  );

  static TextStyle get priceDiscount => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textHint,
    decoration: TextDecoration.lineThrough,
    height: 1.2,
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: textOnPrimary,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: dividerColor,
      shadowColor: shadowColor,
      textTheme: TextTheme(
        displayLarge: heading1,
        displayMedium: heading2,
        displaySmall: heading3,
        headlineMedium: subtitle1,
        headlineSmall: subtitle2,
        bodyLarge: body1,
        bodyMedium: body2,
        bodySmall: caption,
        labelLarge: button,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        titleTextStyle: subtitle1.copyWith(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: cardColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: button.copyWith(color: primaryColor),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: button.copyWith(color: primaryColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: body2.copyWith(color: textHint),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: primaryColor,
        labelStyle: body2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: dividerColor),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        elevation: 4,
      ),
    );
  }

  /// Parses a hex color string (#RRGGBB or RRGGBB) into a Flutter [Color].
  static Color parseHexColor(String? value, [Color? fallback]) {
    if (value == null || value.isEmpty) return fallback ?? primaryColor;
    try {
      final hex = value.replaceFirst('#', '').trim();
      if (hex.length == 6) {
        return Color(int.parse(hex, radix: 16) + 0xFF000000);
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
      return fallback ?? primaryColor;
    } catch (_) {
      return fallback ?? primaryColor;
    }
  }

  // Dynamic theme based on store colors
  static ThemeData storeTheme({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? surface,
    Color? onSurface,
    String? fontFamily,
  }) {
    final p = primary ?? primaryColor;
    final s = secondary ?? secondaryColor;
    final a = accent ?? accentColor;
    final b = background ?? backgroundColor;
    final surf = surface ?? surfaceColor;
    final onSurf = onSurface ?? textPrimary;

    return lightTheme.copyWith(
      primaryColor: p,
      scaffoldBackgroundColor: b,
      cardColor: surf,
      colorScheme: lightTheme.colorScheme.copyWith(
        primary: p,
        secondary: s,
        tertiary: a,
        surface: surf,
        background: b,
        onSurface: onSurf,
        onBackground: onSurf,
      ),
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: p,
        foregroundColor: Colors.white,
        titleTextStyle: subtitle1.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p,
          side: BorderSide(color: p, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: button.copyWith(color: p),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: button.copyWith(color: p),
        ),
      ),
      chipTheme: lightTheme.chipTheme.copyWith(
        selectedColor: p,
      ),
      bottomNavigationBarTheme: lightTheme.bottomNavigationBarTheme.copyWith(
        selectedItemColor: p,
      ),
      floatingActionButtonTheme: lightTheme.floatingActionButtonTheme.copyWith(
        backgroundColor: p,
      ),
      textTheme: fontFamily != null
          ? lightTheme.textTheme.apply(
              fontFamily: fontFamily,
              displayColor: onSurf,
              bodyColor: onSurf,
            )
          : lightTheme.textTheme.apply(
              displayColor: onSurf,
              bodyColor: onSurf,
            ),
    );
  }
}
