import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'theme.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart'; //  Needed for kIsWeb
import 'package:google_maps/google_maps.dart' as gmaps;
import 'web_google_map.dart';
import 'base_layout.dart'; //  Make sure this exists
import 'web_ui_stub.dart'
    if (dart.library.html) 'web_ui_real.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  Only register platform view factory for web
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
// Firebase analytics instance
FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: BaseLayout(child: WebGoogleMap()), //  Renders Google Map inside your layout
      debugShowCheckedModeBanner: false,
    );
  }
}
