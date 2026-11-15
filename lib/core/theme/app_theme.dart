import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData _theme(Brightness b) {
  final isDark = b == Brightness.dark;
  final base = ColorScheme.fromSeed(seedColor: seedColor, brightness: b);
  final cs = base.copyWith(
    primary: isDark ? const Color(0xFF4ADE80) : seedColor,
    onPrimary: isDark ? const Color(0xFF062E16) : Colors.white,
    secondary: isDark ? accentAmberDark : accentAmber,
    surface: isDark ? darkCard : lightCard,
    onSurface: isDark ? const Color(0xFFF5F3EF) : const Color(0xFF1C1917),
    onSurfaceVariant: isDark ? const Color(0xFFA8A29E) : const Color(0xFF57534E),
    surfaceContainerHighest: isDark ? darkContainer : lightContainer,
    outlineVariant: isDark ? darkBorder : lightBorder,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: isDark ? darkBg : lightBg,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? darkBg : lightBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: cs.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: cs.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rCard),
        side: BorderSide(color: cs.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rControl),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rControl),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
  );
}

ThemeData lightTheme() => _theme(Brightness.light);
ThemeData darkTheme() => _theme(Brightness.dark);
