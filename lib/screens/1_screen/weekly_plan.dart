import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/cash_flow_model.dart';
import '../0_common/utility.dart';

class WeekPlanWidget extends StatefulWidget {
  // final int gnMonth;
  // final String gsPayinfo;
  // final String gsGoalinfo;
  // final int gnPercent;
  final String uID;
  int gYear;
  int gMonth;

  WeekPlanWidget({super.key, required this.uID, required this.gYear, required this.gMonth} );
  
  @override
  State<WeekPlanWidget> createState() => _WeekPlanWidgetState();

  //static Widget WeekPlanWidget({required int gnMonth, required String gsPayinfo, required String gsGoalinfo, required int gnPercent}) {}


}

class _WeekPlanWidgetState extends State<WeekPlanWidget> {
  late final String _uID;
  DateTime _selectedDate = DateTime.now();
  late final DateTime firstDate;
  late final DateTime lastDate;
  late List<DateTime> weekDates;
  CashFlowController? cashFlowController;
  late int selYear;
  late int selMonth;

  @override
  void initState() {
    super.initState();
    // _gnMonth = widget.gnMonth;
    // _gsPayinfo = widget.gsPayinfo;
    // _gsGoalinfo = widget.gsGoalinfo;
    // _gnPercent = widget.gnPercent;
    //firstDate = getFirstDayOfWeek(_selectedDate);
    //lastDate = getLastDayOfWeek(_selectedDate);
    //weekDates = getWeekDays(firstDate, lastDate);
    _uID = widget.uID;
    selYear = widget.gYear;
    selMonth = widget.gMonth;
    if(_selectedDate.year != selYear || _selectedDate.month != selMonth){
      //현재 일자와 대쉬보드에서 준 일자가 다른 경우 : 해당 월의 1일로 설정
      _selectedDate = DateTime(selYear, selMonth, 7);
    }

    // cashFlowController 인스턴스 가져오기
    cashFlowController = Get.find<CashFlowController>();

    generateWeekDates();

  }

  DateTime getFirstDayOfWeek(DateTime date) {
    final difference = date.weekday - 1;
    return date.subtract(Duration(days: difference));
  }

  DateTime getLastDayOfWeek(DateTime date) {
    final difference = 7 - date.weekday;
    return date.add(Duration(days: difference));
  }

  List<DateTime> getWeekDays(DateTime firstDay, DateTime lastDay) {
    List<DateTime> weekDays = [];

    for (int i = 0; i <= lastDay.difference(firstDay).inDays; i++) {
      weekDays.add(firstDay.add(Duration(days: i)));
    }

   return weekDays;
  }

  void generateWeekDates() {
    weekDates = [];

    DateTime startDate = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    for (int i = 0; i < 7; i++) {
      weekDates.add(startDate.add(Duration(days: i)));
    }

    //추가 : cashController에서 일주일치에 해당하는 금액 데이터를 가져올 수 있는 rx변수와 함수를 만들고, 여기에 선언.
    cashFlowController?.getExpensesByWeek(_uID, startDate.year, startDate.month, startDate.day); //expensesW 사용 가능해짐.
    
  }

  void changeWeek(int change) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: change * 7));
      generateWeekDates();
    });
  }

  String getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return '월';
      case 2:
        return '화';
      case 3:
        return '수';
      case 4:
        return '목';
      case 5:
        return '금';
      case 6:
        return '토';
      case 7:
        return '일';
      default:
        return '';
    }
  }

  Widget WeekPlanWidget(){
    return Obx(() {
        int weekTotalPayment = cashFlowController!.weekTotalAmount.value;
        List<MoneyFlow2> weekPayInfo = cashFlowController!.expensesW;
        List<int> weekPayment = [0,0,0,0,0,0,0];

        for(int i=0; i < weekPayInfo.length; i++) {
          if(i > 6) break;
          int value = weekPayInfo[i].amount!.ceil();
          weekPayment[i] = value;
        }

        //cashFlowController!.expensesW[0].amount!.ceil();

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
                              "주간 계획",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children:  [
                            const SizedBox(width: 10),
                            Text(
                              " 주간 사용금액: ",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900],
                              ),
                            ),
                            Text(
                              "￦${formatNumberWithComma(weekTotalPayment)}",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        /*
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
                        */
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //const SizedBox(width: 20),
                            IconButton(
                              icon: const Icon(Icons.arrow_left),
                              iconSize: 25,
                              color: Colors.blueGrey.withOpacity(0.6),
                              onPressed: () {
                                changeWeek(-1);
                              },
                            ),
                            Expanded(
                              child: Column(
                                /* 주간 소비금액 표시 */
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
                                        "${getWeekdayName(weekDates[0].weekday)}(${weekDates[0].month}/${weekDates[0].day}) :  ",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      Text(
                                        "￦${formatNumberWithComma(weekPayment[0])}",
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
                                        "화(${weekDates[1].month}/${weekDates[1].day}) :  ",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      Text(
                                        "￦${formatNumberWithComma(weekPayment[1])}",
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
                                        "수(${weekDates[2].month}/${weekDates[2].day}) :  ",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      Text(
                                        "￦${formatNumberWithComma(weekPayment[2])}",
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
                                        "목(${weekDates[3].month}/${weekDates[3].day}) :  ",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      Text(
                                        "￦${formatNumberWithComma(weekPayment[3])}",
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
                                        "금(${weekDates[4].month}/${weekDates[4].day}) :  ",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      Text(
                                        "￦${formatNumberWithComma(weekPayment[4])}",
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
                                        color: Colors.deepOrangeAccent[100],
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        "토(${weekDates[5].month}/${weekDates[5].day}) :  ",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      Text(
                                        "￦${formatNumberWithComma(weekPayment[5])}",
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
                                        color: Colors.deepOrange[800],
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        "일(${weekDates[6].month}/${weekDates[6].day}) :  ",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      Text(
                                        "￦${formatNumberWithComma(weekPayment[6])}",
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
                            IconButton(
                              icon: const Icon(Icons.arrow_right),
                              iconSize: 25,
                               color: Colors.blueGrey.withOpacity(0.6),
                              onPressed: () {
                                changeWeek(1);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Text(
                  //   "30% 도달!",
                  //   style: TextStyle(
                  //     fontSize: 15,
                  //     color: Colors.grey[600],
                  //   ),
                  // ),
                ],
              ),
            ),
          );
      });
  }


  @override
  Widget build(BuildContext context) {
    return WeekPlanWidget();
  }
}