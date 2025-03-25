import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:smarthometest/providers/user_provider.dart';
import 'package:smarthometest/toastMessage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../dioRequest.dart';
import '../providers/kakao_user_provider.dart';


Future<void> kakaoLogin(String acccessToken) async {
  print("카카오 로그인 -> 서버 함수 실행");
  final url = dotenv.get("URL");
  final storage = FlutterSecureStorage();
  final dio = Dio();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('📱 FCM Token: $fcmToken');
  final data = {
    'fcmKey': fcmToken,
  };
  final response = await dio.get(url + "/kakao/flutter?accessToken=" + acccessToken, data: data);


  if (response.statusCode == 200) {
    print("200으로 와씅");
    print(response);

    Map<String, dynamic> data = response.data;
    // 로그인 성공 시 받은 accessToken과 refreshToken 저장
    String accessToken = response.data['accessToken'];
    String refreshToken = response.data['refreshToken'];
    // 보안 스토리지에 토큰 저장
    await storage.write(key: 'ACCESS_TOKEN', value: accessToken);
    await storage.write(key: 'REFRESH_TOKEN', value: refreshToken);
    print(data);
  } else {
    // 응답이 실패했을 경우 처리 로직 추가
    print('카카오 로그인 실패: ${response.statusCode}');
  }
}


///아이디 중복체크
Future<bool> userIdExists(String id) async {
  final url = dotenv.get("URL");
  final dio = Dio();
  dio.options.validateStatus = (status) {
    return status! < 500; // 400 이상 500 미만의 상태 코드는 오류로 처리하지 않음
  };
  final response = await dio.get(url + "/user/userIdExists?userId=" + id);
  print("아이디 중복response : $response");
  if (response.statusCode == 204) {
    print("사용가능");
    showToast("아이디 사용 가능!", gravity: ToastGravity.CENTER);
    return true;
  }
  else {
    print(response.statusCode);
    print(response.data);
    showToast("중복된 아이디입니다!", gravity: ToastGravity.CENTER);
    return false;
  }
}

///닉네임 중복 체크
Future<bool> nickNameExists(String nickName) async {
  final url = dotenv.get("URL");
  final dio = Dio();
  dio.options.validateStatus = (status) {
    return status! < 500; // 400 이상 500 미만의 상태 코드는 오류로 처리하지 않음
  };
  final response = await dio.get(url + "/user/nickNameExists?nickName=" + nickName);

  if (response.statusCode == 204) {
    print("사용가능");
    showToast("닉네임 사용 가능!", gravity: ToastGravity.CENTER);
    return true;
  }
  else {
    print(response.statusCode);
    print(response.data);
    showToast("중복된 닉네임입니다!", gravity: ToastGravity.CENTER);
    return false;
  }
}

///회원가입
Future<bool> signUp(String userId, String userPassword, String userName, String nickName) async {
  final url = dotenv.get("URL");
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  final dio = Dio();

  final data = {
    'userId': userId,
    'userPassword': userPassword,
    'userName': userName,
    'nickName': nickName,
  };

  final response = await dio.post(url + "/user/register" , data: data);

  if (response.statusCode == 200) {
    print("회원가입 완료!");
    showToast("회원가입 완료!", gravity: ToastGravity.CENTER);
    return true;
  }
  else {
    print(response.data);
    showToast("회원가입 실패!", gravity: ToastGravity.CENTER);
    return false;
  }
}

///로그인
Future<bool> login(BuildContext context, String userId, String userPassword) async {
  final url = dotenv.get("URL");
  final storage = FlutterSecureStorage();
  final dio = Dio();

  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('📱 FCM Token: $fcmToken');

  final data = {
    'userId': userId,
    'userPassword': userPassword,
    'fcmKey' : fcmToken,
  };

  try {
    // Dio의 validateStatus를 설정하여 400 상태 코드를 예외로 처리하지 않도록 함
    dio.options.validateStatus = (status) {
      return status! < 500; // 400 이상 500 미만의 상태 코드는 오류로 처리하지 않음
    };

    final response = await dio.post(url + "/user/login", data: data);

    if (response.statusCode == 200) {
      print("로그인 완료!");
      print("로그인 응답 데이터: ${response.data}");

      // 로그인 성공 시 받은 accessToken과 refreshToken 저장
      String accessToken = response.data['accessToken'];
      String refreshToken = response.data['refreshToken'];

      // 보안 스토리지에 토큰 저장
      await storage.write(key: 'ACCESS_TOKEN', value: accessToken);
      await storage.write(key: 'REFRESH_TOKEN', value: refreshToken);

      print("토큰 저장 완료");
      print(storage.read(key: "ACCESS_TOKEN").toString());
      print(storage.read(key: "REFRESH_TOKEN").toString());

      Provider.of<UserProvider>(context, listen: false).setUser(response.data['userNickName']);

      showToast("로그인 완료!", gravity: ToastGravity.CENTER);
      return true;
    } else {
      // 로그인 실패 시 상태 코드와 함께 처리
      print("로그인 실패, 상태 코드: ${response.statusCode}");
      print("응답 데이터: ${response.data}");
      showToast("아이디 및 비밀번호를 확인해주세요!", gravity: ToastGravity.CENTER);
      return false;
    }
  } catch (e) {
    // DioError를 통해 네트워크 관련 예외 처리
    print("로그인 중 오류 발생: $e");
    showToast("로그인 오류 발생! 다시 시도해주세요.", gravity: ToastGravity.CENTER);
    return false;
  }
}

///엑세스토큰 검사(자동로그인) accessCheck
Future<bool> accessCheck(String accessToken) async {
  // final url = dotenv.get("URL");
  // final dio = Dio();
  //
  // try {
  //   // 헤더에 accessToken을 Authorization에 추가
  //   dio.options.headers = {
  //     'Authorization': 'Bearer $accessToken',
  //   };
  //
  //   final response = await dio.get('$url/check/token');
  //
  //   if (response.statusCode == 200) {
  //     print("accessToken 유효!");
  //     return true;
  //   } else {
  //     print("accessToken 만료/불일치");
  //     return false;
  //   }
  // } catch (e) {
  //   print("토큰 검증 중 오류 발생: $e");
  //   return false;
  // }
  return false;
}



