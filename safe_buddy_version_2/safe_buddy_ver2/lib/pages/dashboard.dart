// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:safe_buddy_ver2/theme.dart';
import '../widgets/alert_card.dart';
import '../widgets/map_overlay.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: text.titleLarge),
        backgroundColor: Theme.of(context).colorScheme.background, // updated
      ),
      body: const Dashboard(),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: [
          // Left: Alerts List
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crash Alerts Dashboard',
                  style: text.titleLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                // Example alert cards
                const AlertCard(),
                const SizedBox(height: 16),
                const AlertCard(),
                const SizedBox(height: 16),
                const AlertCard(),
              ],
            ),
          ),

          const SizedBox(width: 32),

          // Right: Map
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: const MapOverlay(),
            ),
          ),
        ],
      ),
    );
  }
}
