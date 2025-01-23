import 'package:flutter/material.dart';

class DeviceGraph extends StatefulWidget {
  const DeviceGraph({super.key});

  @override
  State<DeviceGraph> createState() => _DeviceGraphState();
}

class _DeviceGraphState extends State<DeviceGraph> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("기기별 전력량 그래프"),
      ),
    );
  }
}
