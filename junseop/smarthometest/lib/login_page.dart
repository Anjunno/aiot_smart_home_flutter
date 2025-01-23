import 'package:flutter/material.dart';
import 'package:smarthometest/signUp_page.dart';
import 'package:smarthometest/tab_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  static String routeName = "/LoginPage";

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
            // onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => TabPage()));},
            onPressed: () {Navigator.pushNamedAndRemoveUntil(context, TabPage.routeName, (route) => false);},
            child: Title( color: Colors.amber, child: Text("Login")),
          ),
          ElevatedButton(
            // onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));},
            onPressed: () {Navigator.pushNamed(context, SignUpPage.routeName);},
            child: Title( color: Colors.amber, child: Text("SignUp")),
          ),
        ],
      )
    );
  }
}
// final routes = {
//   TabPage.routeName: (context) => TabPage(),
//   SignUpPage.routeName: (context) => SignUpPage(),
// };
