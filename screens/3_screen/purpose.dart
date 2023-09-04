import 'package:flutter/material.dart';
import 'package:moneymate/screens/3_screen/purpose_enroll.dart';

class PurposeSetScreen extends StatefulWidget {
  const PurposeSetScreen({super.key});

  @override
  State<PurposeSetScreen> createState() => _PurposeSetScreenState();
}

class _PurposeSetScreenState extends State<PurposeSetScreen> {

  /* 소비목표정보(pay_info) 위젯 가져오기 */
  final Widget purposeEnrollWidget =  const PurposeEnrollWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        elevation: 0,
        backgroundColor: Colors.grey[100],
        title: RichText(
          text:
           TextSpan(
            text: 'Money',
            style: const TextStyle(
              color: Color.fromARGB(255, 105, 109, 104),
            ),
            children: <TextSpan>[
              TextSpan(
                text: ' Mind',
                style: TextStyle(
                  color: Colors.lightGreen[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: const [
          /*
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
            color: Colors.black,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
            color: Colors.black,
          ),
          */
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 5,
            ),
            child: Row(
              children: [
                const Text(
                  " 목표금액 ",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Pacifico",
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, 2),
                  child: Text(
                    "정하기",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Montserrat",
                      color: Colors.lightGreen[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
  
           const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              children:  [
                purposeEnrollWidget,
                const SizedBox(height: 10),
                //_weekPlanEnrollWidget,
              ]
            ),
          ),
        ],
      ),
    );
  }
}