import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smarthometest/deviceManagement/deviceManagement_page.dart';
import 'groupDeviceManagement_page.dart';

class DevicemanagementmainPage extends StatelessWidget {
  const DevicemanagementmainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // 탭바를 바로 최상단에 위치시킴
               TabBar(
                onTap: (index) {
                  HapticFeedback.lightImpact();},
                // labelColor: Colors.blue,
                // unselectedLabelColor: Colors.grey,
                // indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: '기기제어'),
                  Tab(text: '그룹 기기제어'),
                ],

              ),
              // 나머지 내용 (탭 뷰)
              const Expanded(
                child: TabBarView(
                  children: [
                    DevicemanagementPage(), // 기기 제어 페이지
                    GroupDevicemanagementPage(), // 그룹 기기 제어 페이지
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
