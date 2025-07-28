import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart'; // For @required

/// Represents a crash event detected by the embedded device.
/// This model mirrors the JSON structure uploaded by the device to Firebase Realtime Database.
class CrashData {
  final String deviceId; // Added deviceId to the model
  final double latitude;
  final double longitude;
  final int severity;
  final double speedKmph;
  final String crashType;
  final DateTime timestamp; // Added to track when the crash occurred

  CrashData({
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.severity,
    required this.speedKmph,
    required this.crashType,
    required this.timestamp,
  });

  /// Factory constructor to create a CrashData object from a Firebase Realtime Database snapshot value.
  /// The snapshot value is expected to be a Map<String, dynamic> representing a single crash event.
  factory CrashData.fromMap(Map<dynamic, dynamic> map, String deviceId) {
    return CrashData(
      deviceId: deviceId, // Pass deviceId from the parent node
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      severity: (map['severity'] as num).toInt(),
      speedKmph: (map['speed_kmph'] as num).toDouble(),
      crashType: map['crash_type'] as String,
      // Use the timestamp field from within the data, falling back to current time if missing
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
    );
  }

  /// Converts this CrashData object into a map, suitable for Firebase.
  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'latitude': latitude,
      'longitude': longitude,
      'severity': severity,
      'speed_kmph': speedKmph,
      'crash_type': crashType,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'CrashData(deviceId: $deviceId, latitude: $latitude, longitude: $longitude, severity: $severity, speedKmph: $speedKmph, crashType: $crashType, timestamp: $timestamp)';
  }
}

/// A service class to interact with the Firebase Realtime Database for crash data.
/// It now expects data structured under deviceId nodes.
class CrashAlgorithmService {
  final DatabaseReference _rootRef = FirebaseDatabase.instance.ref();

  /// Listens for new crash events from the Realtime Database across all devices.
  /// Returns a stream of lists of CrashData objects.
  Stream<List<CrashData>> getCrashStream() {
    // Listen to the root, then process all device children
    return _rootRef.onValue.map((event) {
      final List<CrashData> crashes = [];
      final data = event.snapshot.value;

      if (data != null && data is Map) {
        // Iterate through each device ID (e.g., "0766192699")
        data.forEach((deviceIdKey, deviceCrashesData) {
          if (deviceCrashesData is Map) {
            // Iterate through each crash event under the device ID
            deviceCrashesData.forEach((crashTimestampKey, crashDetails) {
              try {
                if (crashDetails is Map<dynamic, dynamic>) {
                  // Pass the deviceIdKey to the fromMap constructor
                  crashes.add(CrashData.fromMap(crashDetails, deviceIdKey.toString()));
                }
              } catch (e) {
                if (kDebugMode) {
                  print('Error parsing crash data for device $deviceIdKey, key $crashTimestampKey: $e, Data: $crashDetails');
                }
              }
            });
          }
        });
      }
      // Sort crashes by timestamp, newest first
      crashes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return crashes;
    });
  }

  /// Fetches all crash data (if any) from the Realtime Database for all devices.
  Future<List<CrashData>> getLatestCrashes() async {
    final snapshot = await _rootRef.get();
    final List<CrashData> crashes = [];
    final data = snapshot.value;

    if (data != null && data is Map) {
      data.forEach((deviceIdKey, deviceCrashesData) {
        if (deviceCrashesData is Map) {
          deviceCrashesData.forEach((crashTimestampKey, crashDetails) {
            try {
              if (crashDetails is Map<dynamic, dynamic>) {
                crashes.add(CrashData.fromMap(crashDetails, deviceIdKey.toString()));
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error parsing crash data for device $deviceIdKey, key $crashTimestampKey: $e, Data: $crashDetails');
              }
            }
          });
        }
      });
    }
    crashes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return crashes;
  }

// You might add methods here to acknowledge a crash, mark it as resolved, etc.
// These would typically involve updating data in the Realtime Database or Firestore.
}
