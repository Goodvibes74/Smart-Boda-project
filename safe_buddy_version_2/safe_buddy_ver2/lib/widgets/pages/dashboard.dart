// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:flutter/material.dart';
import '../alert_card.dart';
import '../map_overlay.dart';
import 'package:safe_buddy_ver2/crash_algorithm.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(backgroundColor: cs.background, body: const Dashboard());
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // Use FutureBuilder to handle async crash data
    final Future<Map> crashesFuture = getCrashData();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        final alertsColumn = Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Alerts',
                  style: text.titleLarge?.copyWith(
                    color: cs.onSurface,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: FutureBuilder<Map>(
                    future: crashesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        // Network error page
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.wifi_off, size: 64, color: cs.error),
                              const SizedBox(height: 16),
                              Text(
                                'Network Error',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: cs.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please check your internet connection.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: cs.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No alerts found'));
                      }
                      final crashMap = snapshot.data!;
                      final crashEntries = crashMap.entries.toList();
                      return ListView.builder(
                        itemCount: crashEntries.length,
                        itemBuilder: (context, index) {
                          final entry = crashEntries[index];
                          // Convert to Map<String, String> for AlertCard
                          final crashData = entry.value;
                          final Map<String, String> crashStringMap = {
                            'lat': crashData[0]?.toString() ?? '',
                            'lon': crashData[1]?.toString() ?? '',
                            'severity': crashData[2]?.toString() ?? '',
                            'speed': crashData[3]?.toString() ?? '',
                            'type': crashData[4]?.toString() ?? '',
                            'timestamp': entry.key,
                          };
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: AlertCard(crash: crashStringMap),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
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
            children: [alertsColumn, const Divider(thickness: 1), mapSection],
          );
        }
      },
    );
  }
}

Future<Map> getCrashData() async {
  var raw = await getData();
  var crashes = getAllFormattedData(raw);
  return crashes;
}
