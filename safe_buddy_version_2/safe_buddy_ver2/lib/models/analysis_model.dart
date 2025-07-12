import 'dart:convert';
import 'dart:io';

Map<String, dynamic> analyzeData(String jsonString) {
  final Map<String, dynamic> jsonData = jsonDecode(File(jsonString).readAsStringSync());
  final AnalysisResult analysisResult = AnalysisResult.fromJson(jsonData);

  return {
    'summary': analysisResult.summary,
    'overtime': analysisResult.overtime,
    'crashes': analysisResult.crashes,
  };
}

class AnalysisResult {
  final Summary summary;
  final List<TimeSeriesPoint> overtime;
  final List<CrashEvent> crashes;

  AnalysisResult({
    required this.summary,
    required this.overtime,
    required this.crashes,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final analysis = json['analysis'];
    return AnalysisResult(
      summary: Summary.fromJson(analysis['summary']),
      overtime: (analysis['overtime'] as List)
          .map((e) => TimeSeriesPoint.fromJson(e))
          .toList(),
      crashes: (analysis['crashes'] as List)
          .map((e) => CrashEvent.fromJson(e))
          .toList(),
    );
  }
}

class Summary {
  final int totalPoints;
  final double avgLat, avgLon;
  final double avgAccX, avgAccY, avgAccZ, avgAccMagnitude;
  final int suspectedCrashes;

  Summary({
    required this.totalPoints,
    required this.avgLat,
    required this.avgLon,
    required this.avgAccX,
    required this.avgAccY,
    required this.avgAccZ,
    required this.avgAccMagnitude,
    required this.suspectedCrashes,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalPoints: json['totalPoints'],
      avgLat: json['avgLat'],
      avgLon: json['avgLon'],
      avgAccX: json['avgAccX'],
      avgAccY: json['avgAccY'],
      avgAccZ: json['avgAccZ'],
      avgAccMagnitude: json['avgAccMagnitude'],
      suspectedCrashes: json['suspectedCrashes'],
    );
  }
}

class TimeSeriesPoint {
  final DateTime t;
  final double accMag;

  TimeSeriesPoint({required this.t, required this.accMag});

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    return TimeSeriesPoint(
      t: DateTime.parse(json['t']),
      accMag: (json['accMag'] as num).toDouble(),
    );
  }
}

class CrashEvent {
  final DateTime t;
  final double accMag;
  final double g;
  final String severity;

  CrashEvent({
    required this.t,
    required this.accMag,
    required this.g,
    required this.severity,
  });

  factory CrashEvent.fromJson(Map<String, dynamic> json) {
    return CrashEvent(
      t: DateTime.parse(json['t']),
      accMag: (json['accMag'] as num).toDouble(),
      g: (json['g'] as num).toDouble(),
      severity: json['severity'],
    );
  }
}
