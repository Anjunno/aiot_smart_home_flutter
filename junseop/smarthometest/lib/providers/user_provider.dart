import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class UserProvider with ChangeNotifier {
  String? _name;

  String? get name => _name;

  // 로그인 성공 후 이 메서드 호출해서 유저 저장!
  void setUser(String name) {
    _name = name;
    notifyListeners(); // 상태가 바뀌었으니 구독 중인 위젯들한테 알림!
  }

  // 로그아웃 처리
  void clearUser() {
    _name = null;
    notifyListeners();
  }
}