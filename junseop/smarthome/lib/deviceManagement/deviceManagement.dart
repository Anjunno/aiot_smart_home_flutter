import 'package:flutter/material.dart';

import '../function/request.dart';

class DeviceManagement extends StatefulWidget {
  const DeviceManagement({super.key});

  @override
  State<DeviceManagement> createState() => _DeviceManagementState();
}

class _DeviceManagementState extends State<DeviceManagement> {
  late List<Map<String, dynamic>> _devices;
  late List<bool> _deviceStates; // 각 기기의 온/오프 상태 저장

  @override
  void initState() {
    super.initState();
    _devices = getDeviceList();
    _deviceStates = List<bool>.filled(_devices.length, false); // 초기 상태는 모두 꺼짐
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("기기 관리"),
      // ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return ListTile(
            leading: const Icon(Icons.devices),
            title: Text(device['deviceName']),
            subtitle: Text(device['modelName']),
            trailing: Switch(
              value: _deviceStates[index],
              onChanged: (bool value) {
                setState(() {
                  _deviceStates[index] = value; // 상태 업데이트
                });
              },
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(device['deviceName']),
                    content: Text('모델명: ${device['modelName']}\n기기 상태: ${_deviceStates[index]}'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
