import "package:flutter/material.dart";
import "../SmartHomeMain.dart";
import 'signUpPage.dart';

class LoginScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인 & 회원가입'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '아이디',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '비밀번호',
              ),
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // Add login functionality
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SmartHomeMain()));
              },
              child: Text('로그인'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignUpPage()));
                // Add sign up functionality
              },
              child: Text('회원가입'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,

              ),
            ),
          ],
        ),
      ),
    );
  }
}