// ignore_for_file: deprecated_member_use

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
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      color: cs.surface,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deviceId,
              style: text.titleMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              location,
              style: text.bodyLarge?.copyWith(
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  status == 'Online' ? Icons.circle : Icons.circle_outlined,
                  color: status == 'Online'
                      ? cs.tertiary
                      : cs.error,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: text.bodyLarge?.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
