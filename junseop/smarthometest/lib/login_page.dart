import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthometest/onboarding_page.dart';
import 'package:smarthometest/providers/kakao_user_provider.dart';
import 'package:smarthometest/request/login_Signup_request.dart';
import 'package:smarthometest/signUp_page.dart';
import 'package:smarthometest/tab_page.dart';
import 'package:smarthometest/toastMessage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String routeName = "/LoginPage";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loginWithKakao() async {
    print("_loginWithKakao 실행");
    try {
      OAuthToken token;  // OAuth 토큰을 저장할 변수

      // 카카오톡이 설치되어 있는지 확인
      if (await isKakaoTalkInstalled()) {
        try {
          print("카카오톡 앱으로 로그인 시도");
          // 카카오톡 앱으로 로그인 시도
          token = await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공!');  // 로그인 성공 시 출력
        } catch (error) {
          print('카카오톡으로 로그인 실패: $error');  // 카카오톡 로그인 실패 시 출력

          // 카카오톡 로그인 실패한 경우, 카카오 계정으로 로그인 시도
          // 카카오톡이 설치되어 있지 않으면 카카오 계정으로 로그인 시도
          print('카카오톡이 설치되어 있지 않음. 카카오계정으로 로그인 시도합니다.');
          try {
            token = await UserApi.instance.loginWithKakaoAccount();
            print('카카오계정으로 로그인 성공!');  // ✅ 성공 로그
            showToast('카카오계정으로 로그인 성공!'); // ✅ 토스트로도 완료 알림
            print("토큰은 : $token");
          } catch (error) {
            print('카카오계정으로 로그인 실패: $error');
            showToast('카카오계정 로그인 실패: ${error.toString()}');
            return;
          }
        }
      } else {
        // 카카오톡이 설치되어 있지 않으면 카카오 계정으로 로그인 시도
        print("카카오톡이 설치되어 있지 않으면 카카오 계정으로 로그인 시도");
        token = await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공!');  // 계정 로그인 성공 시 출력
      }

      // 로그인 성공 후, 사용자 정보를 조회
      print("TOKEN === $token");
      await kakaoLogin(token.accessToken);
      User user = await UserApi.instance.me();
      print("카카오 로그인 닉네임: ${user.kakaoAccount?.profile?.nickname}");  // 사용자 정보 출력
      print("카카오 로그인 이메일: ${user.kakaoAccount?.email}");  // 사용자 정보 출력
      print("카카오 로그인 프로필URL: ${user.kakaoAccount?.profile?.profileImageUrl}");  // 사용자 정보 출력
      print("카카오 로그인 프로필썸네일URL: ${user.kakaoAccount?.profile?.thumbnailImageUrl}");  // 사용자 정보 출력

      // 화면에 로그인 완료 후, 원하는 페이지로 이동
      if (mounted) {
        // await kakaoLogin(token.accessToken);
        // ✅ Provider에 유저 정보 저장
        Provider.of<KaKaoUserProvider>(context, listen: false).setUser(user);

        // Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   TabPage.routeName,
        //       (route) => false,
        // );
        Navigator.pushNamedAndRemoveUntil(
          context,
          OnboardingPage.routeName,
              (route) => false,
        );

        showToast("카카오 로그인 완료: ${user.kakaoAccount?.profile?.nickname}");
      }
    } catch (e) {
      print("카카오 로그인 실패(예상치 못한 오류): $e");  // 예상치 못한 오류 출력
      showToast("카카오 로그인 실패: ${e.toString()}");  // 사용자에게 오류 메시지 토스트로 표시
    }
  }

  // Future<void> _loginWithKakao() async {
  //   try {
  //     print("🟡 카카오 로그인 시도 중...");
  //
  //     OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
  //
  //     print("🟢 카카오 계정 로그인 성공!");
  //     print("🔑 Access Token: ${token.accessToken}");
  //     print("🔄 서버로 로그인 요청 전송 중...");
  //
  //     await kakaoLogin(token.accessToken); // 백엔드 로그인 요청
  //
  //     print("✅ 카카오 로그인 프로세스 완료!");
  //   } catch (error) {
  //     print("❌ 카카오 로그인 실패: $error");
  //     Fluttertoast.showToast(
  //       msg: "카카오 로그인 실패: ${error.toString()}",
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.CENTER,
  //     );
  //   }
  // }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      ),
                      _gap(),
                      TextFormField(
                        controller: _idController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_passwordFocusNode);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Id',
                          hintText: '아이디를 입력해주세요.',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.done,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: '비밀번호를 입력해주세요.',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      _gap(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              String email = _idController.text;
                              String password = _passwordController.text;

                              print("아이디 : $email");
                              print("비밀번호 : $password");

                              if (await login(context, email, password)) {
                                final prefs = await SharedPreferences.getInstance();
                                final onboardingDone = prefs.getBool('onboarding_done') ?? false;

                                if (onboardingDone) {
                                  // 온보딩 이미 봤으면 메인 페이지로
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    TabPage.routeName,
                                        (route) => false,
                                  );
                                } else {
                                  // 아직 안 봤으면 온보딩 페이지로
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    OnboardingPage.routeName,
                                        (route) => false,
                                  );
                                }
                              } else {
                                // 로그인 실패 시 처리 (예: 토스트)
                                // showToast("입력한 정보를 확인해주세요!", gravity: ToastGravity.CENTER);
                              }
                            }
                          },

                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('로그인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      _gap(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, SignUpPage.routeName);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('회원가입', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      _gap(),
                      SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: _loginWithKakao, // 카카오 로그인 함수 호출
                          child: Image.asset("assets/kakao_logo.png"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
// final routes = {
//   TabPage.routeName: (context) => TabPage(),
//   SignUpPage.routeName: (context) => SignUpPage(),
// };


// Navigator.pushNamedAndRemoveUntil(context, TabPage.routeName, (route) => false);
// showToast("로그인 완료");

// // onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));},
// onPressed: () {Navigator.pushNamed(context, SignUpPage.routeName);},
// child: Title( color: Colors.amber, child: Text("SignUp")),