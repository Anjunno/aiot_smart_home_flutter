// static String routeName = "/OnboardingPage";

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthometest/tab_page.dart';

class OnboardingPage extends StatefulWidget {
  static String routeName = "/OnboardingPage";
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        globalBackgroundColor: Theme.of(context).colorScheme.surface,
        pages: [
          _buildPage(
            title: '요금을 미리 예측하고 절약해요',
            body: '예상 요금을 확인하고\n누진 구간도 쉽게 파악하세요.',
            imagePath: 'assets/level.jpg',
          ),
          _buildPage(
            title: '전기먹는 하마는 누구?',
            body: '기기별 사용량을 분석해서\n많이 쓰는 기기를 찾아보세요.',
            imagePath: 'assets/pieChart.jpg',
          ),
          _buildPage(
            title: '스마트하게 절약해요',
            body: '그래프로 전력 사용량을 확인하고,\nAI 조언으로 더 똑똑하게 절약하세요.',
            imagePath: 'assets/graph.jpg',
          ),
          _buildPage(
            title: '낭비되는 전기를 알려드려요',
            body: '불필요하게 켜진 기기를 감지해서\n푸시 알림으로 알려드려요.',
            imagePath: 'assets/alert_device.png', // 관련 이미지 경고 느낌으로 교체 가능
          ),
          _buildPage(
            title: '실시간 기기 제어',
            body: '언제 어디서든\n기기를 원격으로 제어하세요.',
            imagePath: 'assets/onoff.jpg',
            footer: _buildCheckboxFooter(),
          ),
        ],
        onDone: _onIntroEnd,
        onSkip: _onIntroEnd,
        showSkipButton: true,
        skip: const Text('건너뛰기', style: TextStyle(fontWeight: FontWeight.bold)),
        showBackButton: true,
        back: const Icon(Icons.arrow_back),
        next: const Icon(Icons.arrow_forward),
        done: const Text('시작하기', style: TextStyle(fontWeight: FontWeight.bold)),
        dotsDecorator: DotsDecorator(
          size: const Size(8.0, 8.0),
          activeSize: const Size(16.0, 8.0),
          color: Colors.grey,
          activeColor: Theme.of(context).colorScheme.primary,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        dotsContainerDecorator: const BoxDecoration(color: Colors.transparent),
        curve: Curves.easeInOut,
      ),
    );
  }

  /// ✅ 온보딩 각 페이지 구성
  PageViewModel _buildPage({
    required String title,
    required String body,
    required String imagePath,
    Widget? footer,
  }) {
    return PageViewModel(
      title: title,
      bodyWidget: Column(
        children: [
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          if (footer != null) ...[
            const SizedBox(height: 16),
            footer,
          ]
        ],
      ),
      image: buildImage(imagePath),
      decoration: pageDecoration,
    );
  }


  /// ✅ 이미지 정렬 및 사이즈 조절
  /// ✅ 이미지 정렬 및 사이즈 조절 (크게 보이도록 수정)
  Widget buildImage(String path) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        width: double.infinity,
        height: 300, // 높이를 늘려서 크게 표시
        child: Image.asset(
          path,
          fit: BoxFit.contain, // 비율 유지하면서 최대한 크게
        ),
      ),
    );
  }


  /// ✅ 페이지 전체 스타일
  PageDecoration get pageDecoration => PageDecoration(
    titleTextStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    bodyTextStyle: const TextStyle(fontSize: 16),
    imagePadding: const EdgeInsets.only(top: 10), // 상단 여백 줄임
    contentMargin: const EdgeInsets.only(top: 40), // 전체 내용 아래로
    pageColor: Theme.of(context).colorScheme.surface,
    bodyFlex: 3,
    imageFlex: 4, // 이미지가 더 공간 차지하게
  );


  /// ✅ 마지막 페이지 체크박스
  Widget _buildCheckboxFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _dontShowAgain = !_dontShowAgain;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.grey, // ✅ 체크 안됐을 때 테두리 색
              ),
              child: Checkbox(
                value: _dontShowAgain,
                activeColor: Theme.of(context).colorScheme.primary, // ✅ 체크됐을 때 색
                checkColor: Colors.white, // ✅ 체크표시 색
                onChanged: (value) {
                  setState(() {
                    _dontShowAgain = value ?? false;
                  });
                },
              ),
            ),
            const Text(
              "다시 보지 않기",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }



  /// ✅ 온보딩 종료 시 처리
  Future<void> _onIntroEnd() async {
    print(_dontShowAgain);
    if (_dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TabPage()),
    );
  }
}
