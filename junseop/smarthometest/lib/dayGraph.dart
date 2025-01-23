import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smarthometest/request.dart';

class DayGraph extends StatefulWidget {
  const DayGraph({super.key});

  @override
  State<DayGraph> createState() => _DayGraphState();
}

class _DayGraphState extends State<DayGraph> {
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    fetchDayData(); // 데이터를 초기화할 때 불러옴
  }

  Future<void> fetchDayData() async {
    List<Map<String, dynamic>> data = await getDayEData();
    setState(() {
      _data = data; // 데이터를 받아와서 상태 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return _data.isEmpty
        ? const Center(child: CircularProgressIndicator()) // 데이터가 없으면 로딩 표시
        : LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, // X축 타이틀 표시
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(_data[value.toInt()]['date']); // X축에 날짜 표시
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, // Y축 타이틀 표시
              getTitlesWidget: (value, meta) {
                return Text('${value.toStringAsFixed(0)}Kwh'); // Y축 값 표시
              },
            ),
          ),
        ),
        minX: 0, // X축 최소값
        maxX: _data.length.toDouble() - 1, // X축 최대값
        minY: 0, // Y축 최소값
        maxY: 4, // Y축 최대값
        lineBarsData: [
          LineChartBarData(
            spots: _data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value['electricalEnergy'].toDouble()); // 데이터를 그래프에 표시
            }).toList(),
            isCurved: true, // 곡선으로 그래프 표시
          ),
        ],
      ),
    );
  }
}
