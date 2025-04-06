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
Future<Map<String, dynamic>> getDayEData(BuildContext context) async {
  final response = await dioRequest("GET", "/usage/week", context: context);

  if (response?.statusCode == 200) {
    Map<String, dynamic> decoded = jsonDecode(response?.data);
    Map<String, dynamic> weekUsage = decoded['weekUsage'] ?? {};

    // 날짜 오름차순 정렬
    final sortedEntries = weekUsage.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // 날짜 포맷 변경 및 리스트 변환
    List<Map<String, dynamic>> usageList = sortedEntries.map((entry) {
      List<String> dateParts = entry.key.split('-');
      String formattedDate = "${int.parse(dateParts[1])}/${int.parse(dateParts[2])}"; // MM/DD

      return {
        "date": formattedDate,
        "electricalEnergy": (entry.value as num).toDouble(),
      };
    }).toList();

    return {
      "advice": decoded["advice"]?.toString().replaceAll('"', ''),
      "electricalEnergy": usageList,
    };
  } else {
    return {
      "advice": "",
      "electricalEnergy": [],
    };
  }
}

///일별 단일기기 요청
Future<Map<String, dynamic>> getDayDeviceEData(BuildContext context, String deviceId) async {
  print("일별 단일기기 요청 시작");
  final response = await dioRequest("GET", "/usage/week/plug/$deviceId", context: context);

  if (response?.statusCode == 200) {
    print("오케이");
    Map<String, dynamic> decoded = jsonDecode(response?.data);

    // usage가 문자열 형태의 JSON이므로 다시 디코딩
    List<dynamic> data = jsonDecode(decoded['usage']);

    // 날짜 기준 정렬
    data.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));

    List<Map<String, dynamic>> dayDeviceList = data.map((item) {
      DateTime dateTime = DateTime.parse(item['date']);
      String formattedDate = "${dateTime.month}/${dateTime.day}";

      return {
        "date": formattedDate,
        "electricalEnergy": (item['usage'] as num).toDouble(),
      };
    }).toList();

    return {
      "advice": decoded["advice"]?.toString().replaceAll('"', ''),
      "electricalEnergy": dayDeviceList,
    };
  } else {
    return {
      "advice": "",
      "electricalEnergy": [],
    };
  }
}


///월별 전력량 요청
Future<Map<String, dynamic>> getMonthEData(BuildContext context) async {
  final response = await dioRequest("GET", "/usage/month", context: context);

  if (response?.statusCode == 200) {
    // 응답 데이터 파싱
    Map<String, dynamic> decoded = jsonDecode(response?.data);

    Map<String, dynamic> monthData = decoded['monthData'] ?? {};

    // monthData Map → List<Map>으로 변환
    List<Map<String, dynamic>> monthList = monthData.entries.map((entry) {
      return {
        "month": entry.key, // 예: "2024-12"
        "electricalEnergy": (entry.value as num).toDouble(),
      };
    }).toList();

    // 정렬이 필요하다면 (최신순/오름차순)
    monthList.sort((a, b) => a["month"].compareTo(b["month"]));

    return {
      "advice": decoded["advice"]?.toString().replaceAll('"', '') ?? "",
      "monthUsage": monthList,
    };
  } else {
    return {
      "advice": "",
      "monthUsage": [],
    };
  }
}



///기기별 전력량 요청
Future<Map<String, dynamic>> getDeviceEData(BuildContext context) async {
  final response = await dioRequest("GET", "/usage/week/groupPlug", context: context);

  if (response?.statusCode == 200) {
    Map<String, dynamic> decoded = jsonDecode(response?.data);

    List<dynamic> rawList = decoded['plugUsageData'] ?? [];

    // usage가 0이 아닌 항목만 필터링
    List<Map<String, dynamic>> deviceList = rawList.where((item) {
      return item['usage'] != 0;
    }).map<Map<String, dynamic>>((item) {
      return {
        "plugName": item['plugName'],
        "usage": (item['usage'] as num).toDouble(), // 안전한 double 변환
        "plugId": item['plugId'],
      };
    }).toList();

    // usage 내림차순 정렬
    deviceList.sort((a, b) => b['usage'].compareTo(a['usage']));

    return {
      "advice": decoded['advice']?.toString().replaceAll('"', ''),
      "plugUsageData": deviceList,
    };
  } else {
    return {
      "advice": "",
      "plugUsageData": [],
    };
  }
}


