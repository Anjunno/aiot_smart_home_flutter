import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smarthometest/toastMessage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../dioRequest.dart';


///기기 on/off
// Future<Map<String, dynamic>?> onOff(String deviceName, String onOff) async {
// Future<bool> onOffDevice(String deviceId, String onOff) async {
//   final url = dotenv.get("URL");
//   final dio = Dio();
//   Map<String, dynamic> data = {
//     "action": onOff
//   };
//
//   try {
//     final response = await dio.post(url + "/control/device/" + deviceId, data: data);
//
//     if (response.statusCode == 200) {
//       final responseData = response.data;
//       if (responseData != null && responseData['status'] == 'success') {
//         print("기기 ${onOff == 'on' ? '켜짐' : '꺼짐'}: $deviceId");
//         return true; // 성공 시 true 반환
//       } else {
//         print("기기 상태 변경 실패: ${responseData['message']}");
//         return false; // 실패 시 false 반환
//       }
//     } else {
//       print("요청 실패: ${response.statusCode}");
//       return false; // 실패 시 false 반환
//     }
//   } catch (e) {
//     print("에러 발생: $e");
//     return false; // 에러 발생 시 false 반환
//   }
// }
Future<bool> onOffDevice(BuildContext context, String deviceId, String onOff) async {
  print("---------------기기제어 요청 시작---------------------");
  final response = await dioRequest("POST", "/control/device/$deviceId", data: {"action": onOff}, context: context);
  print("기기 제어 요청 결과앙 : $response?.data");
  if (response?.statusCode == 200) {
  // if (response != null && response.statusCode == 200 && response.data['status'] == 'success') {
    print("기기 ${onOff == 'on' ? '켜짐' : '꺼짐'}: $deviceId");
    return true;
  }
  print("기기 상태 변경 실패: ${response?.data['message'] ?? '알 수 없는 오류'}");
  return false;
}



///그룹 리스트 요청
// Future<List<Map<String, dynamic>>> getGroupList() async {
//   final url = dotenv.get("URL");
//   final storage = FlutterSecureStorage();
//   final accessToken = await storage.read(key: 'ACCESS_TOKEN');
//   print("엑세스토큰은 : $accessToken");
//   final dio = Dio();
//   // dio.options.headers = {
//   //   'Authorization': 'Bearer $accessToken',
//   //   'Content-Type': 'application/json',
//   // };
//   final response = await dio.get(url + "/group/check/list");
//
//   if (response.statusCode == 200) {
//     List<dynamic> data = response.data as List<dynamic>;
//     List<Map<String, dynamic>> groupList = data.map((item) {
//       return {
//         "groupId": item['groupId'],
//         "groupName": item['groupName'],
//         "creationTime": item['creationTime'],
//       };
//     }).toList();
//
//     print("GroupList: $groupList");
//     return groupList;
//   } else {
//     return [];
//   }
// }
Future<List<Map<String, dynamic>>> getGroupList(BuildContext context) async {
  final response = await dioRequest("GET", "/group/check/list", context: context);

  if (response == null || response.statusCode != 200) return [];

  if (response.data == null) return [];

  if (response.data is String) {
    String responseString = response.data.trim();

    // 비어있는 문자열일 경우 빈 리스트 반환
    if (responseString.isEmpty) {
      print("응답이 빈 문자열입니다.");
      return [];
    }

    try {
      final decoded = jsonDecode(responseString);

      if (decoded is List) {
        return decoded.map<Map<String, dynamic>>((item) => {
          "groupId": item['groupId'],
          "groupName": item['groupName'],
          "creationTime": item['creationTime'],
        }).toList();
      } else {
        print("예상과 다른 데이터 타입입니다: ${decoded.runtimeType}");
        return [];
      }
    } catch (e) {
      print("jsonDecode 실패: $e");
      return [];
    }
  }

  if (response.data is List) {
    return (response.data as List).map<Map<String, dynamic>>((item) => {
      "groupId": item['groupId'],
      "groupName": item['groupName'],
      "creationTime": item['creationTime'],
    }).toList();
  }

  print("예상하지 못한 데이터 타입입니다: ${response.data.runtimeType}");
  return [];
}


