import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String message, {ToastGravity gravity = ToastGravity.BOTTOM, Toast toastLength = Toast.LENGTH_SHORT}) {
  Fluttertoast.showToast(
    msg: message,
    gravity: gravity,
    toastLength: toastLength, // 사용자가 지정한 길이
    backgroundColor: Colors.black54,
  );
}

// // 기본적으로 하단에 짧게 표시됨
// showToast("기본 토스트 메시지");
//
// // 상단에 표시하고 싶을 때
// showToast("상단 메시지", gravity: ToastGravity.TOP);
//
// // 중앙에 표시하고 싶을 때
// showToast("중앙 메시지", gravity: ToastGravity.CENTER);