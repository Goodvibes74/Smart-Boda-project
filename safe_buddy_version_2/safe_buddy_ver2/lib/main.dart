import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'widgets/base_layout.dart';
import 'widgets/pages/auth_page.dart';
import 'widgets/pages/initial.dart'; 
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( 
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const SafeBuddyApp(),
    ),
  );
}

class SafeBuddyApp extends StatelessWidget {
  const SafeBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
      return MaterialApp(
        title: 'Safe Buddy',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeProvider.themeMode,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        initialRoute: '/initial', // Changed to start with InitialPage
        routes: {
          '/initial': (context) => const InitialPage(), // Added initial route
          '/auth': (context) => const AuthPage(),
          '/admin_dashboard': (context) => const BaseLayout(child: SizedBox()),
          '/home': (context) => const BaseLayout(child: SizedBox()),
        },
        debugShowCheckedModeBanner: false,
      );
    },
  );
  }
}