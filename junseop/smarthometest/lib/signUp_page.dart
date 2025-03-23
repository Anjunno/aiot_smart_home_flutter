import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smarthometest/request/login_Signup_request.dart';
import 'package:smarthometest/toastMessage.dart';

class SignUpPage extends StatefulWidget {
  static String routeName = "/SignUpPage";

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _nickNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isNickNameChecked = false;
  bool _isIdChecked = false;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _nickNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _idFocusNode.dispose();
    _nameFocusNode.dispose();
    _nickNameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Signup',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                        ),
                        _gap(),

                        /// 이름 입력 필드
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(_nickNameFocusNode);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이름을 입력해주세요.';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: '이름을 입력해주세요.',
                            prefixIcon: Icon(Icons.account_circle_rounded),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        _gap(),

                        /// 닉네임 입력 필드 + 확인 버튼
                        Row(
                          children: [
                            Expanded(
                              flex: 8,
                              child: TextFormField(
                                controller: _nickNameController,
                                focusNode: _nickNameFocusNode,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(_idFocusNode);
                                },
                                onChanged: (_) {
                                  if (_isNickNameChecked) {
                                    setState(() => _isNickNameChecked = false);
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '닉네임을 입력해주세요.';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Nickname',
                                  hintText: '닉네임을 입력해주세요.',
                                  prefixIcon: Icon(Icons.account_circle),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 50,
                                child: _isNickNameChecked
                                    ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: null,
                                  child: const Icon(Icons.check, color: Colors.white),
                                )
                                    : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () async {
                                    if (_nickNameController.text.isEmpty) {
                                      showToast('닉네임을 입력하세요.');
                                      return;
                                    }
                                    final result = await nickNameExists(_nickNameController.text);
                                    if (result == true) {
                                      setState(() {
                                        _isNickNameChecked = true;
                                      });
                                    }
                                  },
                                  child: const Text('확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _gap(),

                        /// 아이디 입력 필드 + 확인 버튼
                        Row(
                          children: [
                            Expanded(
                              flex: 8,
                              child: TextFormField(
                                controller: _idController,
                                focusNode: _idFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                                },
                                onChanged: (_) {
                                  if (_isIdChecked) {
                                    setState(() => _isIdChecked = false);
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '아이디를 입력해주세요.';
                                  }
                                  if (value.length < 5) {
                                    return '아이디는 최소 5자 이상이어야 합니다.';
                                  }
                                  if (value.length > 10) {
                                    return '아이디는 최대 10자 이하이어야 합니다.';
                                  }
                                  if (RegExp(r'[ㄱ-ㅎㅏ-ㅣ가-힣]').hasMatch(value)) {
                                    return '아이디에 한글은 사용할 수 없습니다.';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Id',
                                  hintText: '아이디를 입력해주세요.',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 50,
                                child: _isIdChecked
                                    ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: null,
                                  child: const Icon(Icons.check, color: Colors.white),
                                )
                                    : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () async {
                                    final idText = _idController.text;

                                    if (idText.isEmpty) {
                                      showToast('아이디를 입력하세요.', gravity: ToastGravity.CENTER);
                                      return;
                                    }

                                    if (idText.length < 5 || idText.length > 10) {
                                      showToast('아이디는 5자 이상, 10자 이하로 입력해주세요.', gravity: ToastGravity.CENTER);
                                      return;
                                    }

                                    if (RegExp(r'[ㄱ-ㅎㅏ-ㅣ가-힣]').hasMatch(idText)) {
                                      showToast('아이디에 한글은 사용할 수 없습니다.', gravity: ToastGravity.CENTER);
                                      return;
                                    }

                                    final result = await userIdExists(idText);
                                    if (result == true) {
                                      setState(() {
                                        _isIdChecked = true;
                                      });
                                    }
                                  },
                                  child: const Text('확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),

                        _gap(),

                        /// 비밀번호 입력 필드
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 입력해주세요.';
                            }
                            if (value.length < 8) {
                              return '비밀번호는 최소 8자 이상이어야 합니다.';
                            }
                            if (value.length > 20) {
                              return '비밀번호는 최대 20자 이하이어야 합니다.';
                            }
                            if (RegExp(r'[ㄱ-ㅎㅏ-ㅣ가-힣]').hasMatch(value)) {
                              return '비밀번호에 한글은 사용할 수 없습니다.';
                            }
                            return null;
                          },
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

                        /// 비밀번호 확인 입력 필드
                        TextFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호 확인을 입력해주세요.';
                            }
                            if (value != _passwordController.text) {
                              return '비밀번호가 일치하지 않습니다.';
                            }
                            return null;
                          },
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: '비밀번호를 확인해주세요.',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        _gap(),

                        /// 회원가입 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            onPressed: _onSignUpPressed,
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text('회원가입', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        _gap(),
                      ],
                    ),
                  ),
                ),
                _gap(),  // 여백 추가
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);

  Future<void> _onSignUpPressed() async {
    if (!_isNickNameChecked) {
      showToast('닉네임 중복 확인을 해주세요.', gravity: ToastGravity.CENTER);
      return;
    }
    if (!_isIdChecked) {
      showToast('아이디 중복 확인을 해주세요.', gravity: ToastGravity.CENTER);
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final result = await signUp(
          _idController.text,
          _passwordController.text,
          _nameController.text,
          _nickNameController.text
      );
      if(result) Navigator.pop(context);

    } else {
      showToast('입력한 정보를 확인하세요.', gravity: ToastGravity.CENTER);
    }
  }
}
