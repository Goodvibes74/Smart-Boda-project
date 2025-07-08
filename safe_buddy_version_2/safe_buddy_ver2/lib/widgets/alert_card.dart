// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: colorScheme.error),
                SizedBox(width: 8),
                Text(
                  'Severity: High',
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
            ),
            Text(
              'Device No: 000920',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
            Text(
              '2024-09-11 14:00',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                  child: Text('Locate'),
                ),
                SizedBox(width: 8),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colorScheme.onSurface),
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
