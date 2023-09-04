import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moneymate/models/cash_flow_model.dart';

import '../../models/user_info_model.dart';

class WeekPlanEnrollWidget extends StatefulWidget {
  final int gnMonth;
  final String gsPayinfo;
  final String gsGoalinfo;
  final int gnPercent;

  const WeekPlanEnrollWidget({super.key, required this.gnMonth, required this.gsPayinfo, required this.gsGoalinfo, required this.gnPercent, } );
  
  @override
  State<WeekPlanEnrollWidget> createState() => _WeekPlanEnrollWidgetState();

  //static Widget WeekPlanWidget({required int gnMonth, required String gsPayinfo, required String gsGoalinfo, required int gnPercent}) {}


}

class _WeekPlanEnrollWidgetState extends State<WeekPlanEnrollWidget> {
  late final int _gnMonth;
  late final String _gsPayinfo;
  late final String _gsGoalinfo;
  late final int _gnPercent;
  UserInfo? user;
  MoneyFlow? moneyFlow;
  final DateTime _selectedDate = DateTime.now();
  List<MoneyFlow>? listMoneyFlow;

  final cashFlowController = Get.find<CashFlowController>();
  final userInfoController = Get.find<UserInfoController>();

  @override
  void initState() {
    super.initState();
    _gnMonth = widget.gnMonth;
    _gsPayinfo = widget.gsPayinfo;
    _gsGoalinfo = widget.gsGoalinfo;
    _gnPercent = widget.gnPercent;
    user = userInfoController.getUserInfo();
    cashFlowController.getExpensesByMonth(user!.uID!, _selectedDate.year, _selectedDate.month);
    //listMoneyFlow = cashFlowController.expensesM.toList();

  }

  Widget WeekPlanEnrollWidget(int nMonth, String sPayinfo, String sGoalinfo, int nPercent){
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
                          Icons.edit_calendar_outlined,
                          color: Colors.teal[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "Weekly Plan",
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children:  [
                        const SizedBox(width: 10),
                        Text(
                          "사용금액: ",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[900],
                          ),
                        ),
                        Text(
                          "￦30,000",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children:  [
                        const SizedBox(width: 10),
                        Text(
                          "목표금액: ",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[900],
                          ),
                        ),
                        Text(
                          "￦250,000",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:  [
                              const SizedBox(height: 6),
                              /* 월요일 */
                              Row(
                                children: [
                                    Icon(
                                    Icons.light_outlined,
                                    color: Colors.indigo[900],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    "월(3/13) :  ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    "￦250,000",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[600],
                                    ),
                                  ),
                                ],
                              ),
                              /* 화요일 */
                              Row(
                                children: [
                                    Icon(
                                    Icons.light_outlined,
                                    color: Colors.indigo[900],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    "화(3/14) :  ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    "￦250,000",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[600],
                                    ),
                                  ),
                                ],
                              ),
                              /* 수요일 */
                              Row(
                                children: [
                                    Icon(
                                    Icons.light_outlined,
                                    color: Colors.indigo[900],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    "수(3/15) :  ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    "￦250,000",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[600],
                                    ),
                                  ),
                                ],
                              ),
                              /* 목요일 */
                              Row(
                                children: [
                                    Icon(
                                    Icons.light_outlined,
                                    color: Colors.indigo[900],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    "목(3/16) :  ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    "￦250,000",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[600],
                                    ),
                                  ),
                                ],
                              ),
                              /* 금요일 */
                              Row(
                                children: [
                                    Icon(
                                    Icons.light_outlined,
                                    color: Colors.indigo[900],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    "금(3/17) :  ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    "￦250,000",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[600],
                                    ),
                                  ),
                                ],
                              ),
                              /* 토요일 */
                              Row(
                                children: [
                                    Icon(
                                    Icons.light_outlined,
                                    color: Colors.deepOrange[800],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    "토(3/18) :  ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    "￦250,000",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[600],
                                    ),
                                  ),
                                ],
                              ),
                              /* 일요일 */
                              Row(
                                children: [
                                    Icon(
                                    Icons.light_outlined,
                                    color: Colors.indigo[900],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    "일(3/19) :  ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    "￦250,000",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                "30% 도달!",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
  }


  @override
  Widget build(BuildContext context) {
    return WeekPlanEnrollWidget(_gnMonth, _gsPayinfo, _gsGoalinfo, _gnPercent);
  }
}