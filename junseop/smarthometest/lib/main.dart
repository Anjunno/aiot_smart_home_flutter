import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:smarthometest/home/graph/graphMain_page.dart';
import 'package:smarthometest/main_page.dart';
import 'package:smarthometest/onboarding_page.dart';
import 'package:smarthometest/providers/kakao_user_provider.dart';
import 'package:smarthometest/providers/user_provider.dart';
import 'package:smarthometest/pushNotificationLog.dart';

import 'deviceManagement/deviceManagement_page.dart';
import 'deviceManagement/groupDeviceManagement_page.dart';
import 'login_page.dart';
import 'myInfoPage.dart';
import 'root_page.dart';
import 'signUp_page.dart';
import 'tab_page.dart';
import 'chat_page.dart';
import 'outing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart'; // 이거 추가
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uni_links3/uni_links.dart';
import 'dart:async';



StreamSubscription? _linkSub;


// Navigator.of(context).popUntil((route) => route.isFirst); 위젯트리 확인해보기
// flutter run -d chrome --web-port=8080

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'default_channel', // ID
  '기본 채널', // 이름
  description: '앱에서 사용하는 기본 알림 채널입니다.',
  importance: Importance.high,
);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 백그라운드 또는 종료 상태에서 받은 메시지: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase 초기화 먼저!
  await Firebase.initializeApp();

  // ✅ 그 다음 .env 로딩
  await dotenv.load();
  await dotenv.load(fileName: ".env");

  print("현재 Kakao SDK Origin: ${await KakaoSdk.origin}");

  // ✅ FirebaseMessaging 핸들러는 초기화 이후 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  KakaoSdk.init(
    nativeAppKey: dotenv.get("NATIVE_APP_KEY"),
    javaScriptAppKey: dotenv.get("JAVASCRIPT_APP_KEY"),
  );

  // SharedPreferences 초기화
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('is_dark_mode') ?? false;

  // themeNotifier 초기값 설정
  MyApp.themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // ✅ 알림 초기화
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KaKaoUserProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,

            ).copyWith(
              primary: Colors.green,
              // 카드 등 기본 배경
              // surface: Colors.white,
              surface: Color(0xFFF0F0F0),
              // onSurface: Colors.black87,
              surfaceContainer:Colors.white,
              // surfaceContainer:Color(0xFFF0F0F0),
              secondary: Color(0x66BB6A),
            ),
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
            ChatPage.routeName: (context) => ChatPage(),
            MainPage.routeName: (context) => MainPage(),
            GraphMainPage.routeName: (context) => GraphMainPage(),
            OnboardingPage.routeName: (context) => OnboardingPage(),
            PushNotificationLog.routeName: (context) => PushNotificationLog(),
          },
        );
      },
    );
  }
}
