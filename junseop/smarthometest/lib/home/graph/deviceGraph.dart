import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../request/advice_requests.dart';
import '../../request/graph_request.dart';
import '../../request/group_request.dart';

class DeviceGraph extends StatefulWidget {
  const DeviceGraph({super.key});

  @override
  State<DeviceGraph> createState() => _DeviceGraphState();
}

class _DeviceGraphState extends State<DeviceGraph> {
  List<Map<String, dynamic>> energyData = [];
  Map<String, dynamic> _adviceData = {};
  bool _isLoading = true; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchDeviceData();
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
        _adviceData = {"advice" : "이번 주 전체 전력의 75% 이상이 컴퓨터 본체와 모니터에서 나왔어요! 평소 사용 후 전원 OFF 또는 절전 모드를 적극 활용해보세요"};
      });
    } catch (e) {
      print("Error fetching advice: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchDeviceData() async {
    List<Map<String, dynamic>> data = await getDeviceEData(context);
    setState(() {
      energyData = data;
      _isLoading = false; // 로딩 완료
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
          ),
        ],
      );
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
                    advice,
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
        ? energyData.map((e) => e["usage"] as double).reduce((a, b) => a > b ? a : b) + 0.5
        : 1.0;

    // 화면의 가로 크기에 따라 interval을 유동적으로 조정
    double screenWidth = MediaQuery.of(context).size.width;
    double interval = energyData.length > 10 ? (screenWidth / 100).toDouble() : 1.0;

    return _isLoading
        ? const Center(child: CircularProgressIndicator()) // 로딩 인디케이터 표시
        : energyData.isEmpty
        ? const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_chart_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "최근 일주일간 사용한 전력이 없습니다",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ///한 줄 조언 위젯
        adviceWidget(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 24, 16, 8),
            child: BarChart(
              BarChartData(
                backgroundColor: Theme.of(context).colorScheme.surface,
                barGroups: getChartData(),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,//왼쪽 값
                      reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 == 0) { // 1 단위로 나누어떨어질 때만
                            return Text(
                              '${value.toStringAsFixed(0)} kWh',
                              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface),
                            );
                          } else {
                            return const SizedBox.shrink(); // 빈 위젯
                          }
                        }

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
                            child: SizedBox(
                              width: 40,
                              child: Text(
                                energyData[index]['plugName'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
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
                      return Theme.of(context).colorScheme.primary.withOpacity(0.9);
                    },
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final plugName = energyData[groupIndex]['plugName'];
                      final usage = rod.toY;

                      return BarTooltipItem(
                        '$plugName\n${usage.toStringAsFixed(3)} kWh',
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
