// lib/widgets/alert_card.dart
// Removed ignore_for_file: deprecated_member_use as modern widgets are used

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
    Color effectiveIconColor; // Color for the icon and main title
    Color cardBackgroundColor;
    Color cardBorderColor;
    double? lat;
    double? lon;
    String? deviceNo;
    String? crashTimestampString; // To store formatted timestamp for crash

    if (crashData != null) {
      // Logic for crash data
      lat = crashData!.latitude;
      lon = crashData!.longitude;
      deviceNo = crashData!.deviceId; // Get deviceId from CrashData
      final severity = crashData!.severity;
      final speed = crashData!.speedKmph;
      final crashType = crashData!.crashType;
      final timestamp = crashData!.timestamp;
      crashTimestampString = DateFormat('yyyy-MM-dd HH:mm').format(timestamp);


      // Determine colors based on numerical severity for crash alerts
      if (severity >= 4) {
        effectiveIconColor = cs.error; // Severe/Critical uses error color
        cardBackgroundColor = cs.errorContainer; // Lighter error background
        cardBorderColor = cs.error;
      } else if (severity == 3) {
        effectiveIconColor = Colors.deepOrange; // Moderate-Severe
        cardBackgroundColor = Colors.deepOrange.shade100;
        cardBorderColor = Colors.deepOrange;
      } else if (severity == 2) {
        effectiveIconColor = Colors.orange; // Moderate
        cardBackgroundColor = Colors.orange.shade100;
        cardBorderColor = Colors.orange;
      } else {
        effectiveIconColor = Colors.green; // Minor or default
        cardBackgroundColor = Colors.green.shade100;
        cardBorderColor = Colors.green;
      }

      displayTitle = 'Severity: $severity'; // Display numerical severity
      displayMessage =
      'Speed: ${speed.toStringAsFixed(1)} km/h, Type: $crashType\n'
          'Location: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';

    } else {
      // Logic for generic alerts (using the 'type' property)
      displayTitle = title!;
      displayMessage = message!;

      switch (type) {
        case AlertType.success:
          effectiveIconColor = Colors.green.shade800;
          cardBackgroundColor = Colors.green.shade100;
          cardBorderColor = Colors.green.shade800;
          break;
        case AlertType.warning:
          effectiveIconColor = Colors.orange.shade800;
          cardBackgroundColor = Colors.orange.shade100;
          cardBorderColor = Colors.orange.shade800;
          break;
        case AlertType.error:
          effectiveIconColor = Colors.red.shade800;
          cardBackgroundColor = Colors.red.shade100;
          cardBorderColor = Colors.red.shade800;
          break;
        case AlertType.crash: // Should not happen if crashData is null, but fallback
          effectiveIconColor = Colors.red.shade900;
          cardBackgroundColor = Colors.red.shade200;
          cardBorderColor = Colors.red.shade900;
          break;
        case AlertType.info:
        default:
          effectiveIconColor = Colors.blue.shade800;
          cardBackgroundColor = Colors.blue.shade100;
          cardBorderColor = Colors.blue.shade800;
          break;
      }
    }

    void locateOnMap() {
      if (lat != null && lon != null) {
        final notifier = context.mapPingNotifier;
        if (notifier != null) {
          notifier.pingMap(lat, lon, effectiveIconColor); // Use effectiveIconColor for ping
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.location_on, color: effectiveIconColor),
                const SizedBox(width: 8),
                Text('Pinged location: (${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)})'),
              ],
            ),
            backgroundColor: effectiveIconColor.withOpacity(0.9),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    List<Widget> buildButtons(
        ColorScheme cs,
        Color buttonColor, // This will be the main color for "Locate"
        VoidCallback? onLocate,
        ) {
      final List<Widget> buttons = [];
      if (crashData != null && onLocate != null) {
        buttons.add(
          ElevatedButton(
            onPressed: onLocate,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor, // Use the derived color for Locate button
              foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners for buttons
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Locate'),
          ),
        );
      }
      const SizedBox(width: 8); // Space between buttons
      // Add a generic "Cancel" or "Dismiss" button
      buttons.add(
        TextButton(
          onPressed: onClose ?? () { /* Default action if no onClose provided */ },
          style: TextButton.styleFrom(
            foregroundColor: cs.onSurface.withOpacity(0.7), // Grey text for cancel
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: cs.onSurface.withOpacity(0.2)), // Light border
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Cancel'),
        ),
      );
      return buttons;
    }


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardBorderColor.withOpacity(0.3)), // Subtle border
      ),
      color: cs.surfaceContainerHighest, // Use a darker surface color from your theme for the card background
      elevation: 4, // Add some elevation for a floating effect
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon with a red background circle, matching the image
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: effectiveIconColor.withOpacity(0.2), // Lighter background for icon
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline, // Exclamation mark icon
                        color: effectiveIconColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayTitle,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface, // Text color on card surface
                          ),
                        ),
                        if (crashData != null) // Display Device No only for crash data
                          Text(
                            'Device No: ${deviceNo ?? 'N/A'}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.8),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                // Timestamp on the right
                if (crashData != null)
                  Text(
                    crashTimestampString!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Display additional crash details or generic message
            Text(
              crashData != null ? displayMessage : message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: buildButtons(
                cs,
                effectiveIconColor, // Pass the main color for the Locate button
                crashData != null ? locateOnMap : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
