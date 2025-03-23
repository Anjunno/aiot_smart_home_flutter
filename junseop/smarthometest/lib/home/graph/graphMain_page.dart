import 'package:flutter/material.dart';
import 'package:smarthometest/home/graph/dayGraph.dart';
import 'package:smarthometest/main_page.dart';
import 'package:smarthometest/home/graph/monthGraph.dart';
import 'package:smarthometest/home/graph/deviceGraph.dart';

class GraphMainPage extends StatelessWidget {
  static String routeName = "/GraphMainPage";
  const GraphMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [

              // 탭바를 바로 최상단에 위치시킴
              const TabBar(
                // labelColor: Colors.blue,
                // unselectedLabelColor: Colors.grey,
                // indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: '기기별'),
                  Tab(text: '일별'),
                  Tab(text: '월별'),
                ],
              ),
              // 나머지 내용 (탭 뷰)
              const Expanded(
                child: TabBarView(
                  children: [
                    DeviceGraph(),
                    DayGraph(),
                    MonthGraph(),
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
