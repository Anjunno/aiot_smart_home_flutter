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
  final PageController _pageController = PageController(); // 페이지 컨트롤러 생성

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController, // PageView에 컨트롤러 연결
        onPageChanged: (index) {
          // 스와이프 시 현재 페이지 인덱스 변경
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          DevicemanagementPage(), // 기기 제어 페이지
          GroupDevicemanagementPage(), // 그룹 기기 제어 페이지
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          BottomNavigationBarItem(icon: Icon(Icons.toggle_on), label: '기기제어'), // 기기 제어 탭
          BottomNavigationBarItem(icon: Icon(Icons.account_tree), label: '그룹 기기제어'), // 그룹 기기 제어 탭
        ],
      ),
    );
  }
}