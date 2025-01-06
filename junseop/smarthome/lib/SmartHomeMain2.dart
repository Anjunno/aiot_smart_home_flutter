import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:smarthome/powerGraph.dart';
import 'Theme.dart';
import 'deviceManagement/deviceManagement.dart';
import 'icon/profileIcon.dart'; // ThemeColor 클래스를 import하여 테마 상태 관리

class SmartHomeMain2 extends StatefulWidget {
  // SmartHomeMain2 위젯의 생성자
  SmartHomeMain2({super.key});

  @override
  State<SmartHomeMain2> createState() => _SmartHomeMain2State();
}

class _SmartHomeMain2State extends State<SmartHomeMain2> {
  // Scaffold 상태를 관리할 GlobalKey
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // 각 탭에 대응하는 화면을 리스트로 생성
  final List<Widget> _screens = [
    const MainPage(),   // 메인 페이지
    const DeviceManagement(), //기기관리 페이지
  ];
  @override
  Widget build(BuildContext context) {
    // 화면의 너비를 가져와서 큰 화면과 작은 화면을 구분
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 800; // 화면 너비가 800보다 크면 큰 화면으로 간주

    return Consumer<ThemeColor>( // ThemeColor를 소비하여 테마 상태를 관리
      builder: (context, themeColor, child) {
        return Scaffold(
          key: _scaffoldKey, // GlobalKey로 Scaffold 상태 관리
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent, // AppBar 배경을 투명으로 설정
            elevation: 0, // 그림자 없음
            titleSpacing: 0, // 제목 여백 없음
            leading: isLargeScreen
                ? null // 큰 화면에서는 메뉴 버튼 표시 안함
                : IconButton(
              icon: const Icon(Icons.menu), // 작은 화면에서는 메뉴 버튼
              onPressed: () => _scaffoldKey.currentState?.openDrawer(), // 메뉴 버튼 클릭 시 Drawer 열기
            ),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // 제목에 좌우 여백 추가
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // 제목을 화면 가운데 정렬
                children: [
                  const Text(
                    "SmartHome", // 로고 텍스트
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  if (isLargeScreen) Expanded(child: _navBarItems()) // 큰 화면에서 네비게이션 항목을 표시
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0), // 오른쪽 여백 추가
                child: IconButton(
                  icon: Icon(themeColor.isDark ? Icons.wb_sunny : Icons.nightlight_round), // 테마에 따라 아이콘 변경
                  onPressed: () {
                    // 테마 변경 버튼 클릭 시
                    themeColor.setDark(!themeColor.isDark); // 테마 상태 반전
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16.0), // 오른쪽 여백 추가
                child: CircleAvatar(child: ProfileIcon()), // 프로필 아이콘
              ),
            ],
          ),
          drawer: isLargeScreen ? null : _drawer(), // 큰 화면에서는 Drawer를 사용하지 않음
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
            items: _navBarItemss,
          ),
        );
      },
    );
  }

  // 작은 화면에서 사용할 Drawer 정의
  Widget _drawer() => Drawer(
    child: ListView(
      children: _menuItems
          .map((item) => ListTile(
        onTap: () {
          // 항목을 눌렀을 때 Drawer를 닫음
          _scaffoldKey.currentState?.openEndDrawer();
        },
        title: Text(item), // 메뉴 항목 텍스트
      ))
          .toList(),
    ),
  );

  // 네비게이션 바의 항목들을 정의
  Widget _navBarItems() => Row(
    mainAxisAlignment: MainAxisAlignment.end, // 항목들을 오른쪽으로 정렬
    crossAxisAlignment: CrossAxisAlignment.center,
    children: _menuItems
        .map(
          (item) => InkWell(
        onTap: () {}, // 항목 클릭 시 행동 정의
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
          child: Text(
            item, // 항목 텍스트
            style: const TextStyle(fontSize: 18), // 폰트 크기 설정
          ),
        ),
      ),
    )
        .toList(),
  );
}
// 하단 네비게이션 바의 항목
final _navBarItemss = [
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
// 네비게이션 메뉴 항목 리스트
final List<String> _menuItems = <String>[
  'About',
  'Contact',
  'Settings',
  'Sign Out',
];
