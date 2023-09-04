import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moneymate/models/cash_flow_model.dart';
import 'package:table_calendar/table_calendar.dart';

import '../0_common/utility.dart';

class MonthlyExpenseCalendar extends StatefulWidget {
  String uId;
  Map<DateTime, int> expenses;
  int gYear;
  int gMonth;

  MonthlyExpenseCalendar({super.key, required this.uId, required this.expenses, required this.gYear, required this.gMonth});

  @override
  State<MonthlyExpenseCalendar> createState() => _MonthlyExpenseCalendarState();

}

class _MonthlyExpenseCalendarState extends State<MonthlyExpenseCalendar> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, int> expensesM = {}; 
  CashFlowController? cashFlowController;
  late String uId;
  late int selYear;
  late int selMonth;

  @override
  void initState() {
    super.initState();

    cashFlowController = Get.find<CashFlowController>();
    expensesM = widget.expenses;

    uId = widget.uId;
    selYear = widget.gYear;
    selMonth = widget.gMonth;
    if(_focusedDay.year != selYear || _focusedDay.month != selMonth){
      //현재 일자와 대쉬보드에서 준 일자가 다른 경우 : 해당 월의 1일로 설정
      _focusedDay = DateTime(selYear, selMonth, 7);
    }

  }

  Widget _buildExpenseCell(DateTime date) {
    
    return Obx((){
      expensesM = cashFlowController!.expensesMap;
      DateTime matchDate = DateTime(date.year, date.month, date.day);

      int expense = expensesM[matchDate] ?? 0;

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.brown.shade50),
          borderRadius: BorderRadius.circular(0.0),
        ),
        child: Center(
          child: 
          Transform.translate(
            offset: const Offset(0, 10),
            child: Text(
              (expense == 0) ? '' : formatNumberWithComma(expense).toString(),
              style: TextStyle(color: Colors.teal[900], fontWeight: FontWeight.normal, fontSize: 10),
            ),
          ),
        ),
      );
    });

  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
        child: Column(
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
                  "월간 계획",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(
                  //maxHeight: 200,
                ),
              child: TableCalendar(
                availableGestures: AvailableGestures.none,
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    //_focusedDay = focusedDay;

                    // 선택한 날짜에 대한 소비 내역을 가져옵니다.
                    cashFlowController?.getExpensesForSelectedDay(uId, _selectedDay!);
                    // 가져온 소비 내역을 화면에 표시하는 로직을 여기에 추가합니다.
                  });
                },
                
                onFormatChanged: (format) {
                  setState(() {
                    //_calendarFormat = format; //한달모드 or 2주모드 사용안함.
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    //_focusedDay = focusedDay;
                  });
                },
                eventLoader: (day) {
                  return widget.expenses[day] != null ? [widget.expenses[day]] : [];
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, _) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  },
                  todayBuilder: (context, date, focusedDay) {
                    return Container(
                      color: const Color.fromARGB(255, 211, 225, 241),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          
                        ),
                      ),
                    );
                  },  
                  /* markerBuilder: 일자에 해당하는 소비금액을 넣는 부분 */
                  markerBuilder: (context, date, events) {
                    return _buildExpenseCell(date);
                  },
                  selectedBuilder: (context, date, _) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromARGB(255, 1, 110, 98),
                          width: 3,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  markersAlignment: Alignment.bottomCenter,
                  defaultDecoration: BoxDecoration(),
                  todayDecoration: BoxDecoration(),
                  selectedDecoration: BoxDecoration(
                    
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronVisible: false, 
                  rightChevronVisible: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );



  }

}