import 'package:flutter/material.dart';
import 'package:smarthometest/request/dashBoard_request.dart';

class DashboardPage extends StatefulWidget {
  static String routeName = "/DashboardPage";

  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final data = await getDashBoard(context);
    setState(() {
      dashboardData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard),
            SizedBox(width: 8),
            Text("대시보드", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              context: context,
              title: "📊 어제 vs 그저께",
              children: [
                _buildInfoRow(context, "어제", "${dashboardData!['total_usage']['yesterday']} kWh"),
                _buildInfoRow(context, "그저께", "${dashboardData!['total_usage']['day_before_yesterday']} kWh"),
                _buildInfoRow(
                  context,
                  "변화",
                  dashboardData!['total_usage']['diff_text'],
                  valueColor: dashboardData!['total_usage']['diff'].toDouble() > 0 ? Colors.red : Colors.green,
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildSectionCard(
              context: context,
              title: "⚡ 전력 사용 변화 TOP 3",
              children: List<Widget>.from(
                dashboardData!['top3_devices'].map<Widget>(
                      (device) => _buildDeviceItem(
                    context,
                    device['plug_name'],
                    device['yesterday'].toDouble(),
                    device['day_before_yesterday'].toDouble(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            _buildAdviceCard(context, dashboardData!['advice']),
          ],
        ),
      ),
    );
  }
}



// 📦 공통 카드 스타일
Widget _buildSectionCard({required BuildContext context, required String title, required List<Widget> children}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ...children,
      ],
    ),
  );
}


// ℹ️ 기본 정보 row
Widget _buildInfoRow(BuildContext context, String label, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    ),
  );
}


// 📈 기기 변화 row
Widget _buildDeviceItem(BuildContext context, String name, double yesterday, double dayBefore) {
  final diff = yesterday - dayBefore;
  final isIncrease = diff > 0;
  final arrow = isIncrease ? "▲" : (diff < 0 ? "▼" : "-");
  final diffText = "$arrow ${diff.abs().toStringAsFixed(1)} kWh";

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("어제: ${yesterday.toStringAsFixed(1)} kWh"),
            Text("그제: ${dayBefore.toStringAsFixed(1)} kWh"),
            Text(
              diffText,
              style: TextStyle(
                color: isIncrease ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


// 💡 전력 절감 조언 카드
Widget _buildAdviceCard(BuildContext context, Map<String, dynamic> advice) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              "전력 절감을 위한 조언",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 16),
          if (advice['problem']?.toString().trim().isNotEmpty != true)
            _buildAdviceSection("", advice['raw'])
          else ...[
            _buildAdviceSection("🔎 문제", advice['problem']),
            _buildAdviceSection("📌 원인", advice['cause']),
            _buildAdviceSection("✅ 해결책", advice['solution']),
          ]
      ],
    ),
  );
}



// 💬 조언 내용
Widget _buildAdviceSection(String title, String content) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 4),
        Text(content, style: TextStyle(fontSize: 14, height: 1.5)),
      ],
    ),
  );
}
