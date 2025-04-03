import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../request/advice_requests.dart';
import '../../request/graph_request.dart';

class MonthGraph extends StatefulWidget {
  const MonthGraph({super.key});

  @override
  State<MonthGraph> createState() => _MonthGraphState();
}

class _MonthGraphState extends State<MonthGraph> {
  List<Map<String, dynamic>> energyData = [];
  Map<String, dynamic> _adviceData = {};
  bool _isLoading = true; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await fetchMonthData();
    await fetchAdviceData();
  }

  ///조언 데이터 불러오기
  Future<void> fetchAdviceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> data = await getAdvice(context, "day");
      setState(() {
        // _adviceData = data;
        _adviceData = {"advice" : "최근 전력 사용이 급증하고 있어요!\n난방기기와 대기전력 기기의 사용 시간을 줄이면 전기료를 크게 절감할 수 있어요."};
      });
    } catch (e) {
      print("Error fetching advice: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  Widget adviceWidget() {
    String advice = _adviceData['advice'] ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(8,16,8,8),
      child: Container(
        padding: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start, // 아이콘보다 텍스트 높이가 클 때 맞춰줌
          children: [
            Icon(
              Icons.lightbulb_rounded,
              color: Colors.yellow[800],
              size: 36,
            ),
            SizedBox(width: 8),
            Expanded( // Column을 감싸서 남은 공간 차지하도록 함
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "한 줄 조언",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    advice
                    ,
                    // style: TextStyle(
                    //   fontWeight: FontWeight.w900,
                    // ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "사용한 전력이 없습니다.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        adviceWidget(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 16, 16),
            child: LineChart(
              LineChartData(
                backgroundColor: Theme.of(context).colorScheme.surface,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) {
                      return Theme.of(context).colorScheme.primary.withOpacity(0.9);
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
                              style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onSurface)),
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
                                color: Theme.of(context).colorScheme.onSurface,
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
                    color: Theme.of(context).colorScheme.primary, // ✅ 선 색상
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.15), // ✅ 단일 배경 색
                    ),
                    dotData: FlDotData(
                      show: true,
                      // dotColor: Theme.of(context).colorScheme.primary, // ✅ 도트 색상 (선택)
                    ),
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
