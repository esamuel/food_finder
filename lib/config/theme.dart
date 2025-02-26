import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light theme colors
  static const Color _lightPrimaryColor = Color(0xFF4CAF50);
  static const Color _lightPrimaryVariantColor = Color(0xFF388E3C);
  static const Color _lightSecondaryColor = Color(0xFFFFC107);
  static const Color _lightOnPrimaryColor = Colors.white;
  static const Color _lightBackgroundColor = Colors.white;
  static const Color _lightSurfaceColor = Colors.white;
  static const Color _lightErrorColor = Color(0xFFB00020);
  static const Color _lightTextPrimaryColor = Color(0xFF212121);
  static const Color _lightTextSecondaryColor = Color(0xFF757575);

  // Dark theme colors
  static const Color _darkPrimaryColor = Color(0xFF4CAF50);
  static const Color _darkPrimaryVariantColor = Color(0xFF1B5E20);
  static const Color _darkSecondaryColor = Color(0xFFFFD54F);
  static const Color _darkOnPrimaryColor = Colors.white;
  static const Color _darkBackgroundColor = Color(0xFF121212);
  static const Color _darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color _darkErrorColor = Color(0xFFCF6679);
  static const Color _darkTextPrimaryColor = Colors.white;
  static const Color _darkTextSecondaryColor = Color(0xFFB0B0B0);

  // Custom colors
  static const Color accentGreen = Color(0xFF00C853);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentPurple = Color(0xFF9C27B0);

  // Light theme
  static ThemeData lightTheme(BuildContext context) {
    // Use Google Fonts to load Poppins
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return ThemeData(
      primaryColor: _lightPrimaryColor,
      primaryColorDark: _lightPrimaryVariantColor,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimaryColor,
        primaryContainer: _lightPrimaryVariantColor,
        secondary: _lightSecondaryColor,
        surface: _lightSurfaceColor,
        error: _lightErrorColor,
        onPrimary: _lightOnPrimaryColor,
        onSecondary: _lightTextPrimaryColor,
        onSurface: _lightTextPrimaryColor,
        onError: _lightOnPrimaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: _lightBackgroundColor,
      appBarTheme: AppBarTheme(
        color: _lightPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: _lightOnPrimaryColor),
        titleTextStyle: GoogleFonts.poppins(
          color: _lightOnPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: textTheme.apply(
        bodyColor: _lightTextPrimaryColor,
        displayColor: _lightTextPrimaryColor,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: _lightPrimaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimaryColor,
          foregroundColor: _lightOnPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightPrimaryColor,
          side: const BorderSide(color: _lightPrimaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: _lightSurfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightErrorColor, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          color: _lightTextSecondaryColor,
          fontSize: 16,
        ),
        hintStyle: GoogleFonts.poppins(
          color: _lightTextSecondaryColor.withOpacity(0.5),
          fontSize: 16,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _lightSurfaceColor,
        selectedItemColor: _lightPrimaryColor,
        unselectedItemColor: _lightTextSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: _lightPrimaryColor,
        unselectedLabelColor: _lightTextSecondaryColor,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicator: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _lightPrimaryColor,
              width: 2,
            ),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _lightSurfaceColor,
        contentTextStyle: GoogleFonts.poppins(
          color: _lightTextPrimaryColor,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return _lightTextSecondaryColor.withOpacity(0.3);
            }
            if (states.contains(WidgetState.selected)) {
              return _lightPrimaryColor;
            }
            return _lightTextSecondaryColor;
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _lightSurfaceColor,
        disabledColor: _lightSurfaceColor.withOpacity(0.5),
        selectedColor: _lightPrimaryColor.withOpacity(0.2),
        secondarySelectedColor: _lightPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.poppins(
          color: _lightTextPrimaryColor,
          fontSize: 14,
        ),
        secondaryLabelStyle: GoogleFonts.poppins(
          color: _lightPrimaryColor,
          fontSize: 14,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: _lightSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: GoogleFonts.poppins(
          color: _lightTextPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.poppins(
          color: _lightTextSecondaryColor,
          fontSize: 16,
        ),
      ),
    );
  }

  // Dark theme
  static ThemeData darkTheme(BuildContext context) {
    // Use Google Fonts to load Poppins
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return ThemeData(
      primaryColor: _darkPrimaryColor,
      primaryColorDark: _darkPrimaryVariantColor,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimaryColor,
        primaryContainer: _darkPrimaryVariantColor,
        secondary: _darkSecondaryColor,
        surface: _darkSurfaceColor,
        error: _darkErrorColor,
        onPrimary: _darkOnPrimaryColor,
        onSecondary: _darkTextPrimaryColor,
        onSurface: _darkTextPrimaryColor,
        onError: _darkOnPrimaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: _darkBackgroundColor,
      appBarTheme: AppBarTheme(
        color: _darkSurfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: _darkOnPrimaryColor),
        titleTextStyle: GoogleFonts.poppins(
          color: _darkOnPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: textTheme.apply(
        bodyColor: _darkTextPrimaryColor,
        displayColor: _darkTextPrimaryColor,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: _darkPrimaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimaryColor,
          foregroundColor: _darkOnPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimaryColor,
          side: const BorderSide(color: _darkPrimaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: _darkSurfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkErrorColor, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          color: _darkTextSecondaryColor,
          fontSize: 16,
        ),
        hintStyle: GoogleFonts.poppins(
          color: _darkTextSecondaryColor.withOpacity(0.5),
          fontSize: 16,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242),
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurfaceColor,
        selectedItemColor: _darkPrimaryColor,
        unselectedItemColor: _darkTextSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: _darkPrimaryColor,
        unselectedLabelColor: _darkTextSecondaryColor,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicator: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _darkPrimaryColor,
              width: 2,
            ),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkSurfaceColor,
        contentTextStyle: GoogleFonts.poppins(
          color: _darkTextPrimaryColor,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: _darkSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: GoogleFonts.poppins(
          color: _darkTextPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.poppins(
          color: _darkTextSecondaryColor,
          fontSize: 16,
        ),
      ),
    );
  }
}
