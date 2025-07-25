import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, List<dynamic>>> getAllFormattedData(Map raw) async {
  const String firebaseURL = 'https://safe-buddy-141a4-default-rtdb.firebaseio.com/.json';
  final response = await http.get(Uri.parse(firebaseURL));
  if (response.statusCode == 200) {
    final rawData = jsonDecode(response.body) as Map<String, dynamic>;
    final Map<String, List<dynamic>> formattedCrashes = {};
    rawData.forEach((timestamp, details) {
      final crashDetails = details as Map<String, dynamic>;
      final dataList = [
        crashDetails['sim_number'] ?? '',
        crashDetails['latitude'] ?? 0.0,
        crashDetails['longitude'] ?? 0.0,
        crashDetails['severity'] ?? '',
        crashDetails['speed_kmph'] ?? 0,
        crashDetails['crash_type'] ?? '',
      ];
      formattedCrashes[timestamp] = dataList;
    });
    return formattedCrashes;
  } else {
    throw Exception('Failed to load crash data');
  }
}