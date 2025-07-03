import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'theme.dart';

// Web-specific
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: undefined_prefixed_name
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:google_maps/google_maps.dart' as gmaps;
import 'web_google_map.dart';
import 'base_layout.dart';

// Conditional web UI helper (aliased to avoid collision with dart:ui)
import 'web_ui_stub.dart'
    if (dart.library.html) 'web_ui_real.dart' as web_ui;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register the platform view for web only
  if (kIsWeb) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'map-canvas',
      (int viewId) => html.DivElement()
        ..id = 'map-canvas'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none',
    );
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Analytics (optional)
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  runApp(const SafeBuddyApp());
}

class SafeBuddyApp extends StatelessWidget {
  const SafeBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Buddy',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: BaseLayout(child: WebGoogleMap()),
      debugShowCheckedModeBanner: false,
    );
  }
}
