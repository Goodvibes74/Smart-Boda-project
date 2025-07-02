import 'package:flutter/material.dart';

// Define color constants based on the design tokens from "Global Tokens.json"
const primary = Color(0xFF42A5F5);
const secondaryLight = Color(0xFF1A1A1A);
const secondaryDark = Color(0xFFE0E0E0);
const errorLight = Color(0xFFD32F2F);
const errorDark = Color(0xFFEF5350);
const neutral100 = Color(0xFFFFFFFF);
const neutral200 = Color(0xFFE8E8E8);
const neutral900 = Color(0xFF4A4A4A);
const neutral1000 = Color(0xFF333333);

// Define ColorScheme for light mode (replace deprecated 'background' with 'surface')
final lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: primary,
  onPrimary: neutral100,
  secondary: secondaryLight,
  onSecondary: neutral100,
  error: errorLight,
  onError: neutral100,
  surface: neutral100, // Main backgrounds
  onSurface: neutral1000,
  // Remove 'background' and 'onBackground' as they are deprecated
);

// Define ColorScheme for dark mode (replace deprecated 'background' with 'surface')
final darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: primary,
  onPrimary: neutral100,
  secondary: secondaryDark,
  onSecondary: neutral1000,
  error: errorDark,
  onError: neutral100,
  surface: neutral1000, // Main backgrounds
  onSurface: neutral100,
  // Remove 'background' and 'onBackground' as they are deprecated
);

// Define ThemeData for light mode
final lightTheme = ThemeData(
  colorScheme: lightColorScheme,
  scaffoldBackgroundColor: lightColorScheme.surface,
  // Add other theme properties as needed
);

// Define ThemeData for dark mode
final darkTheme = ThemeData(
  colorScheme: darkColorScheme,
  scaffoldBackgroundColor: darkColorScheme.surface,
  // Add other theme properties as needed
);