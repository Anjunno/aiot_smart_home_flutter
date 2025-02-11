import 'package:flutter/material.dart';
import 'package:smarthometest/request/graph_request.dart'; // 기기 목록을 가져오는 요청 함수 포함

class DevicemanagementPage extends StatefulWidget {
  static String routeName = "/DevicemanagementPage";
  const DevicemanagementPage({super.key});

  @override
  State<DevicemanagementPage> createState() => _DevicemanagementPageState();
}

class _DevicemanagementPageState extends State<DevicemanagementPage> {
  late List<Map<String, dynamic>> _devices; // 기기 목록을 저장하는 리스트
  late List<bool> _deviceStates; // 각 기기의 On/Off 상태를 저장하는 리스트

  @override
  void initState() {
    super.initState();
    _devices = getDeviceList(); // 기기 목록을 가져옴
    _deviceStates = List<bool>.filled(_devices.length, false); // 모든 기기의 초기 상태를 Off(false)로 설정
  }

  /// 기기의 상태를 변경하는 함수
  /// [index]는 변경할 기기의 인덱스, [value]는 변경할 상태 (true: On, false: Off)
  void _toggleDeviceState(int index, bool value) {
    setState(() {
      _deviceStates[index] = value; // 해당 기기의 상태 업데이트
      print(_devices[index]['deviceName']); // 기기 On/Off 요청 시 활용 (테스트용 출력)
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _devices.length, // 기기 개수만큼 리스트 생성
      itemBuilder: (context, index) {
        final device = _devices[index]; // 현재 인덱스의 기기 정보

        return ListTile(
          leading: const Icon(Icons.devices), // 기기 아이콘 표시
          title: Text(device['deviceName']), // 기기 이름
          subtitle: Text(device['modelName']), // 기기 모델명
          trailing: Switch(
            value: _deviceStates[index], // 현재 기기의 On/Off 상태
            onChanged: (value) => _toggleDeviceState(index, value), // 스위치를 변경하면 상태 업데이트
          ),
          onTap: () {
            // 기기를 탭하면 상세 정보 팝업 표시
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(device['deviceName']), // 기기 이름
                  content: Text('모델명: ${device['modelName']}\n기기 상태: ${_deviceStates[index]}'), // 기기 정보 표시
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // 팝업 닫기
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
    );
  }
}
