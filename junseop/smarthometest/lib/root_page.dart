import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smarthometest/login_page.dart';
import 'package:smarthometest/main_page.dart';
import 'main.dart';

class RootPage extends StatefulWidget {
  static String routeName = "/RootPage";
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  RemoteMessage? _initialMessage;

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _requestAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }


  // ✅ FCM 초기화 + 권한 + 토큰 + 푸시 핸들링
  Future<void> _initFCM() async {
    await _requestAndroidNotificationPermission();
    // 🔑 1. 알림 권한 요청 (iOS & Android 13 이상 필수)
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ 알림 권한 허용됨');
    } else {
      print('❌ 알림 권한 거부됨');
      return; // 권한 없으면 푸시 작동 안 하므로 종료
    }

    // 🔑 2. FCM 토큰 받아오기
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('📱 FCM Token: $fcmToken');

    // TODO: 서버로 토큰 전송 로직 추가 (필요시)

    // 🔔 3. 백그라운드 푸시 클릭 시
    FirebaseMessaging.onMessageOpenedApp.listen(_handlePushNavigation);

    // 🔔 4. 포그라운드 푸시 수신 시
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        await flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    // 🔁 5. 종료 상태에서 푸시 클릭
    _initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (_initialMessage != null) {
      _handlePushNavigation(_initialMessage!);
    }
  }

  // 🔄 푸시 메시지를 눌렀을 때 라우팅 처리
  void _handlePushNavigation(RemoteMessage message) {
    final type = message.data['type'];
    if (type == 'chat') {
      print("chat으로 왔어요");
      Navigator.pushNamed(context, MainPage.routeName);
      // Navigator.pushNamed(context, '/chat');
    } else if (type == 'notice') {
      // Navigator.pushNamed(context, '/myInfo');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔓 자동 로그인 제거 → 무조건 로그인 페이지로 이동
    return const LoginPage();
  }
}
