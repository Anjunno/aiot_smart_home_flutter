import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Consumer를 사용하기 위한 import
import '../Theme.dart';
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
    // 테마 상태를 Consumer로 가져옴
    return Consumer<ThemeColor>(
      builder: (context, themeColor, child) {
        // 테마 색상 설정
        Color lineColor = themeColor.isDark ? Colors.blue : Colors.green;
        Color gridColor = themeColor.isDark ? Color(0xff2c2f36) : Color(0xffe7e8ec);
        Color textColor = themeColor.isDark ? Colors.white : Color(0xff67727d);
        Color backgroundColor = themeColor.isDark ? Color(0xff1c1f26) : Colors.white;

        return Container(
          padding: const EdgeInsets.all(16),
          color: backgroundColor, // 배경색을 테마에 맞게 설정
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
                  color: gridColor, // 그리드 색상을 테마에 맞게 설정
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
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor, // 텍스트 색상 테마에 맞게 설정
                            ),
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
                        style: TextStyle(
                          color: textColor, // 텍스트 색상 테마에 맞게 설정
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
                  color: themeColor.isDark ? Colors.white : Color(0xff37434d),
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
                  color: lineColor, // 선 색상을 테마에 맞게 설정
                  barWidth: 3,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                    show: true,
                    color: lineColor.withOpacity(0.2), // 선 아래 색상 테마에 맞게 설정
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
