// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapOverlay extends StatelessWidget {
  const MapOverlay({super.key});

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Stack(
        children: [
          const GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(-1.286389, 36.817223),
              zoom: 12,
            ),
          ),
        ],
      ),
    );
  }
}
