import 'package:flutter/material.dart';

// 서버로 메시지를 전송하는 함수 (실제 서버 요청을 대체하는 예시 함수)
Future<String> sendChat(String message) async {
  await Future.delayed(Duration(seconds: 2)); // 서버 요청 시간 시뮬레이션
  return "응답: $message"; // 서버 응답 (실제 서버에서 응답이 오면 여기에 맞게 수정)
}

class ChatPage extends StatefulWidget {
  static String routeName = "/ChatPage";
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = []; // 메시지를 저장할 리스트

  // 메시지를 전송하고 응답을 처리하는 함수
  void _sendMessage() async {
    String message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'message': message}); // 사용자가 보낸 메시지 추가
    });
    _controller.clear();

    // 서버로 메시지 전송
    String response = await sendChat(message);

    // 서버 응답을 받은 후 상대방의 메시지를 추가
    setState(() {
      _messages.add({'sender': 'other', 'message': response}); // 서버 응답 메시지 추가
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("채팅 페이지"),
      ),
      body: Column(
        children: [
          // 채팅 메시지 목록
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var messageData = _messages[index];
                bool isUserMessage = messageData['sender'] == 'user';

                return Align(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      decoration: BoxDecoration(
                        color: isUserMessage ? Theme.of(context).colorScheme.secondary : Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomLeft: isUserMessage ? Radius.circular(15) : Radius.circular(0),
                          bottomRight: isUserMessage ? Radius.circular(0) : Radius.circular(15),
                        ),
                      ),
                      child: Text(
                        messageData['message']!,
                        style: TextStyle(
                          color: isUserMessage ? Colors.white : Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 입력 필드와 전송 버튼
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
