import 'package:flutter/material.dart';
import '../widgets/device_card.dart';
import '../widgets/device_registration_form.dart';

class DeviceManagerPage extends StatelessWidget {
  const DeviceManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Device Manager')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Status',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            /// ✅ Responsive scrollable row of device cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  DeviceCard(
                    deviceId: 'SafeBoda #001',
                    location: 'Kampala, Uganda',
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

            /// Button row
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Register New Device'),
                        content: const DeviceRegistrationForm(),
                      ),
                    );
                  },
                  child: const Text('Register New Device'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onSurface.withOpacity(0.2),
                    foregroundColor: colorScheme.onSurface,
                  ),
                  onPressed: () {
                    // Handle turn-off logic here
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
