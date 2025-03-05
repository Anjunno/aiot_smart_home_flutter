import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../request/graph_request.dart';

class MonthGraph extends StatefulWidget {
  const MonthGraph({super.key});

  @override
  State<MonthGraph> createState() => _MonthGraphState();
}

class _MonthGraphState extends State<MonthGraph> {
  // 전력량 데이터를 저장할 리스트
  List<Map<String, dynamic>> energyData = [];

  @override
  void initState() {
    super.initState();
    fetchDayData(); // 위젯이 초기화될 때 데이터를 불러옴
  }

  // API에서 데이터를 가져와 상태를 업데이트하는 비동기 함수
  Future<void> fetchDayData() async {
    List<Map<String, dynamic>> data = await getDayEData(); // API 호출하여 데이터를 가져옴
    setState(() {
      energyData = data; // 가져온 데이터를 상태에 저장
    });
  }

  // 데이터를 이용해 차트에 표시할 FlSpot 객체 리스트를 반환하는 함수
  List<FlSpot> getChartData() {
    return energyData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value["electricalEnergy"]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // 에너지 데이터를 기준으로 최대값을 찾아서 그래프의 Y축 범위 설정
    double maxEnergy = energyData.map((e) => e["electricalEnergy"] as double).reduce((a, b) => a > b ? a : b) + 0.5;

    // 그래프의 Y축 간격을 maxEnergy에 맞게 설정 (그리드 선 간격을 0.5로 설정)
    double horizontalInterval = maxEnergy / 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 32, 8), // 여백을 조금 줄임
            child: LineChart(
              LineChartData(
                backgroundColor: Theme.of(context).colorScheme.background, // 배경 색을 테마 색으로 변경

                // 그래프 터치 시 툴팁(숫자) 스타일 설정
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) {
                      return Theme.of(context).colorScheme.secondary;
                    },
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
                gridData: FlGridData(
                  show: true, // 그리드 표시 여부
                  drawVerticalLine: false, // 세로선 표시 여부
                  horizontalInterval: horizontalInterval, // 가로축 간격을 동적으로 설정
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), strokeWidth: 1); // 가로선 색상 테마에 맞게 설정
                  },
                ),
                titlesData: FlTitlesData(
                  // Y축 타이틀 설정
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 0.5, // Y축 값 간격
                      reservedSize: 32, // Y축 타이틀 공간을 줄임
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toStringAsFixed(1)} kWh', style: TextStyle(fontSize: 7, color: Theme.of(context).colorScheme.onBackground)); // Y축 값 표시 형식
                      },
                    ),
                  ),
                  // X축 타이틀 설정
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, // X축 타이틀 표시 여부
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < energyData.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 2,), // X축 타이틀 여백을 더 줄임
                            child: Text(energyData[index]['date'].substring(3),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground)),
                          );
                        }
                        return Text('');
                      },
                      reservedSize: 18, // X축 타이틀 공간 줄임
                      interval: 1, // X축 값 간격
                    ),
                  ),
                  // 오른쪽 Y축 타이틀 숨김
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  // 상단 타이틀 숨김
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: false, // 그래프 테두리 숨김
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: getChartData(), // 차트의 데이터
                    isCurved: true, // 곡선으로 표시
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary, // 선 색상 (테마의 primary 색상 사용)
                        Theme.of(context).colorScheme.secondary // 선 색상 (테마의 secondary 색상 사용)
                      ],
                    ),
                    barWidth: 4, // 선의 두께
                    isStrokeCapRound: true, // 끝을 둥글게 처리
                    belowBarData: BarAreaData(
                      show: true, // 그래프 밑부분 음영 표시 여부
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.2), // 음영 색상 (primary 색상 사용)
                          Theme.of(context).colorScheme.secondary.withOpacity(0.1) // 음영 색상 (secondary 색상 사용)
                        ],
                      ),
                    ),
                    dotData: FlDotData(show: true), // 데이터 점 표시 여부
                  ),
                ],
                minY: 0, // Y축 최소값
                maxY: maxEnergy, // Y축 최대값
              ),
            ),
          ),
        ),
      ],
    );
  }
}
