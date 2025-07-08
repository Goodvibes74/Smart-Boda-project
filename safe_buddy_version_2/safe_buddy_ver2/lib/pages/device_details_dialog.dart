import 'package:flutter/material.dart';
import '../models/device_data.dart';
import '../widgets/device_data_view.dart';

class DeviceDetailPage extends StatelessWidget {
  final String deviceId;
  final DeviceData data;
  final String location;
  final String status;

  const DeviceDetailPage({
    super.key,
    required this.deviceId,
    required this.data,
    required this.location,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Device Details - $deviceId'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location: $location", style: TextStyle(fontSize: 16)),
            Text("Status: $status", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            DeviceDataView(data: data), // full sensor data view
          ],
        ),
      ),
    );
  }
}
