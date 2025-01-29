import 'package:flutter/material.dart';
import 'package:smarthometest/root_page.dart';
import 'package:smarthometest/tab_page.dart';
import 'package:smarthometest/toastMessage.dart';

class SignUpPage extends StatefulWidget {

  static String routeName = "/SignUpPage";

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordVisible = false; // 비밀번호 가시성 상태
  bool _isConfirmPasswordVisible = false; // 비밀번호 확인 가시성 상태

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // 폼 키

  // TextEditingController를 사용하여 텍스트 필드의 값 관리
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // 컨트롤러를 dispose해서 메모리 누수를 방지합니다.
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Form(
            key: _formKey, // 폼에 키를 연결
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Signup',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
                _gap(), // 간격 추가
                // 이메일 입력 필드
                TextFormField(
                  controller: _emailController,
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
                _gap(), // 간격 추가

                // 비밀번호 입력 필드
                TextFormField(
                  controller: _passwordController,
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
                      prefixIcon: const Icon(Icons.lock_outline_rounded), // 비밀번호 아이콘
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible
                            ? Icons.visibility // 비밀번호 숨김 아이콘
                            : Icons.visibility_off), // 비밀번호 보임 아이콘
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      )),
                ),
                _gap(), // 간격 추가

                // 비밀번호 확인 입력 필드
                TextFormField(
                  controller: _confirmPasswordController,
                  validator: (value) {
                    // // 비밀번호 확인 유효성 검사
                    // if (value == null || value.isEmpty) {
                    //   return '비밀번호를 다시 입력해주세요..';
                    // }
                    // if (value != _passwordController.text) {
                    //   return '비밀번호가 일치하지 않습니다..';
                    // }
                    // return null;
                  },
                  obscureText: !_isConfirmPasswordVisible, // 비밀번호 확인 숨김/보임
                  decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: '비밀번호를 확인해주세요.',
                      prefixIcon: const Icon(Icons.lock_outline_rounded), // 비밀번호 아이콘
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_isConfirmPasswordVisible
                            ? Icons.visibility // 비밀번호 확인 숨김 아이콘
                            : Icons.visibility_off), // 비밀번호 확인 보임 아이콘
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      )),
                ),
                _gap(), // 간격 추가

                // 회원가입 버튼
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
                      // 폼 검증 후 회원가입 처리
                      if (_formKey.currentState?.validate() ?? false) {
                        print("회원가입 성공");
                        // 회원가입 후 로그인 화면으로 이동
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                _gap(), // 간격 추가
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 위젯 사이의 간격을 추가하는 헬퍼 메서드
  Widget _gap() => const SizedBox(height: 16);
}