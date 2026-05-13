import 'package:flutter/material.dart';

class AppColors {
  static bool isDark = true;

  static void configure({required bool dark}) {
    isDark = dark;
  }

  static Color get background =>
      isDark ? const Color(0xFF0D0F13) : const Color(0xFFF6F7F9);
  static Color get surface =>
      isDark ? const Color(0xFF171A20) : const Color(0xFFFFFFFF);
  static Color get surfaceHigh =>
      isDark ? const Color(0xFF20242B) : const Color(0xFFF0F2F5);
  static Color get text =>
      isDark ? const Color(0xFFF2F4F7) : const Color(0xFF111317);
  static Color get muted =>
      isDark ? const Color(0xFF9AA3AF) : const Color(0xFF6B7280);
  static Color get line =>
      isDark ? const Color(0xFF2A3038) : const Color(0xFFE0E4EA);
  static Color get soft =>
      isDark ? const Color(0xFF242932) : const Color(0xFFE9EDF3);
  static Color get dark =>
      isDark ? const Color(0xFF0A0C10) : const Color(0xFF111317);
  static Color get accent =>
      isDark ? const Color(0xFFD9E4F2) : const Color(0xFF111317);
  static Color get green =>
      isDark ? const Color(0xFF7FD6A8) : const Color(0xFF128A55);
  static Color get shadow =>
      isDark ? const Color(0x33000000) : const Color(0x160F172A);
}

ThemeData buildAppTheme({required bool isDark}) {
  AppColors.configure(dark: isDark);

  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: isDark ? Brightness.dark : Brightness.light,
    surface: AppColors.surface,
  );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    useMaterial3: true,
    textTheme:
        (isDark ? Typography.whiteCupertino : Typography.blackCupertino).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 24,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceHigh,
      hintStyle: TextStyle(color: AppColors.muted),
      labelStyle: TextStyle(color: AppColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.accent, width: 1.2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.text,
        foregroundColor: AppColors.background,
        minimumSize: const Size.fromHeight(58),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.text,
      foregroundColor: AppColors.background,
    ),
    dividerTheme: DividerThemeData(color: AppColors.line),
  );
}
