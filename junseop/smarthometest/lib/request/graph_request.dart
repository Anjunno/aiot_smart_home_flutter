import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../dioRequest.dart';

///메인 파이차트
Future<List<Map<String, dynamic>>> getMainPieData(BuildContext context) async {
  final response = await dioRequest("GET", "/main/graph", context: context);

  if (response?.statusCode == 200) {
    try {
      Map<String, dynamic> decoded = jsonDecode(response?.data);
      List<dynamic> usageList = decoded['plugTotalUsage'] ?? [];
      print(usageList);

      List<Map<String, dynamic>> parsedData = usageList.map((e) {
        return {
          'name': e['plugName'] ?? 'Unknown',
          'powerUsage': (e['usage'] as num).toDouble(),
        };
      }).toList();

      double totalUsage = parsedData.fold(0.0, (sum, item) => sum + item['powerUsage']);

      List<Map<String, dynamic>> majorDevices = [];
      double etcUsage = 0.0;

      for (var device in parsedData) {
        double percent = device['powerUsage'] / totalUsage * 100;
        if (percent < 2.0) {
          etcUsage += device['powerUsage'];
        } else {
          majorDevices.add(device);
        }
      }

      // 정렬 먼저 수행
      majorDevices.sort((a, b) => (b['powerUsage'] as double).compareTo(a['powerUsage'] as double));

      // 기타는 마지막에 추가
      if (etcUsage > 0) {
        majorDevices.add({'name': '기타', 'powerUsage': etcUsage});
      }

      return majorDevices;
    } catch (e) {
      debugPrint('Error parsing plugTotalUsage: $e');
    }
  }

  return [];
}




///일별 전력량 요청
Future<List<Map<String, dynamic>>> getDayEData(BuildContext context) async {
  final response = await dioRequest("GET", "/usage/week", context: context);

  if (response?.statusCode == 200) {
    Map<String, dynamic> decoded = jsonDecode(response?.data);

    Map<String, dynamic> weekUsage = decoded['weekUsage'] ?? {};

    // 날짜 오름차순 정렬
    final sortedEntries = weekUsage.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    List<Map<String, dynamic>> dayList = sortedEntries.map((entry) {
      List<String> dateParts = entry.key.split('-');
      String formattedDate = "${int.parse(dateParts[1])}/${int.parse(dateParts[2])}";

      return {
        "date": formattedDate,
        "electricalEnergy": (entry.value as num).toDouble(), // 숫자 변환 안전 처리
      };
    }).toList();

    print("Filtered dayList: $dayList");
    return dayList;
  } else {
    return [];
  }
}

///일별 단일기기 요청
Future<List<Map<String, dynamic>>> getDayDeviceEData(BuildContext context, String deviceId) async {
  print("일별 단일기기 요청 시작");
  final response = await dioRequest("GET", "/usage/week/plug/" + deviceId, context: context);

  if (response?.statusCode == 200) {
    print("오케이");
    print(response);
    List<dynamic> data = jsonDecode(response?.data);
    // 날짜기준 오름차순
    data.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));


    List<Map<String, dynamic>> dayDeviceList = data.map((item) {
      // "t"는 "2025-03-14 00:00:00" 형식으로 되어있으므로 DateTime으로 변환
      DateTime dateTime = DateTime.parse(item['date']);
      // 날짜를 "MM/dd" 형식으로 변환
      String formattedDate = "${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}";

      return {
        "date": formattedDate,
        "electricalEnergy": item['usage']
      };
    }).toList();

    print("dayDeviceList: $dayDeviceList");
    return dayDeviceList;
  } else {
    return [];
  }
}

///월별 전력량 요청
Future<List<Map<String, dynamic>>> getMonthEData(BuildContext context) async {
  final response = await dioRequest("GET", "/usage/month", context: context);

  if (response?.statusCode == 200) {
    // 응답 데이터 파싱
    Map<String, dynamic> decoded = jsonDecode(response?.data);

    // message는 사용하지 않고 monthData만 추출
    Map<String, dynamic> monthData = decoded['monthData'] ?? {};

    // monthData Map → List<Map>으로 변환
    List<Map<String, dynamic>> monthList = monthData.entries.map((entry) {
      return {
        "month": entry.key,
        "electricalEnergy": (entry.value as num).toDouble(), // double 변환 안전하게 처리
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
    // 응답 데이터를 Map으로 파싱
    Map<String, dynamic> data = jsonDecode(response?.data);

    // plugUsageData만 추출
    List<dynamic> rawList = data['plugUsageData'];

    // usage가 0이 아닌 데이터만 필터링
    List<Map<String, dynamic>> deviceList = rawList.where((item) {
      return item['usage'] != 0;
    }).map<Map<String, dynamic>>((item) {
      return {
        "plugName": item['plugName'],
        "usage": item['usage'],
        "plugId": item['plugId']
      };
    }).toList();

    // usage 내림차순 정렬
    deviceList.sort((a, b) => b['usage'].compareTo(a['usage']));

    print("Filtered plugList: $deviceList");
    return deviceList;
  } else {
    return [];
  }
}

