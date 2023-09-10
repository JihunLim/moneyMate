import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:moneymate/screens/0_common/utility.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool emailVerified = false; // 이메일 인증 여부를 저장하는 변수
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? _passwordError;
  String? _emailError;

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  /* 이메일 인증 코드 보내기 */
  Future<void> sendEmailVerification() async {
    logger.d("이메일인증코드 전송하기 : sendEmailVerification");
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      showToast("인증 이메일을 보냈습니다. 확인해주세요.");
    }
  }

  /* Firebase로 회원가입 하기 */
  Future<void> signUpWithEmailPassword() async {
    logger.d("회원가입 하기 : signUpWithEmailPassword");
    try {
      //유효성 검사
      if(!(chkPwdOk && chkEmailOk)) return;

      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        await sendEmailVerification();
      }

      //로그인 화면으로 이동
      Get.back();

    } catch (e) {
      logger.d(e);
      showToast("회원가입에 실패했습니다. 다시 시도해주세요.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            '머니메이트 회원가입',
            style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
          ),
          backgroundColor: const Color.fromRGBO(236, 228, 215, 1.0),
          elevation: 0.0,
          leadingWidth: 40,  // Increase the width of the leading area to accommodate the title
          leading: IconButton(
            padding: const EdgeInsets.only(right:4, left:20),
            onPressed: () async {
              // 뒤로 이동하기
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 15),
            color: Colors.black,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red.withOpacity(0.2),
                Colors.orange.withOpacity(0.2),
                Colors.yellow.withOpacity(0.2),
                Colors.green.withOpacity(0.2),
                Colors.blue.withOpacity(0.2),
                Colors.indigo.withOpacity(0.2),
                Colors.purple.withOpacity(0.2)
              ],
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left:20,right:20,top:50,bottom:20),
          child: Column(
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "이메일",
                  border: const OutlineInputBorder(),
                  helperText: "사용가능한 이메일 주소를 입력해주세요.",
                  errorText: _emailError,
                ),
                onChanged: (value) {
                  if (!isValidEmail(value)) {
                    setState(() {
                      _emailError = "올바른 이메일 주소를 입력해주세요.";
                    });
                  }else{
                    setState(() {
                      _emailError = null;
                    });
                  } 
                }
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true, // 비밀번호 필드는 내용을 가리기 위해
                decoration: InputDecoration(
                  labelText: "비밀번호",
                  border: const OutlineInputBorder(),
                  helperText: "비밀번호는 영문자와 숫자를 포함한 6자 이상이어야 합니다.",
                  errorText: _passwordError,
                ),
                onChanged: (value) {
                  if (!validatePassword(value)) {
                    setState(() {
                      _passwordError = "비밀번호를 확인해주세요!";
                      if(value.isEmpty) _passwordError = null;
                    });
                  } else {
                    setState(() {
                      _passwordError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "• 이메일 인증을 완료해야 가입이 완료됩니다.",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900]),
                ),
              ),
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: Text(
              //     emailVerified
              //         ? "(이메일 인증 완료)"
              //         : "(이메일 미인증)",
              //     style: const TextStyle(
              //         fontSize: 12,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.black),
              //   ),
              // ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: signUpWithEmailPassword, //회원가입 로직 추가
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0), backgroundColor: Colors.green[500], // 양 옆에 20.0만큼의 여백 추가
                  minimumSize: const Size(double.infinity, 35), // 버튼의 배경색을 파란색으로 설정
                ),
                child: const Text('회원가입',
                  style:TextStyle(
                    color: Colors.white,  // 텍스트 색상을 흰색으로
                    fontWeight: FontWeight.bold,  // 텍스트를 두껍게
                    fontSize: 19,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
