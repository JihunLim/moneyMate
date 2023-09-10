import 'package:flutter/material.dart';

import '../2_screen/pay_info_enroll.dart';
import '../2_screen/weekly_plan_enroll.dart';

class PaymentEnrollScreen extends StatefulWidget {
  const PaymentEnrollScreen({super.key});

  @override
  State<PaymentEnrollScreen> createState() => _PaymentEnrollScreenState();
}

class _PaymentEnrollScreenState extends State<PaymentEnrollScreen> {
    /* 소비목표정보(pay_info) 위젯 가져오기 */
  final Widget _payInfoEnrollWidget = const PayInfoEnrollWidget(
    gnMonth: 3,
    gsPayinfo: "500,000",
    gsGoalinfo: "1,000,000",
    gnPercent: 50,
  );

  final Widget _weekPlanEnrollWidget = const WeekPlanEnrollWidget(
    gnMonth: 3,
    gsPayinfo: "500,000",
    gsGoalinfo: "1,000,000",
    gnPercent: 50,
  );

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        elevation: 0,
        backgroundColor: Colors.grey[100],
        title: RichText(
          text: TextSpan(
            text: 'Money',
            style: const TextStyle(
              color: Color.fromARGB(255, 105, 109, 104),
            ),
            children: <TextSpan>[
              TextSpan(
                text: ' Mind',
                style: TextStyle(
                  color: Colors.amber[900],
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
                  " 지출 ",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Pacifico",
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, 2),
                  child: Text(
                    "등록하기",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Montserrat",
                      color: Colors.amber[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
          /*
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Text(
              "￦500,000",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ), 
          */
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              children: [
                _payInfoEnrollWidget,
                const SizedBox(height: 10),
                //_weekPlanEnrollWidget,
              ]
            ),
          ),
          // Expanded(
          //   child: ListView.builder( //https://api.flutter.dev/flutter/widgets/ListView-class.html
          //     padding: const EdgeInsets.symmetric(
          //       horizontal: 16,
          //     ),
          //     itemCount: 10,
          //     itemBuilder: (context, index) {
          //       return Padding(
          //         padding: const EdgeInsets.only(bottom: 16),
          //         child: Container(
          //           padding: const EdgeInsets.symmetric(
          //             horizontal: 16,
          //             vertical: 8,
          //           ),
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(16),
          //           ),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: [
          //               const Icon(
          //                 Icons.money,
          //                 color: Colors.teal,
          //               ),
          //               const SizedBox(width: 8),
          //               Expanded(
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //                     Text(
          //                       "Expense",
          //                       style: TextStyle(
          //                         fontSize: 18,
          //                         fontWeight: FontWeight.bold,
          //                         color: Colors.grey[800],
          //                       ),
          //                     ),
          //                     const SizedBox(height: 4),
          //                     Text(
          //                       "\$10.00",
          //                       style: TextStyle(
          //                         fontSize: 16,
          //                         color: Colors.grey[600],
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //               Text(
          //                 "March 8, 2023",
          //                 style: TextStyle(
          //                   fontSize: 14,
          //                   color: Colors.grey[400],
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),



        ],
      ),
    );
  }
}