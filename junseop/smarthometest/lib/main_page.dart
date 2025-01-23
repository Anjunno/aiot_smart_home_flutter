import 'package:flutter/material.dart';
import 'package:smarthometest/dayGraph.dart';
import 'package:smarthometest/monthGraph.dart';

import 'deviceGraph.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스

  // 각 탭에서 보여줄 페이지 목록
  List _pages = [
    DeviceGraph(), // 기기별 전력량 그래프
    DayGraph(), // 일별 전력량 그래프
    MonthGraph(), // 일별 전력량 그래프
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Main Page'),
      // ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped, // 탭 변경 이벤트 처리
        currentIndex: _selectedIndex, // 현재 선택된 탭 표시
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.electric_bolt), label: '기기'),
          BottomNavigationBarItem(icon: Icon(Icons.account_tree), label: '일별'),
          BottomNavigationBarItem(icon: Icon(Icons.ac_unit), label: '월별'),
        ],
      ),
    );
  }


  // 탭 아이템 선택 시 실행되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}


