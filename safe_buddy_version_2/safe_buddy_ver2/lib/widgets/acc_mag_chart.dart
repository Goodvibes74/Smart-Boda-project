import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/analysis_model.dart';

class AccMagChart extends StatelessWidget {
  final List<TimeSeriesPoint> data;

  const AccMagChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: data.map((point) {
              return FlSpot(
                point.t.millisecondsSinceEpoch.toDouble(),
                point.accMag,
              );
            }).toList(),
            isCurved: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            color: Colors.blue,
          ),
        ],
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
      ),
    );
  }
}
