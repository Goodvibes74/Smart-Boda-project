import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Firebase configuration constants (mirroring ESP32 sketch)
const String FIREBASE_HOST = "safe-buddy-141a4-default-rtdb.firebaseio.com";
const String FIREBASE_AUTH = "AIzaSyAkY6qkVOfuXhns81HwTICd41ts-LnBQ0Q";
const String FIREBASE_CRASH_PATH = "/crashData.json?auth="; // Path for crash data upload

/// Fetches crash data from Firebase Realtime Database.
/// Returns a map where keys are Firebase push IDs and values are maps of crash data.
Future<Map<String, Map<String, dynamic>?>> getData() async {
  Map<String, Map<String, dynamic>?> parsedData = {};

  try {
    final uri = Uri.parse(
      'https://$FIREBASE_HOST$FIREBASE_CRASH_PATH$FIREBASE_AUTH',
    );

    final resp = await http.get(uri);
    
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) {
        // Firebase Realtime DB returns a map of unique IDs to data objects
        decoded.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            parsedData[key] = value;
          }
        });
      } else if (decoded == null) {
        print("Firebase returned null, no data available yet.");
      } else {
        print("Unexpected Firebase response format: ${decoded.runtimeType}");
      }
    } else {
      print("Failed to fetch data from Firebase. Status code: ${resp.statusCode}");
      print("Response body: ${resp.body}");
    }

    print("Parsed ${parsedData.length} entries from Firebase.");
    return parsedData;
  } catch (e) {
    print('Error fetching or decoding Firebase data: $e');
    return {};
  }
}

/// Retrieves the severity string directly from the fetched Firebase data.
/// Assumes the severity is already calculated and present in the data.
String getSeverity(Map<dynamic, dynamic> values) {
  return values['severity']?.toString() ?? "Unknown";
}

/// Retrieves the speed (in km/h) directly from the fetched Firebase data.
/// Assumes the speed is already calculated and present in the data.
int getSpeed(Map<dynamic, dynamic> values) {
  // Firebase uploads speed_kmph as a double, convert to int for frontend consistency
  return (values['speed_kmph'] as num?)?.round() ?? 0;
}

/// Retrieves the crash type string directly from the fetched Firebase data.
/// Assumes the crash type is already determined and present in the data.
String getCrashDirection(Map<dynamic, dynamic> values) {
  return values['crash_type']?.toString() ?? "Unknown";
}

/// Processes all fetched Firebase crash data into a formatted structure
/// that includes latitude, longitude, severity, speed, and crash type.
/// It directly uses the values uploaded by the ESP32 sketch.
Map<String, List<dynamic>> getAllFormattedData(Map<dynamic, dynamic> data) {
  Map<String, List<dynamic>> formattedData = {};
  for (var timestampKey in data.keys) {
    var values = data[timestampKey];
    
    // Extract values directly from the Firebase data
    String simNumber = values['sim_number']?.toString() ?? "Unknown";
    double? lat = values['latitude'] as double?;
    double? lon = values['longitude'] as double?;
    String severity = getSeverity(values); // Uses the value from Firebase
    int speed = getSpeed(values);         // Uses the value from Firebase
    String type = getCrashDirection(values); // Uses the value from Firebase

    if (speed < 0) speed = 0; // Ensure speed is non-negative

    formattedData[timestampKey.toString()] = [
      simNumber,
      lat,
      lon,
      severity,
      speed,
      type,
    ];
  }
  print("Processed ${formattedData.length} entries into formatted data.");
  return formattedData;
}
