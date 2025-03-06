import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../request/graph_request.dart';
import '../request/group_request.dart';

class DeviceGraph extends StatefulWidget {
  const DeviceGraph({super.key});

  @override
  State<DeviceGraph> createState() => _DeviceGraphState();
}

class _DeviceGraphState extends State<DeviceGraph> {
  List<Map<String, dynamic>> energyData = [];

  @override
  void initState() {
    super.initState();
    fetchDeviceData();
  }

  Future<void> fetchDeviceData() async {
    List<Map<String, dynamic>> data = await getDeviceEData();
    setState(() {
      energyData = data;
    });
  }

  List<BarChartGroupData> getChartData() {
    return energyData.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value["usage"],
            color: Theme.of(context).colorScheme.primary,
            width: 16,
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double maxEnergy = energyData.isNotEmpty
        ? energyData.map((e) => e["usage"] as double).reduce((a, b) => a > b ? a : b) + 0.5
        : 1.0;

    // 화면의 가로 크기에 따라 interval을 유동적으로 조정
    double screenWidth = MediaQuery.of(context).size.width;
    double interval = energyData.length > 10 ? (screenWidth / 100).toDouble() : 1.0;

    return energyData.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 32, 8),
            child: BarChart(
              BarChartData(
                backgroundColor: Theme.of(context).colorScheme.background,
                barGroups: getChartData(),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toStringAsFixed(1)} kWh',
                            style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onBackground));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < energyData.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              energyData[index]['plugName'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                      reservedSize: 18,
                      interval: interval, // 동적으로 간격 조정
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (touchedSpot) {
                      return Theme.of(context).colorScheme.secondary;
                    },
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)} KWh',
                        TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
