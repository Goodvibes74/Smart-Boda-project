// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Required for Firebase initialization
import 'package:firebase_analytics/firebase_analytics.dart'; // For Firebase Analytics
import 'firebase_options.dart';
import 'theme.dart'; // Custom theme definitions
import 'widgets/base_layout.dart'; // Base layout for authenticated users
import 'widgets/pages/auth_page.dart'; // Authentication page
import 'widgets/pages/initial.dart'; // Initial loading/splash page
import 'package:provider/provider.dart'; // State management
import 'providers/theme_provider.dart'; // Provider for managing theme
import 'providers/profile_image_provider.dart'; // Provider for managing user profile image
import 'package:safe_buddy_ver2/widgets/map_overlay.dart'; // Import MapPingNotifier

// Initialize Firebase Analytics instance
FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  // Ensure Flutter widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase App
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      // Register multiple providers for state management
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Provides theme mode
        ChangeNotifierProvider(create: (_) => ProfileImageProvider()), // Provides user profile image
        // Provider for map interaction across widgets (e.g., pinging locations)
        ChangeNotifierProvider(create: (_) => MapPingNotifier()), 
      ],
      child: const SafeBuddyApp(),
    ),
  );
}

Future<void> signInAnonymously() async {
  // Function to sign in a user anonymously using Firebase Authentication
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    print("Error signing in: $e");
  }
}

class SafeBuddyApp extends StatelessWidget {
  // Constructor for SafeBuddyApp
  const SafeBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer widget to listen for changes in ThemeProvider
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Safe Buddy',
          theme: lightTheme, // Light theme definition
          darkTheme: darkTheme, // Dark theme definition
          themeMode: themeProvider.themeMode, // Current theme mode (light/dark/system)
          navigatorObservers: [
            // Observer for Firebase Analytics to track screen views
            FirebaseAnalyticsObserver(analytics: analytics), 
          ],
          initialRoute: '/initial', // Set the initial route for the app
          routes: {
            // Define named routes for navigation
            '/initial': (context) => const InitialPage(), // Initial loading page
            '/auth': (context) => const AuthPage(), // Authentication page
            // Admin dashboard route, currently a placeholder
            '/admin_dashboard': (context) => const BaseLayout(child: SizedBox()), 
            '/home': (context) => const BaseLayout(child: SizedBox()), // Home page route
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
