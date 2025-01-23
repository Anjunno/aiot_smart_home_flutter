import 'package:flutter/material.dart';
import 'package:smarthometest/login_page.dart';
import 'package:smarthometest/myInfoPage.dart';
import 'package:smarthometest/root_page.dart';

import 'deviceManagement_page.dart';
import 'main.dart';
import 'main_page.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});
  static String routeName = "/TabPage";

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스
  bool _notificationsEnabled = true; // 푸시 알림 ON/OFF 상태

  // 각 탭에서 보여줄 페이지 목록
  List _pages = [
    MainPage(), // 홈 화면
    DevicemanagementPage(), // 기기 관리 화면
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 비활성화
        title: const Text('SmartHome'),

        // 햄버거 메뉴 버튼 (드로어 열기)
        leading: Builder(builder: (context) {
          return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu));
        }),

        // 앱바 액션 버튼 (푸시 알림 토글 + 테마 변경)
        actions: [
          IconButton(
            onPressed: () {//푸시알림 버튼 눌렀을 때
              setState(() {
                _notificationsEnabled = !_notificationsEnabled; // 푸시 알림 ON/OFF 토글
              });
            },
            icon: Icon(
              _notificationsEnabled ? Icons.notifications : Icons.notifications_off, // 아이콘 변경
            ),
          ),
          IconButton(
            onPressed: () { //테마 변경 버튼 눌렀을 때
              MyApp.themeNotifier.value =
              MyApp.themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
            icon: Icon(
              MyApp.themeNotifier.value == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          )
        ],
      ),

      // 드로어 (사이드 메뉴)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // 기본 패딩 제거
          children: [
            ListTile(
              title: const Text('내정보'),
              onTap: () {
                // '내정보' 선택 시 실행할 기능
                Navigator.pop(context);
                Navigator.pushNamed(context, MyInfoPage.routeName);
              },
            ),
            ListTile(
              title: const Text('로그아웃'),
              onTap: () {
                // 로그아웃 후 로그인 페이지로 이동
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginPage.routeName, ModalRoute.withName(RootPage.routeName));
              },
            ),
          ],
        ),
      ),

      // 현재 선택된 탭의 화면을 표시
      body: Center(
        child: _pages[_selectedIndex],
      ),

      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped, // 탭 변경 이벤트 처리
        currentIndex: _selectedIndex, // 현재 선택된 탭 표시
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_tree), label: '기기관리'),
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
