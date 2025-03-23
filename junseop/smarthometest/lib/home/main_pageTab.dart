import 'package:flutter/material.dart';
import 'package:smarthometest/home/graph/graphMain_page.dart';
import 'package:smarthometest/home/graph/dayGraph.dart';
import 'package:smarthometest/main_page.dart';
import 'package:smarthometest/home/graph/monthGraph.dart';
import 'graph/deviceGraph.dart';

class MainPageTab extends StatefulWidget {
  const MainPageTab({super.key});

  @override
  State<MainPageTab> createState() => _MainPageTabState();
}

class _MainPageTabState extends State<MainPageTab> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스
  final PageController _pageController = PageController(); // 페이지 컨트롤러 생성

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController, // PageView에 컨트롤러 연결
              onPageChanged: (index) {
                // 스와이프 시 현재 페이지 인덱스 변경
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: const [
                MainPageTab(),
                GraphMainPage(),
                // DeviceGraph(), // 기기별 전력량 그래프 페이지
                // DayGraph(), // 일별 전력량 그래프 페이지
                // MonthGraph(), // 월별 전력량 그래프 페이지
              ],
            ),
          ),
          BottomNavigationBar(
            selectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            // selectedLabelStyle: TextStyle(fontSize: 16), // 선택된 레이블 색상
            // selectedItemColor: Theme.of(context).colorScheme.onPrimary, // 선택된 아이콘 색상
            // unselectedItemColor: Theme.of(context).colorScheme.onSurface, // 선택되지 않은 아이콘 색상
            // backgroundColor: Theme.of(context).colorScheme.secondary, // 하단 네비게이션 바 배경색
            onTap: (index) {
              // 네비게이션 바 아이템 클릭 시 페이지 이동
              setState(() {
                _selectedIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간 설정
                curve: Curves.easeInOut, // 애니메이션 곡선 설정
              );
            },
            currentIndex: _selectedIndex, // 현재 선택된 인덱스 설정
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'), // 기기별 탭
              BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: '그래프'), // 기기별 탭
              // BottomNavigationBarItem(icon: Icon(Icons.schedule), label: '일별'), // 일  별 탭
              // BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: '월별'), // 월별 탭
            ],
          ),
        ],
      ),
    );
  }
}
