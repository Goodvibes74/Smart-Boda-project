// lib/widgets/pages/dashboard.dart
// Removed ignore_for_file: deprecated_member_use, unused_local_variable as they are no longer necessary with updated code

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For getting current user
import 'package:intl/intl.dart'; // For date formatting
import '../../crash_algorithm.dart'; // Import CrashData and CrashAlgorithmService
import '../device.dart'; // Import Device and DeviceService
import '../alert_card.dart'; // Import AlertCard
import '../map_overlay.dart'; // Import CustomMapView (formerly MapOverlay)

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final CrashAlgorithmService _crashService = CrashAlgorithmService();
  final DeviceService _deviceService = DeviceService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    // Listen for authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (_currentUser == null) {
      return Center(
        child: AlertCard(
          title: 'Authentication Required',
          message: 'Please log in to view the dashboard and recent alerts.',
          type: AlertType.info,
          onClose: () {
            // Optionally navigate to auth page or just dismiss the message
          },
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        // Section for Recent Crash Alerts
        final alertsColumn = Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Crash Alerts',
                  style: text.titleLarge?.copyWith(
                    color: cs.onSurface,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  // StreamBuilder to listen for real-time crash data
                  child: StreamBuilder<List<CrashData>>(
                    stream: _crashService.getCrashStream(), // This now listens to the new structure
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: AlertCard(
                            title: 'Network Error',
                            message: 'Could not load crash data: ${snapshot.error}. Please check your internet connection.',
                            type: AlertType.error,
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: AlertCard(
                            title: 'No Recent Alerts',
                            message: 'No crash alerts have been detected recently.',
                            type: AlertType.info,
                          ),
                        );
                      }

                      final recentCrashes = snapshot.data!;
                      return ListView.builder(
                        itemCount: recentCrashes.length,
                        itemBuilder: (context, index) {
                          final crash = recentCrashes[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            // Pass the CrashData object directly to AlertCard
                            child: AlertCard(
                              crashData: crash,
                              onClose: () {
                                // Implement logic to dismiss/acknowledge crash if needed
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Crash alert dismissed (logic not implemented)')),
                                );
                              },
                            ),
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

        // Map Section
        final mapSection = Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Map & Device Locations',
                  style: text.titleLarge?.copyWith(
                    color: cs.onSurface,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: StreamBuilder<List<CrashData>>(
                      stream: _crashService.getCrashStream(),
                      builder: (context, crashSnapshot) {
                        // Also stream device data to show on map
                        return StreamBuilder<List<Device>>(
                          stream: _deviceService.getDevicesStream(_currentUser!.uid),
                          builder: (context, deviceSnapshot) {
                            if (crashSnapshot.connectionState == ConnectionState.waiting ||
                                deviceSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (crashSnapshot.hasError || deviceSnapshot.hasError) {
                              return Center(
                                child: AlertCard(
                                  title: 'Map Error',
                                  message: 'Could not load map data: ${crashSnapshot.error ?? deviceSnapshot.error}',
                                  type: AlertType.error,
                                ),
                              );
                            }

                            final crashes = crashSnapshot.data ?? [];
                            final devices = deviceSnapshot.data ?? [];

                            return CustomMapView(
                              crashLocations: crashes,
                              deviceLocations: devices,
                              showCrashMarkers: true,
                              showDeviceMarkers: true,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        if (isWide) {
          return Row(children: [alertsColumn, mapSection]);
        } else {
          // Stack vertically on narrow screens
          return SingleChildScrollView( // Added SingleChildScrollView for narrow screens
            child: Column(
              children: [
                alertsColumn,
                const Divider(thickness: 1, indent: 24, endIndent: 24), // Add dividers
                mapSection,
              ],
            ),
          );
        }
      },
    );
  }
}
