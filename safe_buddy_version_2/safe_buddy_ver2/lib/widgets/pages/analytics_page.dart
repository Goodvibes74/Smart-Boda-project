// lib/widgets/pages/analytics_page.dart
// Removed ignore_for_file: deprecated_member_use as modern widgets will be used

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For getting current user
import 'package:safe_buddy_ver2/crash_algorithm.dart'; // Import CrashData and CrashAlgorithmService
import '../device.dart'; // Import Device and DeviceService (for potential future use in analytics)
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:convert'; // For jsonEncode

import '../alert_card.dart'; // For displaying error/info messages
import '../map_overlay.dart'; // For displaying historical crash locations on a map

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final CrashAlgorithmService _crashService = CrashAlgorithmService();
  // final DeviceService _deviceService = DeviceService(); // Uncomment if you need device data in analytics
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    // Listen for authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  /// Exports crash data as CSV or JSON.
  void _exportCrashes(
    BuildContext context,
    List<CrashData> crashList, { // Now takes List<CrashData>
    required bool asCsv,
  }) {
    // Convert CrashData objects to a list of maps for export
    final List<Map<String, dynamic>> exportableList = crashList.map((crash) {
      return {
        'timestamp': crash.timestamp.toIso8601String(), // ISO 8601 for consistent timestamp
        'latitude': crash.latitude,
        'longitude': crash.longitude,
        'severity': crash.severity,
        'speed_kmph': crash.speedKmph,
        'crash_type': crash.crashType,
      };
    }).toList();

    if (asCsv) {
      final headers = ['timestamp', 'deviceId', 'latitude', 'longitude', 'severity', 'speed_kmph', 'crash_type'];
      final csv = StringBuffer();
      csv.writeln(headers.join(','));
      for (final row in exportableList) {
        csv.writeln(headers.map((h) => row[h]?.toString() ?? '').join(','));
      }
      _showExportDialog(context, csv.toString(), 'CSV');
    } else {
      final jsonStr = jsonEncode(exportableList);
      _showExportDialog(context, jsonStr, 'JSON');
    }
  }

  void _showExportDialog(BuildContext context, String data, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Exported $type'),
        content: SizedBox(
          width: MediaQuery.of(ctx).size.width * 0.7, // Make it responsive
          height: MediaQuery.of(ctx).size.height * 0.6,
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (_currentUser == null) {
      return Center(
        child: AlertCard(
          title: 'Authentication Required',
          message: 'Please log in to view crash analytics.',
          type: AlertType.info,
          onClose: () {
            // Optionally navigate to auth page or just dismiss the message
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crash Analytics'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      backgroundColor: cs.background,
      body: StreamBuilder<List<CrashData>>( // Use StreamBuilder for real-time data
        stream: _crashService.getCrashStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error loading analytics: ${snapshot.error}');
            return Center(
              child: AlertCard(
                title: 'Error Loading Analytics',
                message: 'Could not load crash data: ${snapshot.error}',
                type: AlertType.error,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: AlertCard(
                title: 'No Crash Data',
                message: 'No crash events have been recorded yet for analytics.',
                type: AlertType.info,
              ),
            );
          }
          final crashList = snapshot.data!;
          return _buildAnalytics(context, crashList, cs, text);
        },
      ),
    );
  }

  Widget _buildAnalytics(
    BuildContext context,
    List<CrashData> crashList, // Now takes List<CrashData>
    ColorScheme cs,
    TextTheme text,
  ) {
    // Crash type counts
    final typeCounts = <String, int>{};
    for (var crash in crashList) {
      final type = crash.crashType;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    // Accidents by hour
    final hourCounts = List<int>.filled(24, 0);
    for (var crash in crashList) {
      hourCounts[crash.timestamp.hour]++;
    }

    // Accidents by day of week (Monday=1, Sunday=7. Convert to 0-6 for array)
    final dayCounts = List<int>.filled(7, 0);
    for (var crash in crashList) {
      dayCounts[crash.timestamp.weekday % 7]++; // Monday is 1, Sunday is 7. %7 makes Sunday 0, Monday 1...
    }

    // Average interval
    final timestamps = crashList.map((c) => c.timestamp).toList()..sort();
    final intervals = <Duration>[];
    for (int i = 1; i < timestamps.length; i++) {
      intervals.add(timestamps[i].difference(timestamps[i - 1]));
    }
    final avgInterval = intervals.isNotEmpty
        ? intervals.map((d) => d.inMinutes).reduce((a, b) => a + b) / intervals.length
        : 0;

    // Average speed
    final speeds = crashList.map((c) => c.speedKmph).toList();
    final avgSpeed = speeds.isNotEmpty
        ? speeds.reduce((a, b) => a + b) / speeds.length
        : 0;

    // Locations with highest speeds
    final topSpeedCrashes = List.of(crashList)
      ..sort((a, b) => b.speedKmph.compareTo(a.speedKmph));
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
                onPressed: () => _exportCrashes(context, crashList, asCsv: true),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.file_copy),
                label: const Text('Export as JSON'),
                onPressed: () => _exportCrashes(context, crashList, asCsv: false),
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
            labelBuilder: (i) => DateFormat.E().format(DateTime(2020, 1, (i + 1) % 7 == 0 ? 7 : (i + 1) % 7)), // Adjust for correct day mapping
            color: cs.secondary,
          ),
          const SizedBox(height: 32),
          Text('Top 3 Highest Speed Locations', style: text.titleMedium),
          const SizedBox(height: 8),
          ...topLocations.map(
            (c) => ListTile(
              leading: Icon(Icons.location_on, color: cs.error),
              title: Text('Lat: ${c.latitude.toStringAsFixed(4)}, Lon: ${c.longitude.toStringAsFixed(4)}'),
              subtitle: Text(
                'Speed: ${c.speedKmph.toStringAsFixed(1)} km/h, Severity: ${c.severity}',
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Historical Crash Locations',
            style: text.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 400, // Fixed height for the map
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomMapView(
                crashLocations: crashList,
                showDeviceMarkers: false, // Only show crash markers here
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
    return TweenAnimationBuilder<double>( // Changed to double for smoother animation
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(seconds: 2),
      builder: (context, val, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${val.round()}', // Round to integer for display
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 16)),
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
    return SingleChildScrollView( // Added SingleChildScrollView for horizontal scrolling on narrow screens
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.entries.map((e) {
          final barHeight = (e.value / maxVal) * 60;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 24,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(4), // Rounded corners for bars
                  ),
                ),
                const SizedBox(height: 4),
                Text(e.key, style: const TextStyle(fontSize: 12)),
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
      ),
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
      height: 100, // Increased height for better visibility
      child: CustomPaint(
        painter: _LineChartPainter(data, color, maxVal),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding for labels
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              data.length,
              (i) => Text(labelBuilder(i), style: const TextStyle(fontSize: 10)),
            ),
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
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Rounded line caps

    final fillPaint = Paint() // For gradient fill under the line
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1).clamp(1, double.infinity); // Handle single data point
      final y = size.height - (data[i] / maxVal) * size.height;
      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);

      // Draw fill under the line
      final fillPath = Path.from(path)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();
      canvas.drawPath(fillPath, fillPaint);
    } else if (points.length == 1) {
      // Draw a single circle if only one data point
      canvas.drawCircle(points[0], 4, paint..style = PaintingStyle.fill);
    }

    // Draw circles at each data point
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawCircle(p, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color || oldDelegate.maxVal != maxVal;
  }
}
