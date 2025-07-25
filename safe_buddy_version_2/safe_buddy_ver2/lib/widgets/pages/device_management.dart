// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../device.dart';
import '../device_registration_form.dart';

final databaseRef = FirebaseDatabase.instance.ref("devices");
Stream<DatabaseEvent> stream = databaseRef.onValue;

class DeviceManagerPage extends StatelessWidget {
  const DeviceManagerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    DatabaseReference ref = FirebaseDatabase.instance.ref('devices');

    return Scaffold(
      backgroundColor: cs.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Manager',
              style: text.titleLarge?.copyWith(
                color: cs.onSurface,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder<DatabaseEvent>(
              stream: ref.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading devices: ${snapshot.error}'));
                }
                final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>? ?? {};
                final devices = data.entries.map((e) => {
                  'id': e.key,
                }).toList();
                final active = devices.where((d) => d['online'] == true).length;
                final offline = devices
                .where((d) => d['online'] == false)
                .length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _CounterCard(
                          label: 'Active Devices',
                          value: active,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 16),
                        _CounterCard(
                          label: 'Offline Devices',
                          value: offline,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        final crossAxisCount = constraints.maxWidth ~/ 220;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: devices.length,
                          gridDelegate: 
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount > 1 
                                ? crossAxisCount 
                                : 1,
                            childAspectRatio: 1.8,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (_, i) {
                            final d = devices[i];
                            return DeviceCard(
                              deviceId: d['id'],
                              location: d['loc'],
                              isOnline: d['online'],
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: cs.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          'Register New Device',
                          style: text.titleMedium,
                        ),
                        content: const DeviceRegistrationForm(),
                      ),
                    );
                  },
                  child: const Text('Register New Device'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cs.onSurface.withOpacity(0.3)),
                  ),
                  onPressed: () {
                    // Implement turn off all logic if needed
                  },
                  child: const Text('Turn Off All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _CounterCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }
}
