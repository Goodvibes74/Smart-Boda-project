// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final Map<String, String> crash;

  AlertCard({super.key, required this.crash});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Expect crash = { ...fields... }
    final severity = crash['severity'] ?? '';
    final deviceNo = crash['device'] ?? '000920'; // fallback if not present
    final timestamp = crash['timestamp'] ?? '';
    final speed = crash['speed'] ?? '';
    final type = crash['type'] ?? '';
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
      ),
      color: cs.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 300;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: cs.error),
                    const SizedBox(width: 8),
                    Text(
                      'Severity: $severity',
                      style: TextStyle(color: cs.error),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Device No: $deviceNo',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 4),
                Text(
                  timestamp,
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Speed: $speed km/h, Type: $type',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 16),
                isNarrow
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: _buildButtons(cs),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: _buildButtons(cs),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildButtons(ColorScheme cs) => [
    ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.error,
        foregroundColor: cs.onError,
      ),
      child: const Text('Locate'),
    ),
    TextButton(
      onPressed: () {},
      child: Text('Cancel', style: TextStyle(color: cs.onSurface)),
    ),
  ];
}
