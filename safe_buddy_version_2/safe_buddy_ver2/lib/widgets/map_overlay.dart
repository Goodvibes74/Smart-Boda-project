// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

// Notifier for map pings
class MapPingNotifier extends InheritedWidget {
  final void Function(double lat, double lon, Color color) pingMap;
  const MapPingNotifier({
    required this.pingMap,
    required super.child,
    super.key,
  });

  static MapPingNotifier? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MapPingNotifier>();

  @override
  bool updateShouldNotify(MapPingNotifier oldWidget) => false;
}

class MapOverlay extends StatefulWidget {
  const MapOverlay({super.key});

  @override
  State<MapOverlay> createState() => _MapOverlayState();
}

class _MapOverlayState extends State<MapOverlay> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final StreamController<_PingData> _pingController =
      StreamController<_PingData>.broadcast();

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
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _getMarkerHue(severity),
              ),
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
    return MapPingNotifier(
      pingMap: (lat, lon, color) {
        _pingController.add(_PingData(lat, lon, color));
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0.3363, 32.5714), // Kampala center
                  zoom: 13,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  _pingController.stream.listen((ping) async {
                    await _mapController.animateCamera(
                      CameraUpdate.newLatLng(LatLng(ping.lat, ping.lon)),
                    );
                    // Optionally, add a temporary marker or effect
                  });
                },
                markers: _markers,
                circles: _circles,
              ),
              // Optionally, add a visual ping effect overlay here
            ],
          ),
        ),
      ),
    );
  }
}

class _PingData {
  final double lat;
  final double lon;
  final Color color;
  _PingData(this.lat, this.lon, this.color);
}
