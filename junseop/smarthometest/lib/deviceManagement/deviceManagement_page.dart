import 'package:flutter/material.dart';
import 'package:smarthometest/request/graph_request.dart'; // 기기 목록을 가져오는 요청 함수 포함

class DevicemanagementPage extends StatefulWidget {
  static String routeName = "/DevicemanagementPage";
  const DevicemanagementPage({super.key});

  @override
  State<DevicemanagementPage> createState() => _DevicemanagementPageState();
}

class _DevicemanagementPageState extends State<DevicemanagementPage> {
  late Future<List<Map<String, dynamic>>> _devicesFuture;
  List<Map<String, dynamic>> _devices = []; // 기기 목록 변수 추가
  List<bool> _deviceStates = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  // 기기 목록 불러오기
  Future<void> _loadDevices() async {
    setState(() {
      _devicesFuture = getDeviceList(); // Future 초기화
    });
  }

  /// 기기의 상태를 변경하는 함수
  void _toggleDeviceState(int index, bool value) async {
    String deviceId = _devices[index]['id'];
    String onOff = value ? "on" : "off";

    try {
      // 서버에 On/Off 요청 및 결과 반환값 처리
      bool success = await onOffDevice(deviceId, onOff);
      print("success == " + "$success");
      if (success) {
        // 요청 성공 시 로컬 상태 업데이트
        setState(() {
          _deviceStates[index] = value;
        });
      } else {
        // 실패 시, 상태를 원래대로 돌리기 위해 다시 반전시킴
        setState(() {
          _deviceStates[index] = !value;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('기기 상태 변경에 실패했습니다. 다시 시도해 주세요.')),
        );
      }
    } catch (e) {
      // 에러 발생 시, 상태를 원래대로 돌리기 위해 다시 반전시킴
      setState(() {
        _deviceStates[index] = !value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기기 상태 변경에 실패했습니다. 다시 시도해 주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _devicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 로딩 중 표시
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('등록된 기기가 없습니다.'));
          } else {
            _devices = snapshot.data!;

            // 기기 상태 초기화 (첫 로드 시에만 실행)
            if (_deviceStates.isEmpty) {
              _deviceStates = _devices.map((device) {
                return device['power'] == true;
              }).toList();
            }

            return ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return ListTile(
                  leading: const Icon(Icons.devices), // 기기 아이콘
                  title: Text(device['name']), // 기기 이름
                  subtitle: Text('기기 ID: ${device['id']}'), // 기기 ID
                  trailing: Switch(
                    value: _deviceStates[index],
                    onChanged: (value) => _toggleDeviceState(index, value),
                  ),
                  onTap: () {
                    // 기기 상세 정보 팝업
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(device['name']),
                          content: Text(
                            '기기 ID: ${device['id']}\n'
                                '현재 전압: ${device['curVoltage']}V\n'
                                '현재 전력: ${device['curPower']}W\n'
                                '현재 전류: ${device['curCurrent']}mA\n'
                                '온라인 상태: ${device['online'] ? '온라인' : '오프라인'}\n'
                                '전원 상태: ${_deviceStates[index] ? '켜짐' : '꺼짐'}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('확인'),
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
        },
      ),
    );
  }
}
