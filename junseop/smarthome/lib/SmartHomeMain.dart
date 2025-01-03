import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:smarthome/powerGraph.dart';
import 'deviceManagement/deviceManagement.dart';

class SmartHomeMain extends StatefulWidget {
  const SmartHomeMain({super.key});
  @override
  State<SmartHomeMain> createState() => _SmartHomeMainState();
}
class _SmartHomeMainState extends State<SmartHomeMain> {
  int _selectedIndex = 0;
  // 각 탭에 대응하는 화면을 리스트로 생성
  final List<Widget> _screens = [
    const MainPage(),   // 메인 페이지
    const DeviceManagement(), //기기관리 페이지
  ];
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: const Text('Smart Home'),
          automaticallyImplyLeading: false,//이전 화살표 지우기
      ),

      // 메인 화면 레이아웃 구성
      body:_screens[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navBarItems,
      ),
    );
  }
  final _navBarItems = [
    SalomonBottomBarItem(
      icon: const Icon(Icons.home),
      title: const Text("Home"),
      selectedColor: Colors.purple,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.settings_outlined),
      title: const Text("기기 관리"),
      selectedColor: Colors.pink,
    ),
  ];
}