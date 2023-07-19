
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserInfo {
  String? uID;
  String? userName;
  String? userEmail;

  UserInfo({this.uID, this.userName, this.userEmail});
}

class UserInfoController extends GetxController {
  /// DB 저장 리스트
  /// ----------------------------------------------------
  /// > 사용자 정보
  ///   - userId
  ///   - userName
  ///   - userPwd
  ///   - userEmail
  ///   - userPhone
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Rx<UserInfo> userInfo = UserInfo(uID: '', userName: '', userEmail: '').obs;

  UserInfo getUserInfo() {
    return userInfo.value;
  }

  void setUserInfo(String uID, String userName, String userEmail) {
    userInfo.value = UserInfo(uID: uID, userName: userName, userEmail: userEmail);
  }
  

/* 가져오기
  UserInfo user = userInfoController.getUserInfo();
  print('User ID: ${user.uID}');


  onPressed: () async {
  await cashFlowController.saveMonthAmountAndTag('your_user_id', 1000, 'Some Purpose', 2023, 3);
},      
*/



}