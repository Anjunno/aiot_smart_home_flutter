import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smarthometest/request/group_request.dart';

import '../request/graph_request.dart';

class DayGraph extends StatefulWidget {
  const DayGraph({super.key});

  @override
  State<DayGraph> createState() => _DayGraphState();
}

class _DayGraphState extends State<DayGraph> {
  List<Map<String, dynamic>> _data = []; // 전력량 데이터를 저장할 리스트

  @override
  void initState() {
    super.initState();
    fetchDayData(); // 위젯이 초기화될 때 데이터를 불러옴
  }

  // API에서 데이터를 가져와 상태를 업데이트하는 비동기 함수
  Future<void> fetchDayData() async {
    List<Map<String, dynamic>> data = await getDayEData(); // API 호출
    setState(() {
      _data = data; // 가져온 데이터를 상태에 저장
    });
  }

  @override
  Widget build(BuildContext context) {
    return _data.isEmpty
        ? const Center(child: CircularProgressIndicator()) // 데이터가 없으면 로딩 표시
        : LineChart(
      LineChartData(
        minX: 0, // X축 최소값 (첫 번째 데이터 인덱스)
        maxX: _data.length.toDouble() - 1, // X축 최대값 (데이터 개수 - 1)
        minY: 0, // Y축 최소값 (최소 전력량)
        maxY: 4, // Y축 최대값 (최대 전력량)

        // 그래프 터치 시 툴팁(숫자) 스타일 설정
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) {
              return Theme.of(context).colorScheme.secondary;
            },
            // : Colors.black.withOpacity(0.8), // 툴팁 배경색 변경
            // tooltipBorder: BorderSide(color: Colors.white, width: 1), // 툴팁 테두리 추가
            fitInsideHorizontally: true, // 툴팁이 그래프 밖으로 나가지 않도록 설정
            fitInsideVertically: true,
            tooltipRoundedRadius: 8, // 툴팁 모서리 둥글게 설정
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} KWh', // 툴팁에 표시할 텍스트
                  TextStyle(
                    color: Theme.of(context).colorScheme.surface, // 숫자 색상 변경
                    fontSize: 14, // 숫자 크기 변경
                    fontWeight: FontWeight.bold, // 숫자 굵기 변경
                  ),
                );
              }).toList();
            },
          ),
        ),

        // 그래프의 격자선 스타일 설정
        gridData: FlGridData(
          show: true, // 격자선 표시 여부
          drawVerticalLine: false, // 세로선 미표시
          drawHorizontalLine: true, // 가로선 표시
          getDrawingHorizontalLine: (value) => FlLine(
            strokeWidth: 1, // 선 두께 설정
            color: Colors.grey.withOpacity(0.5), // 색상을 연한 회색으로 설정
            dashArray: [5, 5], // 점선 설정 (5픽셀 선, 5픽셀 간격 반복)
          ),
        ),

        // X, Y축 라벨 설정
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, // X축 라벨 표시 여부
              interval: 1, // X축 값 간격을 1로 설정 (요일마다 하나씩 표시)
              getTitlesWidget: (double value, TitleMeta meta) {
                return Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    _data[value.toInt()]['date'], // X축에 날짜 표시
                    style: TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, // Y축 라벨 표시 여부
              interval: 1, // Y축 값 간격 설정
              reservedSize: 42, // 값들과 차트 사이의 공간
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)} KWh',
                  style: TextStyle(fontSize: 12),
                ); // Y축 값 표시
              },
            ),
          ),

          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // 우측 Y축 숨김
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // 상단 X축 숨김
          ),
        ),

        // 그래프의 데이터 설정
        lineBarsData: [
          LineChartBarData(
            color: Theme.of(context).colorScheme.primary,
            spots: _data.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(), // X축 값 (인덱스)
                entry.value['electricalEnergy'].toDouble(), // Y축 값 (전력량)
              );
            }).toList(),
            isCurved: true, // 곡선 그래프 사용 여부
            belowBarData: BarAreaData(
              show: true, // 선 아래에 색상을 채움
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2), // 채운 색상 설정
            ),
          ),
        ],
      ),
    );
  }
}
