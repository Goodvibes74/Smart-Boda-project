import 'package:flutter/material.dart';
import 'package:google_maps/google_maps.dart';

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
            color: Colors.black.withAlpha((0.7 * 255).toInt()),
            // .withOpacity is deprecated; use .withAlpha for 70% opacity (0.7 * 255 = 178)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Battery: 80%', style: TextStyle(color: Colors.white)),
                Text('Signal: Strong', style: TextStyle(color: Colors.white)),
                SizedBox(height: 8),
                ElevatedButton(
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