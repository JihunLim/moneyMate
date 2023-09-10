import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moneymate/screens/0_common/utility.dart';

import '../../login_screen.dart';
import '../../models/cash_flow_model.dart';
import '../../models/user_info_model.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key});

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {

  UserInfoController? userInfoController;
  CashFlowController? cashFlowController;

  final FirebaseAuth _auth = FirebaseAuth.instance;


  UserInfo? user;


    @override
  void initState() {
    super.initState();

    //Get.put(UserInfoController);
    //Get.put(CashFlowController);

    userInfoController = Get.find<UserInfoController>();
    cashFlowController = Get.find<CashFlowController>();

    user = userInfoController!.getUserInfo();


  }



  /* 로그아웃 기능 */
  Future<void> _handleLogout() async {
    await _auth.signOut();
    // 로그아웃한 후 로그인 화면으로 이동합니다.
    // Replace Navigator with GetX for navigating to the LoginScreen
    Get.offAll(() => const LoginScreen());

  }

  /* 회원탈퇴 기능 */
  void showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('회원탈퇴 경고'),
          content: const Text('회원탈퇴 시 사용자의 데이터가 모두 삭제되며 복구할 수 없습니다.\n 정말 탈퇴를 진행하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();  // Dialog 닫기
              },
            ),
            TextButton(
              child: const Text('네'),
              onPressed: () async {
                await _handleDeleteAccount();
                Navigator.of(context).pop();  // Dialog 닫기
                // 회원탈퇴 알림창 보이기
                showToast("회원탈퇴가 정상적으로 처리되었습니다.");
                // 로그인 화면으로 이동
                Get.offAll(() => const LoginScreen());
              },
            ),
          ],
        );
      },
    );
  }

Future<void> _handleDeleteAccount() async {
  try {
    // 현재 로그인한 사용자 가져오기
    final user = _auth.currentUser;

    if (user != null) {
      await user.delete();
      
    } else {
      print('No user is currently signed in.');
    }
  } catch (e) {
    print('Error deleting account: $e');
    // 필요한 경우 사용자에게 에러 메시지를 표시할 수 있습니다.
    // 예를 들면, Snackbar나 Dialog를 사용해서 에러 메시지를 표시하면 됩니다.
  }
}


  @override
  Widget build(BuildContext context) {
    String? code = userInfoController!.getUserInfo().uID;
    String? title = userInfoController!.getUserInfo().userName;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        elevation: 0,
        backgroundColor: Colors.grey[100],
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
        title: RichText(
          text: const TextSpan(
            text: 'Money',
            style: TextStyle(
              color: Color.fromARGB(255, 105, 109, 104),
            ),
            children: <TextSpan>[
              TextSpan(
                text: ' Mind',
                style: TextStyle(
                  color: Color.fromARGB(255, 221, 83, 136),
                  fontWeight: FontWeight.bold,
                ),
              ),
                TextSpan(
                  text: ' 설정하기',
                  style:  TextStyle(
                    color: Color.fromARGB(255, 241, 62, 131),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        actions: const [
          /*
          IconButton(
            onPressed: () async{
              // 뒤로 이동하기
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: Colors.black,
          ),
          */
        ],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('로그아웃'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () async {
              await _handleLogout();
            },
          ),
          ListTile(
            title: const Text('회원탈퇴'),
            leading: const Icon(Icons.delete),
            onTap: () async {
              showDeleteConfirmation();
            },
          ),
          // 이곳에 추가적인 설정 항목을 계속해서 추가할 수 있습니다.
        ],
      )
    );
  }

}