import 'package:flutter/material.dart';

class DeviceStatusCard extends StatelessWidget {
  const DeviceStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Device ID: BD12345', style: TextStyle(color: Colors.white)),
            const Text('Nairobi, Kenya', style: TextStyle(color: Colors.white)),
            Row(
              children: const [
                Icon(Icons.circle, color: Colors.green, size: 10),
                SizedBox(width: 5),
                Text('Online', style: TextStyle(color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// This widget represents a card that displays the status of a device.
// It includes the device ID, location, and online status.