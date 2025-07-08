import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/device_data.dart';

class DeviceDataView extends StatelessWidget {
  final DeviceData data;

  const DeviceDataView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChart('Accelerometer', data.accelX, data.accelY, data.accelZ),
        _buildChart('Gyroscope', data.gyroX, data.gyroY, data.gyroZ),
        _buildBattery(data.battery),
        _buildSpeed(data.speed),
        _buildImpact(data.impactDetected),
        _buildMap(data.latitude, data.longitude),
      ],
    );
  }

  Widget _buildChart(String title, List<double> x, List<double> y, List<double> z) {
    final int len = [x.length, y.length, z.length].reduce((a, b) => a < b ? a : b);
    final List<_Triple> points = List.generate(len, (i) => _Triple('t$i', x[i], y[i], z[i]));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(
            height: 220,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              legend: const Legend(isVisible: true),
              series: <LineSeries<_Triple, String>>[
                LineSeries<_Triple, String>(
                  name: 'X',
                  dataSource: points,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.x,
                  color: Colors.red,
                ),
                LineSeries<_Triple, String>(
                  name: 'Y',
                  dataSource: points,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.y,
                  color: Colors.green,
                ),
                LineSeries<_Triple, String>(
                  name: 'Z',
                  dataSource: points,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.z,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattery(List<double> battery) {
    double latest = battery.isNotEmpty ? battery.last : 0.0;
    Color barColor = latest < 20 ? Colors.red : latest < 50 ? Colors.orange : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Battery Status', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: latest / 100,
            color: barColor,
            backgroundColor: Colors.grey.shade300,
            minHeight: 14,
          ),
          const SizedBox(height: 6),
          Text('${latest.toStringAsFixed(1)}% remaining'),
        ],
      ),
    );
  }

  Widget _buildSpeed(List<double> speeds) {
    final double latest = speeds.isNotEmpty ? speeds.last : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Speed', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Current speed: ${latest.toStringAsFixed(1)} km/h'),
        ],
      ),
    );
  }

  Widget _buildImpact(List<bool> impacts) {
    final bool recentImpact = impacts.contains(true);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            recentImpact ? Icons.warning : Icons.check_circle,
            color: recentImpact ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Text(recentImpact ? 'Impact Detected!' : 'No Impact'),
        ],
      ),
    );
  }

  Widget _buildMap(double lat, double lon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Map: ($lat, $lon)',
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ),
    );
  }
}

class _Triple {
  final String label;
  final double x, y, z;

  _Triple(this.label, this.x, this.y, this.z);
}
