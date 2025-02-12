import 'package:flutter/material.dart';

import '../request/graph_request.dart';

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
        child: Column(
          children: [
            Text("기기별 전력량 그래프"),
            BackButton(),
            MaterialButton(onPressed: () {}),
            TextButton(
                onPressed: () {
                  onOffDevice("fasdfasdfasdf", "on");
                },
                child: Text("전원 On/Off"))
          ],
        ),
      ),
    );
  }
}
