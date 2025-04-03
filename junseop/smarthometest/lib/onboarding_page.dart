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
            imagePath: 'assets/level1_cropped.png',
          ),
          _buildPage(
            title: '전기먹는 하마는 누구?',
            body: '기기별 사용량을 분석해서\n많이 쓰는 기기를 찾아보세요.',
            imagePath: 'assets/hippo_cropped.png',
          ),
          _buildPage(
            title: '스마트하게 절약해요',
            body: '그래프로 전력 사용량을 확인하고,\nAI 조언으로 더 똑똑하게 절약하세요.',
            imagePath: 'assets/graph1_cropped.png',
          ),
          _buildPage(
            title: '낭비되는 전기를 알려드려요',
            body: '불필요하게 켜진 기기를 감지해서\n푸시 알림으로 알려드려요.',
            imagePath: 'assets/push.png', // 관련 이미지 경고 느낌으로 교체 가능
          ),
          _buildPage(
            title: '실시간 기기 제어',
            body: '언제 어디서든\n기기를 원격으로 제어하세요.',
            imagePath: 'assets/onoff1_cropped.png',
            footer: _buildCheckboxFooter(),
          ),
        ],
        onDone: _onIntroEnd,
        onSkip: _onIntroEnd,
        showSkipButton: true,
        skip: const Text('건너뛰기', style: TextStyle(fontWeight: FontWeight.bold)),
        showBackButton: true,
        back: const Icon(Icons.arrow_back_ios_new),
        next: const Icon(Icons.arrow_forward_ios),
        done: Row(
          children: const [
            Icon(Icons.check),
            SizedBox(width: 4),
            Text('시작하기', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
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
            const SizedBox(height: 21),
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
      padding: const EdgeInsets.only(top: 30),
      child: Center(
        child: Container(
          width: 350, // ✅ 고정 너비
          height: 350, // ✅ 고정 높이
          alignment: Alignment.center,
          child: Image.asset(
            path,
            fit: BoxFit.contain, // ✅ 비율 유지
          ),
        ),
      ),
    );
  }


  /// ✅ 페이지 전체 스타일
  /// ✅ 페이지 전체 스타일 (중앙 정렬 느낌을 살리기 위해 조정)
  PageDecoration get pageDecoration => PageDecoration(
    titleTextStyle: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    bodyTextStyle: const TextStyle(fontSize: 20),
    imagePadding: EdgeInsets.zero, // 이미지 여백 제거
    contentMargin: const EdgeInsets.only(top: 20), // 전체 마진 줄임
    pageColor: Theme.of(context).colorScheme.surface,
    bodyFlex: 2,   // 내용 영역 비율 조금 줄임
    imageFlex: 5,  // 이미지 영역 비율 늘림 → 더 아래로 밀림 효과
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
