import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../models/user_info_model.dart';
import '../0_common/utility.dart';

class ConnectRoomScreen extends StatefulWidget {
  const ConnectRoomScreen({super.key});

  @override
  _ConnectRoomScreenState createState() => _ConnectRoomScreenState();
}

class _ConnectRoomScreenState extends State<ConnectRoomScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  UserInfoController? userInfoController;
  
  List<String> items = [];
  final TextEditingController _controller = TextEditingController();
  final int maxItemCount = 5;  // 리스트 최대 생성 개수
  final 
  bool isTap = false;

    @override
  void initState() {
    super.initState();
    Get.put(UserInfoController());
    userInfoController = Get.find<UserInfoController>();
    //requestPermission();
    // Get device's notification token
    //getToken();

    loadData(); //originUID 사용 가능

    /* To-do: userInfoContoller의 connectRoomList 리스트를 먼저 출력되도록 한다. */
    
  }

  void loadData() async {
    await userInfoController!.fetchUserConnectRoomList(userInfoController!.originUID.value);
    List<String> sortedItems = userInfoController!.connectRoomList.map((roomInfo) => "${roomInfo.title}-${roomInfo.uid}").toList();

    sortedItems.sort((a, b) {
      if (a.split('-')[0] == "나의 머니마인드") return -1;
      if (b.split('-')[0] == "나의 머니마인드") return 1;
      return a.compareTo(b);  // 기본적으로 문자열을 기준으로 정렬
    });

    setState(() {
      items.addAll(sortedItems);  // 정렬된 리스트를 items 리스트에 추가
    });
  } 

  Future<void> saveToFirebase(String code, String title) async {
    // Firebase에서 users 컬렉션의 userId 문서의 connect_room에 데이터 저장
    await firestore.collection('users').doc(userInfoController!.getUserInfo().uID).collection('connect_room').doc(code).set({
      'uid': code,
      'title': title,
      'secret_key': "",
    });
  }

  Future<void> createUserDocument(String code, String title, String secretKey) async {
    // firebase에서 users 컬렉션에 문서를 만들고 필드에 데이터 저장
    await firestore.collection('users').doc(code).set({
      'creator': userInfoController!.originUID.value,
      'title': title,
      'secret_key': secretKey,
    });
  }

  /* Firebase에서 UserId 만들기 */
  void changeUserInfo(String code, String title) async {
    //사용자 정보 변경하기
    userInfoController!.setUserInfo(code, title, code);

    // 뒤로 이동하기
    Get.back(result: 'Updated');
  }

  Future<List<dynamic>> checkIfUserDocumentExists(String code) async {
    // Firebase에서 users 컬렉션에서 code를 이용하여 문서 검색
    String title = '';

    DocumentSnapshot snapshot = await firestore
        .collection('users')
        .doc(code)
        .get();

      // 문서가 존재하면 해당 문서의 'title' 필드 값을 반환, 그렇지 않으면 null 반환
    if (snapshot.exists) {
      title = ((snapshot.data() as Map<String, dynamic>)['title'] as String?) ?? '무제';
    } else {
      title = '';
    }

    // 문서가 존재하면 true, 그렇지 않으면 false 반환
    return [snapshot.exists, title];
  }

  //사용자 커넥팅룸에 이미 리스트가 있는지 확인
  Future<bool> checkIfUserInclude(String code) async {
    // Firebase에서 users 컬렉션의 userId 문서의 connect_room에서 code를 이용하여 문서 검색
    DocumentSnapshot snapshot = await firestore
        .collection('users')
        .doc(userInfoController!.originUID.value)  //userInfoController!.originUID.value,
        .collection('connect_room')
        .doc(code)
        .get();

    // 문서가 존재하면 true, 그렇지 않으면 false 반환
    return snapshot.exists;
  }

  // Firebase에서 기존방 연결
  Future<bool> getConnectRoom(String code) async{
    // code가 user정보에 있는지 확인하기
    final result = await checkIfUserDocumentExists(code);
    bool isDocExists = result[0] as bool;
    String title = result[1] as String;

    //만약 이미 해당 code의 커넥팅룸을 가지고 있으면 해당 작업 중지
    bool checkRoom = await checkIfUserInclude(code);
    if(checkRoom){
      //이미 사용자가 해당 커넥팅 룸을 가지고 있으므로 중지
      showToast("이미 연결이 되어있습니다");
      return true;
    }
    
    // firebase에서 users 컬렉션의 userId 문서의 connect_room에 code로 문서를 만들고, 각 필드에 uid는 code, title은 title을, secret_key는 ""을 넣어서 저장하도록 하기. 
    if(isDocExists){
      await saveToFirebase(code, title);
      showToast("연결되었습니다");
      //리스트에 추가하기
      setState(() {
        //items.insert(0, "${_controller.text}-$code"); //후입선출 방식
        items.add("$title-$code");
        _controller.clear();
      });
    }else{
      showToast("유효하지 않은 코드입니다");
    }
    
    return isDocExists;
  }

  // Firebase에서 신규방정보 저장
  void insertConnectRoom(String code, String title, String secretKey) async{
    /* Firebase에서 변경된 UID 저장하기 */
    // firebase에서 users 컬렉션의 userId 문서의 connect_room에 code로 문서를 만들고, 각 필드에 uid는 code, title은 title을, secret_key는 ""을 넣어서 저장하도록 하기. 
    await saveToFirebase(code, title);
    
    /* firebase에서 users 컬렉션에 code로 문서를 만들고, 필드의 creator에는 userInfoController의 originUID RxString타입의 값을 저장한다. */
    if(code.startsWith("MF")) await createUserDocument(code, title, secretKey);
  }

  Future<void> deleteFromFirebase(String userId, String code) async {
    // Firebase에서 users 컬렉션의 userId 문서의 connect_room 서브컬렉션에서 code 문서 삭제
    print("^^^ $userId / $code");

    if(code.substring(0,2) != "MF"){
      //개인 머니플로우는 삭제 불가처리
      return;
    }

    try {
        await firestore.collection('users').doc(userId).collection('connect_room').doc(code).delete();
    } catch (e) {
        print('Error deleting document: $e');
    }
  }

  Future<void> deleteUserDocument(String code) async {
    // Firebase에서 users 컬렉션에서 code 문서 삭제
    try {
      await firestore.collection('users').doc(code).delete();
    } catch (e) {
        print('Error deleting2 document: $e');
    }
  }

  Future<void> addItem() async {
    if (_controller.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "타이틀을 입력하세요.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
      return;
    }

    if (items.length >= maxItemCount) {
      Fluttertoast.showToast(
        msg: "최대 $maxItemCount개의 항목만 생성할 수 있습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
      return;
    }

    final roomTitle = _controller.text;
    /* 기존의 머니플로우 방 조인하는 경우 */
    if(roomTitle.substring(0,2).startsWith('MF')){
      getConnectRoom(roomTitle);
    }else{
      /* 새로운 머니플로우 방 생성하는 경우 */
      final randomNumber = Random().nextInt(10000);
      final randomLetter = String.fromCharCode('A'.codeUnitAt(0) + Random().nextInt(26));
      final code = "MF$randomLetter${randomNumber.toString().padLeft(4, '0')}";

      //code로 firebase에서 userID 만들기 (터치할 경우)
      //int rslt = createCmnUserId(code, _controller.text);
      //secret key는 아직 미구현 상태임. (추후에 사용자에게 입력받아서 세팅 필요)
      const secretKey = '0000';

      insertConnectRoom(code, roomTitle, secretKey);

      setState(() {
        //items.insert(0, "${_controller.text}-$code"); //후입선출 방식
        items.add("${_controller.text}-$code");
        _controller.clear();

      });
    }
    //나의 머니메이트도 생성(없으면...)
      await addMyItem();

  }


   Future<void> addMyItem() async {
    /* 나의 머니메이트 생성 */
    String code = userInfoController!.originUID.value;
    const roomTitle = "나의 머니마인드";
    //secret key는 아직 미구현 상태임. (추후에 사용자에게 입력받아서 세팅 필요)
    const secretKey = '0000';

    bool checkMyRoom = await checkIfUserInclude(code);

    if(!checkMyRoom){
      insertConnectRoom(code, roomTitle, secretKey);

      //나의 머니메이트가 없을 경우에만 리스트에 추가
      setState(() {
        //items.insert(0, "${_controller.text}-$code"); //후입선출 방식
        items.add("$roomTitle-$code");
    });
    }
    
  }

  /* 컨넥팅 쉐어 머니플로우 생성 위젯 */
  Widget buildInputRow() {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color.fromARGB(255, 189, 189, 189)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '타이틀 또는 초대코드 입력',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 5.0),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: addItem,        
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 70),
              ),
              child: const Icon(  // 아이콘을 사용하도록 변경
                Icons.create_new_folder_sharp,
                color: Colors.white, // 아이콘 색상을 지정
                size: 24,            // 아이콘 크기를 지정
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDismissibleItem(int index) {
    final item = items[index];
    final title = item.split('-')[0];
    final code = item.split('-')[1];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Dismissible(
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        key: Key(item),
        confirmDismiss: (direction) async { 
          // "MF"로 시작하는 code는 삭제 불가처리
          if(!code.startsWith("MF")){
            Fluttertoast.showToast(
              msg: "나의 머니마인드는 삭제할 수 없습니다.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
            );
          }else{
            // confirmDismiss 콜백 사용
            return await showDialog(  // 대화상자 표시
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('확인'),
                content: const Text('정말 삭제하시겠습니까?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('삭제하기'),
                    onPressed: () {
                      Navigator.of(context).pop(true);  // 대화상자 닫기 & 삭제 수행
                    },
                  ),
                  TextButton(
                    child: const Text('취소하기'),
                    onPressed: () {
                      Navigator.of(context).pop(false);  // 대화상자 닫기 & 삭제 취소
                    },
                  ),
                ],
              ),
            );
          }
          return null;
        },
        onDismissed: (direction) async {  // 삭제된 후의 작업
          setState(() {
            items.removeAt(index);
          });

          // Firebase에서 문서 제거
          // 사용자의 connect_room에서 목록제거
          await deleteFromFirebase(userInfoController!.originUID.value, code);
          // user 정보 삭제 
          //await deleteUserDocument(code);

          //토스트 메시지
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$item 삭제되었습니다'),
            duration: const Duration(seconds: 1),
          ));
        },
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,  
              fontSize: 16.0,  
            ),
          ),
          trailing: ("MF" != code.substring(0,2)) ? null
            : Container(
              alignment: Alignment.topRight,
              constraints: const BoxConstraints(maxWidth: 100.0, maxHeight: 50.0),
              child: Text(code),
          ),
          contentPadding: const EdgeInsets.all(5),
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          onTap: () async{ //리스트 클릭 시 이벤트
            changeUserInfo(code, title);
            // userInfoController!.setUserInfo(code, title, code);
            //   Get.back(result: 'Updated');
          }
        ),
      ),
    );
  }
  
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          automaticallyImplyLeading: false, 
          elevation: 0,
          backgroundColor: Colors.grey[100],
          title: RichText(
            text: const TextSpan(
              text: 'Money',
              style: TextStyle(
                color: Color.fromARGB(255, 105, 109, 104),
              ),
              children: <TextSpan>[
                TextSpan(
                  text: ' Mind Room',
                  style: TextStyle(
                    color: Color.fromARGB(255, 74, 0, 192),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
          actions: const [
            /*
            IconButton(
              onPressed: () async{   
              },
              icon: const Icon(Icons.settings),
              color: Colors.black,
            ),
            */
          ],
        ),
        body: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,  // ListView의 크기를 자식의 크기에 맞게 조절
              itemCount: items.length,
              itemBuilder: (context, index) {
                return buildDismissibleItem(index);
              },
            ),
            buildInputRow(),
            Expanded(
              child: Container(),  // 나머지 공간을 차지하는 빈 컨테이너
            )
          ],
        ),
      ),
    );
  }

}