///그룹 이름 생성
// //그룹 이름 생성
// Future<void> createGroup(String groupName) async {
//   final url = dotenv.get("URL");
//   final storage = FlutterSecureStorage();
//   final accessToken = await storage.read(key: 'ACCESS_TOKEN');
//   final dio = Dio();
//   Map<String, dynamic> data = {
//     "groupName": groupName + " 그룹"
//   };
//   final response = await dio.post(url + "/group/create", data: data);
//   if (response.statusCode == 200) {
//     print("그룹 생성 성공: $groupName");
//   } else {
//     print("그룹 생성 실패: ${response.statusCode}");
//   }
// }
Future<void> createGroup(BuildContext context, String groupName) async {
  final response = await dioRequest("POST", "/group/create", data: {"groupName": "$groupName 그룹"}, context: context);
  if (response?.statusCode == 200) {
    print("그룹 생성 성공: $groupName");
    showToast("그룹 생성 완료", gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_SHORT);
  } else {
    print("그룹 생성 실패: ${response?.statusCode ?? '네트워크 오류'}");
  }
}

///그룹 액션 설정
//그룹 액션 설정
// Future<void> groupAction(Map<String, dynamic> groupData) async {
//   final url = dotenv.get("URL");
//   final storage = FlutterSecureStorage();
//   final accessToken = await storage.read(key: 'ACCESS_TOKEN');
//   final dio = Dio();
//   final response = await dio.post(url + "/group/action/add", data: groupData);
//   if (response.statusCode == 200) {
//     print("그룹 액션 추가 성공: $groupData");
//   } else {
//     print("그룹 액션 추가 실패: ${response.statusCode}");
//   }
// }
Future<void> groupAction(BuildContext context, Map<String, dynamic> groupData) async {
  final response = await dioRequest("PUT", "/group/action/edit", data: groupData, context: context);

  if (response?.statusCode == 200) {
    print("그룹 액션 추가 성공: $groupData");
    showToast("그룹 설정 완료", gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_SHORT);
  } else {
    print("그룹 액션 추가 실패: ${response?.statusCode ?? '네트워크 오류'}");
  }
}


///그룹 액션 확인
//그룹 액션 확인
// Future<List<Map<String, dynamic>>> groupActionCheck(groupId) async {
//   final url = dotenv.get("URL");
//   final storage = FlutterSecureStorage();
//   final accessToken = await storage.read(key: 'ACCESS_TOKEN');
//   final dio = Dio();
//
//   try {
//     // groupId가 int 타입일 경우 toString()으로 변환
//     final response = await dio.get(url + "/group/action/check/" + groupId.toString());
//
//     if (response.statusCode == 200) {
//       // JSON 데이터를 List<dynamic>으로 변환
//       List<dynamic> data = jsonDecode(response.data);
//       print(data);
//       // Map으로 변환
//       List<Map<String, dynamic>> groupAction = data.map((item) {
//         return {
//           "groupId": item['groupId'],
//           "groupName": item['groupName'],
//           "plug": (item['plug'] as List).map((plug) {
//             return {
//               "plugId": plug['plugId'],
//               "plugName": plug['plugName'],
//               "plugControl": plug['plugControl'],
//             };
//           }).toList(),
//         };
//       }).toList();
//
//
//       print("groupAction 내용:\n$groupAction");
//       return groupAction;
//     } else {
//       print("응답 오류: ${response.statusCode}");
//       return [];
//     }
//   } catch (e) {
//     print("예외 발생: $e");
//     return [];
//   }
// }
Future<List<Map<String, dynamic>>> groupActionCheck(BuildContext context, int groupId) async {
  final response = await dioRequest("GET", "/group/action/check/$groupId", context: context);
  if (response == null || response.statusCode != 200) return [];

  List<dynamic> data = response.data is String ? jsonDecode(response.data) : response.data;
  return data.map((item) => {
    "groupId": item['groupId'],
    "groupName": item['groupName'],
    "plug": List<Map<String, dynamic>>.from(
        (item['plug'] as List).map((plug) => {
          "plugId": plug['plugId'],
          "plugName": plug['plugName'],
          "plugControl": plug['plugControl'],
        })
    ),
  }).toList();
}

