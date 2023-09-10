import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:moneymate/screens/0_common/utility.dart';
import 'package:moneymate/screens/1_screen/pay_info.dart';
import 'package:moneymate/screens/1_screen/weekly_plan.dart';
import 'package:moneymate/screens/1_screen/expense_list.dart';
import 'package:moneymate/screens/4_screen/setting.dart';

import '../../models/cash_flow_model.dart';
import '../../models/user_info_model.dart';
import '../5_screen/connect_room_board.dart';
import 'month_plan.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {

  UserInfoController? userInfoController;
  CashFlowController? cashFlowController;

  UserInfo? user;
  MoneyFlow? cashFlow;
  DateTime _selectedDate = DateTime.now();
  //주 구하기. 
  int weekCount = 0;
  int monthTotalAmt = 0;

  late Widget _payInfoWidget;
  late Widget _weekPlanWidget;
  late Widget _monthPlanWidget;
  late Widget _expenseListWidget;

  late AnimationController _animationController;
  late Animation<double> _animation;

  var logger = Logger(
    printer: PrettyPrinter(),
  );
  
  @override
  void initState() {
    super.initState();

    //Get.put(UserInfoController);
    //Get.put(CashFlowController);

    userInfoController = Get.find<UserInfoController>();
    cashFlowController = Get.find<CashFlowController>();

    weekCount = (_selectedDate.day / 7).ceil();

    user = userInfoController!.getUserInfo();
    logger.d('***User ID: ${user!.uID}');

    //cashFlowController!.getExpensesByMonth(user!.uID!, _selectedDate.year, _selectedDate.month);
    //cashFlowController!.getPurposeByMonth(user!.uID!, _selectedDate.year, _selectedDate.month);
    loadData();

    // 에니메이션 효과 추가
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    // 애니메이션 초기 상태 설정
    _animationController.forward();
  }

  loadData() async{
    setState(() {
      logger.d("*** 조회 월 정보 : ${_selectedDate.toString()}");

      cashFlowController!.getExpensesByMonth(user!.uID!, _selectedDate.year, _selectedDate.month); //expensesMap 사용가능
      cashFlowController!.getPurposeByMonth(user!.uID!, _selectedDate.year, _selectedDate.month);

      monthTotalAmt = cashFlowController!.monthTotalAmount.value;

      /* Load Widgets data */
      //loadWidgetData();
      });
  }

  void loadWidgetData(){
    /* 소비목표정보(pay_info) 위젯 가져오기 */
      _payInfoWidget = PayInfoWidget(
        gYear: _selectedDate.year,
        gMonth: _selectedDate.month,
      );

      /* 주간소비정보 위젯 가져오기 */
      _weekPlanWidget =  WeekPlanWidget(
        key: UniqueKey(),
        uID: user!.uID!,
        gYear: _selectedDate.year,
        gMonth: _selectedDate.month
      );

      /* 월간소비정보 위젯 가져오기 */
      _monthPlanWidget = MonthlyExpenseCalendar(
          key: UniqueKey(),
          uId: user!.uID!,
          expenses: cashFlowController!.expensesMap,
          gYear: _selectedDate.year,
          gMonth: _selectedDate.month
        );

        _expenseListWidget = ExpensesList();
        // 선택한 날짜에 대한 소비 내역을 가져옵니다.
        cashFlowController?.getExpensesForSelectedDay(user!.uID!, _selectedDate);
  }

  /* 월 변경하기 */
  void changeMonth(int increment) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + increment);
      // 금액 초기화
      cashFlowController!.monthTotalAmount.value = 0;
      cashFlowController!.monthAmount.value = 0;
      loadData();
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    String? code = userInfoController!.getUserInfo().uID;
    String? title = userInfoController!.getUserInfo().userName;

    /* Load Widgets data */
    loadWidgetData();

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
                  color: Colors.lightBlue[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (code?.startsWith('MF') ?? false) 
                TextSpan(
                  text: ' for $title',
                  style:  TextStyle(
                    color: Colors.lightBlue[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async{
              var result = await Get.to(() => const ConnectRoomScreen());
              if (result == 'Updated') {
                setState(() {
                  // 여기에 업데이트 로직을 추가
                  user = userInfoController!.getUserInfo();
                  print('>>>User ID: ${user!.uID}');
                  loadData();
                });
              }
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const ConnectRoomScreen()), // NewScreen은 이동하려는 화면의 위젯입니다.
              // );
            },
            icon: const Icon(Icons.ballot_outlined),
            color: Colors.black,
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingWidget()), // NewScreen은 이동하려는 화면의 위젯입니다.
              );
            },
            icon: const Icon(Icons.settings),
            color: Colors.black,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(_animation),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => changeMonth(-1),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: Colors.blueGrey.withOpacity(0.3),
                        iconSize: 17, // adjust the size as needed
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "${_selectedDate.year}.",
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Pacifico",
                                      color: Colors.black,  // 원하는 기본색을 선택하세요.
                                    ),
                                  ),
                                  TextSpan(
                                    text: _selectedDate.month.toString().padLeft(2, '0'),
                                    style:  TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Pacifico",
                                      color: Colors.lightBlue[900],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            /*Text(
                              "${_selectedDate.year}.${_selectedDate.month.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Pacifico",
                              ),
                            ),*/
                            /*Transform.translate(
                              offset: const Offset(0, 4),
                              child: Text(
                                "소비정보",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Montserrat",
                                  color: Colors.lightBlue[900],
                                ),
                              ),
                            ),*/
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => changeMonth(1),
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        color: Colors.blueGrey.withOpacity(0.3),
                        iconSize: 17, // adjust the size as needed
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "  \" 현재 사용가능금액은 ",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Obx(() {
                        int tmpPayInfo = cashFlowController!.monthTotalAmount.value;
                        int tmpGoalInfo = cashFlowController!.monthAmount.value.ceil();
                        int tmpRemainAmt = tmpGoalInfo - tmpPayInfo;
                        return Text(
                          "￦${formatNumberWithComma(tmpRemainAmt)}",
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        );
                      }),
                      Text(
                        " 입니다 \"",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: [
                      _payInfoWidget,
                      const SizedBox(height: 20),
                      _weekPlanWidget,
                      const SizedBox(height: 20),
                      _monthPlanWidget,
                      const SizedBox(height: 20),
                      _expenseListWidget
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  } // End build
}

