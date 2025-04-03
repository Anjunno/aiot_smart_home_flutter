import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../dioRequest.dart';

Future<Map<String, dynamic>> getDashBoard (BuildContext context) async {
  final response = await dioRequest("GET", "/dash", context: context);


  if (response?.statusCode == 200) {
    print('200');
    try {
      dynamic rawData = response?.data;
      print(rawData);

      // 문자열인 경우 처리
      if (rawData is String) {
        if (rawData.trim().isEmpty) {
          print("빈 문자열 응답");
          return {"result": false};
        }
        rawData = jsonDecode(rawData);
      }

      if (rawData is! Map<String, dynamic>) {
        print("예상치 못한 형식의 응답: $rawData");
        return {"result": false};
      }

      print(rawData);
      return rawData;
    } catch (e, stack) {
      print("getDashBoard 파싱 오류: $e");
      print(stack);
      return {"result": false};
    }
  } else {
    return {"result": false};
  }
}
