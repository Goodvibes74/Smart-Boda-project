// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/device.dart';
import '../widgets/device_registration_form.dart';

class DeviceManagerPage extends StatelessWidget {
  const DeviceManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Device Manager', style: text.titleLarge),
        backgroundColor: Theme.of(context).colorScheme.background, // updated
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Status',
              style: text.titleLarge?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 24),

            // Device cards row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  DeviceCard(
                    deviceId: 'BD12345',
                    location: 'Nairobi, Kenya',
                    status: 'Online',
                  ),
                  SizedBox(width: 16),
                  DeviceCard(
                    deviceId: 'BD67890',
                    location: 'Mombasa, Kenya',
                    status: 'Offline',
                  ),
                  SizedBox(width: 16),
                  DeviceCard(
                    deviceId: 'BD11223',
                    location: 'Kisumu, Kenya',
                    status: 'Online',
                  ),
                  SizedBox(width: 16),
                  DeviceCard(
                    deviceId: 'BD44556',
                    location: 'Nakuru, Kenya',
                    status: 'Online',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(
                          'Register New Device',
                          style: text.titleMedium,
                        ),
                        content: const DeviceRegistrationForm(),
                        backgroundColor: cs.surface,
                        titleTextStyle: text.titleMedium?.copyWith(
                          color: cs.primary,
                        ),
                      ),
                    );
                  },
                  child: Text('Register New Device', style: text.bodyLarge),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.onSurface.withOpacity(0.2),
                    foregroundColor: cs.onSurface,
                  ),
                  onPressed: () {},
                  child: Text('Turn Off All', style: text.bodyLarge),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
