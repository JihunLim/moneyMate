
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserInfo {
  String? uID;
  String? userName;
  String? userEmail;

  UserInfo({this.uID, this.userName, this.userEmail});
}

class ConnectRoomInfo {
  String? title;
  String? secretKey;
  String? uid;

  ConnectRoomInfo({required this.title, this.secretKey, required this.uid});

  // Firestore 문서를 ConnectRoom 객체로 변환하는 팩토리 메서드
  factory ConnectRoomInfo.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ConnectRoomInfo(
      title: data['title'],
      secretKey: data['secret_key'],
      uid: data['uid'],
    );
  }
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
  final connectRoomList = <ConnectRoomInfo>[].obs;
  RxString originUID = "".obs; //페이스북 uid

  UserInfo getUserInfo() {
    return userInfo.value;
  }

  void setUserInfo(String uID, String userName, String userEmail) {
    userInfo.value = UserInfo(uID: uID, userName: userName, userEmail: userEmail);
  }
  
  /* 사용자의 컨넥팅룸 목록을 가져온다. */
  Future<void> fetchUserConnectRoomList(String userId) async {
    String originUserId = ""; //페이스북 uid

    try {
      //uid 타입 확인
      if("MF" != userId.substring(0,2)){
        // case1) userId가 페이스북 uid인 경우 > 바로 사용
        originUserId = userId;
      }else{
        // case2) userId가 이미 컨넥팅룸 uid인 경우 > creator 필드 사용
        DocumentSnapshot doc = await firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          originUserId =  doc['creator'];
          print("case2 uid: $originUserId");
        } else {
          print("Document doesn't exist");
          originUserId = userId;
        }
      }
      originUID.value = originUserId;

      QuerySnapshot querySnapshot = await firestore.collection('users').doc(originUserId).collection('connect_room').get();
  
      List<ConnectRoomInfo> rooms = querySnapshot.docs.map((doc) => ConnectRoomInfo.fromDocument(doc)).toList();
      
      // connectRoomList의 내용을 rooms로 대체합니다.
      connectRoomList.assignAll(rooms);

    } catch (e) {
      print('Error fetch connect room info: $e');
    }
  }  















/* 가져오기
  UserInfo user = userInfoController.getUserInfo();
  print('User ID: ${user.uID}');


  onPressed: () async {
  await cashFlowController.saveMonthAmountAndTag('your_user_id', 1000, 'Some Purpose', 2023, 3);
},      
*/



}