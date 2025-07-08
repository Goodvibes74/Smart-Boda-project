import 'package:flutter/material.dart';
import '../models/device_data.dart';
import '../widgets/device_data_view.dart';

class DeviceDetailPage extends StatelessWidget {
  final String deviceId;
  final String location;
  final String status;
  final DeviceData data;

  const DeviceDetailPage({
    super.key,
    required this.deviceId,
    required this.location,
    required this.status,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Device Details - $deviceId')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('📍 Location: $location'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: status == 'Online' ? Colors.green : Colors.red,
                  size: 12,
                ),
                const SizedBox(width: 6),
                Text(
                  'Status: $status',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 👇 Add graphs + sensors UI here
            DeviceDataView(data: data),
          ],
        ),
      ),
    );
  }
}
