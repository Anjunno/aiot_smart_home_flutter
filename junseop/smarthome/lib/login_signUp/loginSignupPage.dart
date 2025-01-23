import "package:flutter/material.dart";
import "../SmartHomeMain.dart";
import "../SmartHomeMain2.dart";
import 'signUpPage.dart';

// LoginScreen 클래스는 애플리케이션의 로그인 화면을 정의하는 StatelessWidget입니다.
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 화면 너비가 600보다 작으면 작은 화면으로 간주합니다.
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
        body: Center(
          // 작은 화면에서는 열(Column) 레이아웃을 사용하고,
          // 큰 화면에서는 행(Row) 레이아웃을 사용하여 내용을 배치합니다.
            child: isSmallScreen
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _Logo(), // 앱의 로고를 표시하는 위젯
                _FormContent(), // 로그인 폼을 표시하는 위젯
              ],
            )
                : Container(
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(maxWidth: 800),
              child: Row(
                children: const [
                  Expanded(child: _Logo()), // 왼쪽에 로고를 표시
                  Expanded(
                    child: Center(child: _FormContent()), // 오른쪽에 로그인 폼을 표시
                  ),
                ],
              ),
            )));
  }
}

// _Logo 클래스는 로그인 화면의 로고와 텍스트를 정의하는 StatelessWidget입니다.
class _Logo extends StatelessWidget {
  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 작은 화면 여부를 판별
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image.asset(
        //   'good.png',
        //   width: isSmallScreen ? 100 : 200,
        //   height: isSmallScreen ? 100 : 200,
        // ),
        // FlutterLogo(size: isSmallScreen ? 100 : 200),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "로그인 / 회원가입",
            textAlign: TextAlign.center,
            style: isSmallScreen
                ? Theme.of(context).textTheme.headlineSmall // 작은 화면용 텍스트 스타일
                : Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.black), // 큰 화면용 텍스트 스타일
          ),
        )
      ],
    );
  }
}

// _FormContent 클래스는 로그인 폼을 정의하는 StatefulWidget입니다.
class _FormContent extends StatefulWidget {
  const _FormContent({Key? key}) : super(key: key);

  @override
  State<_FormContent> createState() => __FormContentState();
}

// __FormContentState는 로그인 폼의 상태를 관리합니다.
class __FormContentState extends State<_FormContent> {
  bool _isPasswordVisible = false; // 비밀번호 가시성 상태
  bool _rememberMe = false; // "Remember me" 체크박스 상태

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // 폼의 키

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: _formKey, // 폼에 키를 연결
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이메일 입력 필드
            TextFormField(
              validator: (value) {
                // 이메일 유효성 검사
                if (value == null || value.isEmpty) {
                  return '이메일을 입력해주세요..';
                }
                bool emailValid = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                if (!emailValid) {
                  return '유효한 이메일을 입력해주세요..';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: '이메일을 입력해주세요.',
                prefixIcon: Icon(Icons.email_outlined), // 이메일 아이콘
                border: OutlineInputBorder(),
              ),
            ),
            _gap(), // 간격 추가
            // 비밀번호 입력 필드
            TextFormField(
              validator: (value) {
                // 비밀번호 유효성 검사
                if (value == null || value.isEmpty) {
                  return '비밀번호 입력해주세요..';
                }
                if (value.length < 6) {
                  return '6자 이상 입력해주세요..';
                }
                return null;
              },
              obscureText: !_isPasswordVisible, // 비밀번호 숨김/보임
              decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '비밀번호를 입력해주세요.',
                  prefixIcon: const Icon(Icons.lock_outline_rounded), // 비밀번호 아이콘
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility_off // 비밀번호 숨김 아이콘
                        : Icons.visibility), // 비밀번호 보임 아이콘
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )),
            ),
            _gap(), // 간격 추가
            // "Remember me" 체크박스
            CheckboxListTile(
              value: _rememberMe,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _rememberMe = value;
                });
              },
              title: const Text('Remember me'),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: const EdgeInsets.all(0),
            ),
            _gap(), // 간격 추가
            // 로그인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    '로그인',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () {
                  // 폼 검증 후 다음 화면으로 이동 _formKey.currentState?.validate() -> 모든 validator 검사
                  if (_formKey.currentState?.validate() ?? false) {
                    print("로그인 성공");
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SmartHomeMain2()));
                  }
                },
              ),
            ),
            _gap(), // 간격 추가
            // 로그인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    '회원가입',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 위젯 사이의 간격을 추가하는 헬퍼 메서드
  Widget _gap() => const SizedBox(height: 16);
}
