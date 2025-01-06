import 'package:flutter/material.dart';
class ThemeColor with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  void setDark(bool color) {
    _isDark = color;
    notifyListeners(); // 상태 변경을 알리기 위해 notifyListeners 호출
  }
}