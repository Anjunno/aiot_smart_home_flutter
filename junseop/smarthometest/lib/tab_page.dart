import 'package:flutter/material.dart';
import 'package:smarthometest/login_page.dart';
import 'package:smarthometest/myInfoPage.dart';
import 'package:smarthometest/toastMessage.dart';

import 'deviceManagement/deviceManagementMain_page.dart';
import 'deviceManagement/deviceManagement_page.dart';
import 'main.dart';
import 'home/main_page.dart';

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
    DevicemanagementmainPage(), // 기기 관리 화면
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary, // AppBar 배경색
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 비활성화
        centerTitle: true, // 타이틀을 중앙에 배치
        title: Text('SmartHome', style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.bold)),

        // 햄버거 메뉴 버튼 (드로어 열기)
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Icon(Icons.menu, color: colorScheme.onSecondary), // 아이콘 색을 onSecondary로 설정
          );
        }),

        // 앱바 액션 버튼 (푸시 알림 토글 + 테마 변경)
        actions: [

          //푸시알림 버튼
          IconButton(
            onPressed: () {//푸시알림 버튼 눌렀을 때
              setState(() {
                _notificationsEnabled = !_notificationsEnabled; // 푸시 알림 ON/OFF 토글
                _notificationsEnabled
                    ? showToast("푸시알림 ON")
                    : showToast("푸시알림 OFF");
              });
            },
            icon: Icon(
              _notificationsEnabled ? Icons.notifications : Icons.notifications_off, // 아이콘 변경
              color: colorScheme.onSecondary, // 아이콘 색을 onSecondary로 설정
            ),
          ),

          //테마 변경 버튼
          IconButton(
            onPressed: () {
              // 테마 변경 시 setState로 UI를 반영
              setState(() {
                MyApp.themeNotifier.value = MyApp.themeNotifier.value == ThemeMode.light
                    ? ThemeMode.dark
                    : ThemeMode.light;
              });

              // 테마 변경 후 토스트 메시지
              MyApp.themeNotifier.value == ThemeMode.light
                  ? showToast("Light mode")
                  : showToast("Dark mode");
            },
            icon: Icon(
              MyApp.themeNotifier.value == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: colorScheme.onSecondary, // 아이콘 색을 onSecondary로 설정
            ),
          )
        ],
      ),

      // 드로어 (사이드 메뉴)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // 기본 패딩 제거
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("내 이름"),
              accountEmail: Text("myEmail@naver.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/good.png'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle_rounded, color: colorScheme.onSurface,),
              title: Text('내정보', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),),
              onTap: () {
                // '내정보' 선택 시 실행할 기능
                Navigator.pop(context);
                Navigator.pushNamed(context, MyInfoPage.routeName);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.onSurface,),
              title: Text('로그아웃', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),),
              onTap: () async {
                try {
                  // 비동기 화면 전환 처리
                  await Navigator.pushNamedAndRemoveUntil(context, LoginPage.routeName, (route) => false);
                  showToast("로그아웃");
                } catch (e) {
                  // 에러 처리
                  print("로그인 화면 전환 중 오류 발생: $e");
                  showToast("로그인 중 오류가 발생했습니다.");
                }
              },
            ),
          ],
        ),
      ),

      // 현재 선택된 탭의 화면을 표시
      body: Center(
        child: _pages[_selectedIndex],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colorScheme.surfaceContainerHighest, width: 1), // 상단 테두리 색을 surfaceContainerHighest로 설정
          ),
        ),
        child: BottomNavigationBar(
          selectedLabelStyle: TextStyle(fontSize: 16), // 선택된 레이블 색상
          selectedItemColor: colorScheme.onPrimary, // 선택된 아이콘 색상
          unselectedItemColor: colorScheme.onSurface, // 선택되지 않은 아이콘 색상
          backgroundColor: colorScheme.secondary, // 하단 네비게이션 바 배경색
          onTap: _onItemTapped, // 탭 변경 이벤트 처리
          currentIndex: _selectedIndex, // 현재 선택된 탭 표시
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.electrical_services),
              label: '기기관리',
            ),
          ],
        )

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
