import 'package:flutter/material.dart';
import 'package:smarthometest/deviceManagement/deviceManagement_page.dart';
import 'groupDeviceManagement_page.dart';

class DevicemanagementmainPage extends StatefulWidget {
  const DevicemanagementmainPage({super.key});

  @override
  State<DevicemanagementmainPage> createState() => _DevicemanagementmainPageState();
}

class _DevicemanagementmainPageState extends State<DevicemanagementmainPage> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스

  // 각 탭에서 보여줄 페이지 목록
  List _pages = [
    DevicemanagementPage(),
    GroupDevicemanagementPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Main Page'),
      // ),
      // body: Padding(
      //   padding: EdgeInsets.fromLTRB(10, 10, 40, 10), // 모든 방향에 10씩 패딩 추가
      //   child: _pages[_selectedIndex],
      // ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        onTap: _onItemTapped, // 탭 변경 이벤트 처리
        currentIndex: _selectedIndex, // 현재 선택된 탭 표시
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.toggle_on), label: '기기제어'),
          BottomNavigationBarItem(icon: Icon(Icons.account_tree), label: '그룹 기기제어'),
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