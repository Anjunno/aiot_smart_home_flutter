import 'package:flutter/material.dart';
import 'package:smarthometest/request/group_request.dart';
import 'package:smarthometest/toastMessage.dart';
import 'package:fluttertoast/fluttertoast.dart';


class GroupDevicemanagementPage extends StatefulWidget {
  static String routeName = "/GroupManagementPage";

  const GroupDevicemanagementPage({super.key});

  @override
  State<GroupDevicemanagementPage> createState() =>
      _GroupDevicemanagementPageState();
}

class _GroupDevicemanagementPageState extends State<GroupDevicemanagementPage> {
  List<Map<String, dynamic>> _devices = []; // 기기 목록 저장
  List<Map<String, dynamic>> _groups = []; // 그룹 목록 저장
  bool isLoading = false; // 로딩 상태를 나타내는 변수

  @override
  void initState() {
    super.initState();
    _loadGroups(); // 페이지 초기화 시 그룹 목록 불러오기
    _loadDevices(); // 페이지 초기화 시 기기 목록 불러오기
  }

  // ⭐ 그룹 목록 불러오기 ⭐
  Future<void> _loadGroups() async {
    setState(() {
      isLoading = true; // 그룹 목록 요청 시작 시 로딩 상태 활성화
    });

    // 서버에서 그룹 목록을 가져오는 비동기 요청
    var groups = await getGroupList();
    setState(() {
      _groups = groups;
      isLoading = false; // 데이터 로딩 완료 후 로딩 상태 비활성화
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

  //⭐ 그룹 이름 추가 ⭐
  void _createGroupName() async {
    TextEditingController groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("그룹 이름 추가"),
          content: TextField(
            controller: groupNameController,
            decoration: const InputDecoration(labelText: "그룹 이름"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                String groupName = groupNameController.text.trim();

                if (groupName.isEmpty) {
                  showToast("그룹명을 입력하세요.");
                  return;
                }

                print("그룹이름 요청할게");
                await createGroup(groupName);

                // 그룹 추가 후 목록 갱신
                await _loadGroups();

                Navigator.pop(context);
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  // ⭐ 그룹 액션 추가 Dialog ⭐
  void _showAddGroupDialog(groupId) async {
    Map<String, dynamic> groupData;

    setState(() {
      isLoading = true; // 로딩 상태 활성화
    });

    await _loadDevices();

    // 기기 목록 불러오는 작업 (비동기)
    setState(() {
      isLoading = false; // 로딩 상태 비활성화
    });

    // Dialog에서 사용할 TextEditingController 및 상태 변수
    TextEditingController groupNameController = TextEditingController();
    Map<String, bool> deviceSelection = {}; // 기기 선택 상태 저장
    Map<String, String> deviceState = {}; // 사용자가 선택한 on/off 상태 저장

    // 기기 목록 초기화 (초기 상태는 모두 off)
    for (var device in _devices) {
      deviceSelection[device['id']] = false;
      deviceState[device['id']] = "off";
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
                    const SizedBox(height: 20),

                    // 기기 목록 출력 및 선택
                    Column(
                      // 그룹명 입력 필드
                      // TextField(
                      //   controller: groupNameController,
                      //   decoration: const InputDecoration(labelText: "그룹명"),
                      // ),
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
                            value: deviceState[device['id']] == "on",
                            onChanged: deviceSelection[device['id']]!
                                ? (bool value) {
                                    setState(() {
                                      deviceState[device['id']] =
                                          value ? "on" : "off";
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
                    // String groupName = groupNameController.text;
                    // if (groupName.isEmpty) {
                    //   // 그룹명이 비어있을 경우 경고 메시지
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(content: Text('그룹명을 입력하세요.')),
                    //   );
                    //   return;
                    // }
                    // 선택된 기기 목록 저장
                    List<Map<String, dynamic>> selectedDevices = _devices
                        .where(
                            (device) => deviceSelection[device['id']] == true)
                        .map((device) => {
                              "plugId": device['id'],
                              "action": deviceState[device['id']]
                            })
                        .toList();
                    print("액션설정\n" + selectedDevices.toString());

                    groupData = {
                      "groupId": groupId,
                      "devices": selectedDevices,
                    };

                    setState(() {
                      print(groupData); // 디버깅용 출력
                    });

                    await groupAction(groupData);

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
        toolbarHeight: 35.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createGroupName,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadGroups();
          await _loadDevices();
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _groups.isEmpty
            ? const Center(child: Text('등록된 그룹이 없습니다.'))
            : ListView.builder(
          itemCount: _groups.length,
          itemBuilder: (context, index) {
            final group = _groups[index];
            bool groupState = (group['devices'] ?? [])
                .every((device) => device['power'] == true);

            return Card(
              margin: const EdgeInsets.all(5),
              child: ListTile(
                title: Text(group['groupName']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showAddGroupDialog(
                            _groups[index]["groupId"].toString());
                      },
                    ),
                    IconButton(
                        onPressed: () async {
                          await groupDelete(_groups[index]["groupId"]);
                          await _loadGroups();
                        }, icon: const Icon(Icons.delete)),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .onInverseSurface,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: () {
                          groupActionRun(_groups[index]["groupId"]);
                        },
                        child: Text("실행")),
                  ],
                ),
                onTap: () async {
                  // groupActionCheck 결과 받아오기
                  List<Map<String, dynamic>> groupAction = await groupActionCheck(_groups[index]["groupId"]);

                  // 다이얼로그 표시
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Row(
                          children: [
                            Icon(Icons.devices, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${group["groupName"]} 설정 상태",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        content: SingleChildScrollView( // 스크롤 가능하게 감싸기
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8, // 다이얼로그 크기 조절
                            child: groupAction.isNotEmpty
                                ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: groupAction.map((group) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    group["plug"].isNotEmpty
                                        ? Column(
                                      children: (group["plug"] as List).map((plug) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            elevation: 4,
                                            child: ListTile(
                                              leading: Icon(Icons.power, color: Colors.orange),
                                              title: Text('${plug["plugName"]}',
                                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Plug ID: ${plug["plugId"]}'),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "동작 설정",
                                                        style: TextStyle(
                                                          color: plug["plugControl"] == "on"
                                                              ? Colors.green
                                                              : Colors.red,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Icon(
                                                        plug["plugControl"] == "on"
                                                            ? Icons.toggle_on
                                                            : Icons.toggle_off,
                                                        color: plug["plugControl"] == "on"
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    )
                                        : const Text('등록된 플러그가 없습니다.'),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              }).toList(),
                            )
                                : const Text('그룹 설정이 필요합니다.'),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('닫기', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      );
                    },
                  );



                },

              ),
            );
          },
        ),
      ),
    );
  }

}
