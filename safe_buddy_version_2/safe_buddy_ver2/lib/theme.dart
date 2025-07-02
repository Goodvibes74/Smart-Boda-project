import 'package:flutter/material.dart';

// Define color constants based on the design tokens from "Global Tokens.json"
const primary = Color(0xFF42A5F5); // Colors/Primary/500: {"r":0.25882354378700256,"g":0.6470588445663452,"b":0.9607843160629272,"a":1}
const secondaryLight = Color(0xFF1A1A1A); // Colors/Secondary/500 light mode: {"r":0.10196078568696976,"g":0.10196078568696976,"b":0.10196078568696976,"a":1}
const secondaryDark = Color(0xFFE0E0E0); // Colors/Secondary/500 dark mode: {"r":0.8784313797950745,"g":0.8784313797950745,"b":0.8784313797950745,"a":1}
const errorLight = Color(0xFFD32F2F); // Colors/Error/500 light mode: {"r":0.8196078538894653,"g":0,"b":0,"a":1}
const errorDark = Color(0xFFEF5350); // Colors/Error/500 dark mode: {"r":0.9372549057006836,"g":0.32549020648002625,"b":0.3137255012989044,"a":1}
const neutral100 = Color(0xFFFFFFFF); // Colors/Neutral/100: {"r":1,"g":1,"b":1,"a":1}
const neutral200 = Color(0xFFE8E8E8); // Colors/Neutral/200: {"r":0.9098039269447327,"g":0.9098039269447327,"b":0.9098039269447327,"a":1}
const neutral900 = Color(0xFF4A4A4A); // Colors/Neutral/900: {"r":0.29019609093666077,"g":0.29019609093666077,"b":0.29019609093666077,"a":1}
const neutral1000 = Color(0xFF333333); // Colors/Neutral/1000: {"r":0.20000000298023224,"g":0.20000000298023224,"b":0.20000000298023224,"a":1}

// Define ColorScheme for light mode
final lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: primary,
  onPrimary: neutral100, // White text on primary color
  secondary: secondaryLight,
  onSecondary: neutral100, // White text on dark secondary
  error: errorLight,
  onError: neutral100, // White text on error color
  background: neutral100, // White background
  onBackground: neutral1000, // Dark text on light background
  surface: neutral200, // Light surface color for cards, sheets, etc.
  onSurface: neutral1000, // Dark text on light surface
);

// Define ColorScheme for dark mode
final darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: primary,
  onPrimary: neutral100, // White text on primary color
  secondary: secondaryDark,
  onSecondary: neutral1000, // Dark text on light secondary
  error: errorDark,
  onError: neutral100, // White text on error color
  background: neutral1000, // Dark background
  onBackground: neutral100, // Light text on dark background
  surface: neutral900, // Darker surface color for cards, sheets, etc.
  onSurface: neutral100, // Light text on dark surface
);

// Define ThemeData for light mode
final lightTheme = ThemeData(
  colorScheme: lightColorScheme,
  scaffoldBackgroundColor: lightColorScheme.background,
  // Additional properties can be added as needed (e.g., textTheme, appBarTheme)
);

// Define ThemeData for dark mode
final darkTheme = ThemeData(
  colorScheme: darkColorScheme,
  scaffoldBackgroundColor: darkColorScheme.background,
  // Additional properties can be added as needed
);