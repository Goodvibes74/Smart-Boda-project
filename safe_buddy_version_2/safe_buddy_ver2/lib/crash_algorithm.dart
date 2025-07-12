import 'dart:math' as math;
import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; // Only works in Dart CLI, not Flutter

Future<Map<String, Map<String, double?>>> getData() async {
  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, Map<String, double?>> parsedData = {};

  try {
    final int channelId = 3001035;
    const String apiKey = 'RI4Q6J38OQU6LEXA';
    const int results = 500;

    final uri = Uri.parse(
      'https://api.thingspeak.com/channels/$channelId/feeds.json'
      '?api_key=$apiKey&results=$results',
    );

    final resp = await http.get(uri);
    List<dynamic> feeds = [];

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      feeds = decoded['feeds'] as List<dynamic>;
    } else {
      final file = File('raw_input.json'); // Local fallback file
      print("Failed to fetch data from API, trying local file.");
      if (await file.exists()) {
        final contents = await file.readAsString();
        final decoded = jsonDecode(contents) as Map<String, dynamic>;
        feeds = decoded['feeds'] as List<dynamic>;
      }
    }

    for (var item in feeds) {
      double? lat = _toDouble(item['field1']);
      double? lon = _toDouble(item['field2']);
      double? ax = _toDouble(item['field3']);
      double? ay = _toDouble(item['field4']);
      double? az = _toDouble(item['field5']);
      double? gx = _toDouble(item['field6']);
      double? gy = _toDouble(item['field7']);
      double? gz = _toDouble(item['field8']);
      String? timestamp = item['created_at'];

      if (timestamp != null) {
        parsedData[timestamp] = {
          'lat': lat,
          'lon': lon,
          'ax': ax,
          'ay': ay,
          'az': az,
          'gx': gx,
          'gy': gy,
          'gz': gz,
        };
      }
    }

    print("Parsed ${parsedData.length} entries.");
    return parsedData;
  } catch (e) {
    print('Error decoding JSON: $e');
    return {};
  }
}

bool isCrash(Map<dynamic, dynamic> data) {
  double g = 9.81;
  double crashGThreshold = 1.215; // Lowered for debugging
  double crashAThreshold = 0.45;  // Lowered for debugging

  double _magnitude(double ax, double ay, double az) {
    return math.sqrt(ax * ax + ay * ay + az * az);
  }

  double _angularVelocity(double gx, double gy, double gz) {
    return math.sqrt(gx * gx + gy * gy + gz * gz);
  }

  double ax = data['ax'] ?? 0.0;
  double ay = data['ay'] ?? 0.0;
  double az = data['az'] ?? 0.0;
  double magnitude = _magnitude(ax, ay, az);
  double angularVelocity = _angularVelocity(
    data['gx'] ?? 0.0,
    data['gy'] ?? 0.0,
    data['gz'] ?? 0.0,
  );
  double gForce = magnitude / g;
  double currentSpeed = getSpeed(data).toDouble();

  print("Speed: $currentSpeed, G-Force: ${gForce.toStringAsFixed(2)}, Angular: ${angularVelocity.toStringAsFixed(2)}");

  if (currentSpeed > 10) {
    return gForce > crashGThreshold || angularVelocity > crashAThreshold;
  } else {
    return false;
  }
}

Map<String, List<dynamic>> getCrashes(Map<dynamic, dynamic> data) {
  Map<String, List<dynamic>> crashes = {};
  for (var timestamp in data.keys) {
    var values = data[timestamp];
    if (isCrash(values)) {
      var severity = getSeverity(values);
      var speed = getSpeed(values);
      var type = getCrashDirection(values);
      if (speed < 0) speed = 0;
      crashes[timestamp] = [
        values['lat'],
        values['lon'],
        severity,
        speed,
        type,
      ];
    }
  }
  print("Detected ${crashes.length} crashes.");
  return crashes;
}

String getSeverity(Map<dynamic, dynamic> values) {
  double ax = values['ax'] ?? 0.0;
  double ay = values['ay'] ?? 0.0;
  double az = values['az'] ?? 0.0;

  double magnitude = math.sqrt(ax * ax + ay * ay + az * az);
  if (magnitude < 2.0) return "Minor";
  if (magnitude < 4.0) return "Moderate";
  if (magnitude < 6.0) return "Severe";
  return "Critical";
}

int getSpeed(Map<dynamic, dynamic> values) {
  double ax = values['ax'] ?? 0.0;
  double ay = values['ay'] ?? 0.0;
  double az = values['az'] ?? 0.0;

  double speed = math.sqrt(ax * ax + ay * ay + az * az);
  return speed.round(); // Convert m/s to km/h
}

String getCrashDirection(Map<dynamic, dynamic> values) {
  double ax = values['ax'] ?? 0.0;
  double ay = values['ay'] ?? 0.0;

  if (ax.abs() > ay.abs()) {
    return ax > 0 ? 'Right' : 'Left';
  } else {
    return ay > 0 ? 'Forward' : 'Backward';
  }
}

void main() async {

}
