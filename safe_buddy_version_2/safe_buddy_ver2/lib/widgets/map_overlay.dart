// lib/widgets/map_overlay.dart
// Removed ignore_for_file: deprecated_member_use as modern practices are used

// ignore_for_file: public_member_api_docs
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart'; // For Realtime Database
import 'package:safe_buddy_ver2/crash_algorithm.dart'; // Import CrashData
import 'device.dart'; // Import Device and DeviceService
import 'package:provider/provider.dart'; // <--- ADDED THIS IMPORT

/// Notifier for map pings, using Provider for better state management.
/// This replaces the InheritedWidget for more standard Flutter practice.
class MapPingNotifier extends ChangeNotifier {
  LatLng? _pingLocation;
  Color? _pingColor;
 
  /// The geographical coordinates of the last ping.
  LatLng? get pingLocation => _pingLocation;
  /// The color associated with the last ping.
  Color? get pingColor => _pingColor;
 
  /// Pings the map at the given coordinates with a specified color.
  void pingMap(double lat, double lon, Color color) {
    _pingLocation = LatLng(lat, lon);
    _pingColor = color;
    notifyListeners(); // Notify listeners that the state has changed
  }
}

/// A widget that displays a map with device locations and crash markers.
/// This widget now takes `crashLocations` and `deviceLocations` directly,
/// allowing its parent to manage the data streams.
class CustomMapView extends StatefulWidget {
  /// A list of [CrashData] objects to be displayed as markers on the map.
  final List<CrashData> crashLocations;
  /// A list of [Device] objects to be displayed as markers on the map.
  final List<Device> deviceLocations;
  /// A boolean indicating whether crash markers should be shown.
  final bool showCrashMarkers;
  /// A boolean indicating whether device markers should be shown.
  final bool showDeviceMarkers;
  /// The initial geographical position for the map camera.
  final LatLng? initialCameraPosition; // Optional initial camera position

  const CustomMapView({
    super.key,
    this.crashLocations = const [],
    this.deviceLocations = const [],
    this.showCrashMarkers = true,
    this.showDeviceMarkers = true,
    this.initialCameraPosition,
  });

  @override
  State<CustomMapView> createState() => _CustomMapViewState();
}

class _CustomMapViewState extends State<CustomMapView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update markers whenever the input data changes
    if (widget.crashLocations != oldWidget.crashLocations ||
        widget.deviceLocations != oldWidget.deviceLocations ||
        widget.showCrashMarkers != oldWidget.showCrashMarkers ||
        widget.showDeviceMarkers != oldWidget.showDeviceMarkers) {
      _updateMarkers();
    }
  }

  /// Callback function when the Google Map is created.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMarkers(); // Initial marker update

    // Listen to the MapPingNotifier for camera movements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapPingNotifier = context.mapPingNotifier; // Access via extension
      if (mapPingNotifier != null) {
        mapPingNotifier.addListener(() {
          if (mapPingNotifier.pingLocation != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(mapPingNotifier.pingLocation!),
            );
            // Optionally add a temporary visual effect for the ping
          }
        });
      }
    });

    _moveCameraToInitialPosition();
  }

  /// Updates the markers and circles on the map based on crash and device data.
  void _updateMarkers() {
    _markers.clear();
    _circles.clear(); // Clear existing circles as well

    if (widget.showCrashMarkers) {
      for (var crash in widget.crashLocations) {
        final position = LatLng(crash.latitude, crash.longitude);
        // Use deviceId and timestamp for unique marker ID
        final markerId = MarkerId('crash_${crash.deviceId}_${crash.timestamp.millisecondsSinceEpoch}');

        // Determine marker hue and circle color based on severity
        Color severityColor;
        double markerHue;
        if (crash.severity >= 4) {
          severityColor = Colors.red;
          markerHue = BitmapDescriptor.hueRed;
        } else if (crash.severity == 3) {
          severityColor = Colors.deepOrange;
          markerHue = BitmapDescriptor.hueOrange;
        } else if (crash.severity == 2) {
          severityColor = Colors.orange;
          markerHue = BitmapDescriptor.hueYellow;
        } else {
          severityColor = Colors.green;
          markerHue = BitmapDescriptor.hueGreen;
        }

        _markers.add(
          Marker(
            markerId: markerId,
            position: position,
            infoWindow: InfoWindow(
              title: 'Crash: ${crash.crashType}',
              snippet: 'Device: ${crash.deviceId}, Severity: ${crash.severity}, Speed: ${crash.speedKmph.toStringAsFixed(1)} km/h',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
          ),
        );

        _circles.add(
          Circle(
            circleId: CircleId('crash_circle_${crash.deviceId}_${crash.timestamp.millisecondsSinceEpoch}'),
            center: position,
            radius: 150, // Example radius
            fillColor: severityColor.withOpacity(0.3),
            strokeColor: severityColor,
            strokeWidth: 2,
          ),
        );
      }
    }

    // Add device markers if enabled
    if (widget.showDeviceMarkers) {
      for (var device in widget.deviceLocations) {
        if (device.lastKnownLatitude != null && device.lastKnownLongitude != null) {
          final position = LatLng(device.lastKnownLatitude!, device.lastKnownLongitude!);
          final markerId = MarkerId('device_${device.deviceId}');

          // Device markers are typically blue or green
          Color deviceColor = device.status == 'active' ? Colors.blue : Colors.grey;
          double deviceHue = device.status == 'active' ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueAzure;

          _markers.add(
            Marker(
              markerId: markerId,
              position: position,
              infoWindow: InfoWindow(
                title: device.name,
                snippet: 'ID: ${device.deviceId}, Status: ${device.status}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(deviceHue),
            ),
          );

          _circles.add(
            Circle(
              circleId: CircleId('device_circle_${device.deviceId}'),
              center: position,
              radius: 50, // Smaller radius for devices
              fillColor: deviceColor.withOpacity(0.2),
              strokeColor: deviceColor,
              strokeWidth: 1,
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {}); // Rebuild the map with updated markers and circles
    }
  }

  /// Moves the camera to an initial position or centers on markers if available.
  void _moveCameraToInitialPosition() {
    if (_mapController == null) return;

    if (widget.initialCameraPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(widget.initialCameraPosition!, 12.0),
      );
    } else if (_markers.isNotEmpty) {
      // If no initial position, try to center on all markers
      final bounds = _getLatLngBounds(_markers.map((m) => m.position).toList());
      if (bounds != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50.0), // Padding
        );
      }
    } else {
      // Default to Kampala, Uganda if no markers or initial position
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(const LatLng(0.3476, 32.5825), 10.0),
      );
    }
  }

  /// Calculates the LatLngBounds for a list of LatLng points.
  LatLngBounds? _getLatLngBounds(List<LatLng> points) {
    if (points.isEmpty) return null;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialCameraPosition ?? const LatLng(0.3476, 32.5825), // Default to Kampala
        zoom: 13.0,
      ),
      onMapCreated: _onMapCreated,
      markers: _markers,
      circles: _circles,
      mapType: MapType.normal,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
    );
  }
}

/// Helper extension to get [MapPingNotifier] from context using [Provider].
extension MapPingNotifierExtension on BuildContext {
  MapPingNotifier? get mapPingNotifier {
    try {
      return Provider.of<MapPingNotifier>(this, listen: false);
    } catch (e) {
      // Handle case where provider is not found in the widget tree
      return null;
    }
  }
}
