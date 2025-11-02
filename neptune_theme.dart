import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Neptune MIUI Color Palette
class NeptuneColors {
  // Primary Colors
  static const Color primary = Color(0xFF1677FF);
  static const Color primaryLight = Color(0xFF40A9FF);
  static const Color primaryDark = Color(0xFF0958D9);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFE6F4FF);
  static const Color accent = Color(0xFF36CFC9);
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFFA940);
  static const Color error = Color(0xFFF5222D);
  static const Color info = Color(0xFF1677FF);
  
  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textDisabled = Color(0xFFCCCCCC);
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);
}

// Neptune MIUI Theme Data
class NeptuneTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: NeptuneColors.primary,
        brightness: Brightness.light,
        primary: NeptuneColors.primary,
        secondary: NeptuneColors.secondary,
        surface: NeptuneColors.surface,
        background: NeptuneColors.background,
        error: NeptuneColors.error,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: NeptuneColors.background,
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: NeptuneColors.surface,
        foregroundColor: NeptuneColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: NeptuneColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: 0.2,
        ),
        iconTheme: const IconThemeData(
          color: NeptuneColors.primary,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: NeptuneColors.textSecondary,
          size: 24,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: NeptuneColors.surface,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shadowColor: NeptuneColors.shadow,
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NeptuneColors.surface,
        elevation: 8,
        selectedItemColor: NeptuneColors.primary,
        unselectedItemColor: NeptuneColors.textTertiary,
        selectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        type: BottomNavigationBarType.fixed,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: NeptuneColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 3,
        iconSize: 20,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: NeptuneColors.primary.withOpacity(0.1),
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: NeptuneColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: NeptuneColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 15,
          color: NeptuneColors.textSecondary,
        ),
        elevation: 8,
      ),
      
      // Text Theme
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme().apply(
          bodyColor: NeptuneColors.textPrimary,
          displayColor: NeptuneColors.textPrimary,
        ),
      ).copyWith(
        // Headlines
        headlineLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 28,
          color: NeptuneColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: NeptuneColors.textPrimary,
          letterSpacing: -0.3,
        ),
        headlineSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: NeptuneColors.textPrimary,
        ),
        
        // Titles
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: NeptuneColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: NeptuneColors.primary,
        ),
        titleSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: NeptuneColors.textSecondary,
        ),
        
        // Body
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          color: NeptuneColors.textPrimary,
          height: 1.4,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: NeptuneColors.textSecondary,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: NeptuneColors.textTertiary,
          height: 1.3,
        ),
        
        // Labels
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: NeptuneColors.textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: NeptuneColors.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 11,
          color: NeptuneColors.textTertiary,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeptuneColors.surfaceVariant,
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
          borderSide: const BorderSide(
            color: NeptuneColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: NeptuneColors.error,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: NeptuneColors.textTertiary,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeptuneColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: NeptuneColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NeptuneColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NeptuneColors.primary,
          side: const BorderSide(
            color: NeptuneColors.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return NeptuneColors.primary;
          }
          return Colors.grey[400];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return NeptuneColors.primary.withOpacity(0.3);
          }
          return Colors.grey[300];
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return NeptuneColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return NeptuneColors.primary;
          }
          return Colors.grey[400];
        }),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: NeptuneColors.primary,
        inactiveTrackColor: Colors.grey[300],
        thumbColor: NeptuneColors.primary,
        overlayColor: NeptuneColors.primary.withOpacity(0.2),
        valueIndicatorColor: NeptuneColors.primary,
        valueIndicatorTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: NeptuneColors.border,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: NeptuneColors.textSecondary,
        size: 24,
      ),
      
      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: NeptuneColors.primary,
        size: 24,
      ),
      
      // Use Material 3
      useMaterial3: true,
    );
  }
}

// Neptune MIUI Spacing Constants
class NeptuneSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

// Neptune MIUI Border Radius Constants
class NeptuneRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

// Neptune MIUI Shadow Constants
class NeptuneShadows {
  static List<BoxShadow> get small => [
    BoxShadow(
      color: NeptuneColors.shadowLight,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: NeptuneColors.shadow,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get large => [
    BoxShadow(
      color: NeptuneColors.shadow,
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get primary => [
    BoxShadow(
      color: NeptuneColors.primary.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
} 