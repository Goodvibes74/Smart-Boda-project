import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapOverlay extends StatelessWidget {
  const MapOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(-1.286389, 36.817223), // Example: Nairobi
            zoom: 12,
          ),
          markers: {
            Marker(
              markerId: MarkerId('device1'),
              position: LatLng(-1.286389, 36.817223),
            ),
          },
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(
              context,
            ).colorScheme.surface.withAlpha((0.7 * 255).toInt()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Battery: 80%',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Signal: Strong',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {},
                  child: Text('Navigate to Device'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
