import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smarthometest/request/group_request.dart';

import '../../request/graph_request.dart';

class DayGraph extends StatefulWidget {
  const DayGraph({super.key});

  @override
  State<DayGraph> createState() => _DayGraphState();
}

class _DayGraphState extends State<DayGraph> {
  List<Map<String, dynamic>> _data = []; // 전력량 데이터
  List<Map<String, dynamic>> _deviceData = []; // 기기 데이터
  String? _choiceDevice = "전체";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchDeviceData();
    await fetchDayData(); // 기본적으로 "전체" 데이터를 가져옵니다.
  }

  Future<void> fetchDayData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> data = await getDayEData(context);
      setState(() {
        _data = data;
      });
    } catch (e) {
      print("Error fetching day data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchDayDeviceData(String deviceId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> data = await getDayDeviceEData(context, deviceId);
      setState(() {
        print("주간단일기기 데이터는용 : $data");
        _data = data;
      });
    } catch (e) {
      print("Error fetching device data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchDeviceData() async {
    try {
      List<Map<String, dynamic>> data = await getDeviceList(context);
      setState(() {
        _deviceData = data;
      });
    } catch (e) {
      print("Error fetching device list: $e");
    }
  }

  // ✔️ 데이터 변환 (오류 수정된 부분)
  List<FlSpot> getChartData() {
    return _data.asMap().entries.map((entry) {
      double xValue = entry.key.toDouble(); // 인덱스를 x값으로 사용
      double yValue;

      // 데이터 구조가 ["electricalEnergy"]인지 ["value"]인지 확인 후 맞게 사용!
      if (entry.value.containsKey("value")) {
        yValue = (entry.value["value"] as num).toDouble(); // JSON에서 value를 double로 변환
      } else {
        yValue = (entry.value["electricalEnergy"] as num).toDouble();
      }

      return FlSpot(xValue, yValue);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double maxEnergy = _data.isNotEmpty
        ? (() {
      double maxVal = _data.fold(0.0, (prev, e) {
        double val;
        if (e.containsKey("value")) {
          val = (e["value"] as num).toDouble();
        } else {
          val = (e["electricalEnergy"] as num).toDouble();
        }
        return val > prev ? val : prev;
      });

      double minVal = _data.fold(maxVal, (prev, e) {
        double val;
        if (e.containsKey("value")) {
          val = (e["value"] as num).toDouble();
        } else {
          val = (e["electricalEnergy"] as num).toDouble();
        }
        return val < prev ? val : prev;
      });

      // 변화폭 계산
      double diff = maxVal - minVal;

      // 마진: 변화폭이 작을수록 더 크게 부여
      double margin = diff == 0
          ? maxVal == 0 ? 10.0 : maxVal * 0.2
          : diff * 0.2;

      // 최종 maxY 설정
      return (maxVal + margin) < 1.0 ? 1.0 : maxVal + margin;
    })()
        : 10.0;

    double horizontalInterval = maxEnergy / 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            children: [
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _data.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.show_chart, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      "최근 일주일간 사용한 전력이 없습니다",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )

        : Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                child: LineChart(
                  LineChartData(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    lineTouchData: _buildLineTouchData(),
                    gridData: _buildGridData(horizontalInterval),
                    titlesData: _buildTitlesData(horizontalInterval),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [_buildLineChartBarData()],
                    minY: 0,
                    maxY: maxEnergy,
                  ),
                ),
              ),
              Positioned(
                right: 16,
                child: AnimatedOpacity(
                  opacity: _isLoading ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: _buildDropdown(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 드롭다운 위젯 분리
  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _choiceDevice,
          icon: const Icon(Icons.arrow_drop_down, size: 24),
          isExpanded: false,
          onChanged: (String? newValue) async {
            if (newValue == null) return;

            setState(() {
              _choiceDevice = newValue;
            });

            if (newValue == "전체") {
              await fetchDayData();
            } else {
              final selectedDevice = _deviceData.firstWhere(
                    (device) => device["name"] == newValue,
                orElse: () => {},
              );
              final deviceId = selectedDevice["id"];
              if (deviceId != null) {
                print("fetchDayDeviceData 요청 시작한다");
                await fetchDayDeviceData(deviceId.toString());
              }
            }
          },
          items: [
            const DropdownMenuItem<String>(
              value: "전체",
              child: Text("전체"),
            ),
            ..._deviceData.map((device) {
              return DropdownMenuItem<String>(
                value: device["name"],
                child: Text(device["name"]),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// 차트 터치 데이터
  LineTouchData _buildLineTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.secondary,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        tooltipRoundedRadius: 8,
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((spot) {
            return LineTooltipItem(
              '${spot.y.toStringAsFixed(3)} kWh',
              TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  /// 그리드 데이터
  FlGridData _buildGridData(double horizontalInterval) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: horizontalInterval,
      getDrawingHorizontalLine: (value) => FlLine(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
        strokeWidth: 1,
      ),
    );
  }

  /// 타이틀 데이터
  FlTitlesData _buildTitlesData(double horizontalInterval) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: horizontalInterval,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              '${value.toStringAsFixed(1)} kWh',
              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onBackground),
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 20,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (index >= 0 && index < _data.length) {
              String dateStr;

              if (_data[index].containsKey("date")) {
                dateStr = _data[index]['date'];
              } else if (_data[index].containsKey("t")) {
                dateStr = _data[index]['t'].toString().substring(5, 10); // MM-DD만 사용
              } else {
                dateStr = "";
              }

              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /// 라인 차트 바 데이터
  LineChartBarData _buildLineChartBarData() {
    return LineChartBarData(
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
      dotData: FlDotData(show: true),
    );
  }
}
