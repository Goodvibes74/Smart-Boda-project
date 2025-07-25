import 'dart:convert';
import 'package:http/http.dart' as http;

// The URL for your Firebase Realtime Database. The .json suffix is required for the REST API.
const String firebaseURL = 'https://safe-buddy-141a4-default-rtdb.firebaseio.com/0766192699.json';

/// Fetches the raw data from the Firebase URL.
///
/// This function makes an HTTP GET request and returns the decoded JSON data as a Map.
Future<Map<String, dynamic>> getData() async {
  final uri = Uri.parse(firebaseURL);
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response, parse the JSON.
    // Firebase returns the string "null" for an empty database, so we handle that case.
    print('Firebase response: ${response.body}');
    if (response.body == 'null') {
      return {};
    }
    return json.decode(response.body) as Map<String, dynamic>;
  } else {
    // If the server did not return a 200 OK response, throw an exception.
    // This will be caught by the FutureBuilder in dashboard.dart.
    throw Exception('Failed to load crash data');
  }
}

/// Processes the raw, nested data from Firebase and formats it for the UI.
///
/// The raw data is structured by SIM number, then by timestamp. This function
/// flattens that structure into a single map where each key is a timestamp.
/// The value is a list of crash details in the order expected by `dashboard.dart`.
Map<String, List<dynamic>> getAllFormattedData(Map<dynamic, dynamic> rawData) {
  final Map<String, List<dynamic>> formattedCrashes = {};

  // Iterate over each SIM number entry in the raw data.
  rawData.forEach((simNumber, crashesForSim) {
    final crashesMap = crashesForSim as Map<String, dynamic>;

    // Iterate over each crash event (keyed by timestamp) for the current SIM.
    crashesMap.forEach((timestamp, details) {
      final crashDetails = details as Map<String, dynamic>;

      // Create a list with crash data in the specific order
      // that dashboard.dart's ListView.builder expects.
      final dataList = [
        crashDetails['sim_number'],      // index 0
        crashDetails['latitude'],        // index 1
        crashDetails['longitude'],       // index 2
        crashDetails['severity'],        // index 3
        crashDetails['speed_kmph'],      // index 4
        crashDetails['crash_type'],      // index 5
      ];
      
      // Add the formatted list to our final map, keyed by its unique timestamp.
      formattedCrashes[timestamp] = dataList;
    });
  });

  return formattedCrashes;
}