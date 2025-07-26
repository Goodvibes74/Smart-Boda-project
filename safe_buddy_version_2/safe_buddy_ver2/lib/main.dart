// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
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
import 'providers/profile_image_provider.dart';
import 'package:safe_buddy_ver2/widgets/map_overlay.dart'; // Import MapPingNotifier

FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase App
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileImageProvider()),
        //for map interaction across widgets
        ChangeNotifierProvider(create: (_) => MapPingNotifier()),
      ],
      child: const SafeBuddyApp(),
    ),
  );
}

Future<void> signInAnonymously() async {
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    print("Error signing in: $e");
  }
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
          initialRoute: '/initial',
          routes: {
            '/initial': (context) => const InitialPage(),
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
