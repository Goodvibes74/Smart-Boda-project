import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<DeviceData>> getDeviceDataStream() {
    return _db.collection('devices').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DeviceData.fromFirestore(doc)).toList();
    });
  }
}

class DeviceData {
  final String deviceId;
  final double lat;
  final double lng;
  final double speed;
  final int battery;
  final bool crashDetected;

  DeviceData({
    required this.deviceId,
    required this.lat,
    required this.lng,
    required this.speed,
    required this.battery,
    required this.crashDetected,
  });

  factory DeviceData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeviceData(
      deviceId: data['deviceId'],
      lat: data['lat'],
      lng: data['lng'],
      speed: (data['speed'] ?? 0).toDouble(),
      battery: data['battery'] ?? 0,
      crashDetected: data['crashDetected'] ?? false,
    );
  }
}
