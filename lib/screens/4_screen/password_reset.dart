import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moneymate/screens/0_common/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../manage_value.dart';

class PasswordResetButton extends StatefulWidget {
  final FirebaseAuth auth;
  final String inputEmail;
  
  const PasswordResetButton({super.key, required this.auth, required this.inputEmail});

  @override
  State<PasswordResetButton> createState() => _PasswordResetButtonState();
}

class _PasswordResetButtonState extends State<PasswordResetButton> {
  int _resendPwdAttempts = 0;

  @override
  void initState() {
    super.initState();
    _loadResendAttempts();
  }

  _loadResendAttempts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _resendPwdAttempts = (prefs.getInt('resendPwdAttempts') ?? 0);
    });
  }

  _updateResendAttempts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('resendPwdAttempts', _resendPwdAttempts);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty){
        showToast('이메일이 비어있습니다. 이메일을 입력하신 후 다시 시도해주세요.');
        return;
      }

      if (_resendPwdAttempts >= MAX_PWD_RESET_ATTEMPTS) {
        showToast('비밀번호 재설정 횟수를 초과했습니다. 관리자 이메일로 문의주십시오.');
        return;
      }

      //비밀번호 재설정 이메일 전송
      await widget.auth.sendPasswordResetEmail(email: email);

      setState(() {
        _resendPwdAttempts++;
      });

      showToast('비밀번호 재설정 이메일이 전송되었습니다.');
    } catch (e) {
      showToast('오류가 발생했습니다. 다시 시도해주세요.');
      print("Error sending password reset email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => sendPasswordResetEmail(widget.inputEmail),
      child: const Text("비밀번호 재설정 이메일 전송", style: TextStyle(color: Colors.red),),
    );

  }
}
