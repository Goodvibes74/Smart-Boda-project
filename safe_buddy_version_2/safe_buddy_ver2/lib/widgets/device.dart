import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final String deviceId;
  final String location;
  final String status;

  const DeviceCard({
    super.key,
    required this.deviceId,
    required this.location,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deviceId,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              location,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
            Row(
              children: [
                Icon(
                  status == 'Online' ? Icons.circle : Icons.circle_outlined,
                  color: status == 'Online' ? Colors.green : colorScheme.error,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(status, style: TextStyle(color: colorScheme.onSurface)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
