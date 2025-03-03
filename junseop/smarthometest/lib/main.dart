import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smarthometest/deviceManagement/deviceManagement_page.dart';
import 'package:smarthometest/login_page.dart';
import 'package:smarthometest/myInfoPage.dart';
import 'package:smarthometest/root_page.dart';
import 'package:smarthometest/signUp_page.dart';
import 'package:smarthometest/tab_page.dart';

import 'deviceManagement/groupDeviceManagement_page.dart';
import 'outing_page.dart';
// Navigator.of(context).popUntil((route) => route.isFirst); 위젯트리 확인해보기
Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 테마 변경을 위한 ValueNotifier
  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier, // 테마 변경 감지를 위한 리스너
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true, // Material3 적용
          ),
          darkTheme: ThemeData.dark(), // 다크 모드 테마 설정
          themeMode: currentMode, // 현재 테마 모드 적용
          home: RootPage(), // 초기 페이지 설정
          routes: {
            LoginPage.routeName: (context) => LoginPage(),
            RootPage.routeName: (context) => RootPage(),
            TabPage.routeName: (context) => TabPage(),
            SignUpPage.routeName: (context) => SignUpPage(),
            DevicemanagementPage.routeName: (context) => DevicemanagementPage(),
            GroupDevicemanagementPage.routeName: (context) => GroupDevicemanagementPage(),
            MyInfoPage.routeName: (context) => MyInfoPage(),
            OutingPage.routeName: (context) => OutingPage(),
          },
        );
      },
    );
  }
}

// @override
// Widget build(BuildContext context) {
//   return MaterialApp(
//     title: 'Flutter Demo',
//     theme: ThemeData(
//       colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       useMaterial3: true,
//     ),
//     home: RootPage(),  // 초기 페이지 설정
//     routes: {
//       LoginPage.routeName: (context) => LoginPage(),
//       RootPage.routeName: (context) => RootPage(),
//       TabPage.routeName: (context) => TabPage(),
//       SignUpPage.routeName: (context) => SignUpPage(),
//       DevicemanagementPage.routeName: (context) => DevicemanagementPage(),
//     },
//   );
// }