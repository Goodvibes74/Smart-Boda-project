// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

/// Represents the live telemetry data for a device.
/// This includes its current location, speed, battery, and crash status.
class DeviceTelemetry {
  final String deviceId; // The unique ID of the device (e.g., SIM number)
  final double latitude;
  final double longitude;
  final double speedKmph; // Renamed for consistency with embedded system
  final int batteryPercentage; // Renamed for clarity
  final bool crashDetected;
  final DateTime lastUpdated; // Timestamp of the last update

  DeviceTelemetry({
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.speedKmph,
    required this.batteryPercentage,
    required this.crashDetected,
    required this.lastUpdated,
  });

  /// Factory constructor to create a DeviceTelemetry object from a Firestore DocumentSnapshot.
  factory DeviceTelemetry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeviceTelemetry(
      deviceId: doc.id, // The document ID is the deviceId
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      speedKmph: (data['speedKmph'] as num?)?.toDouble() ?? 0.0,
      batteryPercentage: (data['batteryPercentage'] as num?)?.toInt() ?? 0,
      crashDetected: data['crashDetected'] as bool? ?? false,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this DeviceTelemetry object into a map, suitable for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'speedKmph': speedKmph,
      'batteryPercentage': batteryPercentage,
      'crashDetected': crashDetected,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  @override
  String toString() {
    return 'DeviceTelemetry(deviceId: $deviceId, lat: $latitude, lng: $longitude, speed: $speedKmph, battery: $batteryPercentage, crashDetected: $crashDetected, lastUpdated: $lastUpdated)';
  }
}

/// A service class to interact with a Firestore collection for live device telemetry data.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection reference for live device telemetry.
  // This data is typically stored per device ID.
  // Path: /artifacts/{appId}/live_device_telemetry/{deviceId}
  CollectionReference<DeviceTelemetry> _telemetryCollection() {
    // __app_id is provided by the Canvas environment.
    const String appId = String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

    return _db
        .collection('artifacts')
        .doc(appId)
        .collection('live_device_telemetry')
        .withConverter<DeviceTelemetry>(
          fromFirestore: (snapshot, _) => DeviceTelemetry.fromFirestore(snapshot),
          toFirestore: (telemetry, _) => telemetry.toFirestore(),
        );
  }

  /// Streams all live device telemetry data.
  /// This will return a list of all devices' latest telemetry.
  Stream<List<DeviceTelemetry>> getAllDeviceTelemetryStream() {
    return _telemetryCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Streams the live telemetry data for a specific device.
  Stream<DeviceTelemetry?> getDeviceTelemetryStream(String deviceId) {
    return _telemetryCollection().doc(deviceId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  /// Sets or updates the live telemetry data for a specific device.
  /// The `deviceId` in the `telemetry` object will be used as the document ID.
  Future<void> setDeviceTelemetry(DeviceTelemetry telemetry) async {
    try {
      await _telemetryCollection().doc(telemetry.deviceId).set(telemetry);
      if (kDebugMode) {
        print('Device telemetry for ${telemetry.deviceId} updated successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting device telemetry for ${telemetry.deviceId}: $e');
      }
      rethrow;
    }
  }

  // You might add other methods here, e.g., to delete old telemetry data,
  // or to query telemetry for a specific time range (if you store historical telemetry).
}
