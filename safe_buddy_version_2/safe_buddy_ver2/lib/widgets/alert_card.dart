// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'map_overlay.dart'; // Assuming map_overlay.dart defines MapPingNotifier

class AlertCard extends StatelessWidget {
  final Map<String, String> crash;

  AlertCard({super.key, required this.crash});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Expect crash = { ...fields... }
    // These keys now correctly match what is passed from dashboard.dart
    final severity = crash['severity'] ?? '';
    final timestamp = crash['timestamp'] ?? '';
    final speed = crash['speed_kmph'] ?? ''; // Corrected key
    final type = crash['crash_type'] ?? ''; // Corrected key
    final simNumber = crash['sim_number'] ?? ''; // Corrected key
    final lat = double.tryParse(crash['latitude'] ?? ''); // Corrected key
    final lon = double.tryParse(crash['longitude'] ?? ''); // Corrected key

    Color severityColor;
    switch (severity.toLowerCase()) {
      case 'minor':
        severityColor = Colors.green;
        break;
      case 'moderate':
        severityColor = Colors.orange;
        break;
      case 'severe':
        severityColor = Colors.deepOrange;
        break;
      case 'critical':
        severityColor = Colors.red;
        break;
      default:
        severityColor = cs.error;
    }

    void _locateOnMap() {
      if (lat != null && lon != null) {
        final notifier = MapPingNotifier.of(context);
        if (notifier != null) {
          notifier.pingMap(lat, lon, severityColor);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.location_on, color: severityColor),
                const SizedBox(width: 8),
                Text('Pinged location: ($lat, $lon)'),
              ],
            ),
            backgroundColor: severityColor.withOpacity(0.9),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

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
                    Icon(Icons.warning, color: severityColor),
                    const SizedBox(width: 8),
                    Text(
                      'SIM: $simNumber', // Display SIM number
                      style: TextStyle(color: cs.onSurface),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Severity: $severity',
                      style: TextStyle(color: severityColor),
                    ),
                  ],
                ),
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
                        children: _buildButtons(
                          cs,
                          severityColor,
                          _locateOnMap,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: _buildButtons(
                          cs,
                          severityColor,
                          _locateOnMap,
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildButtons(
    ColorScheme cs,
    Color severityColor,
    VoidCallback onLocate,
  ) => [
    ElevatedButton(
      onPressed: onLocate,
      style: ElevatedButton.styleFrom(
        backgroundColor: severityColor,
        foregroundColor: cs.onPrimary,
      ),
      child: const Text('Locate'),
    ),
    TextButton(
      onPressed: () {},
      child: Text('Cancel', style: TextStyle(color: cs.onSurface)),
    ),
  ];
}
