import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;

Future<String> initFCM() async {
  await messaging.requestPermission();

  String? token = await messaging.getToken();
  print("FCM Token: $token");

  if (token == null) {
    throw Exception("FCM 토큰을 가져오지 못했습니다.");
  }

  return token;
}



class PushTest extends StatefulWidget {
  static String routeName = "/PushTest";
  const PushTest({super.key});

  
  
  @override
  State<PushTest> createState() => _PushTestState();
}



class _PushTestState extends State<PushTest> {
  String _token = '토큰을 불러오는 중...';

  @override
  void initState() {
    super.initState();
    _init(); // async 함수 분리
  }

  Future<void> _init() async {
    String token = await initFCM();
    setState(() {
      _token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(_token),
      ),
    );
  }
}