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
  bool isLoading = false;  // 로딩 상태를 나타내는 변수

  @override
  void initState() {
    super.initState();
    _loadGroups();    // 페이지 초기화 시 그룹 목록 불러오기
    _loadDevices();   // 페이지 초기화 시 기기 목록 불러오기
  }

  // ⭐ 그룹 목록 불러오기 ⭐
  Future<void> _loadGroups() async {
    setState(() {
      isLoading = true;  // 그룹 목록 요청 시작 시 로딩 상태 활성화
    });

    // 서버에서 그룹 목록을 가져오는 비동기 요청
    var groups = await getGroupList();
    setState(() {
      _groups = groups;
      isLoading = false;  // 데이터 로딩 완료 후 로딩 상태 비활성화
    });
  }

  // ⭐ 기기 목록 불러오기 ⭐
  Future<void> _loadDevices() async {
    // 서버에서 기기 목록을 가져오는 비동기 요청
    var devices = await getDeviceList();
    setState(() {
      _devices = devices;
    });
  }

  // ⭐ 그룹 추가 Dialog ⭐
  void _showAddGroupDialog() async {
    setState(() {
      isLoading = true; // 로딩 상태 활성화
    });

    // 기기 목록 불러오는 작업 (비동기)
    await _loadDevices();

    setState(() {
      isLoading = false; // 로딩 상태 비활성화
    });

    // Dialog에서 사용할 TextEditingController 및 상태 변수
    TextEditingController groupNameController = TextEditingController();
    Map<String, bool> deviceSelection = {};  // 기기 선택 상태 저장
    Map<String, bool> deviceState = {};      // 사용자가 선택한 on/off 상태 저장

    // 기기 목록 초기화 (초기 상태는 모두 off)
    for (var device in _devices) {
      deviceSelection[device['id']] = false;
      deviceState[device['id']] = false;
    }

    // ⭐ 그룹 추가 Dialog UI ⭐
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
                    // 그룹명 입력 필드
                    TextField(
                      controller: groupNameController,
                      decoration: const InputDecoration(labelText: "그룹명"),
                    ),
                    const SizedBox(height: 20),

                    // 기기 목록 출력 및 선택
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
                          // 기기 on/off 스위치
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
                // 취소 버튼
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
                ),
                // 확인 버튼
                ElevatedButton(
                  onPressed: () async {
                    String groupName = groupNameController.text;
                    if (groupName.isEmpty) {
                      // 그룹명이 비어있을 경우 경고 메시지
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
                      "power": deviceState[device['id']]
                    })
                        .toList();

                    await createGroup(groupName);

                    // 새로운 그룹 추가
                    setState(() {
                      // _groups.add({
                      //   "groupName": groupName,
                      //   "devices": selectedDevices,
                      // });
                      print(_groups);  // 디버깅용 출력
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

  // ⭐ 그룹 전체 상태 변경 ⭐
  void _toggleGroupState(int groupIndex, bool value) {
    setState(() {
      // 해당 그룹의 모든 기기의 power 상태 변경
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
          // 그룹 추가 버튼
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddGroupDialog, // 그룹 추가 Dialog 호출
          ),
        ],
      ),
      body: isLoading
      // 🔄 로딩 상태일 때: 로딩 화면 표시
          ? const Center(child: CircularProgressIndicator())
      // ❌ 그룹이 없을 때: 안내 문구 출력
          : _groups.isEmpty
          ? const Center(child: Text('등록된 그룹이 없습니다.'))
      // ✅ 그룹 목록 출력
          : ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          // 그룹 내 모든 기기의 상태가 true일 때 그룹 상태도 true
          bool groupState = (group['devices'] ?? []).every((device) => device['power'] == true);

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(group['groupName']),
              // 그룹 상태 on/off 스위치
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
