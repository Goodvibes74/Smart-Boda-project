import 'package:flutter/material.dart';
import '../models/device_data.dart'; // Contains DeviceData class and mock()
import '../pages/device_details_page.dart'; // Full-page view

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

    return InkWell(
      onTap: status == 'Online'
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeviceDetailPage(
                    deviceId: deviceId,
                    location: location,
                    status: status,
                    data: DeviceData.mock(), // Replace with live data later
                  ),
                ),
              );
            }
          : null,
      child: Card(
        color: colorScheme.surface,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deviceId,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 14,
                    color: status == 'Online' ? Colors.green : colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
