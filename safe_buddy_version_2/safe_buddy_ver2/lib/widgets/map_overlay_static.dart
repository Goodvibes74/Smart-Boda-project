import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapOverlayStatic extends StatefulWidget {
  const MapOverlayStatic({super.key});

  @override
  State<MapOverlayStatic> createState() => _MapOverlayStaticState();
}

class _MapOverlayStaticState extends State<MapOverlayStatic> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _loadStaticData();
  }

  void _loadStaticData() {
    final staticLocations = [
      {
        'deviceId': '000920',
        'latitude': 0.3363,
        'longitude': 32.5714,
        'severity': 'High',
      },
      {
        'deviceId': '000921',
        'latitude': 0.3350,
        'longitude': 32.5685,
        'severity': 'Medium',
      },
      {
        'deviceId': '000922',
        'latitude': 0.3290,
        'longitude': 32.5625,
        'severity': 'Low',
      },
    ];

    for (var data in staticLocations) {
      final lat = data['latitude'] as double;
      final lng = data['longitude'] as double;
      final severity = data['severity'] as String;
      final id = data['deviceId'] as String;

      final marker = Marker(
        markerId: MarkerId(id),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: 'Device $id',
          snippet: 'Severity: $severity',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(severity)),
      );

      final circle = Circle(
        circleId: CircleId(id),
        center: LatLng(lat, lng),
        radius: 150,
        fillColor: _getSeverityColor(severity).withOpacity(0.3),
        strokeColor: _getSeverityColor(severity),
        strokeWidth: 2,
      );

      _markers.add(marker);
      _circles.add(circle);
    }
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
    return SafeArea(
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0.3363, 32.5714), // Centered on Wandegeya
          zoom: 14,
        ),
        markers: _markers,
        circles: _circles,
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
