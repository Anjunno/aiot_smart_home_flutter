import 'package:flutter/material.dart';
import 'package:smarthometest/tab_page.dart';

class SignUpPage extends StatefulWidget {
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
              onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => TabPage()));},
              child: Title( color: Colors.amber, child: Text("SignUp")),
            ),
          ],
        ),
      ),
    );
  }
}
