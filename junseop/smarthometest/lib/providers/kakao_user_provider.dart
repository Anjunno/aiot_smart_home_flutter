import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KaKaoUserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  // 로그인 성공 후 이 메서드 호출해서 유저 저장!
  void setUser(User newUser) {
    _user = newUser;
    notifyListeners(); // 상태가 바뀌었으니 구독 중인 위젯들한테 알림!
  }

  // 로그아웃 처리
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
