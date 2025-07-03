import 'package:flutter/material.dart';
import '../widgets/alert_card.dart';
import '../widgets/map_overlay.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Dashboard(),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                // Example alert cards
                AlertCard(), // You can pass props for severity, etc.
                const SizedBox(height: 16),
                AlertCard(),
                const SizedBox(height: 16),
                AlertCard(),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Right: Map
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MapOverlay(),
            ),
          ),
        ],
      ),
    );
  }
}
