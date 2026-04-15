import 'package:flutter/material.dart';

final lightMode = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1DB954), // Spotify green
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF1DB954),
    onPrimary: Colors.white,
    secondary: const Color(0xFF191414),
    onSecondary: Colors.white,
    // Black text on light background
    surface: Colors.white, // Light surface
    onSurface: const Color(0xFF000000), // Black text/icons on surface
    error: const Color(0xFFD32F2F),
    onError: Colors.white,
    tertiary: const Color(0xFF9E9E9E), // Light gray for tertiary elements
    outline: const Color(0xFFBDBDBD), // Light gray for borders/dividers
    shadow: const Color(0xFF000000),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white, // Primary color
    foregroundColor: Colors.black, // Text/icon color
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Color(0xFF919199),
    shadowColor: Colors.black,
  ),
  // bottomAppBarTheme: const BottomAppBarThemeData(color: Colors.white),
  bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
);

// Define the dark theme
final darkMode = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1DB954), // Spotify green
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF1DB954),
    onPrimary: Colors.white,
    secondary: const Color(0xFF191414),
    onSecondary: Colors.white,

    surface: Colors.black, // Dark surface
    onSurface: Colors.white,
    error: const Color(0xFFE57373),
    onError: Colors.white,
    tertiary: const Color(0xFF535353), // Mid-gray for tertiary elements
    outline: const Color(0xFF404040), // Dark gray for borders/dividers
    shadow: const Color(0xFF000000),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black, // Primary color
    foregroundColor: Colors.white, // Text/icon color
  ),
  navigationBarTheme: const NavigationBarThemeData(
    shadowColor: Colors.white,
    backgroundColor: Colors.white,
  ),
  // bottomAppBarTheme: const BottomAppBarThemeData(color: Colors.white),
  bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
);