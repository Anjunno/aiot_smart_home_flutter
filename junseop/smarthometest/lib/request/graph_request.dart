import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smarthometest/toastMessage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../dioRequest.dart';

///일별 전력량 요청
Future<List<Map<String, dynamic>>> getDayEData(BuildContext context) async{
  final response = await dioRequest("GET", "/usage/week", context: context);

  if (response?.statusCode == 200) {
    List<dynamic> data = jsonDecode(response?.data);
    List<Map<String, dynamic>> dayList = data.map((item) {

      List<String> dateParts = item['date'].split('-');
      String formattedDate = "${int.parse(dateParts[1])}/${int.parse(dateParts[2])}";

      return {
        "date": formattedDate,
        "electricalEnergy": item['usage']
      };
    }).toList();

    print("dayList: $dayList");
    return dayList;
  } else {
    return [];
  }
}

Future<List<Map<String, dynamic>>> getDayDeviceEData(BuildContext context, String deviceId) async {
  print("일별 단일기기 요청 시작");
  final response = await dioRequest("GET", "/usage/week/plug/" + deviceId, context: context);

  if (response?.statusCode == 200) {
    print("오케이");
    print(response);
    List<dynamic> data = jsonDecode(response?.data);
    List<Map<String, dynamic>> dayDeviceList = data.map((item) {
      // "t"는 "2025-03-14 00:00:00" 형식으로 되어있으므로 DateTime으로 변환
      DateTime dateTime = DateTime.parse(item['t']);
      // 날짜를 "MM/dd" 형식으로 변환
      String formattedDate = "${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}";

      return {
        "date": formattedDate,
        "electricalEnergy": item['value']
      };
    }).toList();

    print("dayDeviceList: $dayDeviceList");
    return dayDeviceList;
  } else {
    return [];
  }
}


// List<Map<String, dynamic>> getMonthEData() {
//   ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//   List<Map<String, dynamic>> data = [
//     {
//       'month': "Jan",
//       'electricalEnergy': 450
//     },
//     {
//       'month': "Feb", // 겨울
//       'electricalEnergy': 420 // 난방기 사용 지속
//     },
//     {
//       'month': "Mar", // 초봄
//       'electricalEnergy': 320 // 난방 사용 감소
//     },
//     {
//       'month': "Apr", // 봄
//       'electricalEnergy': 350 // 온화한 날씨로 전력 소비 감소
//     },
//     {
//       'month': "May", // 늦봄
//       'electricalEnergy': 400 // 날씨가 따뜻해지며 소비량 약간 증가
//     },
//     {
//       'month': "Jun", // 초여름
//       'electricalEnergy': 500 // 에어컨 사용 시작으로 소비량 증가
//     },
//     {
//       'month': "Jul", // 여름
//       'electricalEnergy': 600 // 에어컨 사용량 최대치
//     },
//     {
//       'month': "Aug", // 여름
//       'electricalEnergy': 600 // 여전히 높은 에어컨 사용량
//     },
//     {
//       'month': "Sep", // 초가을
//       'electricalEnergy': 550 // 에어컨 사용량 감소
//     },
//     {
//       'month': "Oct", // 가을
//       'electricalEnergy': 350 // 온화한 날씨로 소비량 감소
//     },
//     {
//       'month': "Nov", // 늦가을
//       'electricalEnergy': 400 // 난방기 사용 시작
//     },
//     {
//       'month': "Dec", // 겨울
//       'electricalEnergy': 480 // 난방 사용으로 소비량 증가
//     },
//   ];

//   List<Map<String, dynamic>> monthList = data.map((item) {
//     return {
//       "month": item['month'],
//       "electricalEnergy": item['electricalEnergy']
//     };
//   }).toList();
//   return monthList;
// }
///월별 전력량 요청
Future<List<Map<String, dynamic>>> getMonthEData(BuildContext context) async {
  final response = await dioRequest("GET", "/usage/month", context: context);

  if (response?.statusCode == 200) {
    List<dynamic> data = jsonDecode(response?.data);
    List<Map<String, dynamic>> monthList = data.map((item) {
      return {
        "month": item['date'],
        "electricalEnergy": item['usage']
      };
    }).toList();

    print("monthList: $monthList");
    return monthList;
  } else {
    return [];
  }
}

///일별 전력량 요청
// Future<List<Map<String, dynamic>>> getDayEData() async {
//   final url = dotenv.get("URL");
//   final storage = FlutterSecureStorage();
//   final accessToken = await storage.read(key: 'ACCESS_TOKEN');
//   final dio = Dio();
//   final response = await dio.get(url + "/usage/week/plug");
//   print("일별 요청할게");
//   if (response.statusCode == 200) {
//     List<dynamic> data = response.data as List<dynamic>;
//     List<Map<String, dynamic>> dayList = data.map((item) {
//       return {
//         "date": item['date'],
//         "electricalEnergy": item['usage']
//       };
//     }).toList();
//
//     print("dayList: $dayList");
//     return dayList;
//   } else {
//     return [];
//   }
// }

///기기별 전력량 요청
Future<List<Map<String, dynamic>>> getDeviceEData(BuildContext context) async {
  final response = await dioRequest("GET", "/usage/week/groupPlug", context: context);

  if (response?.statusCode == 200) {
    List<dynamic> data = jsonDecode(response?.data);
    print(data);
    // 첫 번째 항목(메시지)을 제외한 나머지 데이터에서 usage가 0이 아닌 것만 필터링
    List<Map<String, dynamic>> deviceList = data.skip(1).where((item) {
      return item['usage'] != 0; // usage가 0인 데이터는 제외
    }).map((item) {
      return {
        "plugName": item['plugName'],
        "usage": item['usage'],
        "plugId": item['plugId']
      };
    }).toList();
    // electricalEnergy를 기준으로 내림차순 정렬
  deviceList.sort((a, b) => b['usage'].compareTo(a['usage']));
    print("Filtered plugList: $deviceList");
    return deviceList;
  } else {
    return [];
  }
}

