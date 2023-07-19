import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:moneymate/screens/0_common/home_screen.dart';

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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Login MoneyMind')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  final userInfo = await signInWithFacebook();
                  if (userInfo != null) {
                    logger.d('Facebook 로그인 성공: ${userInfo.user!.displayName}');
                    logger.d('Facebook 로그인 UID: ${userInfo.user!.uid}');
                    //사용자 정보 저장
                    userInfoController!.setUserInfo(userInfo.user!.uid, userInfo.user!.displayName!, userInfo.user!.uid);

                    // go next page
                    Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (context) => const HomeScreenWidget(),
                        ),
                    );
                  }
                },
                child: const Text('Facebook으로 로그인'),
              ),
              ElevatedButton(
                onPressed: () async {
                  //const user = "aa";//await signInWithPlayGames();
                  //print('Play Games 로그인 성공: ${user.user!.displayName}');
                },
                child: const Text('Play Games로 로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}