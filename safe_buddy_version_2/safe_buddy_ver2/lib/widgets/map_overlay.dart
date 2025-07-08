// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe_buddy_ver2/theme.dart';

class MapOverlay extends StatelessWidget {
  const MapOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(-1.286389, 36.817223),
            zoom: 12,
          ),
          markers: const {
            // Marker(
            //   markerId: MarkerId('device1'),
            //   position: LatLng(-1.286389, 36.817223),
            // ),
          },
        ),

        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: cs.shadow.withOpacity(0.2), blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Battery: 80%', style: text.bodyLarge?.copyWith(color: cs.onSurface)),
                Text('Signal: Strong', style: text.bodyLarge?.copyWith(color: cs.onSurface)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                    ),
                    onPressed: () {},
                    child: Text('Navigate to Device', style: text.bodyLarge),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
