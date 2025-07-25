// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:safe_buddy_ver2/crash_algorithm.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:convert'; // Added for jsonEncode

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  
  void _exportCrashes(
    BuildContext context,
    List<Map<String, dynamic>> crashList, {
    required bool asCsv,
  }) {
    if (asCsv) {
      // CSV header - ensure these match the keys used in the map below
      final headers = ['timestamp', 'sim_number', 'latitude', 'longitude', 'severity', 'speed_kmph', 'crash_type'];
      final csv = StringBuffer();
      csv.writeln(headers.join(','));
      for (final row in crashList) {
        csv.writeln(headers.map((h) => row[h]?.toString() ?? '').join(','));
      }
      _showExportDialog(context, csv.toString(), 'CSV');
    } else {
      // Convert the list of maps to a JSON string
      final jsonStr = jsonEncode(crashList); // Use jsonEncode for proper JSON formatting
      _showExportDialog(context, jsonStr, 'JSON');
    }
  }

  void _showExportDialog(BuildContext context, String data, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Exported $type'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(child: SelectableText(data)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  late Future<Map> _rawFuture;
  late Future<Map<String, List<dynamic>>> _crashesFuture;

  @override
  void initState() {
    super.initState();
    _rawFuture = getData(); // From crash_algorithm.dart
    _crashesFuture = _rawFuture.then((raw) => getAllFormattedData(raw)); // From crash_algorithm.dart
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crash Analytics'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      backgroundColor: cs.background,
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: _crashesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error loading analytics: ${snapshot.error}'); // Added for debugging
            return const Center(child: Text('Error loading analytics'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No crash data found'));
          }
          final crashMap = snapshot.data!;
          return _buildAnalytics(context, crashMap, cs, text);
        },
      ),
    );
  }

  Widget _buildAnalytics(
    BuildContext context,
    Map<String, List<dynamic>> crashMap,
    ColorScheme cs,
    TextTheme text,
  ) {
    // Prepare data
    // The List<dynamic> from getAllFormattedData is:
    // [simNumber, lat, lon, severity, speed, type]
    final crashList = crashMap.entries
        .map(
          (e) => {
            'timestamp': e.key,
            'sim_number': e.value[0], // Corrected index
            'latitude': e.value[1],   // Corrected index
            'longitude': e.value[2],  // Corrected index
            'severity': e.value[3],
            'speed_kmph': e.value[4], // Corrected key and index
            'crash_type': e.value[5], // Corrected key and index
          },
        )
        .toList();

    // Crash type counts
    final typeCounts = <String, int>{};
    for (var crash in crashList) {
      final type = crash['crash_type']?.toString() ?? 'Unknown'; // Use 'crash_type' key
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }
    // Accidents by hour
    final hourCounts = List<int>.filled(24, 0);
    for (var crash in crashList) {
      final dt = DateTime.tryParse(crash['timestamp'] ?? '') ?? DateTime(2000);
      hourCounts[dt.hour]++;
    }
    // Accidents by day of week
    final dayCounts = List<int>.filled(7, 0);
    for (var crash in crashList) {
      final dt = DateTime.tryParse(crash['timestamp'] ?? '') ?? DateTime(2000);
      dayCounts[dt.weekday % 7]++;
    }
    // Average interval
    final timestamps =
        crashList
            .map(
              (c) => DateTime.tryParse(c['timestamp'] ?? '') ?? DateTime(2000),
            )
            .toList()
          ..sort();
    final intervals = <Duration>[];
    for (int i = 1; i < timestamps.length; i++) {
      intervals.add(timestamps[i].difference(timestamps[i - 1]));
    }
    final avgInterval = intervals.isNotEmpty
        ? intervals.map((d) => d.inMinutes).reduce((a, b) => a + b) /
              intervals.length
        : 0;
    // Average speed
    final speeds = crashList
        .map(
          (c) => (c['speed_kmph'] is num) // Use 'speed_kmph' key
              ? c['speed_kmph']
              : int.tryParse(c['speed_kmph']?.toString() ?? '0') ?? 0,
        )
        .toList();
    final avgSpeed = speeds.isNotEmpty
        ? speeds.reduce((a, b) => a + b) / speeds.length
        : 0;
    // Locations with highest speeds
    final topSpeedCrashes = List.of(crashList)
      ..sort((a, b) => (b['speed_kmph'] as num).compareTo(a['speed_kmph'] as num)); // Use 'speed_kmph' key
    final topLocations = topSpeedCrashes.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Export as CSV'),
                onPressed: () =>
                    _exportCrashes(context, crashList, asCsv: true),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.file_copy),
                label: const Text('Export as JSON'),
                onPressed: () =>
                    _exportCrashes(context, crashList, asCsv: false),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _AnimatedCounter(
            label: 'Total Accidents',
            value: crashList.length,
            color: cs.primary,
          ),
          const SizedBox(height: 16),
          _AnimatedCounter(
            label: 'Average Speed (km/h)',
            value: avgSpeed.round(),
            color: cs.secondary,
          ),
          const SizedBox(height: 16),
          _AnimatedCounter(
            label: 'Avg. Accident Interval (min)',
            value: avgInterval.round(),
            color: cs.tertiary,
          ),
          const SizedBox(height: 32),
          Text('Accidents by Type', style: text.titleMedium),
          const SizedBox(height: 8),
          _BarChart(typeCounts, cs),
          const SizedBox(height: 32),
          Text('Accidents by Hour of Day', style: text.titleMedium),
          const SizedBox(height: 8),
          _LineChart(
            hourCounts,
            labelBuilder: (i) => i.toString(),
            color: cs.primary,
          ),
          const SizedBox(height: 32),
          Text('Accidents by Day of Week', style: text.titleMedium),
          const SizedBox(height: 8),
          _LineChart(
            dayCounts,
            labelBuilder: (i) =>
                DateFormat.E().format(DateTime(2020, 1, i + 1)),
            color: cs.secondary,
          ),
          const SizedBox(height: 32),
          Text('Top 3 Highest Speed Locations', style: text.titleMedium),
          const SizedBox(height: 8),
          ...topLocations.map(
            (c) => ListTile(
              leading: Icon(Icons.location_on, color: cs.error),
              title: Text('Lat: ${c['latitude']}, Lon: ${c['longitude']}'), // Use 'latitude' and 'longitude' keys
              subtitle: Text(
                'Speed: ${c['speed_kmph']} km/h, Severity: ${c['severity']}', // Use 'speed_kmph' key
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCounter extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _AnimatedCounter({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(seconds: 2),
      builder: (context, val, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$val',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final Map<String, int> data;
  final ColorScheme cs;
  const _BarChart(this.data, this.cs);

  @override
  Widget build(BuildContext context) {
    final maxVal = data.values.isNotEmpty ? data.values.reduce(max) : 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.entries.map((e) {
        final barHeight = (e.value / maxVal) * 60;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(width: 24, height: barHeight, color: cs.primary),
              const SizedBox(height: 4),
              Text(e.key, style: TextStyle(fontSize: 12)),
              Text(
                '${e.value}',
                style: TextStyle(
                  fontSize: 10,
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<int> data;
  final String Function(int) labelBuilder;
  final Color color;
  const _LineChart(
    this.data, {
    required this.labelBuilder,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = data.isNotEmpty ? data.reduce(max) : 1;
    return SizedBox(
      height: 80,
      child: CustomPaint(
        painter: _LineChartPainter(data, color, maxVal),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            data.length,
            (i) => Text(labelBuilder(i), style: const TextStyle(fontSize: 10)),
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<int> data;
  final Color color;
  final int maxVal;
  _LineChartPainter(this.data, this.color, this.maxVal);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - (data[i] / maxVal) * size.height;
      points.add(Offset(x, y));
    }
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
