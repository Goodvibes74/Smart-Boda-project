import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final String deviceId;
  final String location;
  final String status;

  DeviceCard({required this.deviceId, required this.location, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(deviceId, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(location, style: TextStyle(color: Colors.white70)),
            Row(
              children: [
                Icon(
                  status == 'Online' ? Icons.circle : Icons.circle_outlined,
                  color: status == 'Online' ? Colors.green : Colors.red,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(status, style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}