import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:smarthometest/request/pushNotification_request.dart';

class PushNotificationLog extends StatefulWidget {
  static String routeName = "/PushNotificationLog";
  const PushNotificationLog({super.key});

  @override
  State<PushNotificationLog> createState() => _PushNotificationLogState();
}

class _PushNotificationLogState extends State<PushNotificationLog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allLogs = [];
  List<Map<String, dynamic>> _filteredLogs = [];
  String _searchKeyword = '';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final logs = await getPushNotificationLog(context);
      setState(() {
        _allLogs = logs;
        _applySearchFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _applySearchFilter() {
    setState(() {
      _filteredLogs = _allLogs.where((log) {
        final message = log['message']?.toString().toLowerCase() ?? '';
        return message.contains(_searchKeyword.toLowerCase());
      }).toList();
    });
  }

  String _formatGroupDate(String time) {
    final DateTime parsedTime = DateTime.tryParse(time) ?? DateTime.now();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(parsedTime.year, parsedTime.month, parsedTime.day);

    if (logDate == today) return '오늘';
    if (logDate == yesterday) return '어제';
    return DateFormat('yyyy.MM.dd').format(logDate);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 화면 터치 시 키보드 내리기
      child: Scaffold(
        appBar: AppBar(title:  Text("푸시 알림 내역", style: TextStyle(color: Theme.of(context).colorScheme.surface),),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.surface,),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
            ? const Center(child: Text("오류가 발생했습니다."))
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    hintText: '메시지 검색...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: const Icon(Icons.search, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _searchKeyword = '';
                        _applySearchFilter();
                        FocusScope.of(context).unfocus();
                      },
                    )
                        : null,
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchKeyword = value;
                      _applySearchFilter();
                    });
                  },
                ),
              ),
            ),
            _filteredLogs.isEmpty
                ? Expanded( // ✅ 이게 꼭 필요함
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ← 세로축 중앙
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.notifications_off, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text("알림 기록이 없습니다.", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )


        : Expanded(
              child: RefreshIndicator(
                onRefresh: _loadLogs,
                child: GroupedListView<Map<String, dynamic>, String>(
                  elements: _filteredLogs,
                  groupBy: (log) => _formatGroupDate(log['time'] ?? ''),
                  groupSeparatorBuilder: (String group) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                    child: Text(
                      group,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  itemBuilder: (context, log) {
                    final sender = log['sender'] ?? 'Unknown';
                    final time = log['time'] ?? '';
                    final message = log['message'] ?? '알 수 없는 메시지';

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(message, style: const TextStyle(fontSize: 15)),
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
                  order: GroupedListOrder.DESC,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
