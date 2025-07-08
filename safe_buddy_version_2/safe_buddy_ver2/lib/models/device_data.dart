class DeviceData {
  final List<double> accelX, accelY, accelZ;
  final List<double> gyroX, gyroY, gyroZ;
  final List<double> battery;
  final List<double> speed;
  final List<bool> impactDetected;
  final double latitude, longitude;

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
      accelX: List.generate(10, (i) => (5 * i).toDouble()),
      accelY: List.generate(10, (i) => (3 * i).toDouble()),
      accelZ: List.generate(10, (i) => (2 * i).toDouble()),
      gyroX: List.generate(10, (i) => (1.5 * i).toDouble()),
      gyroY: List.generate(10, (i) => (2.5 * i).toDouble()),
      gyroZ: List.generate(10, (i) => (3.5 * i).toDouble()),
      battery: List.generate(10, (i) => 100 - (i * 3)),
      speed: List.generate(10, (i) => 10 + i * 2),
      impactDetected: List.generate(10, (i) => i == 7),
      latitude: 0.3476,
      longitude: 32.5825,
    );
  }
}

