
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:moneymate/screens/0_common/home_screen.dart';
import 'package:moneymate/screens/0_common/utility.dart';
import 'package:moneymate/screens/4_screen/email_verification.dart';
import 'package:moneymate/screens/4_screen/password_reset.dart';
import 'package:moneymate/signup_screen.dart';

import 'models/user_info_model.dart';

//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:play_games/play_games.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  String? _emailError;

  bool isLoading = false; // 로딩상태 추가
  bool showResendEmailButton = false;
  bool showPasswordResetButton = false;  

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  //final GoogleSignIn _googleSignIn = GoogleSignIn();

  //late AndroidNotificationChannel channel;
  //late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  UserInfoController? userInfoController;

  @override
  void initState() {
    super.initState();
    Get.put(UserInfoController);
    userInfoController = Get.find<UserInfoController>();
    requestPermission();
    //loadFCM();
    //listenFCM();
    // Get device's notification token
    getToken();
    //자동 로그인 설정
    checkLoginStatus();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) => print(token));
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  /*
  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(channel.id, channel.name,
                    // ignore: todo
                    // TODO add a proper drawable resource to android (now using one that already exists)
                    icon: 'launch_background')));
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
*/

/*
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }
  */

  Future<UserCredential?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) return null;

    final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
    return await _auth.signInWithCredential(credential);
  }

