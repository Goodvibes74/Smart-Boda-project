// lib/widgets/alert_card.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../crash_algorithm.dart'; // Import CrashData
import 'map_overlay.dart'; // Assuming MapPingNotifier is defined here or accessible
import 'package:intl/intl.dart'; // For date formatting

/// Defines the type of alert for styling.
enum AlertType {
  info,
  success,
  warning,
  error,
  crash, // Specific type for crash alerts
}

class AlertCard extends StatelessWidget {
  // Original crash map is replaced by CrashData object
  final CrashData? crashData; // Optional, if this card is used for generic alerts too
  final String? title; // Optional, for generic alerts
  final String? message; // Optional, for generic alerts
  final AlertType type; // For generic alerts, or derived from crashData severity

  // Callback to dismiss/close the alert card, if used as a dismissible notification
  final VoidCallback? onClose;

  const AlertCard({
    super.key,
    this.crashData,
    this.title,
    this.message,
    this.type = AlertType.info, // Default for generic use
    this.onClose,
  }) : assert(
          (crashData != null && title == null && message == null) ||
              (crashData == null && title != null && message != null),
          'Either provide crashData OR title and message, but not both or neither.',
        );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String displayTitle;
    String displayMessage;
    AlertType effectiveType;
    Color effectiveSeverityColor;
    double? lat;
    double? lon;
    String? deviceNo;

    if (crashData != null) {
      // Logic for crash data
      lat = crashData!.latitude;
      lon = crashData!.longitude;
      final severity = crashData!.severity;
      final speed = crashData!.speedKmph;
      final crashType = crashData!.crashType;
      final timestamp = crashData!.timestamp;

      displayTitle = 'Crash Detected! (Severity: $severity)';
      displayMessage =
          'Device: ${deviceNo ?? 'N/A'}\n'
          'Time: ${DateFormat.yMMMd().add_jm().format(timestamp)}\n'
          'Speed: ${speed.toStringAsFixed(1)} km/h\n'
          'Type: $crashType\n'
          'Location: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
      effectiveType = AlertType.crash;

      // Determine severity color based on numerical severity
      if (severity >= 4) {
        effectiveSeverityColor = Colors.red; // Critical/Severe
      } else if (severity == 3) {
        effectiveSeverityColor = Colors.deepOrange; // Severe
      } else if (severity == 2) {
        effectiveSeverityColor = Colors.orange; // Moderate
      } else {
        effectiveSeverityColor = Colors.green; // Minor or default
      }
    } else {
      // Logic for generic alerts
      displayTitle = title!;
      displayMessage = message!;
      effectiveType = type;

      switch (effectiveType) {
        case AlertType.success:
          effectiveSeverityColor = Colors.green.shade800;
          break;
        case AlertType.warning:
          effectiveSeverityColor = Colors.orange.shade800;
          break;
        case AlertType.error:
          effectiveSeverityColor = Colors.red.shade800;
          break;
        case AlertType.crash: // Should not happen if crashData is null, but fallback
          effectiveSeverityColor = Colors.red.shade900;
          break;
        case AlertType.info:
        default:
          effectiveSeverityColor = Colors.blue.shade800;
          break;
      }
    }

    void locateOnMap() {
      if (lat != null && lon != null) {
        final notifier = context.mapPingNotifier;
        if (notifier != null) {
          notifier.pingMap(lat, lon, effectiveSeverityColor);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.location_on, color: effectiveSeverityColor),
                const SizedBox(width: 8),
                Text('Pinged location: (${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)})'),
              ],
            ),
            backgroundColor: effectiveSeverityColor.withOpacity(0.9),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    // Determine background color based on effectiveType, similar to previous logic
    Color cardBackgroundColor;
        cardBackgroundColor = Colors.green.shade100;

    List<Widget> buildButtons(
      ColorScheme cs,
      Color color,
      VoidCallback? onLocate,
    ) {
      final List<Widget> buttons = [];
      if (crashData != null && onLocate != null) { // Only show Locate for crash alerts
        buttons.add(
          ElevatedButton(
            onPressed: onLocate,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: cs.onPrimary,
            ),
            child: const Text('Locate'),
          ),
        );
      }
      // Add a generic "Dismiss" or "Cancel" button if onClose is provided
      if (onClose != null) {
        buttons.add(
          TextButton(
            onPressed: onClose,
            child: Text('Dismiss', style: TextStyle(color: cs.onSurface)),
          ),
        );
      } else {
        // If no specific onClose, keep the original "Cancel" for crash alerts
        // This might be redundant if we always provide onClose for dismissible alerts
        if (crashData != null) {
           buttons.add(
            TextButton(
              onPressed: () { /* Do nothing or specific action */ },
              child: Text('Cancel', style: TextStyle(color: cs.onSurface)),
            ),
          );
        }
      }
      return buttons;
    }


    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
      ),
      color: cardBackgroundColor, // Use the derived background color
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
                    Icon(Icons.warning, color: effectiveSeverityColor), // Icon based on type
                    const SizedBox(width: 8),
                    Expanded( // Use Expanded to prevent overflow for long titles
                      child: Text(
                        displayTitle,
                        style: TextStyle(color: effectiveSeverityColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (onClose != null) // Add a close button if onClose is provided
                      IconButton(
                        icon: Icon(Icons.close, color: effectiveSeverityColor.withOpacity(0.7)),
                        onPressed: onClose,
                        tooltip: 'Dismiss',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  displayMessage,
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 16),
                isNarrow
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: buildButtons(
                          cs,
                          effectiveSeverityColor,
                          crashData != null ? locateOnMap : null, // Only pass locateOnMap if crashData exists
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: buildButtons(
                          cs,
                          effectiveSeverityColor,
                          crashData != null ? locateOnMap : null, // Only pass locateOnMap if crashData exists
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Ensure MapPingNotifier is accessible. If it's in map_overlay.dart,
// it needs to be defined there as a ChangeNotifier or InheritedWidget.
// For example, if it's a ChangeNotifier:
/*
class MapPingNotifier extends ChangeNotifier {
  LatLng? _pingLocation;
  Color? _pingColor;

  LatLng? get pingLocation => _pingLocation;
  Color? get pingColor => _pingColor;

  void pingMap(double lat, double lon, Color color) {
    _pingLocation = LatLng(lat, lon);
    _pingColor = color;
    notifyListeners();
  }

  // Static method to easily access the notifier
  static MapPingNotifier? of(BuildContext context) {
    try {
      return Provider.of<MapPingNotifier>(context, listen: false);
    } catch (e) {
      // Handle case where provider is not found in the widget tree
      return null;
    }
  }
}
*/
// You would then wrap your app or a relevant part of it with ChangeNotifierProvider<MapPingNotifier>
// in main.dart or a higher-level widget.
// If MapPingNotifier is an InheritedWidget, its `of` method would be different.
// I will assume it's a Provider-based ChangeNotifier for now.
