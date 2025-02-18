
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


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
  final response = await dio.get(url + "/group/check/list");

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
    "groupName": groupName
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

      // Map으로 변환
      List<Map<String, dynamic>> groupAction = data.map((item) {
        return {
          "groupId": item['groupId'],
          "plugId": item['plugId'],
          "plugControl": item['plugControl'],
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
Future<void> groupActionRun(groupId) async {
  final url = dotenv.get("URL");
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  final dio = Dio();

  final response = await dio.get(url + "/group/action/run/" + groupId.toString());
  if (response.statusCode == 200) {
    print(response);
  } else {
    print(response);
    print("그룹 액션 실패: ${response.statusCode}");
  }
}




// List<Map<String, dynamic>> getDayData(BuildContext context)
List<Map<String, dynamic>> getDeviceEData() {
  // List<dynamic> data = response.data;
  List<dynamic> data = [
    {
      "device": "TV",
      "electricalEnergy": 120.5
    },
    {
      "device": "냉장고",
      "electricalEnergy": 200.0
    },
    {
      "device": "에어컨",
      "electricalEnergy": 180.0
    },
    {
      "device": "세탁기",
      "electricalEnergy": 90.0
    },
    {
      "device": "조명",
      "electricalEnergy": 20.0
    },
    {
      "device": "기타",
      "electricalEnergy": 70.0
    }
  ];


  List<Map<String, dynamic>> deviceList = data.map((item) {
    return {
      "device": item['device'],
      "electricalEnergy": item['electricalEnergy']
    };
  }).toList();

  // electricalEnergy를 기준으로 내림차순 정렬
  deviceList.sort((a, b) => b['electricalEnergy'].compareTo(a['electricalEnergy']));

  return deviceList;
}

//일별 전력량
List<Map<String, dynamic>> getDayEData() {
  // List<dynamic> data = response.data;
  List<dynamic> data = [
    {
      "date": "24/10/08",
      "electricalEnergy": 1.8
    },
    {
      "date": "24/10/09", // 월요일
      "electricalEnergy": 1.2 // 평일, 사용량이 약간 낮음
    },
    {
      "date": "24/10/10", // 화요일
      "electricalEnergy": 1.3 // 평일, 일반적인 사용량
    },
    {
      "date": "24/10/11", // 수요일
      "electricalEnergy": 1.1 // 평일, 사용량이 조금 더 낮음
    },
    {
      "date": "24/10/12", // 목요일
      "electricalEnergy": 1.4 // 평일, 사용량이 다시 상승
    },
    {
      "date": "24/10/13", // 금요일
      "electricalEnergy": 1.5 // 평일, 주말을 앞두고 약간의 증가
    },
    {
      "date": "24/10/14", // 토요일
      "electricalEnergy": 2.0 // 주말, 사용량 증가
    },
  ];

  List<Map<String, dynamic>> dayList = data.map((item) {
    return {
      "date": item['date'],
      "electricalEnergy": item['electricalEnergy']
    };
  }).toList();
  return dayList;
}

List<Map<String, dynamic>> getMonthEData() {
  ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  List<Map<String, dynamic>> data = [
    {
      'month': "Jan",
      'electricalEnergy': 450
    },
    {
      'month': "Feb", // 겨울
      'electricalEnergy': 420 // 난방기 사용 지속
    },
    {
      'month': "Mar", // 초봄
      'electricalEnergy': 320 // 난방 사용 감소
    },
    {
      'month': "Apr", // 봄
      'electricalEnergy': 350 // 온화한 날씨로 전력 소비 감소
    },
    {
      'month': "May", // 늦봄
      'electricalEnergy': 400 // 날씨가 따뜻해지며 소비량 약간 증가
    },
    {
      'month': "Jun", // 초여름
      'electricalEnergy': 500 // 에어컨 사용 시작으로 소비량 증가
    },
    {
      'month': "Jul", // 여름
      'electricalEnergy': 600 // 에어컨 사용량 최대치
    },
    {
      'month': "Aug", // 여름
      'electricalEnergy': 600 // 여전히 높은 에어컨 사용량
    },
    {
      'month': "Sep", // 초가을
      'electricalEnergy': 550 // 에어컨 사용량 감소
    },
    {
      'month': "Oct", // 가을
      'electricalEnergy': 350 // 온화한 날씨로 소비량 감소
    },
    {
      'month': "Nov", // 늦가을
      'electricalEnergy': 400 // 난방기 사용 시작
    },
    {
      'month': "Dec", // 겨울
      'electricalEnergy': 480 // 난방 사용으로 소비량 증가
    },
  ];

  List<Map<String, dynamic>> monthList = data.map((item) {
    return {
      "month": item['month'],
      "electricalEnergy": item['electricalEnergy']
    };
  }).toList();
  return monthList;
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