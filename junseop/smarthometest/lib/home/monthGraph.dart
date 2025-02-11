import 'package:flutter/material.dart';

class MonthGraph extends StatefulWidget {
  const MonthGraph({super.key});

  @override
  State<MonthGraph> createState() => _MonthGraphState();
}

class _MonthGraphState extends State<MonthGraph> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("월별 전력량 그래프"),
      ),
    );
  }
}
