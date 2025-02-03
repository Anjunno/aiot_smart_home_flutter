import 'package:flutter/material.dart';
import 'package:smarthometest/signUp_page.dart';
import 'package:smarthometest/tab_page.dart';
import 'package:smarthometest/toastMessage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String routeName = "/LoginPage";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false; // 비밀번호 가시성 상태
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // 폼의 키
  final TextEditingController _emailController = TextEditingController(); // 이메일 컨트롤러
  final TextEditingController _passwordController = TextEditingController(); // 비밀번호 컨트롤러
  final FocusNode _passwordFocusNode = FocusNode(); // 비밀번호 입력 필드 포커스 노드 추가

  @override
  void dispose() {
    // TextEditingController 해제
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  key: _formKey, // 폼에 키를 연결
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
                        textInputAction: TextInputAction.next, // 다음 필드로 이동
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_passwordFocusNode);
                        },
                        validator: (value) {
                          // 이메일 유효성 검사
                          // if (value == null || value.isEmpty) {
                          //   return '이메일을 입력해주세요..';
                          // }
                          // bool emailValid = RegExp(
                          //     r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          //     .hasMatch(value);
                          // if (!emailValid) {
                          //   return '유효한 이메일을 입력해주세요..';
                          // }
                          // return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: '이메일을 입력해주세요.',
                          prefixIcon: Icon(Icons.email_outlined), // 이메일 아이콘
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode, // 포커스 노드 설정
                        textInputAction: TextInputAction.done, // 완료 버튼
                        validator: (value) {
                          // 비밀번호 유효성 검사
                          // if (value == null || value.isEmpty) {
                          //   return '비밀번호 입력해주세요..';
                          // }
                          // if (value.length < 6) {
                          //   return '6자 이상 입력해주세요..';
                          // }
                          // return null;
                        },
                        obscureText: !_isPasswordVisible, // 비밀번호 숨김/보임
                        decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: '비밀번호를 입력해주세요.',
                            prefixIcon: const Icon(Icons.lock_outline_rounded,), // 비밀번호 아이콘
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible
                                  ? Icons.visibility // 비밀번호 숨김 아이콘
                                  : Icons.visibility_off
                              ), // 비밀번호 보임 아이콘
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            )),
                      ),
                      _gap(),
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
                          onPressed: () async {
                            // 폼 검증 후 다음 화면으로 이동 _formKey.currentState?.validate() -> 모든 validator 검사
                            if (_formKey.currentState?.validate() ?? false) {

                              String email = _emailController.text; // 입력된 이메일 값 가져오기
                              String password = _passwordController.text; // 입력된 비밀번호 값 가져오기

                              print("아이디 : $email");
                              print("비밀번호 : $password");
                              try {
                                // 비동기 화면 전환 처리
                                await Navigator.pushNamedAndRemoveUntil(context, TabPage.routeName, (route) => false);
                                showToast("로그인 완료");
                              } catch (e) {
                                // 에러 처리
                                print("로그인 화면 전환 중 오류 발생: $e");
                                showToast("로그인 중 오류가 발생했습니다.");
                              }
                            }
                          },
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
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              '회원가입',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                            // onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));},
                            onPressed: () {Navigator.pushNamed(context, SignUpPage.routeName);},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

// 위젯 사이의 간격을 추가하는 헬퍼 메서드
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