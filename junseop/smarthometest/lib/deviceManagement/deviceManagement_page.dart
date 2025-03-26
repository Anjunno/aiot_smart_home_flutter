import 'package:flutter/material.dart';
import 'package:smarthometest/request/group_request.dart'; // 기기 목록을 가져오는 요청 함수 포함

class DevicemanagementPage extends StatefulWidget {
  static String routeName = "/DevicemanagementPage";
  const DevicemanagementPage({super.key});

  @override
  State<DevicemanagementPage> createState() => _DevicemanagementPageState();
}

class _DevicemanagementPageState extends State<DevicemanagementPage> {
  late Future<List<Map<String, dynamic>>> _devicesFuture;
  List<Map<String, dynamic>> _devices = [];
  List<bool> _deviceStates = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _devicesFuture = getDeviceList(context);
    });
  }

  void _toggleDeviceState(int index, bool value) async {
    String deviceId = _devices[index]['id'];
    String onOff = value ? "on" : "off";

    if(!_devices[index]["online"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${_devices[index]["name"]}이(가) 오프라인입니다.")),);
      return;
    }

    try {
      bool success = await onOffDevice(context, deviceId, onOff);
      if (success) {
        setState(() {
          _deviceStates[index] = value;
        });
      } else {
        _showErrorSnackbar();
      }
    } catch (e) {
      _showErrorSnackbar();
    }
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('기기 상태 변경에 실패했습니다. 다시 시도해 주세요.')),
    );
  }

  void _showDeviceDialog(Map<String, dynamic> device, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.devices, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(child: Text(device['name'], style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow(Icons.numbers, '기기 ID', device['id']),
              _buildInfoRow(Icons.electric_bolt, '현재 전압', '${device['curVoltage']}V'),
              _buildInfoRow(Icons.power, '현재 전력', '${device['curPower']}W'),
              _buildInfoRow(Icons.electric_meter, '현재 전류', '${device['curCurrent']}mA'),
              _buildInfoRow(
                device['online'] ? Icons.wifi : Icons.wifi_off,
                '온라인 상태',
                device['online'] ? '온라인' : '오프라인',
                color: device['online'] ? Colors.green : Colors.red,
              ),
              _buildInfoRow(
                _deviceStates[index] ? Icons.toggle_on : Icons.toggle_off,
                '전원 상태',
                _deviceStates[index] ? '켜짐' : '꺼짐',
                color: _deviceStates[index] ? Colors.green : Colors.red,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w500))),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDevices,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _devicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('오류 발생: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.power_off, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      '등록된 기기가 없습니다.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );

            } else {
              _devices = snapshot.data!;

              if (_deviceStates.isEmpty) {
                _deviceStates = _devices.map((device) => device['power'] == true).toList();
              }

              return ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final device = _devices[index];
                  final isOnline = device['online'];

                  return InkWell(
                    child: Card(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ListTile(
                        leading: const Icon(Icons.devices),
                        title: Text(device['name']),
                        subtitle: Row(
                          children: [
                            Icon(
                              isOnline ? Icons.wifi : Icons.wifi_off,
                              color: isOnline ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isOnline ? '온라인' : '오프라인',
                              style: TextStyle(
                                color: isOnline ? Colors.green : Colors.red,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Switch(
                          value: _deviceStates[index],
                          onChanged: isOnline ? (value) => _toggleDeviceState(index, value) : null, // 비활성화
                        ),
                        onTap: () => _showDeviceDialog(device, index),
                      ),
                    ),
                  );
                },
              );

            }
          },
        ),
      ),
    );
  }
}
