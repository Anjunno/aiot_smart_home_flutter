import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:smarthometest/login_page.dart';
import 'package:smarthometest/signUp_page.dart'; // 네비게이션을 위해 필요

// 보안 저장소 및 Dio 인스턴스 생성
final storage = FlutterSecureStorage();
final dio = Dio();

// 저장된 액세스 토큰을 가져오는 함수
Future<String?> _getAccessToken() async {
  return await storage.read(key: 'ACCESS_TOKEN');
}

// 리프레시 토큰을 사용하여 새로운 액세스 토큰을 요청하는 함수
Future<String?> _refreshToken(BuildContext context) async {
  final refreshToken = await storage.read(key: 'REFRESH_TOKEN');
  if (refreshToken == null) {
    _handleSessionExpired(context);
    return null;
  }

  try {
    String url = await dotenv.get("URL");
    final response = await dio.post(url + "/token/refresh",
      data: {"refreshToken": refreshToken},
    );

    if (response.statusCode == 200) {
      print("리프레시로 엑세스 재요청 성공");
      print("리프레시로 갱신 정보 : ${response.data}");

      final responseData = jsonDecode(response.data);
      String newAccessToken = responseData['newAccessToken'];

      await storage.write(key: 'ACCESS_TOKEN', value: newAccessToken);
      return newAccessToken;
    }

  } catch (e) {
    print("토큰 갱신 실패: $e");
    _handleSessionExpired(context);
  }
  return null;
}

// 세션 만료 처리 함수
void _handleSessionExpired(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("세션 만료"),
        content: Text("로그인이 만료되었습니다.\n 다시 로그인해주세요."),
        actions: [
          TextButton(
            onPressed: () {
              storage.deleteAll(); // 모든 저장된 인증 정보 삭제
              Navigator.pushNamedAndRemoveUntil(context, LoginPage.routeName, (route) => false);
            },
            child: Text("확인"),
          ),
        ],
      );
    },
  );
}

// API 요청을 수행하는 함수
Future<Response?> dioRequest(String method, String endpoint, {Map<String, dynamic>? data, required BuildContext context}) async {
  final url = dotenv.get("URL") + endpoint;
  String? accessToken = await _getAccessToken();

  // 요청 헤더에 액세스 토큰 추가
  dio.options.headers = {
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };

  try {
    Response response;
    if (method == "GET") {
      response = await dio.get(url);
      print("겟 정보: $response");
    } else if (method == "POST") {
      response = await dio.post(url, data: data);
    } else if (method == "PUT") {
      response = await dio.put(url, data: data);
    } else if (method == "DELETE") {
      response = await dio.delete(url);
    }
    else {
      throw Exception("Unsupported HTTP method: $method");
    }
    return response;
  } catch (e) {
    // 토큰 만료 시 리프레시 토큰을 사용하여 갱신 후 재요청
    if (e is DioException && e.response?.statusCode == 401) {
      print("토큰 만료, 갱신 시도...");
      accessToken = await _refreshToken(context);
      if (accessToken != null) {
        dio.options.headers['Authorization'] = 'Bearer $accessToken';
        return dioRequest(method, endpoint, data: data, context: context); // 갱신된 토큰으로 재요청
      }
    }
    print("API 요청 오류 ($method $endpoint): $e");
    return null;
  }
}
