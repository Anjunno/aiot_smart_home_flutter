import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smarthometest/toastMessage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../dioRequest.dart';


Future<List<Map<String, dynamic>>> getPushNotificationLog(BuildContext context) async {
  // final response = await dioRequest("GET", "/group/check/list", context: context);
  //
  // if (response == null || response.statusCode != 200) return [];
  //
  // // JSON 문자열일 경우 파싱
  // List<dynamic> data = response.data is String ? jsonDecode(response.data) : response.data;
  //
  // return data.map((item) => {
  //   "sender": item['sender'],
  //   "time": item['time'],
  //   "message": item['message'],
  //
  // }).toList();

  List<Map<String, dynamic>> data = [
    {
      "sender": "System",
      "time": "2025-03-26 09:15:00",
      "message": "앱 업데이트가 완료되었습니다."
    },
    {
      "sender": "Admin",
      "time": "2025-03-26 08:45:23",
      "message": "오늘 정기 점검이 예정되어 있습니다."
    },
    {
      "sender": "Scheduler",
      "time": "2025-03-25 22:00:00",
      "message": "예약된 기기 제어가 실행되었습니다."
    },
    {
      "sender": "IoT Plug 1",
      "time": "2025-03-25 21:59:10",
      "message": "전력 사용량이 급증했습니다."
    },
    {
      "sender": "User Notification",
      "time": "2025-03-25 20:30:00",
      "message": "하루 전력 사용량이 목표를 초과했습니다."
    },
    {
      "sender": "System",
      "time": "2025-03-25 19:00:00",
      "message": "기기가 정상적으로 연결되었습니다."
    },
    {
      "sender": "Security",
      "time": "2025-03-25 18:12:47",
      "message": "알 수 없는 기기가 접근을 시도했습니다."
    },
    {
      "sender": "IoT Plug 2",
      "time": "2025-03-25 17:10:00",
      "message": "전원 제어가 완료되었습니다."
    },
    {
      "sender": "Reminder",
      "time": "2025-03-25 08:00:00",
      "message": "전기요금 납부일이 다가오고 있습니다."
    },
    {
      "sender": "Energy Monitor",
      "time": "2025-03-24 23:59:59",
      "message": "오늘의 전력 사용량: 12.5 kWh"
    }
  ];

  return data;
}