///그룹 액션 실행
Future<Map<String, dynamic>> groupActionRun(BuildContext context, int groupId) async {

  final response = await dioRequest("GET", "/group/action/run/$groupId", context: context);

  if (response == null || response.statusCode != 200) {
    showToast("그룹 설정이 필요합니다.", gravity: ToastGravity.CENTER);
    print("그룹 액션 실패: ${response?.statusCode}");
    return {
      "successCount": -1,
      "errorCount": 0,
      "successArray": [],
      "errorArray": [],
    };
  }

  final data = response.data is String ? jsonDecode(response.data) : response.data;

  // successCount와 errorCount가 String이면 int로 변환
  int successCount = data["successCount"] is String
      ? int.parse(data["successCount"])
      : data["successCount"];

  int errorCount = data["errorCount"] is String
      ? int.parse(data["errorCount"])
      : data["errorCount"];

  List<String> successArray = List<String>.from(data["successArray"] ?? []);
  List<String> errorArray = List<String>.from(data["errorArray"] ?? []);

  if (successCount != 0 || errorCount != 0) {
    // 필요시 메시지 출력
    // String message =
    //     "✅ 성공한 기기 ($successCount개):\n${successArray.join(", ")}\n\n"
    //     "❌ 실패한 기기 ($errorCount개):\n${errorArray.isNotEmpty ? errorArray.join(", ") : "없음"}";
    // showToast(message, gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_LONG);
    return {
      "successCount": successCount,
      "errorCount": errorCount,
      // "errorCount": 2,
      "successArray": successArray,
      "errorArray": errorArray,
      // "errorArray": ["오프라인 플러그","오프라인 플러그2"],
    };
  } else {
    showToast("그룹 설정이 필요합니다.",
        gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_LONG);

    return {
      "successCount": -1,
      "errorCount": 0,
      "successArray": [],
      "errorArray": [],
    };
  }
}





///기기 리스트 요청
// Future<List<Map<String, dynamic>>> getDeviceList() async {
//   final url = dotenv.get("URL");
//   print(url);
//   final storage = new FlutterSecureStorage();
//   final accessToken = await storage.read(key: 'ACCESS_TOKEN');
//   final dio = Dio();
//
//   final response = await dio.get(url + "/check/plugList");
//
//   if (response.statusCode == 200) {
//     List<dynamic> data = jsonDecode(response.data);
//     List<Map<String, dynamic>> deviceList = data.map((item) {
//       return {
//         "curVoltage": item['curVoltage'], //raw 전력 V
//         "curPower": item['curPower'], //raw 전력 W
//         "curCurrent": item['curCurrent'], //현재 전류 mA
//         "name": item['name'], //플러그 명
//         "online": item['online'], //온라인 여부(네트워크 연결 여부)
//         "id": item['id'], //기기 고유 기기값
//         "power": item['power'], //전원 on / off 여부
//       };
//     }).toList();
//     return deviceList;
//   } else {
//     return [];
//   }
// }
///기기 리스트 요청
Future<List<Map<String, dynamic>>> getDeviceList(BuildContext context) async {
  final response = await dioRequest("GET", "/check/plugList", context: context);

  if (response == null || response.statusCode != 200) return [];

    // JSON 문자열일 경우 파싱
    List<dynamic> data = response.data is String ? jsonDecode(response.data) : response.data;

    return data.map((item) => {
      "curVoltage": item['curVoltage'],
      "curPower": item['curPower'],
      "curCurrent": item['curCurrent'],
      "name": item['name'],
      "online": item['online'],
      "id": item['id'],
      "power": item['power'],
    }).toList();
}

///그룹 삭제
Future<void> groupDelete(BuildContext context, int groupId) async {
  print("그룹 아이디는 : $groupId");
  final response = await dioRequest("DELETE", "/group/remove/$groupId", context: context);

  if (response == null || response.statusCode != 200) {
    print("그룹이 존재하지 않습니다.: ${response?.statusCode}");
    return;
  }
  // final responseData = response.data is String ? jsonDecode(response.data) : response.data;


  showToast("그룹이 삭제되었습니다", gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_SHORT);
}
