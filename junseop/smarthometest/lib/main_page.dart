import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // fl_chart 패키지 import

class MainPage extends StatefulWidget {
  static String routeName = "/MainPage";
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double estimatedElectricityCost = 0.0;
  double actualElectricityUsage = 0.0;

  String mostPowerConsumingDevice = '';
  double mostPowerConsumingDeviceUsage = 0.0;
  double mostPowerConsumingDeviceCost = 0.0;

  // 기기별 전력 사용 데이터 (동적 데이터)
  List<DevicePowerData> deviceData = [];

  @override
  void initState() {
    super.initState();
    _fetchEstimatedCostAndUsage();
    _fetchMostPowerConsumingDevice();
    _fetchDevicePowerData();
  }

  void _fetchEstimatedCostAndUsage() {
    setState(() {
      estimatedElectricityCost = 12345.67; // 임시 데이터 //사용자 전기요금
      actualElectricityUsage = 350.5; // 임시 데이터 //사용자 전력 사용량
    });
  }

  void _fetchMostPowerConsumingDevice() {
    setState(() {
      mostPowerConsumingDevice = "냉장고"; // 임시 데이터
      mostPowerConsumingDeviceUsage = 10.0; // 임시 데이터
      mostPowerConsumingDeviceCost = mostPowerConsumingDeviceUsage * 200; // 임시 데이터
    });
  }

  void _fetchDevicePowerData() {
    // 실제로는 API나 DB에서 값을 받아오겠지만, 지금은 예시 데이터
    setState(() {
      deviceData = [
        DevicePowerData('냉장고', 10.0), // 임시 데이터
        DevicePowerData('에어컨', 5.0),  // 임시 데이터
        DevicePowerData('세탁기', 3.0),  // 임시 데이터
        DevicePowerData('조명', 2.0),    // 임시 데이터
        DevicePowerData('기타', 4.0),    // 임시 데이터
      ];
    });
  }

  Widget _buildElectricityCostSection() {
    final formatter = NumberFormat('#,###');
    // 예시 데이터 (실제 데이터로 교체)
    double estimatedElectricityCost = 15000.00; // 예상 전기요금
    double actualElectricityUsage = 350; // 실제 사용량 (kWh)
    double tierStart = 300; // 예시: 누진 구간 시작
    double tierEnd = 400; // 예시: 누진 구간 끝

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "이번 달 예상 전기요금",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          // SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "₩${formatter.format(estimatedElectricityCost)}",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              Text(
                "/ ${actualElectricityUsage.toStringAsFixed(2)} kWh",
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///누진 그래프
  Widget _buildTierIndicator() {
    const double maxUsage = 600.0;
    const double graphHeight = 8.0;

    // 누진 단계 및 색상 결정
    String tierText;
    Color tierColor;

    if (actualElectricityUsage <= 300) {
      tierText = "1단계";
      tierColor = Colors.green;
    } else if (actualElectricityUsage <= 450) {
      tierText = "2단계";
      tierColor = Colors.yellow[800]!;
    } else {
      tierText = "3단계";
      tierColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          final double tier1Width = (300 / maxUsage) * width;
          final double tier2Width = (150 / maxUsage) * width;
          final double tier3Width = (150 / maxUsage) * width;

          double markerPosition = (actualElectricityUsage / maxUsage) * width;
          if (markerPosition > width) markerPosition = width;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text("나의 누진 구간"),
                  const SizedBox(width: 16),
                  Text(
                    tierText,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: tierColor,
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  SizedBox(
                    height: 32,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(width: tier1Width, height: graphHeight, color: Colors.green),
                        Container(width: tier2Width, height: graphHeight, color: Colors.yellow),
                        Container(width: tier3Width, height: graphHeight, color: Colors.red),
                      ],
                    ),
                  ),
                  Positioned(
                    left: markerPosition - 10,
                    top: 5,
                    child: Tooltip(
                      message: '${actualElectricityUsage.toStringAsFixed(1)} kWh',
                      triggerMode: TooltipTriggerMode.tap, // ⬅️ 터치만 해도 툴팁이 뜨도록 설정
                      preferBelow: false, // ⬅️ 위쪽에 툴팁 표시
                      child: Icon(
                        Icons.flash_on,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Theme.of(context).colorScheme.onSurface,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    )

                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 16,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: Text('0', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant,)),
                    ),
                    Positioned(
                      left: tier1Width - 12,
                      child: Text('300', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant,)),
                    ),
                    Positioned(
                      left: tier1Width + tier2Width - 12,
                      child: Text('450', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant,)),
                    ),
                    Positioned(
                      left: width - 24,
                      child: Text('600', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant,)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  ///전기먹는 하마
  Widget _buildPowerConsumingDeviceSection() {
    final formatter = NumberFormat('#,###'); // 쉼표 포맷 생성
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15), // 살짝 더 진하게
              blurRadius: 16,    // 흐림 정도를 높임 → 더 부드러운 경계
              spreadRadius: 1,   // 그림자 넓이를 약간 확장
              offset: Offset(0, 6), // 아래쪽으로 더 띄우는 느낌
            ),

          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
                SizedBox(width: 8),
                Text(
                  "전기먹는 하마!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildPowerUsagePieChart(),
            Text(
              mostPowerConsumingDevice,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "₩${formatter.format(mostPowerConsumingDeviceCost)}",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                SizedBox(width: 10),
                Text(
                  "/ ${mostPowerConsumingDeviceUsage.toStringAsFixed(2)} kWh",
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///파이차트
  Widget _buildPowerUsagePieChart() {
    if (deviceData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final double totalPowerUsage = deviceData.fold(0.0, (sum, data) => sum + data.powerUsage);

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: deviceData.asMap().entries.map((entry) {
            final index = entry.key;
            final device = entry.value;

            final percentage = device.powerUsage / totalPowerUsage * 100;

            return PieChartSectionData(
              color: _getThemeColorByIndex(index),
              value: percentage,
              title: '${device.name}\n${percentage.toStringAsFixed(1)}%',
              radius: 60,
              titleStyle:  TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          }).toList(),
          borderData: FlBorderData(show: false),
          sectionsSpace: 0,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Color _getThemeColorByIndex(int index) {
    final colorScheme = Theme.of(context).colorScheme;
    // 색상을 순환하도록 리스트로 관리
    final colorList = [
      colorScheme.primary,          // 밝은 primary
      colorScheme.primary.withOpacity(0.8),        // 밝은 secondary
      colorScheme.primary.withOpacity(0.6),
      colorScheme.primary.withOpacity(0.4),
      colorScheme.primary.withOpacity(0.2),
      Colors.lightGreen.shade100,
      Colors.cyan.shade100,
    ];

    return colorList[index % colorList.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildElectricityCostSection(),
                _buildTierIndicator(),
                // _buildPowerUsagePieChart(),
                SizedBox(height: 20),
                _buildPowerConsumingDeviceSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DevicePowerData {
  final String name;
  final double powerUsage;

  DevicePowerData(this.name, this.powerUsage);
}