/*
  Future<UserCredential?> signInWithPlayGames() async {
    final PlayGamesSignInResult signInResult = await PlayGames.signIn();

    if (!signInResult.success) return null;

    final PlayGamesAccount? playGamesAccount = signInResult.account;
    if (playGamesAccount == null) return null;

    final AuthCredential credential = PlayGamesAuthProvider.credential(playGamesAccount.serverAuthCode!);
    return await _auth.signInWithCredential(credential);
  }
  */

  /// 자동 로그인 함수
  Future<void> checkLoginStatus() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Firebase 사용자 상태 확인
      User? user = _auth.currentUser;
      if (user != null) {
        // 이미 로그인한 상태
        if (user.emailVerified) {
          // 이메일이 인증된 경우
          //사용자 정보 저장
          userInfoController!.setUserInfo(user.uid, "", user.email!); //userCredential.user.email _emailController.text
          Get.offAll(() => const HomeScreenWidget());
        } else {
          // 이메일이 인증되지 않은 경우
          showToast("이메일 인증이 필요합니다.");
        }
      }
    });
    
  }

  /* Firebase 로그인 인증코드 재전송 */
  Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      showToast("인증 이메일을 다시 보냈습니다.");
    }
  }

  /* Firebase 로그인 인증 함수 */
  Future<User?> loginWithEmailPassword(String email, String password) async { // 2번 수정: 함수 추가
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      logger.d("Login Success > $userCredential.user.email / $email"); //userCredential.user.email

      return userCredential.user;
    } catch (e) {
      logger.d(e);
      return null;
    }
  }

  /* Firebase 로그인 인증 로그인 핸들러 */
  Future<void> handleLogin() async {
    //유효성 검사
    if(!(chkPwdOk && chkEmailOk)) return;

    final user = await loginWithEmailPassword(_emailController.text, _passwordController.text);
    
    if (user != null) {
      if (user.emailVerified) {
        // 이메일이 인증된 경우
        //사용자 정보 저장
        userInfoController!.setUserInfo(user.uid, "", user.email!); //userCredential.user.email _emailController.text
        //showToast("로그인에 성공하였습니다.");
        Get.offAll(() => const HomeScreenWidget());
      } else {
        // 이메일이 인증되지 않은 경우
        setState(() {
          _errorMessage = "이메일 인증을 진행해야 로그인이 가능합니다.";
          showResendEmailButton = true;
          showToast("이메일 인증이 필요합니다.");
        });
      }
    } else {
      // 로그인 실패
      setState(() {
        _errorMessage = "로그인에 실패하였습니다. 이메일과 비밀번호를 확인해주세요.";
        showPasswordResetButton = true;
      });
    }
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            '머니메이트 로그인',
            style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
          ),
          backgroundColor: const Color.fromRGBO(236, 228, 215, 1.0),
          elevation: 0.0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background.png'),
              fit: BoxFit.cover,
              ),
          ),
          alignment: Alignment.bottomLeft,  // 이 줄을 추가하여 왼쪽 아래에 위젯을 배치합니다.
          padding: const EdgeInsets.only(left: 40, top: 0, bottom: 0, right: 40),  // 왼쪽 및 아래쪽 패딩을 추가하여 버튼 위치 조정
          child: isLoading ? const Center(child: CircularProgressIndicator()) // 로딩 중이면 인디케이터 표시
          : Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  border: Border.all(color: Colors.blue),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,  // 왼쪽으로 정렬
                  children: [
                  TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "이메일",
                            hintText: "이메일을 입력하세요",
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
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "비밀번호",
                            hintText: "비밀번호를 입력하세요",
                          ),
                          onChanged: (value) {
                            if (!validatePassword(value)) {
                              setState(() {
                                _errorMessage = "비밀번호는 영문과 숫자가 포함된 6자 이상이어야 합니다.";
                                if(value.isEmpty) _errorMessage = null;
                              });
                            }else{
                              setState(() {
                                _errorMessage = null;
                              });
                            } 
                          },
                        ),
                        const SizedBox(height: 10),
                        _errorMessage != null
                            ? Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.amber[900]),
                              )
                            : Container(),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: handleLogin, //로그인 구현 핸들러
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0), backgroundColor: Colors.blueAccent[200], // 양 옆에 20.0만큼의 여백 추가
                            minimumSize: const Size(double.infinity, 35), // 버튼의 배경색을 파란색으로 설정
                          ),
                          child: const Text('로그인',
                            style:TextStyle(
                              color: Colors.white,  // 텍스트 색상을 흰색으로
                              fontWeight: FontWeight.bold,  // 텍스트를 두껍게
                              fontSize: 17,
                            ),
                          )
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            '회원가입하러 가기',
                            style: TextStyle(color: Colors.blueAccent[200]),
                          ),
                        ),
                        const SizedBox(height: 5,),
                        // /* 이메일 재전송 기능 */
                        // if (showResendEmailButton) EmailVerificationButton(auth: _auth),
                        // /* 비밀번호 재설정 기능 */
                        // if (showPasswordResetButton) PasswordResetButton(auth: _auth, inputEmail: _emailController.text),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /* 이메일 재전송 기능 */
                            if (showResendEmailButton) EmailVerificationButton(auth: _auth),
                            /* 비밀번호 재설정 기능 */
                            //const SizedBox(height: 5.0), 
                            if (showPasswordResetButton) PasswordResetButton(auth: _auth, inputEmail: _emailController.text),
                          ],
                        )


                          // TextButton(
                          //   onPressed: resendEmailVerification,
                          //   child: const Text("이메일 인증코드 재전송"),
                          // ),
                        
                        
                  /* 하단은 sns 로그인 구현 항목임 */
                  //const Spacer(),
                  /*
                  ElevatedButton(
                    onPressed: () async {
                      //final user = await signInWithGoogle();
                      // if (user != null) {
                      //   print('Google 로그인 성공: ${user.user!.displayName}');
                      // }
                    },
                    child: const Text('Google로 로그인'),
                  ),
                  
                  ElevatedButton(
                    onPressed: () async {
                      //로딩바 켜기
                      setState(() {
                        isLoading = true; // 로딩 시작
                      });
                      
                      //페이스북 로그인
                      final userInfo = await signInWithFacebook();
                        
                      //로딩바 끄기
                      setState(() {
                          isLoading = false; // 로딩 종료
                        });
                        
                      if (userInfo != null) {
                        logger.d('Facebook 로그인 성공: ${userInfo.user!.displayName}');
                        logger.d('Facebook 로그인 UID: ${userInfo.user!.uid}');
                        //사용자 정보 저장
                        userInfoController!.setUserInfo(userInfo.user!.uid, userInfo.user!.displayName!, userInfo.user!.uid);
                    
                        // go next page (뒤로가기 가능 버전)
                        // Navigator.push(context, 
                        //   MaterialPageRoute(
                        //     builder: (context) => const HomeScreenWidget(),
                        //     ),
                        // );
                        /* 뒤로가기 불가능 */
                        // Navigator.pushReplacement(context, 
                        //   MaterialPageRoute(
                        //     builder: (context) => const HomeScreenWidget(),
                        //   ),
                        // );
                        Get.offAll(() => const HomeScreenWidget());
                      }
                    },
                    child: const Text('Facebook으로 로그인'),
                  ),
                  */
                  /*
                  ElevatedButton(
                    onPressed: () async {
                      //const user = "aa";//await signInWithPlayGames();
                      //print('Play Games 로그인 성공: ${user.user!.displayName}');
                    },
                    child: const Text('Play Games로 로그인'),
                  ),
                  */
                        
                  //SizedBox(height: 20,),
                ],
                          ),
              ),
          ),
        ),
      ),
    );
  }
}