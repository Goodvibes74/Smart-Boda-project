// lib/device.dart
// Removed ignore_for_file: deprecated_member_use as modern practices are used

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore integration
import 'package:flutter/foundation.dart'; // For @required

/// Represents a registered device in the system.
/// This model is primarily used for device management in Firestore.
/// It includes fields for device metadata and last known status/location.
class Device {
  final String deviceId; // Unique ID for the device (e.g., SIM number from embedded system)
  final String name;
  final String description;
  final String ownerId; // The Firebase User ID of the user who registered the device
  final String status; // e.g., 'active', 'inactive', 'offline'
  final double? lastKnownLatitude; // Last reported location from the device
  final double? lastKnownLongitude;
  final DateTime registrationDate;
  final DateTime? lastActive; // Last time the device reported any data

  Device({
    required this.deviceId,
    required this.name,
    this.description = '',
    required this.ownerId,
    this.status = 'active',
    this.lastKnownLatitude,
    this.lastKnownLongitude,
    required this.registrationDate,
    this.lastActive,
  });

  /// Factory constructor to create a Device object from a Firestore DocumentSnapshot.
  factory Device.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Device(
      deviceId: doc.id, // Use the document ID as the deviceId
      name: data['name'] as String,
      description: data['description'] as String? ?? '',
      ownerId: data['ownerId'] as String,
      status: data['status'] as String? ?? 'active',
      lastKnownLatitude: (data['lastKnownLatitude'] as num?)?.toDouble(),
      lastKnownLongitude: (data['lastKnownLongitude'] as num?)?.toDouble(),
      registrationDate: (data['registrationDate'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts this Device object into a map, suitable for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'status': status,
      'lastKnownLatitude': lastKnownLatitude,
      'lastKnownLongitude': lastKnownLongitude,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
    };
  }

  @override
  String toString() {
    return 'Device(deviceId: $deviceId, name: $name, ownerId: $ownerId, status: $status)';
  }
}

/// A service class to manage device registration and data in Firestore.
class DeviceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for devices.
  // Devices will be stored under /artifacts/{appId}/users/{userId}/devices
  // This ensures devices are private to the user who registered them.
  CollectionReference<Device> _devicesCollection(String userId) {
    // __app_id is provided by the Canvas environment.
    // Use a fallback for local development if __app_id is not defined.
    const String appId = String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

    return _firestore
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('devices')
        .withConverter<Device>(
          fromFirestore: (snapshot, _) => Device.fromFirestore(snapshot),
          toFirestore: (device, _) => device.toFirestore(),
        );
  }

  /// Registers a new device in Firestore.
  /// The deviceId will be used as the document ID.
  Future<void> registerDevice(String userId, Device device) async {
    try {
      await _devicesCollection(userId).doc(device.deviceId).set(device);
      if (kDebugMode) {
        print('Device ${device.deviceId} registered successfully for user $userId.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering device: $e');
      }
      rethrow;
    }
  }

  /// Fetches a single device by its ID for a specific user.
  Future<Device?> getDevice(String userId, String deviceId) async {
    try {
      final doc = await _devicesCollection(userId).doc(deviceId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device $deviceId: $e');
      }
      return null;
    }
  }

  /// Streams all registered devices for a specific user.
  Stream<List<Device>> getDevicesStream(String userId) {
    return _devicesCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Updates an existing device's information.
  Future<void> updateDevice(String userId, Device device) async {
    try {
      await _devicesCollection(userId).doc(device.deviceId).update(device.toFirestore());
      if (kDebugMode) {
        print('Device ${device.deviceId} updated successfully for user $userId.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating device: $e');
      }
      rethrow;
    }
  }

  /// Deletes a device from Firestore.
  Future<void> deleteDevice(String userId, String deviceId) async {
    try {
      await _devicesCollection(userId).doc(deviceId).delete();
      if (kDebugMode) {
        print('Device $deviceId deleted successfully for user $userId.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting device: $e');
      }
      rethrow;
    }
  }
}

// The DeviceCard widget from the user's original file, adapted to use the Device model.
class DeviceCard extends StatelessWidget {
  final Device device; // Now takes a Device object directly
  // Removed location and isOnline as they are properties of the Device object

  const DeviceCard({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Determine status color based on device.status
    Color statusColor = Colors.grey;
    String statusText = 'Unknown';
    if (device.status == 'active') {
      statusColor = Colors.greenAccent;
      statusText = 'Online';
    } else if (device.status == 'offline') {
      statusColor = Colors.redAccent;
      statusText = 'Offline';
    } else {
      // For 'inactive' or other statuses, you might have a different color
      statusColor = Colors.orangeAccent;
      statusText = device.status; // Display the actual status
    }

    // Format location if available
    String locationText = 'Location: N/A';
    if (device.lastKnownLatitude != null && device.lastKnownLongitude != null) {
      locationText = 'Location: ${device.lastKnownLatitude!.toStringAsFixed(4)}, ${device.lastKnownLongitude!.toStringAsFixed(4)}';
    }

    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device ID: ${device.deviceId}', // Use device.deviceId
            style: text.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            device.name, // Display device name
            style: text.bodyLarge?.copyWith(
              color: cs.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            locationText, // Use formatted location
            style: text.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: statusColor,
              ),
              const SizedBox(width: 4),
              Text(
                statusText, // Use derived status text
                style: text.bodySmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
