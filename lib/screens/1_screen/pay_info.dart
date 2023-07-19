import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/cash_flow_model.dart';
import '../../models/user_info_model.dart';

class PayInfoWidget extends StatefulWidget {
  int gYear;
  int gMonth;

  PayInfoWidget({super.key, required this.gYear, required this.gMonth} );

  @override
  State<PayInfoWidget> createState() => _PayInfoWidgetState();

  //static Widget payInfoWidget({required int gnMonth, required String gsPayinfo, required String gsGoalinfo, required int gnPercent}) {}


}

class _PayInfoWidgetState extends State<PayInfoWidget> {
  late int selYear;
  late int selMonth;
  DateTime _selectedDate = DateTime.now();

  // cashFlowController 인스턴스 가져오기
  UserInfoController? userInfoController;
  CashFlowController? cashFlowController;

  UserInfo? user;
  
  @override
  void initState() {
    super.initState();
    userInfoController = Get.find<UserInfoController>();
    cashFlowController = Get.find<CashFlowController>();

    user = userInfoController!.getUserInfo();

    /* 위 함수를 사용하면 안되는 이유 */
    // getExpensesByMonth 함수는 비동기로 작동되는데, 대쉬보드에서도 작동되고 여기서도 작동되면
    // 이중으로 호출되면서 하나의 변수에 여러번 소비데이터 값이 더해지는 문제가 발생한다. 
    // 따라서 해당 함수는 대쉬보드에서 한번만 실행하기로 한다. 
    //loadData(); 

    selYear = widget.gYear;
    selMonth = widget.gMonth;
    if(_selectedDate.year != selYear || _selectedDate.month != selMonth){
      //현재 일자와 대쉬보드에서 준 일자가 다른 경우 : 해당 월의 1일로 설정
      _selectedDate = DateTime(selYear, selMonth, 1);
    }

  }

  void loadData() {
    cashFlowController!.getExpensesByMonth(user!.uID!, _selectedDate.year, _selectedDate.month);
    cashFlowController!.getPurposeByMonth(user!.uID!, _selectedDate.year, _selectedDate.month);

    //monthTotalAmt = cashFlowController!.monthTotalAmount.value;

  }

  Widget payInfoWidget(int selYear, int selMonth){
        return Obx(() {
      int tmpPayInfo = cashFlowController!.monthTotalAmount.value;
      int tmpGoalInfo = cashFlowController!.monthAmount.value.ceil();
      int nPercent;

      if (tmpGoalInfo == 0) {
        nPercent = 0;
      } else {
        nPercent = ((tmpPayInfo / tmpGoalInfo) * 100).round();
      }

      final formatter = NumberFormat('###,###');
      String lsPayInfo = formatter.format(tmpPayInfo);
      String lsGoalInfo = formatter.format(tmpGoalInfo);

      return SizedBox(
        //height: 80,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0.0),
              topRight: Radius.circular(16.0),
              bottomLeft: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.money,
                          color: Colors.teal[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "이번달의 소비정보",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.lightBlue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        RichText(
                          text: TextSpan(
                            text: '소비금액: ',
                            style:  const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: lsPayInfo,
                                style:  TextStyle(
                                  color: Colors.blueAccent[200],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23,
                                ),
                              ),
                              const TextSpan(
                                text: ' 원',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Text(
                        //   "소비금액: ￦$lsPayInfo / $lsGoalInfo",
                        //   style: TextStyle(
                        //     fontSize: 23,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.blueGrey[500],
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        RichText(
                          text: TextSpan(
                            text: '목표금액: ',
                            style:  const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: lsGoalInfo,
                                style:  TextStyle(
                                  color: Colors.lightBlue[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23,
                                ),
                              ),
                              const TextSpan(
                                text: ' 원',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Text(
                "$nPercent% 도달!",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return payInfoWidget(selYear, selMonth);
  }
}