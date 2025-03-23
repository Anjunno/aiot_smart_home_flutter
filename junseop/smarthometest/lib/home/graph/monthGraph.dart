import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../request/graph_request.dart';

class MonthGraph extends StatefulWidget {
  const MonthGraph({super.key});

  @override
  State<MonthGraph> createState() => _MonthGraphState();
}

class _MonthGraphState extends State<MonthGraph> {
  List<Map<String, dynamic>> energyData = [];
  bool _isLoading = true; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    fetchMonthData();
  }

  Future<void> fetchMonthData() async {
    List<Map<String, dynamic>> data = await getMonthEData(context);

    // 날짜를 기준으로 정렬 (오름차순)
    data.sort((a, b) => a['month'].compareTo(b['month']));

    setState(() {
      energyData = data;
      _isLoading = false; // 로딩 완료
    });
  }

  List<FlSpot> getChartData() {
    return energyData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value["electricalEnergy"]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double maxEnergy = energyData.isNotEmpty
        ? energyData.fold(0.0, (prev, e) => prev > e["electricalEnergy"] ? prev : e["electricalEnergy"]) + 5
        : 10.0;

    double horizontalInterval = maxEnergy / 5;

    return _isLoading
        ? const Center(child: CircularProgressIndicator()) // 로딩 인디케이터 표시
        : energyData.isEmpty
        ? const Center(
      child: Text(
        "사용한 전력이 없습니다",
        style: TextStyle(fontSize: 16,),
      ),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 16, 16),
            child: LineChart(
              LineChartData(
                backgroundColor: Theme.of(context).colorScheme.background,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) {
                      return Theme.of(context).colorScheme.secondary;
                    },
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)} kWh',
                          TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: horizontalInterval,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                        strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: horizontalInterval,
                      reservedSize: 40, // Y축 레이블 공간을 넉넉하게 설정
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text('${value.toStringAsFixed(1)} kWh',
                              style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onBackground)),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20, // X축 라벨 간격 조정
                      interval: 1, // 라벨이 겹치지 않도록 설정
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < energyData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              energyData[index]['month'].substring(2), // 월 부분만 표시
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: getChartData(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        ],
                      ),
                    ),
                    dotData: FlDotData(show: true), // 점을 표시하여 데이터 강조
                  ),
                ],
                minY: 0,
                maxY: maxEnergy,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
