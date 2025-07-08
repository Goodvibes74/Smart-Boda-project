class DeviceData {
  final List<double> accelX, accelY, accelZ;
  final List<double> gyroX, gyroY, gyroZ;
  final List<double> battery;
  final List<double> speed;
  final List<bool> impactDetected;
  final double latitude;
  final double longitude;

  DeviceData({
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.battery,
    required this.speed,
    required this.impactDetected,
    required this.latitude,
    required this.longitude,
  });

  factory DeviceData.mock() {
    return DeviceData(
      accelX: List.generate(20, (i) => (i * 0.5) % 10),
      accelY: List.generate(20, (i) => (i * 0.4) % 10),
      accelZ: List.generate(20, (i) => (i * 0.3) % 10),
      gyroX: List.generate(20, (i) => (i * 0.2) % 5),
      gyroY: List.generate(20, (i) => (i * 0.1) % 5),
      gyroZ: List.generate(20, (i) => (i * 0.3) % 5),
      battery: List.generate(10, (i) => 70 - i * 2),
      speed: List.generate(10, (i) => 30 + i.toDouble()),
      impactDetected: List.generate(10, (i) => i == 5),
      latitude: 0.3476,
      longitude: 32.5825,
    );
  }
}

