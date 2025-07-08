import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'widgets/base_layout.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: lightTheme,           // Your Poppins + Material3 light theme
      darkTheme: darkTheme,        // Your Poppins + Material3 dark theme
      themeMode: ThemeMode.system, // Follows OS setting
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: const BaseLayout(
        // Since BaseLayout manages its own child pages,
        // you can pass an empty placeholder here.
        child: SizedBox(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
