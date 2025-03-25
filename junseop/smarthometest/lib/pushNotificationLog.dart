import 'package:flutter/material.dart';
import 'package:smarthometest/request/pushNotification_request.dart';

class PushNotificationLog extends StatefulWidget {
  static String routeName = "/PushNotificationLog";
  const PushNotificationLog({super.key});

  @override
  State<PushNotificationLog> createState() => _PushNotificationLogState();
}

class _PushNotificationLogState extends State<PushNotificationLog> {
  late Future<List<Map<String, dynamic>>> _pushNotificationLogFuture;

  @override
  void initState() {
    super.initState();
    _pushNotificationLogFuture = getPushNotificationLog(context); // 초기 로딩
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("푸시 알림 로그"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pushNotificationLogFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("오류가 발생했습니다."));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("알림 기록이 없습니다."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final log = data[index];
              final sender = log['sender'] ?? 'Unknown';
              final time = log['time'] ?? '';
              final message = log['message'] ?? '알 수 없는 메시지';

              return Align(
                alignment: Alignment.centerLeft, // 왼쪽 정렬 (상대방 메시지 느낌)
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sender,
                        style:  TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        time,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
