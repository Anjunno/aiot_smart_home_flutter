import 'package:flutter/material.dart';
import 'package:smarthometest/signUp_page.dart';
import 'package:smarthometest/tab_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Column(
        children: [
          const Center(
            child: Text('This is the login page'),
          ),
          ElevatedButton(
            onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => TabPage()));},
            child: Title( color: Colors.amber, child: Text("login")),
          ),
          ElevatedButton(
            onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));},
            child: Title( color: Colors.amber, child: Text("SignUp")),
          ),
        ],
      )
    );
  }
}
