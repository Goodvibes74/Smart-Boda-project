// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:flutter/material.dart';
import '../alert_card.dart';
import '../map_overlay.dart';
import 'package:safe_buddy_ver2/crash_algorithm.dart'; // Ensure this import is correct

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
    final Future<Map> crashesFuture = getCrashData(); // getCrashData is from crash_algorithm.dart

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
                        return const Center(child: Text('No alerts found'));
                      }
                      final crashMap = snapshot.data!;
                      final crashEntries = crashMap.entries.toList();
                      return ListView.builder(
                        itemCount: crashEntries.length,
                        itemBuilder: (context, index) {
                          final entry = crashEntries[index];
                          // crashData is List<dynamic> from getAllFormattedData:
                          // [simNumber, lat, lon, severity, speed, type]
                          final List<dynamic> crashDataList = entry.value;

                          // CORRECTED MAPPING:
                          // Map the List<dynamic> to the Map<String, String> format
                          // that AlertCard expects, using the correct keys.
                          final Map<String, String> crashStringMap = {
                            'sim_number': crashDataList[0]?.toString() ?? '',
                            'latitude': crashDataList[1]?.toString() ?? '',
                            'longitude': crashDataList[2]?.toString() ?? '',
                            'severity': crashDataList[3]?.toString() ?? '',
                            'speed_kmph': crashDataList[4]?.toString() ?? '',
                            'crash_type': crashDataList[5]?.toString() ?? '',
                            'timestamp': entry.key, // Timestamp is the map key
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

// This function is correctly defined in crash_algorithm.dart and imported.
// It fetches raw data and then formats it.
Future<Map> getCrashData() async {
  var raw = await getData(); // getData from crash_algorithm.dart
  var crashes = getAllFormattedData(raw); // getAllFormattedData from crash_algorithm.dart
  return crashes;
}
