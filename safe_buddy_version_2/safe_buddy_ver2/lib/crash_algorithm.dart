// lib/crash_algorithm.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart'; // For @required

/// Represents a crash event detected by the embedded device.
/// This model mirrors the JSON structure uploaded by the device to Firebase Realtime Database.
class CrashData {
  final double latitude;
  final double longitude;
  final int severity;
  final double speedKmph;
  final String crashType;
  final DateTime timestamp; // Added to track when the crash occurred

  CrashData({
    required this.latitude,
    required this.longitude,
    required this.severity,
    required this.speedKmph,
    required this.crashType,
    required this.timestamp,
  });

  /// Factory constructor to create a CrashData object from a Firebase Realtime Database snapshot.
  /// The snapshot value is expected to be a Map<String, dynamic>.
  factory CrashData.fromMap(Map<dynamic, dynamic> map) {
    return CrashData(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      severity: (map['severity'] as num).toInt(),
      speedKmph: (map['speed_kmph'] as num).toDouble(),
      crashType: map['crash_type'] as String,
      // Realtime Database often uses server timestamps or client timestamps.
      // If the device doesn't send a timestamp, Firebase will add a server timestamp
      // when you push data. For now, we'll use DateTime.now() as a fallback
      // or assume the device sends a timestamp field (e.g., 'timestamp').
      // If the device sends a timestamp, you'd parse it here.
      // For simplicity, we'll use the child key as a rough timestamp if available,
      // or assume the Realtime Database push key can be converted to a timestamp.
      // A more robust solution would be for the device to send a Unix timestamp.
      // For now, let's assume the device *should* send a 'timestamp' field.
      // If it doesn't, you'll need to adjust how you get the timestamp.
      // For this example, we'll use a placeholder or assume a `timestamp` field exists.
      // Let's assume Firebase push ID can be used, or a field named 'timestamp' is present.
      // If the device doesn't send it, you might rely on Firebase's server timestamp
      // or the push key's time component.
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(), // Fallback if no timestamp from device
    );
  }

  /// Converts this CrashData object into a map, suitable for Firebase.
  Map<String, dynamic> toMap() {
    return {
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
    return 'CrashData(latitude: $latitude, longitude: $longitude, severity: $severity, speedKmph: $speedKmph, crashType: $crashType, timestamp: $timestamp)';
  }
}

/// A service class to interact with the Firebase Realtime Database for crash data.
class CrashAlgorithmService {
  final DatabaseReference _crashDataRef =
      FirebaseDatabase.instance.ref().child('crashData');

  /// Listens for new crash events from the Realtime Database.
  /// Returns a stream of CrashData objects.
  Stream<List<CrashData>> getCrashStream() {
    return _crashDataRef.onValue.map((event) {
      final List<CrashData> crashes = [];
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        data.forEach((key, value) {
          try {
            // Each child under 'crashData' is a separate crash event.
            // The embedded system uses POST, so Firebase generates unique keys.
            // We can use the key to derive a timestamp if the device doesn't send one.
            // For now, let's assume the device sends a 'timestamp' field.
            // If not, you might need to parse the push key or use Firebase server timestamps.
            if (value is Map<dynamic, dynamic>) {
              // Add the Firebase push key's timestamp component if available and not sent by device
              // Or, if the device sends a timestamp, use that.
              // For now, assuming the device sends a 'timestamp' field.
              // If the device does not send a timestamp, you might need to add it on the server side
              // or use Firebase's `ServerValue.timestamp` when pushing from the device.
              // For this example, we'll add a timestamp to the map if it's missing,
              // using the Firebase push key's time component (though not perfectly accurate).
              // A better approach is for the device to send a timestamp.
              if (!value.containsKey('timestamp')) {
                 // Attempt to derive timestamp from Firebase push key (less reliable)
                 // Firebase push keys are lexicographically ordered and contain time info.
                 // This is a rough estimation. Best to send timestamp from device.
                 // For now, let's just use DateTime.now() if not provided by device.
                 value['timestamp'] = DateTime.now().millisecondsSinceEpoch;
              }
              crashes.add(CrashData.fromMap(value));
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing crash data: $e, Data: $value');
            }
          }
        });
      }
      // Sort crashes by timestamp, newest first
      crashes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return crashes;
    });
  }

  /// Fetches the latest crash data (if any) from the Realtime Database.
  Future<List<CrashData>> getLatestCrashes() async {
    final snapshot = await _crashDataRef.get();
    final List<CrashData> crashes = [];
    final data = snapshot.value;
    if (data != null && data is Map) {
      data.forEach((key, value) {
        try {
          if (value is Map<dynamic, dynamic>) {
            if (!value.containsKey('timestamp')) {
               value['timestamp'] = DateTime.now().millisecondsSinceEpoch;
            }
            crashes.add(CrashData.fromMap(value));
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing crash data: $e, Data: $value');
          }
        }
      });
    }
    crashes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return crashes;
  }

  // You might add methods here to acknowledge a crash, mark it as resolved, etc.
  // These would typically involve updating data in the Realtime Database or Firestore.
}
