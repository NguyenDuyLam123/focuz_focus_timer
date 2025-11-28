import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsScreen extends StatelessWidget {
  final int completedSessions;

  const StatisticsScreen({super.key, required this.completedSessions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thống kê Pomodoro")),
      body: Center(
        child: SfCircularChart(
          legend: Legend(isVisible: true),
          series: [
            DoughnutSeries<_Data, String>(
              dataSource: [
                _Data("Đã hoàn thành", completedSessions.toDouble()),
                _Data("Chưa làm", (50 - completedSessions).toDouble()),
              ],
              xValueMapper: (d, _) => d.label,
              yValueMapper: (d, _) => d.value,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _Data {
  final String label;
  final double value;
  _Data(this.label, this.value);
}
