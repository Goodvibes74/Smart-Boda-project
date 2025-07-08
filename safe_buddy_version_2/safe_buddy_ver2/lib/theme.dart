// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// ==================
// Color Constants
// ==================
const Color primary = Color(0xFF42A5F5);
const Color secondaryLight = Color(0xFF1A1A1A);
const Color secondaryDark = Color(0xFFE0E0E0);
const Color errorLight = Color(0xFFD32F2F);
const Color errorDark = Color(0xFFEF5350);
const Color neutral100 = Color(0xFFFFFFFF);
const Color neutral200 = Color(0xFFE8E8E8);
const Color neutral900 = Color(0xFF4A4A4A);
const Color neutral1000 = Color(0xFF333333);
const Color success = Color(0xFF4CAF50);
const Color warning = Color.fromARGB(255, 255, 140, 0);
const Color background_bright = Color(0xFFFAFAFA);
const Color background_dark = Color(0xFF1A1A1A);

// =============================
// Light & Dark ColorSchemes
// =============================
final ColorScheme lightColorScheme = const ColorScheme(
  brightness: Brightness.light,
  primary: primary,
  onPrimary: neutral100,
  primaryContainer: Color(0xFF90CAF9),
  onPrimaryContainer: neutral1000,
  secondary: secondaryLight,
  onSecondary: neutral100,
  secondaryContainer: Color(0xFFBDBDBD),
  onSecondaryContainer: neutral1000,
  error: errorLight,
  onError: neutral100,
  errorContainer: Color(0xFFFFCDD2),
  onErrorContainer: neutral1000,
  surface: neutral100,
  onSurface: neutral1000,
  surfaceContainerHighest: neutral200,
  onSurfaceVariant: neutral900,
  outline: neutral900,
  outlineVariant: neutral200,
  shadow: Colors.black,
  scrim: Colors.black54,
  inverseSurface: neutral1000,
  onInverseSurface: neutral100,
  inversePrimary: primary,
  tertiary: neutral200,
  onTertiary: neutral900,
  tertiaryContainer: Color(0xFFB2DFDB),
  onTertiaryContainer: neutral1000,
  background: background_bright, // Use your main background color here
);

final ColorScheme darkColorScheme = const ColorScheme(
  brightness: Brightness.dark,
  primary: primary,
  onPrimary: neutral100,
  primaryContainer: Color(0xFF1565C0),
  onPrimaryContainer: neutral100,
  secondary: secondaryDark,
  onSecondary: neutral1000,
  secondaryContainer: Color(0xFF616161),
  onSecondaryContainer: neutral100,
  error: errorDark,
  onError: neutral100,
  errorContainer: Color(0xFFB71C1C),
  onErrorContainer: neutral100,
  surface: neutral1000,
  onSurface: neutral100,
  surfaceContainerHighest: neutral900,
  onSurfaceVariant: neutral200,
  outline: neutral200,
  outlineVariant: neutral900,
  shadow: Colors.black,
  scrim: Colors.black54,
  inverseSurface: neutral100,
  onInverseSurface: neutral1000,
  inversePrimary: primary,
  tertiary: neutral200,
  onTertiary: neutral1000,
  tertiaryContainer: Color(0xFF004D40),
  onTertiaryContainer: neutral100,
  background: background_dark, // Use your main background color here
);

// ========================
// Text Theme Definitions
// ========================
final TextTheme lightTextTheme = const TextTheme(
  titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  bodyLarge: TextStyle(fontSize: 16),
);

final TextTheme darkTextTheme = const TextTheme(
  titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  bodyLarge: TextStyle(fontSize: 16),
);

// =============================
// Custom Extension for Extras
// =============================
class CustomTheme extends ThemeExtension<CustomTheme> {
  final Color sidebarBackground;
  final Color searchBarBackground;
  final Color searchBarBorder;

  const CustomTheme({
    required this.sidebarBackground,
    required this.searchBarBackground,
    required this.searchBarBorder,
  });

  @override
  CustomTheme copyWith({
    Color? sidebarBackground,
    Color? searchBarBackground,
    Color? searchBarBorder,
  }) {
    return CustomTheme(
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
      searchBarBackground: searchBarBackground ?? this.searchBarBackground,
      searchBarBorder: searchBarBorder ?? this.searchBarBorder,
    );
  }

  @override
  CustomTheme lerp(ThemeExtension<CustomTheme>? other, double t) {
    if (other is! CustomTheme) return this;
    return CustomTheme(
      sidebarBackground: Color.lerp(
        sidebarBackground,
        other.sidebarBackground,
        t,
      )!,
      searchBarBackground: Color.lerp(
        searchBarBackground,
        other.searchBarBackground,
        t,
      )!,
      searchBarBorder: Color.lerp(searchBarBorder, other.searchBarBorder, t)!,
    );
  }
}

// =========================
// Poppins-based ThemeData
// =========================

/// Make sure in pubspec.yaml you declared your assets/fonts:
///
/// flutter:
///   fonts:
///     - family: Poppins
///       fonts:
///         - asset: assets/fonts/Poppins-Thin.ttf       weight: 100
///         - asset: assets/fonts/Poppins-ExtraLight.ttf weight: 200
///         - asset: assets/fonts/Poppins-Light.ttf      weight: 300
///         - asset: assets/fonts/Poppins-Regular.ttf    weight: 400
///         - asset: assets/fonts/Poppins-Medium.ttf     weight: 500
///         - asset: assets/fonts/Poppins-SemiBold.ttf   weight: 600
///         - asset: assets/fonts/Poppins-Bold.ttf       weight: 700
///         - asset: assets/fonts/Poppins-ExtraBold.ttf  weight: 800
///         - asset: assets/fonts/Poppins-Black.ttf      weight: 900

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
  scaffoldBackgroundColor: background_bright, // Use your main background color
  // Global Poppins font
  fontFamily: 'Poppins',
  textTheme: lightTextTheme.apply(
    bodyColor: lightColorScheme.onSurface,
    displayColor: lightColorScheme.onSurface,
  ),

  iconTheme: IconThemeData(color: lightColorScheme.primary),
  extensions: <ThemeExtension<dynamic>>[
    const CustomTheme(
      sidebarBackground: neutral200,
      searchBarBackground: neutral100,
      searchBarBorder: neutral200,
    ),
  ],
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme,
  scaffoldBackgroundColor: background_dark, // Use your main background color
  // Global Poppins font
  fontFamily: 'Poppins',
  textTheme: darkTextTheme.apply(
    bodyColor: darkColorScheme.onSurface,
    displayColor: darkColorScheme.onSurface,
  ),

  iconTheme: IconThemeData(color: darkColorScheme.primary),
  extensions: <ThemeExtension<dynamic>>[
    const CustomTheme(
      sidebarBackground: neutral1000,
      searchBarBackground: neutral900,
      searchBarBorder: neutral200,
    ),
  ],
);
