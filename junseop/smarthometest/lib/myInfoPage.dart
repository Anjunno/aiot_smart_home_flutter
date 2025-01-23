import 'package:flutter/material.dart';

class MyInfoPage extends StatelessWidget {
  static String routeName = "/MyInfoPage";
  const MyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title : Text("내정보"),
      ),
      body: Center(
        child: Text("내정보 페이지입니다."),
      ),
    );
  }
}
