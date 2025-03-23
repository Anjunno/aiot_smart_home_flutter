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
      body: Column(
        children: [
          // ✅ IntroductionScreen 위젯
          Expanded(
            child: IntroductionScreen(
              globalBackgroundColor: Colors.white,
              pages: [
                PageViewModel(
                  title: '스마트하게 절약해요',
                  body: '에너지 사용을 한눈에 보고\n쉽게 관리하세요.',
                  image: buildImage('assets/good.png'),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  title: '실시간 기기 제어',
                  body: '언제 어디서든\n기기를 원격으로 제어하세요.',
                  image: buildImage('assets/good.png'),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  title: '전기료 절감 도우미',
                  body: '패턴을 분석해서\n절전 팁을 알려드려요.',
                  image: buildImage('assets/good.png'),
                  decoration: pageDecoration,
                ),
              ],
              onDone: () async {
                if (_dontShowAgain) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboarding_done', true);
                }
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const TabPage()),
                );
              },
              onSkip: () async {
                if (_dontShowAgain) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboarding_done', true);
                }
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const TabPage()),
                );
              },
              showSkipButton: true,
              skip: const Text('건너뛰기', style: TextStyle(fontWeight: FontWeight.bold)),
              showBackButton: true, // ✅ 이전 버튼 활성화
              back: const Icon(Icons.arrow_back),
              next: const Icon(Icons.arrow_forward),
              done: const Text('시작하기', style: TextStyle(fontWeight: FontWeight.bold)),
              dotsDecorator: DotsDecorator(
                size: const Size(10.0, 10.0),
                color: Colors.grey.shade300,
                activeSize: const Size(22.0, 10.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
              curve: Curves.easeInOut,
            ),
          ),

          // ✅ 체크박스를 아래에 고정
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _dontShowAgain,
                onChanged: (value) {
                  setState(() {
                    _dontShowAgain = value ?? false;
                  });
                },
              ),
              const Text("다시 보지 않기"),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildImage(String path) {
    return Center(
      child: Image.asset(path, width: 250),
    );
  }

  PageDecoration get pageDecoration => const PageDecoration(
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    bodyTextStyle: TextStyle(
      fontSize: 16,
    ),
    imagePadding: EdgeInsets.only(top: 40),
    pageColor: Colors.white,
  );
}
