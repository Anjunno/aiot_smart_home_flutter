import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

final storage = FlutterSecureStorage();
final dio = Dio();

Future<Response?> dioRequest(String method, String endpoint, {Map<String, dynamic>? data}) async {
  final url = dotenv.get("URL") + endpoint;
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  try {
    Response response;
    if (method == "GET") {
      response = await dio.get(url);
    } else if (method == "POST") {
      response = await dio.post(url, data: data);
    } else {
      throw Exception("Unsupported HTTP method: $method");
    }

    return response;
  } catch (e) {
    print("API 요청 오류 ($method $endpoint): $e");
    return null;
  }
}
