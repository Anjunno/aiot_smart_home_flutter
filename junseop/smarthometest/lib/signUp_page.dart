import 'package:flutter/material.dart';
import 'package:smarthometest/root_page.dart';
import 'package:smarthometest/tab_page.dart';

class SignUpPage extends StatefulWidget {

  static String routeName = "/SiginUpPage";

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Siginup Page'),
      ),
      body: Center(
        child: Column(
          children: [
            Text("This is the Siginup Page"),
            ElevatedButton(
              // onPressed: () {Navigator.pushNamed(context, TabPage.routeName);},
              onPressed: () {Navigator.pushNamedAndRemoveUntil(context, TabPage.routeName, ModalRoute.withName(RootPage.routeName));},
              child: Title( color: Colors.amber, child: Text("SignUp")),
            ),
          ],
        ),
      ),
    );
  }
}
