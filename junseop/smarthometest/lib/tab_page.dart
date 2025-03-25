import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:smarthometest/chat_page.dart';
import 'package:smarthometest/home/graph/graphMain_page.dart';
import 'package:smarthometest/main_page.dart';
import 'package:smarthometest/login_page.dart';
import 'package:smarthometest/myInfoPage.dart';
import 'package:smarthometest/onboarding_page.dart';
import 'package:smarthometest/outing_page.dart';
import 'package:smarthometest/providers/kakao_user_provider.dart';
import 'package:smarthometest/providers/user_provider.dart';
import 'package:smarthometest/pushNotificationLog.dart';
import 'package:smarthometest/toastMessage.dart';

import 'deviceManagement/deviceManagementMain_page.dart';
import 'main.dart';
import 'home/main_pageTab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});
  static String routeName = "/TabPage";

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int _selectedIndex = 0;
  bool _notificationsEnabled = true;
  late PageController _pageController; // 페이지 컨트롤러 추가

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _loadNotificationState();
  }

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ///푸시알림 상태 불러오기
  Future<void> _loadNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  ///푸시알림 상태 저장
  Future<void> _saveNotificationState(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', isEnabled);
  }

  ///테마상태
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', mode == ThemeMode.dark);
  }


  // 토큰 삭제 함수
  Future<void> _removeTokens() async {
    try {
      await _secureStorage.delete(key: 'ACCESS_TOKEN');
      await _secureStorage.delete(key: 'REFRESH_TOKEN');
      showToast("토큰이 제거되었습니다.");
    } catch (e) {
      print("토큰 제거 중 오류 발생: $e");
      showToast("토큰 제거 중 오류 발생.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final kakaoUserProvider = Provider.of<KaKaoUserProvider>(context);
    final kakaoUser = kakaoUserProvider.user;
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.name;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('SmartHome',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.bold)),
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Icon(Icons.menu, color: colorScheme.onSecondary),
          );
        }),
        actions: [
          IconButton(
            onPressed: () async {
              await _removeTokens();
              showToast("토큰제거 완료.");
            },
            icon: Icon(
              Icons.logout,
              color: colorScheme.onSecondary,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _notificationsEnabled = !_notificationsEnabled;
                _saveNotificationState(_notificationsEnabled);
                _notificationsEnabled
                    ? showToast("푸시알림 ON")
                    : showToast("푸시알림 OFF");
              });
            },
            icon: Icon(
              _notificationsEnabled
                  ? Icons.notifications
                  : Icons.notifications_off,
              color: colorScheme.onSecondary,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                MyApp.themeNotifier.value =
                MyApp.themeNotifier.value == ThemeMode.light
                    ? ThemeMode.dark
                    : ThemeMode.light;
                _saveThemeMode(MyApp.themeNotifier.value);
              });

              MyApp.themeNotifier.value == ThemeMode.light
                  ? showToast("Light mode")
                  : showToast("Dark mode");
            },
            icon: Icon(
              MyApp.themeNotifier.value == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: colorScheme.onSecondary,
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                  kakaoUser?.kakaoAccount?.profile?.nickname
                      ?? (user ?? "사용자").toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              accountEmail: Text(
                kakaoUser?.kakaoAccount?.email ?? '이메일 정보가 없습니다!',
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: kakaoUser?.kakaoAccount?.profile?.profileImageUrl !=
                    null
                    ? NetworkImage(
                    kakaoUser!.kakaoAccount!.profile!.profileImageUrl!)
                    : const AssetImage('assets/good.png') as ImageProvider,
                backgroundColor: colorScheme.onSecondary,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.account_circle_rounded,
                color: colorScheme.onSurface,
              ),
              title: Text(
                '내정보',
                style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, MyInfoPage.routeName);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.help,
                color: colorScheme.onSurface,
              ),
              title: Text(
                '사용방법',
                style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, OnboardingPage.routeName);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.chat,
                color: colorScheme.onSurface,
              ),
              title: Text(
                '채팅',
                style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, ChatPage.routeName);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.chat,
                color: colorScheme.onSurface,
              ),
              title: Text(
                '푸시알림 내역',
                style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, PushNotificationLog.routeName);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: colorScheme.onSurface,
              ),
              title: Text(
                '로그아웃',
                style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                try {
                  userProvider.clearUser();
                  kakaoUserProvider.clearUser();
                  await Navigator.pushNamedAndRemoveUntil(
                      context, LoginPage.routeName, (route) => false);
                  showToast("로그아웃");
                } catch (e) {
                  print("로그인 화면 전환 중 오류 발생: $e");
                  showToast("로그인 중 오류가 발생했습니다.");
                }
              },
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          MainPage(),
          GraphMainPage(),
          DevicemanagementmainPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
                color: colorScheme.surfaceContainerHighest, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          selectedLabelStyle: TextStyle(fontSize: 16),
          selectedItemColor: colorScheme.onPrimary,
          unselectedItemColor: colorScheme.onSurface,
          backgroundColor: colorScheme.secondary,
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_graph),
              label: '그래프',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.electrical_services),
              label: '기기관리',
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
