
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smarthometest/toastMessage.dart';
import 'package:fluttertoast/fluttertoast.dart';


///기기 on/off
// Future<Map<String, dynamic>?> onOff(String deviceName, String onOff) async {
Future<bool> onOffDevice(String deviceId, String onOff) async {
  final url = dotenv.get("URL");
  final dio = Dio();
  Map<String, dynamic> data = {
    "action": onOff
  };

  try {
    final response = await dio.post(url + "/control/device/" + deviceId, data: data);

    if (response.statusCode == 200) {
      final responseData = response.data;
      if (responseData != null && responseData['status'] == 'success') {
        print("기기 ${onOff == 'on' ? '켜짐' : '꺼짐'}: $deviceId");
        return true; // 성공 시 true 반환
      } else {
        print("기기 상태 변경 실패: ${responseData['message']}");
        return false; // 실패 시 false 반환
      }
    } else {
      print("요청 실패: ${response.statusCode}");
      return false; // 실패 시 false 반환
    }
  } catch (e) {
    print("에러 발생: $e");
    return false; // 에러 발생 시 false 반환
  }
}

///그룹 리스트 요청
Future<List<Map<String, dynamic>>> getGroupList() async {
  final url = dotenv.get("URL");
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  final dio = Dio();
  final response = await dio.get(url + "/usage/month");

  if (response.statusCode == 200) {
    List<dynamic> data = response.data as List<dynamic>;
    List<Map<String, dynamic>> groupList = data.map((item) {
      return {
        "groupId": item['groupId'],
        "groupName": item['groupName'],
        "creationTime": item['creationTime'],
      };
    }).toList();

    print("GroupList: $groupList");
    return groupList;
  } else {
    return [];
  }
}
//그룹 이름 생성
Future<void> createGroup(String groupName) async {
  final url = dotenv.get("URL");
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  final dio = Dio();
  Map<String, dynamic> data = {
    "groupName": groupName + " 그룹"
  };
  final response = await dio.post(url + "/group/create", data: data);
  if (response.statusCode == 200) {
    print("그룹 생성 성공: $groupName");
  } else {
    print("그룹 생성 실패: ${response.statusCode}");
  }
}

//그룹 액션 설정
Future<void> groupAction(Map<String, dynamic> groupData) async {
  final url = dotenv.get("URL");
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  final dio = Dio();
  final response = await dio.post(url + "/group/action/add", data: groupData);
  if (response.statusCode == 200) {
    print("그룹 액션 추가 성공: $groupData");
  } else {
    print("그룹 액션 추가 실패: ${response.statusCode}");
  }
}

//그룹 액션 확인
Future<List<Map<String, dynamic>>> groupActionCheck(groupId) async {
  final url = dotenv.get("URL");
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  final dio = Dio();

  try {
    // groupId가 int 타입일 경우 toString()으로 변환
    final response = await dio.get(url + "/group/action/check/" + groupId.toString());

    if (response.statusCode == 200) {
      // JSON 데이터를 List<dynamic>으로 변환
      List<dynamic> data = jsonDecode(response.data);
      print(data);
      // Map으로 변환
      List<Map<String, dynamic>> groupAction = data.map((item) {
        return {
          "groupId": item['groupId'],
          "groupName": item['groupName'],
          "plug": (item['plug'] as List).map((plug) {
            return {
              "plugId": plug['plugId'],
              "plugName": plug['plugName'],
              "plugControl": plug['plugControl'],
            };
          }).toList(),
        };
      }).toList();


      print("groupAction 내용:\n$groupAction");
      return groupAction;
    } else {
      print("응답 오류: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("예외 발생: $e");
    return [];
  }
}

//그룹 액션 실행
Future<void> groupActionRun(int groupId) async {
  final url = dotenv.get("URL");
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  final dio = Dio();

  try {
    final response = await dio.get("$url/group/action/run/$groupId");
    print(response);
    print(response.statusCode);

    // 응답이 JSON 문자열일 경우, JSON 파싱을 시도
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
      response.data is String ? jsonDecode(response.data) : response.data;

      //응답 데이터 처리
      int successCount = responseData["successCount"];
      int errorCount = responseData["errorCount"];
      List<String> successArray = List<String>.from(responseData["successArray"]);
      List<String> errorArray = List<String>.from(responseData["errorArray"]);

      String message = "✅ 성공한 기기 ($successCount개):\n"
          "${successArray.join(", ")}\n\n"
          "❌ 실패한 기기 ($errorCount개):\n"
          "${errorArray.isNotEmpty ? errorArray.join(", ") : "없음"}";
      showToast(message, gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_LONG);
    } else {
      showToast("그룹 설정이 필요합니다.", gravity: ToastGravity.CENTER);
      print("그룹 액션 실패: ${response.statusCode}");
    }
  } catch (e) {
    showToast("네트워크 오류 발생", gravity: ToastGravity.CENTER);
    print("오류 발생: $e");
  }
}




///기기 리스트 요청
Future<List<Map<String, dynamic>>> getDeviceList() async {
  final url = dotenv.get("URL");
  print(url);
  final storage = new FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  final dio = Dio();

  final response = await dio.get(url + "/check/plugList");

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.data);
    List<Map<String, dynamic>> deviceList = data.map((item) {
      return {
        "curVoltage": item['curVoltage'], //raw 전력 V
        "curPower": item['curPower'], //raw 전력 W
        "curCurrent": item['curCurrent'], //현재 전류 mA
        "name": item['name'], //플러그 명
        "online": item['online'], //온라인 여부(네트워크 연결 여부)
        "id": item['id'], //기기 고유 기기값
        "power": item['power'], //전원 on / off 여부
      };
    }).toList();
    return deviceList;
  } else {
    return [];
  }
}