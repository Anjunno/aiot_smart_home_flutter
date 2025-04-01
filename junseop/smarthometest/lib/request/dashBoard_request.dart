import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smarthometest/toastMessage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../dioRequest.dart';

Future<Map<String, dynamic>> getDashBoard (BuildContext context) async{
  final response = await dioRequest("GET", "/dash", context: context);
  if (response?.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response?.data);
    print(data);
    return data;
  }
  else {
    Map<String, dynamic> result = {"result" : false};
    return result;
  }
  // return
  //   {'advice': {'cause': '사용이 필요 이상으로 지속되고 있어 에너지를 낭비하고 있습니다.',
  //   'problem': '컴퓨터 본체와 모니터가 불필요하게 오랜 시간 동안 켜져 있습니다.',
  //   'solution': '컴퓨터 사용이 끝나면 즉시 본체와 모니터를 꺼주세요. 앱에서 그룹제어 기능을 사용하여 한번에 끌 '
  //       '수 있어요.'},
  //   'top3_devices': [{'day_before_yesterday': 2.0,
  //     'diff': 0.3,
  //     'plug_name': '컴퓨터 본체',
  //     'yesterday': 2.3},
  //     {'day_before_yesterday': 0,
  //       'diff': 0.2,
  //       'plug_name': '전자레인지',
  //       'yesterday': 0.2},
  //     {'day_before_yesterday': 0.3,
  //       'diff': 0.0,
  //       'plug_name': '컴퓨터모니터',
  //       'yesterday': 0.4}],
  //   'total_usage': {'day_before_yesterday': 2.4,
  //     'diff': 0.6,
  //     'diff_text': '▲ 0.6W 증가',
  //     'yesterday': 3.0}};
}