import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Theme.dart';
import 'login_signUp/loginSignupPage.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Theme.dart'; // ThemeColor 클래스를 import
import 'login_signUp/loginSignupPage.dart'; // 로그인 페이지 임포트

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeColor(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeColor>( // ThemeColor를 Consumer로 감싸서 상태 변경을 반영
      builder: (context, themeColor, child) {
        return MaterialApp(
          home: LoginScreen(),
          title: "SmartHome",
          theme: themeColor.isDark
              ? ThemeData.dark() // Dark 테마
              : ThemeData.light(), // Light 테마
        );
      },
    );
  }
}
