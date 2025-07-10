// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class MapOverlay extends StatefulWidget {
  const MapOverlay({super.key});

  @override
  State<MapOverlay> createState() => _MapOverlayState();
}

class _MapOverlayState extends State<MapOverlay> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _listenToDeviceLocations();
  }

  void _listenToDeviceLocations() {
    final dbRef = FirebaseDatabase.instance.ref('devices');
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return;

      final markers = <Marker>{};
      final circles = <Circle>{};

      data.forEach((key, value) {
        final lat = value['latitude'];
        final lng = value['longitude'];
        final severity = value['severity'];
        final deviceId = value['deviceId'];

        if (lat != null && lng != null && severity != null) {
          final position = LatLng(lat, lng);

          markers.add(
            Marker(
              markerId: MarkerId(deviceId ?? key),
              position: position,
              infoWindow: InfoWindow(
                title: 'Device $deviceId',
                snippet: 'Severity: $severity',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(severity)),
            ),
          );

          circles.add(
            Circle(
              circleId: CircleId(deviceId ?? key),
              center: position,
              radius: 150,
              fillColor: _getSeverityColor(severity).withOpacity(0.3),
              strokeColor: _getSeverityColor(severity),
              strokeWidth: 2,
            ),
          );
        }
      });

      setState(() {
        _markers
          ..clear()
          ..addAll(markers);
        _circles
          ..clear()
          ..addAll(circles);
      });
    });
  }

  double _getMarkerHue(String severity) {
    switch (severity) {
      case 'High':
        return BitmapDescriptor.hueRed;
      case 'Medium':
        return BitmapDescriptor.hueOrange;
      case 'Low':
        return BitmapDescriptor.hueYellow;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(0.3363, 32.5714), // Kampala center
            zoom: 13,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          markers: _markers,
          circles: _circles,
        ),
      ),
    );
  }
}
