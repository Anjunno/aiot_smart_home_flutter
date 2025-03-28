import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  bool _showFab = true;
  late ScrollController _scrollController;


  final TextEditingController _groupNameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadGroups();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_showFab) setState(() => _showFab = false);
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_showFab) setState(() => _showFab = true);
      }
    });
  }


  @override
  void dispose() {
    _groupNameController.dispose();
    _scrollController.dispose(); // 🔹 꼭 메모리 해제해 주세요!
    super.dispose();
  }

  // ⭐ 그룹 목록 불러오기 ⭐
  Future<void> _loadGroups() async {
    setState(() {
      isLoading = true; // 그룹 목록 요청 시작 시 로딩 상태 활성화
    });

    // 서버에서 그룹 목록을 가져오는 비동기 요청
    var groups = await getGroupList(context);
    setState(() {
      _groups = groups;
      isLoading = false; // 데이터 로딩 완료 후 로딩 상태 비활성화
    });
  }

  // ⭐ 기기 목록 불러오기 ⭐
  Future<void> _loadDevices() async {
    // 서버에서 기기 목록을 가져오는 비동기 요청
    var devices = await getDeviceList(context);
    setState(() {
      _devices = devices;
    });
  }

  //⭐ 그룹 이름 추가 ⭐
  void _createGroupName() async {
    _groupNameController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("그룹 추가", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("그룹으로 사용할 이름을 추가해주세요. ", style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 15),
                TextField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    labelText: "그룹 이름",
                    labelStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("취소", style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final groupName = _groupNameController.text.trim();
                        if (groupName.isEmpty) {
                          showToast("그룹명을 입력하세요.");
                          return;
                        }
                        await createGroup(context, groupName);
                        await _loadGroups();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("확인", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              title: const Text("그룹 설정", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상태, 기기명, 사용 여부 레이블
                    Text("기기 목록을 선택하고, 상태를 설정하세요.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 10),

                    // 기기 목록 출력 및 선택
                    Column(
                      children: _devices.map((device) {
                        return InkWell(
                          child: Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              title: Text(device['name'], style: const TextStyle(fontSize: 16)),
                              subtitle: Text('ID: ${device['id']}', style: const TextStyle(color: Colors.grey, fontSize: 9)),
                              leading: Checkbox(
                                value: deviceSelection[device['id']],
                                onChanged: (bool? value) {
                                  setState(() {
                                    deviceSelection[device['id']] = value ?? false;
                                  });
                                },
                              ),
                              trailing: Switch(
                                value: deviceState[device['id']] == "on",
                                onChanged: deviceSelection[device['id']]!
                                    ? (bool value) {
                                  setState(() {
                                    deviceState[device['id']] = value ? "on" : "off";
                                  });
                                }
                                    : null, // 체크 안된 기기는 비활성화
                              ),
                              onTap: () {
                                setState(() {
                                  deviceSelection[device['id']] = !deviceSelection[device['id']]!;
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                // 취소 버튼
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소", style: TextStyle(fontSize: 16, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                // 확인 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () async {
                    // 선택된 기기 목록 저장
                    List<Map<String, dynamic>> selectedDevices = _devices
                        .where((device) => deviceSelection[device['id']] == true)
                        .map((device) => {
                      "plugId": device['id'],
                      "action": deviceState[device['id']]
                    }).toList();

                    if (selectedDevices.isEmpty) {
                      // 체크된 기기가 없을 경우 토스트 메시지 표시
                      showToast("최소 하나의 기기를 설정해주세요.", gravity: ToastGravity.CENTER);
                      return;  // 함수 종료
                    }

                    print("액션설정\n" + selectedDevices.toString());
                    groupData = {
                      "groupId": groupId,
                      "devices": selectedDevices,
                    };

                    setState(() {
                      print(groupData); // 디버깅용 출력
                    });

                    await groupAction(context, groupData);

                    Navigator.pop(context);
                  },
                  child: const Text("확인", style: TextStyle(color: Colors.white)),
                )
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
    // return Scaffold(
    //   appBar: AppBar(
    //     // title: const Text("그룹 관리", style: TextStyle(fontWeight: FontWeight.bold)),
    //     toolbarHeight: 50.0,
    //     automaticallyImplyLeading: false,
    //     // backgroundColor: Colors.blueAccent, // 앱바 색상
    //     centerTitle: true, // 제목 중앙 정렬
    //     actions: [
    //       Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: FloatingActionButton(
    //           onPressed: _createGroupName,
    //           backgroundColor: Theme.of(context).colorScheme.secondary,
    //           foregroundColor: Theme.of(context).colorScheme.onSecondary,
    //           child: const Icon(Icons.add, size: 30),
    //         ),
    //       ),
    //     ],
    //   ),

    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 50.0,
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      // ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
        onPressed: _createGroupName,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        child:  Icon(Icons.add, color: Theme.of(context).colorScheme.surface,),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadGroups();
          await _loadDevices();
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _groups.isEmpty
            ?  const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.group_off, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text('등록된 그룹이 없습니다.', style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    )

    : ListView.builder(
          controller: _scrollController,
          itemCount: _groups.length,
          itemBuilder: (context, index) {
            final group = _groups[index];
            bool groupState = (group['devices'] ?? [])
                .every((device) => device['power'] == true);

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
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
                            String groupName = _groups[index]["groupName"];
                            await groupDelete(context, _groups[index]["groupId"]);
                            // showToast("$groupName 이(가) 삭제되었습니다.");
                            await _loadGroups();
                          }, icon: const Icon(Icons.delete)),
                      IconButton(onPressed: () {
                        groupActionRun(context, _groups[index]["groupId"]);
                      },
                          icon: const Icon(Icons.play_arrow)),
                      // ElevatedButton(
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Theme.of(context)
                      //           .colorScheme
                      //           .onInverseSurface,
                      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      //       elevation: 10
                      //     ),
                      //     onPressed: () {
                      //       groupActionRun(_groups[index]["groupId"]);
                      //     },
                      //     child: Text("실행")
                      // ),
                    ],
                  ),
                  onTap: () async {
                    // groupActionCheck 결과 받아오기
                    List<Map<String, dynamic>> groupAction = await groupActionCheck(context, _groups[index]["groupId"]);

                    // 다이얼로그 표시
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Row(
                            children: [
                              Icon(Icons.group, color: Theme.of(context).colorScheme.primary,),
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
                                              color: Theme.of(context).colorScheme.surfaceContainer,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              elevation: 4,
                                              child: ListTile(
                                                leading: Icon(Icons.power, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                                title: Text('${plug["plugName"]}',
                                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Plug ID: ${plug["plugId"]}', style: TextStyle(fontSize: 10),),
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

                            ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("닫기", style: TextStyle(color: Colors.white)),
                            ),

                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
