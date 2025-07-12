// thing_speak_analyzer.dart
//
// Usage:
//   dart pub add http
//   dart run thing_speak_analyzer.dart
//
// NOTE:
//   • Tune CRASH_G_THRESHOLD, RESULTS_LIMIT, or any other constant as you wish.

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

const String readKey = 'RI4Q6J38OQU6LEXA';
const int resultsLimit = 8000; // how many recent entries to pull
const double g = 9.80665; // 1 g in m s‑2
const double crashGThreshold = 3.0; // ≥ 3 g ⇒ suspected crash
const double severeGThreshold = 5.0; // ≥ 5 g ⇒ severe crash

Future<void> main() async {
  final int channelId = 3001035; // Use fixed channel ID

  final List<Map<String, dynamic>> feeds = await _fetchFeeds(
    channelId,
    readKey,
    resultsLimit,
  );

  // Determine the script's directory
  final scriptDir = File(Platform.script.toFilePath()).parent;

  // Construct the path to the assets directory
  final assetsDir = Directory(
    '${scriptDir.path}${Platform.pathSeparator}assets',
  );

  // Check if the assets directory exists, and create it if not
  if (!await assetsDir.exists()) {
    await assetsDir.create(recursive: true); // `recursive: true` ensures all parent directories are created
    print('Created assets directory: ${assetsDir.path}');
  }

  // ---------- RAW JSON ----------
  final rawJson = jsonEncode({'rawData': feeds});
  // Write raw JSON to file
  final rawJsonFile = File(
    '${assetsDir.path}${Platform.pathSeparator}raw_output.json', // Use assetsDir.path here
  );
  await rawJsonFile.writeAsString(rawJson);
  print('Raw JSON written to: ${rawJsonFile.path}'); // Removed leading backslash, it's not needed and can look odd

  // ---------- ANALYSIS ----------
  final analysisJson = jsonEncode(_analyze(feeds));
  // Write analysis JSON to file
  final analysisJsonFile = File(
    '${assetsDir.path}${Platform.pathSeparator}analysis_output.json', // Use assetsDir.path here
  );
  await analysisJsonFile.writeAsString(analysisJson);
  print('Analysis JSON written to: ${analysisJsonFile.path}'); // Removed leading backslash
}

/* ────────────────────────────────────────────────────────────── */
/* STEP 2: pull feeds                                          */
Future<List<Map<String, dynamic>>> _fetchFeeds(
    int channelId,
    String apiKey,
    int results,
) async {
  final uri = Uri.parse(
    'https://api.thingspeak.com/channels/$channelId/feeds.json'
    '?api_key=$apiKey&results=$results',
  );
  final resp = await http.get(uri);
  if (resp.statusCode != 200) {
    stderr.writeln('❌  ThingSpeak returned HTTP ${resp.statusCode}');
    exit(2);
  }
  final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
  final feeds = decoded['feeds'] as List<dynamic>;
  return feeds.cast<Map<String, dynamic>>();
}

/* ────────────────────────────────────────────────────────────── */
/* STEP 3: crunch numbers                                      */
Map<String, dynamic> _analyze(List<Map<String, dynamic>> feeds) {
  if (feeds.isEmpty) {
    print('⚠️ Warning: Feed data is empty. Nothing to analyze.');
    return {'analysis': 'No data'};
  }

  double sumLat = 0, sumLon = 0;
  double sumAx = 0, sumAy = 0, sumAz = 0, sumMag = 0;
  int count = 0;

  final List<Map<String, dynamic>> overtime = [];
  final List<Map<String, dynamic>> crashes = [];

  for (final f in feeds) {
    // Parse numbers; skip entries with missing data
    final double? lat = _toDouble(f['latitude']);
    final double? lon = _toDouble(f['longitude']);
    final double? ax = _toDouble(f['acc_x']);
    final double? ay = _toDouble(f['acc_y']);
    final double? az = _toDouble(f['acc_z']);
    final String ts = f['created_at'] as String;

    if ([lat, lon, ax, ay, az].contains(null)) continue;

    final double mag = _magnitude(ax!, ay!, az!);

    // stats
    sumLat += lat!;
    sumLon += lon!;
    sumAx += ax;
    sumAy += ay;
    sumAz += az;
    sumMag += mag;
    count += 1;

    // time‑series
    overtime.add({'t': ts, 'accMag': mag});

    // crash detection
    final double gVal = mag / g;
    if (gVal >= crashGThreshold) {
      crashes.add({
        't': ts,
        'accMag': mag,
        'g': gVal,
        'severity': gVal >= severeGThreshold ? 'severe' : 'moderate',
      });
    }
  }

  // summary averages
  double safeDivide(double sum, int count) => count == 0 ? 0.0 : sum / count;

  final summary = {
    'totalPoints': count,
    'avgLat': safeDivide(sumLat, count),
    'avgLon': safeDivide(sumLon, count),
    'avgAccX': safeDivide(sumAx, count),
    'avgAccY': safeDivide(sumAy, count),
    'avgAccZ': safeDivide(sumAz, count),
    'avgAccMagnitude': safeDivide(sumMag, count),
    'suspectedCrashes': crashes.length,
  };

  return {
    'analysis': {'summary': summary, 'overtime': overtime, 'crashes': crashes},
  };
}

/* ────────────────────────────────────────────────────────────── */
double? _toDouble(Object? o) =>
    o == null ? null : double.tryParse(o.toString());

double _magnitude(double x, double y, double z) =>
    (x * x + y * y + z * z).sqrt();

/* Dart has no .sqrt() on double literals before 2.19; add one */


extension on double {
  double sqrt() => math.sqrt(this);
}