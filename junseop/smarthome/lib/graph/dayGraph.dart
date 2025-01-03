import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../function/request.dart';

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
      _data = data;
      print(_data);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), // 16픽셀 패딩 추가
      child:  _data.isEmpty // 데이터가 비어 있으면 로딩 표시
          ? const Center(child: CircularProgressIndicator())
      : LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true, // 그리드 라인 표시
            drawVerticalLine: false, // 수직선 숨김
            drawHorizontalLine: true, // 수평선 표시
            horizontalInterval: 0.5, // 수평선 간격 설정
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xffe7e8ec), // 수평선 색상
              strokeWidth: 1, // 수평선 두께
            ),
          ),
          titlesData: FlTitlesData(
            show: true, // 타이틀(축 값) 표시
            rightTitles: AxisTitles( // 우측 Y축 값 숨김
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles( // 상단 X축 값 숨김
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, // X축 타이틀 표시
                interval: 1, // X축 값 간격을 1로 설정하여 요일마다 하나씩만 표시
                getTitlesWidget: (double value, TitleMeta meta) {
                  // X축에 각 전자기기의 이름을 타이틀로 표시
                  if (value.toInt() < _data.length){
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 8, //텍스트와 축 사이 여백
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          _data[value.toInt()]['date'], // 동적으로 기기 이름을 표시
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // 범위를 벗어난 경우 빈 위젯 반환
                },
                reservedSize: 32, // 타이틀 영역 크기
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, // 좌측 Y축 타이틀 표시
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toStringAsFixed(0)}Kwh', // Y축 값 표시 (소수점 자리 없애기 + 'k' 추가)
                    style: const TextStyle(
                      color: Color(0xff67727d), // 글자 색상
                      fontWeight: FontWeight.bold, // 글자 두께
                      fontSize: 10, // 글자 크기
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true, // 테두리 표시
            border: Border.all(
              color: const Color(0xff37434d), // 테두리 색상 설정
              width: 1, // 테두리 두께 설정
            ),
          ),
          minX: 0, // X축 최소값
          maxX: 6, // X축 최대값
          minY: 0, // Y축 최소값
          maxY: 4, // Y축 최대값
          lineBarsData: [
            LineChartBarData(
              spots:_data.asMap().entries.map((entry) {
                int index = entry.key;
                double electricalEnergy = (entry.value['electricalEnergy'] as num).toDouble();
                return FlSpot(index.toDouble(), electricalEnergy); // 동적으로 FlSpot 생성
              }).toList(),
              isCurved: true, // 꺾은선 그래프를 곡선으로 만듬
              color: Colors.blue, // 선의 색상
              barWidth: 3, // 선의 두께
              isStrokeCapRound: true, // 선의 끝을 둥글게 설정
              belowBarData: BarAreaData(
                show: true, // 선 아래에 색상을 채움
                color: Colors.blue.withOpacity(0.2), // 채운 색상 설정
              ),
            ),
          ],
        ),
      ),
    );
  }
}
