// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:flutter/material.dart';
import '../widgets/alert_card.dart';
import '../widgets/map_overlay.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        final alertsColumn = Expanded(
          flex: 2,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Page Title
              Text(
                'Recent Alerts',
                style: text.titleLarge?.copyWith(color: cs.onSurface, fontSize: 32),
              ),
              const SizedBox(height: 24),
              const AlertCard(),
              const SizedBox(height: 16),
              const AlertCard(),
              const SizedBox(height: 16),
              const AlertCard(),
            ],
          ),
        );

        final mapSection = Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: const MapOverlay(),
            ),
          ),
        );

        if (isWide) {
          return Row(children: [alertsColumn, mapSection]);
        } else {
          // stack vertically on narrow screens
          return Column(
            children: [
              alertsColumn,
              const Divider(thickness: 1),
              mapSection,
            ],
          );
        }
      },
    );
  }
}
