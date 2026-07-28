import 'package:flutter/material.dart';

/// One ThemeData for the whole app. Widgets never hard-code a colour.
const seed = Color(0xFF7C5CFF);

ThemeData hanzoTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(surface: const Color(0xFF0A0A0B)),
    scaffoldBackgroundColor: const Color(0xFF0A0A0B),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0A0A0B), centerTitle: false),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF141417),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF232329)),
      ),
    ),
  );
}
