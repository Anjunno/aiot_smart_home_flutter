import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../function/request.dart';

class DeviceGraph extends StatefulWidget {
  const DeviceGraph({super.key});

  @override
  State<DeviceGraph> createState() => _DeviceGraphState();
}

class _DeviceGraphState extends State<DeviceGraph> {
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    fetchDeviceEData(); // 데이터를 초기화할 때 불러옴
  }

  Future<void> fetchDeviceEData() async {
    List<Map<String, dynamic>> data = await getDeviceEData();
    setState(() {
      _data = data;
      print(_data);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), // 전체 컨테이너에 16픽셀 패딩 추가
      child:  _data.isEmpty // 데이터가 비어 있으면 로딩 표시
          ? const Center(child: CircularProgressIndicator())
      : BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly, // 막대 간 간격을 균등하게 설정
          gridData: FlGridData(
            show: true, // 그리드 라인을 표시
            drawVerticalLine: false, // 수직선을 숨김
            horizontalInterval: 0.5, // 수평선 간격을 0.5로 설정
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: const Color(0xffe7e8ec), // 수평선의 색상을 설정
                strokeWidth: 1, // 수평선의 두께를 1로 설정
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true, // 타이틀(축 값)을 표시
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false), // 우측 Y축 값을 숨김
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false), // 상단 X축 값을 숨김
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, // 하단 X축 타이틀을 표시
                getTitlesWidget: (double value, TitleMeta meta) {
                  // X축에 각 전자기기의 이름을 타이틀로 표시
                  if (value.toInt() < _data.length){
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        _data[value.toInt()]['device'], // 동적으로 기기 이름을 표시
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // 범위를 벗어난 경우 빈 위젯 반환
                },
                reservedSize: 28, // 타이틀 영역의 크기를 28로 설정
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, // 좌측 Y축 타이틀을 표시
                reservedSize: 40, // 좌측 타이틀 영역 크기를 40으로 설정
                getTitlesWidget: (value, meta) {
                  // Y축에 kWh 단위의 전력 사용량을 표시
                  return Text('${value.toStringAsFixed(0)} kWh', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true, // 차트 테두리를 표시
            border: Border.all(
              color: const Color(0xff37434d), // 테두리 색상 설정
              width: 1, // 테두리 두께 설정
            ),
          ),
          // minX: 0, // X축 최소값
          // maxX: (_data.length - 1).toDouble(), // X축 최대값 (데이터 길이에 맞게 동적 설정)
          minY: 0, // Y축 최소값
          maxY: _data[0]['electricalEnergy'] + 20, // Y축 최대값(전력량이 가장 큰 기기의 전력량 + 20)
          barGroups: _data.asMap().entries.map((entry) {
            int index = entry.key;
            double energy = entry.value['electricalEnergy'];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: energy,
                  width: 30,
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(0),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}