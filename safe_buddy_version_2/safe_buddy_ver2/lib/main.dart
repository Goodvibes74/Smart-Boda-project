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
      theme: lightTheme,           
      darkTheme: darkTheme,        
      themeMode: ThemeMode.system,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: const BaseLayout(
        //mainlyout widget that contains the main structure of the app
        //it contains the header, body and side menu
        child: SizedBox(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
