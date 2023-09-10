import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moneymate/screens/0_common/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../manage_value.dart';

class EmailVerificationButton extends StatefulWidget {
  final FirebaseAuth auth;

  const EmailVerificationButton({Key? key, required this.auth}) : super(key: key);

  @override
  _EmailVerificationButtonState createState() => _EmailVerificationButtonState();
}

class _EmailVerificationButtonState extends State<EmailVerificationButton> {
  int _resendVFAttempts = 0;

  @override
  void initState() {
    super.initState();
    _loadResendAttempts();
  }

  _loadResendAttempts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _resendVFAttempts = (prefs.getInt('resendVFAttempts') ?? 0);
    });
  }

  _updateResendAttempts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('resendVFAttempts', _resendVFAttempts);
  }
  
  /* Firebase 로그인 인증코드 재전송 */
  Future<void> resendEmailVerification() async {
    final user = widget.auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      showToast("인증 이메일을 다시 보냈습니다.");
    }
  }

  Future<void> resendEmail() async {
    if (_resendVFAttempts >= MAX_VF_RESET_ATTEMPTS) {
      showToast('한 계정에 3번만 재전송할 수 있습니다.');
      return;
    }

    // 여기에 실제 이메일 재전송 코드를 넣습니다.
    await resendEmailVerification();

    setState(() {
      _resendVFAttempts++;
    });

    _updateResendAttempts();
    showToast('이메일을 재전송했습니다.');
  }

   @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: resendEmail,
       style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(100, 20),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerLeft),
      child: const Text("이메일 인증코드 재전송", style: TextStyle(color: Colors.red)),
    );
  }

}
