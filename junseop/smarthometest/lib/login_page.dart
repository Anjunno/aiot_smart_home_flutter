import 'package:flutter/material.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithKakao() async {
    try {
      OAuthToken token;  // OAuth 토큰을 저장할 변수

      // 카카오톡이 설치되어 있는지 확인
      if (await isKakaoTalkInstalled()) {
        try {
          // 카카오톡 앱으로 로그인 시도
          token = await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공!');  // 로그인 성공 시 출력
        } catch (error) {
          print('카카오톡으로 로그인 실패: $error');  // 카카오톡 로그인 실패 시 출력

          // 카카오톡 로그인 실패한 경우, 카카오 계정으로 로그인 시도
          try {
            token = await UserApi.instance.loginWithKakaoAccount();
            print('카카오계정으로 로그인 성공!');  // 계정 로그인 성공 시 출력
          } catch (error2) {
            print('카카오계정으로도 로그인 실패: $error2');  // 계정 로그인 실패 시 출력
            showToast('로그인 실패: ${error2.toString()}');  // 사용자에게 실패 메시지 토스트로 표시
            return;  // 로그인 실패 시 종료
          }
        }
      } else {
        // 카카오톡이 설치되어 있지 않으면 카카오 계정으로 로그인 시도
        token = await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공!');  // 계정 로그인 성공 시 출력
      }

      // 로그인 성공 후, 사용자 정보를 조회
      User user = await UserApi.instance.me();
      print("카카오 로그인 최종 성공: ${user.kakaoAccount?.profile?.nickname}");  // 사용자 정보 출력

      // 화면에 로그인 완료 후, 원하는 페이지로 이동
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, TabPage.routeName, (route) => false);  // 로그인 후 이동할 페이지로 이동
        showToast("카카오 로그인 완료: ${user.kakaoAccount?.profile?.nickname}");  // 로그인 성공 토스트로 표시
      }
    } catch (e) {
      print("카카오 로그인 실패(예상치 못한 오류): $e");  // 예상치 못한 오류 출력
      showToast("카카오 로그인 실패: ${e.toString()}");  // 사용자에게 오류 메시지 토스트로 표시
    }
  }




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
                        controller: _emailController,
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
                              String email = _emailController.text;
                              String password = _passwordController.text;

                              print("아이디 : $email");
                              print("비밀번호 : $password");
                              try {
                                // print(await KakaoSdk.origin);
                                await Navigator.pushNamedAndRemoveUntil(context, TabPage.routeName, (route) => false);
                                showToast("로그인 완료");
                              } catch (e) {
                                print("로그인 화면 전환 중 오류 발생: $e");
                                showToast("로그인 중 오류가 발생했습니다.");
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