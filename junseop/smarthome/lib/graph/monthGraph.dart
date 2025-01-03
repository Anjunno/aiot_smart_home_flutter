import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../function/request.dart';

class MonthGraph extends StatefulWidget {
  const MonthGraph({super.key});

  @override
  State<MonthGraph> createState() => _MonthGraphState();
}

class _MonthGraphState extends State<MonthGraph> {
  List<Map<String, dynamic>> _data = [];
  double _maxY = 0; // Y축의 최대값 저장 변수

  @override
  void initState() {
    super.initState();
    fetchMonthEData();
  }

  Future<void> fetchMonthEData() async {
    List<Map<String, dynamic>> data = await getMonthEData();
    setState(() {
      _data = data;

      // 데이터를 기반으로 Y축 최대값 계산
      _maxY = _data.isNotEmpty
          ? (_data.map((e) => e['electricalEnergy'] as num).reduce((a, b) => a > b ? a : b) + 100).toDouble()
          : 0;

      print("Max Y: $_maxY");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: _data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: 100, // Y축 간격 설정
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xffe7e8ec),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() < _data.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        _data[value.toInt()]['month'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 32,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toStringAsFixed(0)}k', // 소수점 제거
                    style: const TextStyle(
                      color: Color(0xff67727d),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: const Color(0xff37434d),
              width: 1,
            ),
          ),
          minX: 0,
          maxX: _data.length.toDouble() - 1, // X축 최대값
          minY: 0,
          maxY: _maxY, // 동적으로 설정된 Y축 최대값
          lineBarsData: [
            LineChartBarData(
              spots: _data.asMap().entries.map((entry) {
                int index = entry.key;
                double electricalEnergy =
                (entry.value['electricalEnergy'] as num).toDouble();
                return FlSpot(index.toDouble(), electricalEnergy);
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

