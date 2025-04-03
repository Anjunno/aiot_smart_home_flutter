import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../dioRequest.dart';


// Future<List<Map<String, dynamic>>> getPushNotificationLog(BuildContext context) async {
//   final response = await dioRequest("GET", "/notification", context: context);
//   if (response == null || response.statusCode != 200) return [];
//   // JSON 문자열일 경우 파싱
//
//   print(response);
//   List<dynamic> data = response.data is String ? jsonDecode(response.data) : response.data;
//   List<Map<String, dynamic>> notificationList = data.map((item) {
//     return {
//               "sender" : item['sender'],
//               // "sender" : item['sender'],
//               "time": item['timestamp'],
//               "message": item['message']
//     };}).toList();
//
//   return notificationList;
//   // List<Map<String, dynamic>> data = [
//   //   {
//   //     "sender": "System",
//   //     "time": "2025-03-26 09:15:00",
//   //     "message": "앱 업데이트가 완료되었습니다."
//   //   },
//   //   {
//   //     "sender": "Admin",
//   //     "time": "2025-03-26 08:45:23",
//   //     "message": "오늘 정기 점검이 예정되어 있습니다."
//   //   },
//   //   {
//   //     "sender": "Scheduler",
//   //     "time": "2025-03-25 22:00:00",
//   //     "message": "예약된 기기 제어가 실행되었습니다."
//   //   },
//   //   {
//   //     "sender": "IoT Plug 1",
//   //     "time": "2025-03-25 21:59:10",
//   //     "message": "전력 사용량이 급증했습니다."
//   //   },
//   //   {
//   //     "sender": "User Notification",
//   //     "time": "2025-03-25 20:30:00",
//   //     "message": "하루 전력 사용량이 목표를 초과했습니다."
//   //   },
//   //   {
//   //     "sender": "System",
//   //     "time": "2025-03-25 19:00:00",
//   //     "message": "기기가 정상적으로 연결되었습니다."
//   //   },
//   //   {
//   //     "sender": "Security",
//   //     "time": "2025-03-25 18:12:47",
//   //     "message": "알 수 없는 기기가 접근을 시도했습니다."
//   //   },
//   //   {
//   //     "sender": "IoT Plug 2",
//   //     "time": "2025-03-25 17:10:00",
//   //     "message": "전원 제어가 완료되었습니다."
//   //   },
//   //   {
//   //     "sender": "Reminder",
//   //     "time": "2025-03-25 08:00:00",
//   //     "message": "전기요금 납부일이 다가오고 있습니다."
//   //   },
//   //   {
//   //     "sender": "Energy Monitor",
//   //     "time": "2025-03-24 23:59:59",
//   //     "message": "오늘의 전력 사용량: 12.5 kWh"
//   //   }
//   // ];
//
//   // return data;
//   // return [];
// }

Future<List<Map<String, dynamic>>> getPushNotificationLog(BuildContext context) async {
  final response = await dioRequest("GET", "/notification", context: context);
  if (response == null || response.statusCode != 200) return [];

  final data = response.data is String ? jsonDecode(response.data) : response.data;

  final sender = data['sender'];
  final List<dynamic> adviceList = data['advice'];

  final notificationList = adviceList.map<Map<String, dynamic>>((item) {
    return {
      "sender": sender,
      "time": item['timestamp'], // 여기가 문자열이라면 DateTime.parse도 가능
      // 또는 DateTime.parse(item['timestamp']) 로 변환
      "message": item['message'],
    };
  }).toList();

  return notificationList;
}
