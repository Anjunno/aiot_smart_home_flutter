import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'graph/dayGraph.dart';
import 'graph/deviceGraph.dart';
import 'graph/monthGraph.dart';
import 'Theme.dart'; // 테마 상태 관리 클래스를 추가

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // _selectedIndex를 클래스 필드로 선언

  // 각 탭에 대응하는 화면을 리스트로 생성
  final List<Widget> _graphScreens = [
    const DeviceGraph(),
    const DayGraph(),
    const MonthGraph(),
  ];

  @override
  Widget build(BuildContext context) {
    // 테마 상태를 가져오기
    final themeColor = Provider.of<ThemeColor>(context);

    // 테마에 맞는 색상 설정
    Color activeColor = themeColor.isDark ? Colors.green : Colors.green;
    Color inactiveColor = themeColor.isDark ? Colors.grey : Colors.grey;

    // 화면의 전체 높이를 가져옴
    final double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.8, // 화면의 0.8만 차지
      margin: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
      decoration: BoxDecoration(
        color: themeColor.isDark ? Colors.black87 : Colors.grey[200], // 배경 색상
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          // 선택된 화면을 표시하는 부분
          Expanded(
            child: _graphScreens[_selectedIndex],
          ),
          // 네비게이션 버튼들이 들어가는 컨테이너
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: themeColor.isDark ? Colors.black87 : Colors.grey[200],  // 배경 색상
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 버튼 또는 아이콘으로 네비게이션 가능
                _buildNavButton(Icons.electric_bolt, "기기별 전력량", 0, activeColor, inactiveColor),
                _buildNavButton(Icons.access_time, "일별 전력량", 1, activeColor, inactiveColor),
                _buildNavButton(Icons.calendar_month, "월별 전력량", 2, activeColor, inactiveColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 네비게이션 버튼을 만드는 메서드 (테마에 맞는 색상 적용)
  Widget _buildNavButton(IconData icon, String label, int index, Color activeColor, Color inactiveColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index; // 상태 변경
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? activeColor : inactiveColor,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
