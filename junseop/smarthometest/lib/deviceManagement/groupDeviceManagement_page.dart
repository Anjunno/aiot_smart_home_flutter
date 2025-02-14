import 'package:flutter/material.dart';
import 'package:smarthometest/request/graph_request.dart';

class GroupDevicemanagementPage extends StatefulWidget {
  static String routeName = "/GroupManagementPage";
  const GroupDevicemanagementPage({super.key});

  @override
  State<GroupDevicemanagementPage> createState() => _GroupDevicemanagementPageState();
}

class _GroupDevicemanagementPageState extends State<GroupDevicemanagementPage> {
  List<Map<String, dynamic>> _devices = [];  // 기기 목록 저장
  List<Map<String, dynamic>> _groups = [];   // 그룹 목록 저장
  bool isLoading = false;  // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    _loadDevices();  // 초기화 시 기기 목록 불러오기
  }

  // 기기 목록 불러오기
  Future<void> _loadDevices() async {
    var devices = await getDeviceList();
    setState(() {
      _devices = devices;
    });
  }

  // 그룹 추가 Dialog
  void _showAddGroupDialog() async {
    setState(() {
      isLoading = true; // 로딩 상태 활성화
    });

    // _loadDevices가 완료될 때까지 기다리기
    await _loadDevices();  // 기기 목록 불러오는 작업

    setState(() {
      isLoading = false; // 로딩 상태 비활성화
    });

    TextEditingController groupNameController = TextEditingController();
    Map<String, bool> deviceSelection = {};  // 기기 선택 상태 저장
    Map<String, bool> deviceState = {};      // 사용자가 선택한 on/off 상태 저장

    // 기기 목록 초기화 (초기 상태는 모두 off)
    for (var device in _devices) {
      deviceSelection[device['id']] = false;
      deviceState[device['id']] = false;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("그룹 추가"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: groupNameController,
                      decoration: const InputDecoration(labelText: "그룹명"),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: _devices.map((device) {
                        return CheckboxListTile(
                          title: Text(device['name']),
                          subtitle: Text('ID: ${device['id']}'),
                          value: deviceSelection[device['id']],
                          onChanged: (bool? value) {
                            setState(() {
                              deviceSelection[device['id']] = value ?? false;
                            });
                          },
                          secondary: Switch(
                            value: deviceState[device['id']]!,
                            onChanged: deviceSelection[device['id']]!
                                ? (bool value) {
                              setState(() {
                                deviceState[device['id']] = value;
                              });
                            }
                                : null, // 체크 안된 기기는 비활성화
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
                ),
                ElevatedButton(
                  onPressed: () {
                    String groupName = groupNameController.text;
                    if (groupName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('그룹명을 입력하세요.')),
                      );
                      return;
                    }

                    // 선택된 기기 목록 저장
                    List<Map<String, dynamic>> selectedDevices = _devices
                        .where((device) => deviceSelection[device['id']] == true)
                        .map((device) => {
                      "id": device['id'],
                      // "name": device['name'],
                      "power": deviceState[device['id']]
                    })
                        .toList();

                    // 그룹 추가
                    setState(() {
                      _groups.add({
                        "groupName": groupName,
                        "devices": selectedDevices,
                      });
                      print(_groups);
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 그룹 전체 상태 변경
  void _toggleGroupState(int groupIndex, bool value) {
    setState(() {
      for (var device in _groups[groupIndex]['devices']) {
        device['power'] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("그룹 관리"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddGroupDialog, // 그룹 추가 Dialog 호출
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 화면
          : _groups.isEmpty
          ? const Center(child: Text('등록된 그룹이 없습니다.'))
          : ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          bool groupState =
          group['devices'].every((device) => device['power'] == true);

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(group['groupName']),
              trailing: Switch(
                value: groupState,
                onChanged: (value) => _toggleGroupState(index, value),
              ),
            ),
          );
        },
      ),
    );
  }
}
