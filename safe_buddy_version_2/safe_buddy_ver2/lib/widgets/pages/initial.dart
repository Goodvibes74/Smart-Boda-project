// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:safe_buddy_ver2/theme.dart'; // Import your theme file
import 'package:flutter_svg/flutter_svg.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    super.initState();
    // Simulate loading time (e.g., 3 seconds) and navigate to '/auth'
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    

    return Scaffold(
      backgroundColor: cs.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/icon.svg',
              height: 150,
              width: 366,
            ),
            const SizedBox(height: 20),
            Text(
              'Safe Buddy',
              style: text.titleLarge?.copyWith(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: cs.onBackground,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your safety is our priority',
              style: text.bodyLarge?.copyWith(
                fontSize: 18,
                color: cs.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(cs.onBackground),
                minHeight: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}