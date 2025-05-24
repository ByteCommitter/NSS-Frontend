import 'package:flutter/material.dart';

/// Class that defines all colors used in the application
/// This makes it easy to switch between different theme colors
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();
  
  // Current active theme
  static AppTheme currentTheme = tealTheme;
  
  // Theme accessor methods
  static Color get primary => currentTheme.primary;
  static Color get primaryLight => currentTheme.primaryLight;
  static Color get primaryDark => currentTheme.primaryDark;
  static Color get accent => currentTheme.accent;
  static Color get background => currentTheme.background;
  static Color get cardBackground => currentTheme.cardBackground;
  static Color get textPrimary => currentTheme.textPrimary;
  static Color get textSecondary => currentTheme.textSecondary;
  static Color get error => currentTheme.error;
  static Color get success => currentTheme.success;
  static Color get warning => currentTheme.warning;
  static Color get info => currentTheme.info;
  static Color get divider => currentTheme.divider;
  
  // Additional color accessors for specific components
  static Color get profileHeaderBackground => currentTheme.profileHeaderBackground;
  static Color get drawerHeaderStart => currentTheme.drawerHeaderStart;
  static Color get drawerHeaderEnd => currentTheme.drawerHeaderEnd;
  static Color get drawerBodyStart => currentTheme.drawerBodyStart;
  static Color get drawerBodyEnd => currentTheme.drawerBodyEnd;
  static Color get bottomNavSelectedItem => currentTheme.bottomNavSelectedItem;

  // Function to change the entire theme
  static void setTheme(AppTheme theme) {
    currentTheme = theme;
  }

  // Predefined themes
  static final AppTheme purpleTheme = AppTheme(
    name: 'Purple Theme',
    primary: const Color(0xFF673AB7),        // Deep Purple
    primaryLight: const Color(0xFFD1C4E9),   // Light Purple
    primaryDark: const Color(0xFF512DA8),    // Dark Purple
    accent: const Color(0xFFF8D510),         // Yellow
    background: Colors.white,
    cardBackground: Colors.white,
    textPrimary: Colors.black87,
    textSecondary: Colors.black54,
    error: Colors.red,
    success: Colors.green,
    warning: Colors.amber,
    info: Colors.blue,
    divider: Colors.grey[300]!,
    profileHeaderBackground: const Color(0xFFD1C4E9),
    drawerHeaderStart: const Color(0xFF673AB7),
    drawerHeaderEnd: const Color(0xFF9575CD),
    drawerBodyStart: Colors.white,
    drawerBodyEnd: const Color(0xFFEDE7F6),
    bottomNavSelectedItem: const Color(0xFFF8D510),
  );
  
  static final AppTheme tealTheme = AppTheme(
    name: 'Teal Theme',
    primary: const Color(0xFF009688),        // Teal
    primaryLight: const Color(0xFFB2DFDB),   // Light Teal
    primaryDark: const Color(0xFF00796B),    // Dark Teal
    accent: const Color(0xFFFFD54F),         // Amber
    background: Colors.white,
    cardBackground: Colors.white,
    textPrimary: Colors.black87,
    textSecondary: Colors.black54,
    error: Colors.red[700]!,
    success: Colors.green[700]!,
    warning: Colors.orange,
    info: Colors.lightBlue,
    divider: Colors.grey[300]!,
    profileHeaderBackground: const Color(0xFFB2DFDB),
    drawerHeaderStart: const Color(0xFF009688),
    drawerHeaderEnd: const Color(0xFF26A69A),
    drawerBodyStart: Colors.white,
    drawerBodyEnd: const Color(0xFFE0F2F1),
    bottomNavSelectedItem: const Color(0xFFFFD54F),
  );
  
  static final AppTheme indigoTheme = AppTheme(
    name: 'Indigo Theme',
    primary: const Color(0xFF3F51B5),        // Indigo
    primaryLight: const Color(0xFFC5CAE9),   // Light Indigo
    primaryDark: const Color(0xFF303F9F),    // Dark Indigo
    accent: const Color(0xFFFF4081),         // Pink
    background: Colors.white,
    cardBackground: Colors.white,
    textPrimary: Colors.black87,
    textSecondary: Colors.black54,
    error: Colors.red[700]!,
    success: Colors.green[700]!,
    warning: Colors.orange,
    info: Colors.blue,
    divider: Colors.grey[300]!,
    profileHeaderBackground: const Color(0xFFC5CAE9),
    drawerHeaderStart: const Color(0xFF3F51B5),
    drawerHeaderEnd: const Color(0xFF5C6BC0),
    drawerBodyStart: Colors.white,
    drawerBodyEnd: const Color(0xFFE8EAF6),
    bottomNavSelectedItem: const Color(0xFFFF4081),
  );
  
  // Component-specific colors that don't change with themes
  static const Color transparent = Colors.transparent;
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color blackOpacity30 = Color(0x4D000000);
  static const Color blackOpacity20 = Color(0x33000000);
  static final Color blackOpacity10 = Colors.black.withOpacity(0.1);
}

/// Class that holds a complete theme color set
class AppTheme {
  final String name;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Color background;
  final Color cardBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final Color divider;
  final Color profileHeaderBackground;
  final Color drawerHeaderStart;
  final Color drawerHeaderEnd;
  final Color drawerBodyStart;
  final Color drawerBodyEnd;
  final Color bottomNavSelectedItem;

  const AppTheme({
    required this.name,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.background,
    required this.cardBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.divider,
    required this.profileHeaderBackground,
    required this.drawerHeaderStart,
    required this.drawerHeaderEnd,
    required this.drawerBodyStart,
    required this.drawerBodyEnd,
    required this.bottomNavSelectedItem,
  });
}
