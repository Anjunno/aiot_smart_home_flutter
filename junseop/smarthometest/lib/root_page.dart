import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smarthometest/tab_page.dart';
import 'package:smarthometest/login_page.dart'; // 로그인 페이지 import

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  // 🔒 Secure Storage 인스턴스 생성 (iOS의 경우 Keychain 사용)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 📌 비동기 함수: Secure Storage에서 accessToken 가져오기
  Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getAccessToken(), // accessToken 가져오기
      builder: (context, snapshot) {
        // 📌 데이터 로딩 중 (비동기 작업 진행 중)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // 로딩 화면 표시
          );
        }

        // 📌 에러 발생 시 (예외 처리)
        // if (snapshot.hasError) {
        //   return const Scaffold(
        //     body: Center(child: Text('오류가 발생했습니다. 다시 시도해주세요.')),
        //   );
        // }

        // 📌 accessToken이 없으면 로그인 페이지로 이동
        if (snapshot.data == null || snapshot.hasError) {
          return const LoginPage();
        }

        // 📌 accessToken이 있으면 TabPage로 이동
        return const TabPage();
      },
    );
  }
}
