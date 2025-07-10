// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../device.dart';
import '../device_registration_form.dart';

class DeviceManagerPage extends StatelessWidget {
  const DeviceManagerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Example data
    final devices = const [
      {'id': 'BD12345', 'loc': 'Nairobi, Kenya',  'online': true},
      {'id': 'BD67890', 'loc': 'Mombasa, Kenya',  'online': false},
      {'id': 'BD11223', 'loc': 'Kisumu, Kenya',   'online': true},
      {'id': 'BD44556', 'loc': 'Nakuru, Kenya',   'online': true},
    ];

    return Scaffold(
      backgroundColor: cs.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 
            // Page Title
            Text(
              'Device Manager',
              style: text.titleLarge?.copyWith(color: cs.onSurface, fontSize: 32),
            ),

            const SizedBox(height: 24),

            // Responsive grid/wrap
            Expanded(
              child: LayoutBuilder(builder: (ctx, constraints) {
                final crossAxisCount = constraints.maxWidth ~/ 220;
                return GridView.builder(
                  itemCount: devices.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount > 1 ? crossAxisCount : 1,
                    childAspectRatio: 1.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (_, i) {
                    final d = devices[i];
                    return DeviceCard(
                      deviceId: d['id']! as String,
                      location: d['loc']! as String,
                      isOnline: d['online']! as bool,
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 16),

            // Actions
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
                        title: Text('Register New Device', style: text.titleMedium),
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
                  onPressed: () {/* Turn off all logic */},
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
