import 'package:flutter/material.dart';
import 'package:smarthometest/request/graph_request.dart'; // 기기 목록을 가져오는 요청 함수 import

class GroupDevicemanagementPage extends StatefulWidget {
  static String routeName = "/GroupDevicemanagementPage"; // 페이지의 라우트 이름
  const GroupDevicemanagementPage({super.key});

  @override
  State<GroupDevicemanagementPage> createState() => _GroupDevicemanagementPageState();
}

class _GroupDevicemanagementPageState extends State<GroupDevicemanagementPage> {
  late List<Map<String, dynamic>> _devices; // API에서 가져온 기기 목록을 저장할 변수
  List<Map<String, dynamic>> _selectedDevices = []; // 그룹에 선택된 기기를 저장할 리스트
  String? _groupName; // 그룹 이름을 저장할 변수

  @override
  void initState() {
    super.initState();
    _loadDevices(); // 기기 목록을 처음 로드
  }

  // 기기 목록을 새로 고치는 함수
  Future<void> _loadDevices() async {
    setState(() {
      _devices = getDeviceList(); // 기기 목록을 다시 가져오는 함수 호출
    });
  }

  // 그룹에 추가할 기기를 선택하는 다이얼로그를 표시하는 함수
  void _showGroupDialog() {
    List<bool> selected = List<bool>.filled(_devices.length, false); // 각 기기의 선택 상태를 저장할 리스트
    TextEditingController groupNameController = TextEditingController(); // 그룹 이름을 입력할 텍스트 컨트롤러

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("그룹에 추가할 기기 선택"), // 다이얼로그 제목
              content: SingleChildScrollView(  // SingleChildScrollView로 감싸기
                child: SizedBox(
                  width: double.maxFinite, // 다이얼로그 내용의 크기
                  child: Column(
                    children: [
                      TextField(
                        controller: groupNameController, // 그룹 이름 입력 텍스트 필드
                        decoration: InputDecoration(
                          labelText: "그룹 이름", // 텍스트 필드 라벨
                          hintText: "그룹 이름을 입력하세요", // 힌트 텍스트
                        ),
                      ),
                      SizedBox(height: 16), // 공백
                      ListView.builder(
                        shrinkWrap: true, // ListView의 크기를 내용에 맞게 조정
                        itemCount: _devices.length, // 기기 목록의 개수만큼 리스트 항목을 생성
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            title: Text(_devices[index]['deviceName']), // 기기 이름 표시
                            subtitle: Text(_devices[index]['modelName']), // 기기 모델명 표시
                            value: selected[index], // 해당 기기의 선택 상태
                            onChanged: (bool? value) {
                              setState(() {
                                selected[index] = value ?? false; // 선택 상태 변경
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // 취소 버튼: 다이얼로그 닫기
                  child: Text("취소"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      // 그룹 이름을 _groupName에 저장
                      _groupName = groupNameController.text.isNotEmpty
                          ? groupNameController.text
                          : null;

                      // 선택된 기기들을 _selectedDevices 리스트에 저장
                      _selectedDevices = _devices.asMap().entries
                          .where((entry) => selected[entry.key]) // 선택된 기기만 필터링
                          .map((entry) => entry.value)
                          .toList();

                      // 디버깅을 위한 출력
                      print("그룹 이름: $_groupName");
                      print("선택된 기기 목록: $_selectedDevices");
                    });

                    Navigator.pop(context); // 다이얼로그 닫기
                  },
                  child: Text("확인"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 그룹명을 클릭했을 때 선택된 기기 목록을 보여주는 팝업
  void _showSelectedDevicesPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("선택된 기기 목록"),
          content: _selectedDevices.isEmpty
              ? Text("선택된 기기가 없습니다.")
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: _selectedDevices.map((device) {
              return ListTile(
                title: Text(device['deviceName']),
                subtitle: Text(device['modelName']),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("닫기"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("기기 그룹 관리"), // AppBar 제목
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDevices, // 새로고침 버튼 눌렀을 때 기기 목록 새로고침
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 그룹 이름이 비어있지 않으면 표시
          if (_groupName != null && _groupName!.isNotEmpty)
            GestureDetector(
              onTap: _showSelectedDevicesPopup, // 그룹명을 클릭하면 팝업 띄우기
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "그룹 이름: $_groupName",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: _showGroupDialog, // 플로팅 액션 버튼을 눌렀을 때 다이얼로그 표시
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondary,), // "+" 아이콘 표시
      ),
    );
  }
}
