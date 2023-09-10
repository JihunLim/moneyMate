import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

class MoneyFlow {
  Map<String, dynamic>? dayAmountMap; //일자, 금액
  String? dayTag;

  MoneyFlow({required this.dayTag, required this.dayAmountMap});
}

class MoneyFlow2 {
  String? basDt;
  double? amount;
  String? tag;

  MoneyFlow2({required this.basDt, required this.amount, this.tag});
}

class CashFlowModel {
  DateTime? basDtm;
  double? amount;
  String? tag;
  String? timeStamp;

  CashFlowModel({required this.basDtm, required this.amount, this.tag, this.timeStamp});
}

class MoneyFlowM {
  DateTime? dateTime;
  int? amount;

  MoneyFlowM({required this.dateTime, required this.amount});
}

class CashFlowController extends GetxController {
  /// DB 저장 리스트
  /// ----------------------------------------------------
  /// > 사용자 정보
  ///   - userId
  ///   - userName
  ///   - userPwd
  ///   - userEmail
  ///   - userPhone
  /// 
  /// > CashFlow 정보
  ///   > Purpose 정보
  ///     - 202303 {amount : 금액, tag : 목표}
  ///   > Spent 정보
  ///     - 20230301 {amout : 금액, tag : 사유}

  final DatabaseReference expenseRef = FirebaseDatabase.instance.reference().child("expenses");
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final expensesM = <MoneyFlowM>[].obs; //리스트로 선언
  final expensesD = <MoneyFlow>[].obs; //리스트로 선언
  final expensesW = <MoneyFlow2>[].obs; //리스트로 선언
  final expenses_list = <CashFlowModel>[].obs;
 final expenses_list_date = DateTime.now().obs;

  RxDouble monthAmount = 0.0.obs;
  RxString monthTag = ''.obs;

  RxInt monthTotalAmount = 0.obs;
  RxInt weekTotalAmount = 0.obs;

  RxMap<DateTime, int> expensesMap = <DateTime, int>{}.obs;




  Future<void> getPurposeByMonth(String userId, int year, int month) async {
    final String monthStr = '${year.toString().padLeft(4, '0')}${month.toString().padLeft(2, '0')}';
    //Init..
    monthAmount.value = 0; // 월 목표금액 초기화
    monthTag.value = ""; // 월 목표태그 초기화

    DocumentSnapshot docSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('purpose')
        .doc(monthStr)
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      monthAmount.value = data['monthAmount'].toDouble();
      monthTag.value = data['monthTag'];
      
      print('월 목표금액: ${data['monthAmount']}');
      print('월 목표: ${data['monthTag']}');
    } else {
      print('해당 월의 데이터가 없습니다.');
    }
  }

  ///월 기준으로 expenses 리스트에 일자별로 소비한 금액의 sum값을 넣는 함수(비동기)
  /*
  Future<void> getExpensesByMonth(String userId, int year, int month) async {

    monthTotalAmount.value = 0;
    // expensesM 리스트 초기화
    expensesM.clear();
    expensesMap.clear();

    // 시작일과 종료일 구하기
    final DateTime startDate = DateTime(year, month, 1);
    final DateTime endDate = DateTime(year, month + 1, 0);

    // 모든 일자 생성
    final List<String> dates = [];
    for (DateTime date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final DateFormat formatter = DateFormat("yyyyMMdd");
      final String formattedDate = formatter.format(date);
      dates.add(formattedDate);
    }

    // 일자별 데이터 가져오기
    for (final date in dates) {
      //print('*** Date > ${date.toString()}');
      double dayAmount = 0;
      String dayTag = "";
      int chkYear = int.parse(date.substring(0, 4));
      int chkMonth = int.parse(date.substring(4, 6));

      if(!(year == chkYear && month == chkMonth)) break; // 년월 정보 맞지 않을경우 braek

      try {
        QuerySnapshot querySnapshot = await firestore.collection('users').doc(userId).collection('payment').doc(date).collection('data').get();
        
        // querySnapshot.docs는 해당 일자의 모든 'data' 문서를 포함한 리스트입니다.
        for (var doc in querySnapshot.docs) {
          // 각 문서의 데이터에 액세스하려면 doc.data()를 사용하세요.
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          print('*** Date > ${date.toString()} > data > ${data.toString()}');

          //빠르게 월정보를 넘길 경우, 소비금액이 잘못 더해지는 경우가 발생하여 방어로직 생성
          if(year == chkYear && month == chkMonth) {
            dayAmount += data['dayAmount'] ?? 0.0;
          }
        }
        monthTotalAmount.value += dayAmount.round();
        dayTag = "합계";
        //print('Date: ${date.toString()}, MonthTotalAmount: ${monthTotalAmount.value}, Day amount: $dayAmount, Day tag: $dayTag');
        //일별 소비합계 금액 저장
        String tmpStrDt = "${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)}";
        DateTime tmpDt = DateTime.parse(tmpStrDt);
        //expensesM.add(MoneyFlowM(dateTime: tmpDt, amount: dayAmount.ceil()));
        expensesMap[tmpDt] = dayAmount.ceil();

      } catch (e) {
        print('Error getting day amount and tag: $e');
      }
    }
  }
  */

  ///월 기준으로 expenses 리스트에 일자별로 소비한 금액의 sum값을 넣는 함수 (동기)
  Future<void> getExpensesByMonth(String userId, int year, int month) async {

    monthTotalAmount.value = 0;
    // expensesM 리스트 초기화
    expensesM.clear();
    expensesMap.clear();

    // 시작일과 종료일 구하기
    final DateTime startDate = DateTime(year, month, 1);
    final DateTime endDate = DateTime(year, month + 1, 0);

    // 모든 일자 생성
    final List<String> dates = [];
    for (DateTime date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final DateFormat formatter = DateFormat("yyyyMMdd");
      final String formattedDate = formatter.format(date);
      dates.add(formattedDate);
    }

    // 일자별 데이터 가져오기
    List<Future> futures = [];
    for (final date in dates) {
      futures.add(getDayAmount(userId, date, year, month));
    }
    await Future.wait(futures);
  }
  
  Future<void> getDayAmount(String userId, String date, int year, int month) async {
    //print('*** Date > ${date.toString()}');
    double dayAmount = 0;
    String dayTag = "";
    int chkYear = int.parse(date.substring(0, 4));
    int chkMonth = int.parse(date.substring(4, 6));

    if(!(year == chkYear && month == chkMonth)) return; // 년월 정보 맞지 않을경우 braek

    try {
      QuerySnapshot querySnapshot = await firestore.collection('users').doc(userId).collection('payment').doc(date).collection('data').get();

      // querySnapshot.docs는 해당 일자의 모든 'data' 문서를 포함한 리스트입니다.
      for (var doc in querySnapshot.docs) {
        // 각 문서의 데이터에 액세스하려면 doc.data()를 사용하세요.
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('*** Date > ${date.toString()} > data > ${data.toString()}');

        //빠르게 월정보를 넘길 경우, 소비금액이 잘못 더해지는 경우가 발생하여 방어로직 생성
        if(year == chkYear && month == chkMonth) {
          dayAmount += data['dayAmount'] ?? 0.0;
        }
      }
      monthTotalAmount.value += dayAmount.round();
      dayTag = "합계";
      //print('Date: ${date.toString()}, MonthTotalAmount: ${monthTotalAmount.value}, Day amount: $dayAmount, Day tag: $dayTag');
      //일별 소비합계 금액 저장
      String tmpStrDt = "${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)}";
      DateTime tmpDt = DateTime.parse(tmpStrDt);
      //expensesM.add(MoneyFlowM(dateTime: tmpDt, amount: dayAmount.ceil()));
      expensesMap[tmpDt] = dayAmount.ceil();

    } catch (e) {
      print('Error getting day amount and tag: $e');
    }
  }

  ///월 기준으로 expenses 리스트에 일자별로 소비한 금액의 sum값을 넣는 함수
  Future<void> getExpensesByMonth2(String userId, int year, int month) async {

    //monthTotalAmount.value = 0;
    // expensesM 리스트 초기화
    expensesM.clear();
    expensesMap.clear();

    // 시작일과 종료일 구하기
    final DateTime startDate = DateTime(year, month, 1);
    final DateTime endDate = DateTime(year, month + 1, 0);

    // 모든 일자 생성
    final List<String> dates = [];
    for (DateTime date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final DateFormat formatter = DateFormat("yyyyMMdd");
      final String formattedDate = formatter.format(date);
      dates.add(formattedDate);
    }

    // 일자별 데이터 가져오기
    for (final date in dates) {
      //print('*** Date > ${date.toString()}');
      double dayAmount = 0;
      //String dayTag = "";

      try {
        QuerySnapshot querySnapshot = await firestore.collection('users').doc(userId).collection('payment').doc(date).collection('data').get();
        
        // querySnapshot.docs는 해당 일자의 모든 'data' 문서를 포함한 리스트입니다.
        for (var doc in querySnapshot.docs) {
          // 각 문서의 데이터에 액세스하려면 doc.data()를 사용하세요.
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          dayAmount += data['dayAmount'] ?? 0.0;
        }
        //monthTotalAmount.value += dayAmount.round();
        //dayTag = "합계";
        //print('Date: ${date.toString()}, MonthTotalAmount: ${monthTotalAmount.value}, Day amount: $dayAmount, Day tag: $dayTag');
        //일별 소비합계 금액 저장
        String tmpStrDt = "${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)}";
        DateTime tmpDt = DateTime.parse(tmpStrDt);
        //expensesM.add(MoneyFlowM(dateTime: tmpDt, amount: dayAmount.ceil()));
        expensesMap[tmpDt] = dayAmount.ceil();

      } catch (e) {
        print('Error getting day amount and tag: $e');
      }
    }
  }

  //getExpensesByWeek
  ///Week 기준으로 expenses 리스트에 일자별로 소비한 금액의 sum값을 넣는 함수
  void getExpensesByWeek(String userId, int year, int month, int day)  async {
    //파라미터로 입력한 일자 포함하여 일주일에 해당하는 금액 Set
    weekTotalAmount.value = 0;
    // expensesM 리스트 초기화
    expensesW.clear();

    // 시작일과 종료일 구하기
    final DateTime startDate = DateTime(year, month, day);
    final DateTime endDate = DateTime(year, month, day + 7);

    // 모든 일자 생성
    final List<String> dates = [];
    DateTime date = startDate;

    for (int i = 0; i < 7; i++){
      final DateFormat formatter = DateFormat("yyyyMMdd");
      final String formattedDate = formatter.format(date);
      dates.add(formattedDate);
      // 1일 더하기
      date = date.add(const Duration(days: 1));
    }

    // week별 데이터 가져오기
    List<Future> futures = [];
    for (final date in dates) {
      futures.add(getWeekAmount(userId, date, year, month));
    }
    await Future.wait(futures);

    // 일자별 데이터 가져오기
    /*
    for (final date in dates) {
      //print('*** Date > ${date.toString()}');
      double dayAmount = 0;
      String dayTag = "";

      try {
        QuerySnapshot querySnapshot = await firestore.collection('users').doc(userId).collection('payment').doc(date).collection('data').get();
        
        // querySnapshot.docs는 해당 일자의 모든 'data' 문서를 포함한 리스트임.
        // 하루에 해당하는 데이터 모두 가져오기
        for (var doc in querySnapshot.docs) {
          // 각 문서의 데이터에 액세스하려면 doc.data()를 사용하세요.
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          dayAmount += data['dayAmount'] ?? 0.0;
        }
        weekTotalAmount.value += dayAmount.round();
        dayTag = "합계";
        //print('Date: ${date.toString()}, weekTotalAmount: ${weekTotalAmount.value}, Day amount: $dayAmount, Day tag: $dayTag');
        //일별 소비합계 금액 저장
        expensesW.add(MoneyFlow2(basDt: date, amount: dayAmount, tag: dayTag));
      } catch (e) {
        print('Error getting day amount and tag: $e');
      }
    }
    */
  }

  Future<void> getWeekAmount(String userId, String date, int year, int month) async {
    //print('*** Date > ${date.toString()}');
    double dayAmount = 0;
    String dayTag = "";
    int chkYear = int.parse(date.substring(0, 4));
    int chkMonth = int.parse(date.substring(4, 6));

    //if(!(year == chkYear && month == chkMonth)) return; // 년월 정보 맞지 않을경우 braek

    try {
      QuerySnapshot querySnapshot = await firestore.collection('users').doc(userId).collection('payment').doc(date).collection('data').get();

      // querySnapshot.docs는 해당 일자의 모든 'data' 문서를 포함한 리스트입니다.
      for (var doc in querySnapshot.docs) {
        // 각 문서의 데이터에 액세스하려면 doc.data()를 사용하세요.
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        //print('*** Date > ${date.toString()} > data > ${data.toString()}');
        dayAmount += data['dayAmount'] ?? 0.0;
      }
      weekTotalAmount.value += dayAmount.round();
      dayTag = "합계";
      //print('Date: ${date.toString()}, MonthTotalAmount: ${monthTotalAmount.value}, Day amount: $dayAmount, Day tag: $dayTag');
      //주별 소비합계 금액 저장
      expensesW.add(MoneyFlow2(basDt: date, amount: dayAmount, tag: dayTag));

    } catch (e) {
      print('Error getting day amount and tag: $e');
    }
  }


  ///일 기준으로 expenses 리스트에 일자별로 소비한 금액의 sum값을 넣는 
  Future<Map<String, dynamic>> getExpensesByDay(String userId, int year, int month, int day) async {
    // 시작일과 종료일 구하기
    final String baseDt = year.toString() + month.toString() + day.toString();

    // 결과를 저장할 변수
    double dayAmount = 0;
    String dayTag = "";

    try {
      QuerySnapshot querySnapshot = await firestore.collection('users').doc(userId).collection('payment').doc(baseDt).collection('data').get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        dayAmount = data['dayAmount'] ?? 0.0;
        dayTag = data['dayTag'] ?? "기타";
      }
      dayTag = "합계";
      //print('Day amount: $dayAmount, Day tag: $dayTag');

      // 결과를 반환
      return {'dayAmount': dayAmount, 'dayTag': dayTag};
    } catch (e) {
      print('Error getting day amount and tag: $e');
      return {'dayAmount': 0.0, 'dayTag': 'Error'};
    }
  }

  Future<void> saveMonthAmountAndTag(String userId, double monthAmount, String monthTag, int year, int month) async {
    try {
      final String monthStr = '${year.toString().padLeft(4, '0')}${month.toString().padLeft(2, '0')}';

      await firestore.collection('users').doc(userId).collection('purpose').doc(monthStr).set({
        'monthAmount': monthAmount, //월 목표금액
        'monthTag': monthTag, //월 목표
      });

      print('Month amount and tag saved successfully');
    } catch (e) {
      print('Error saving month amount and tag: $e');
    }
  }

  Future<void> saveDayAmountAndTag(String userId, double dayAmount, String dayTag, String baseDt, String dateTime) async {
    try {
      //final String monthStr = '${year.toString().padLeft(4, '0')}${month.toString().padLeft(2, '0')}';
      /*
      await firestore.collection('users').doc(userId).collection('payment').doc(baseDt).set({
        'dayAmount': dayAmount, //일 목표금액
        'dayTag': dayTag, //일 목표
      });
      */

      await firestore.collection('users').doc(userId).collection('payment').doc(baseDt).collection('data').add({
        'dayAmount': dayAmount, //일 목표금액
        'dayTag': dayTag, //일 목표
        'timeStamp': dateTime, //타임스탬프
      });

      print('Month amount and tag saved successfully');
    } catch (e) {
      print('Error saving month amount and tag: $e');
    }
  }

  // 선택된 날짜에 해당하는 소비 내역 반환
  Future<void> getExpensesForSelectedDay(String userId, DateTime selectedDay) async {
    List<CashFlowModel> selectedDayExpenses = [];

    final DateFormat formatter = DateFormat("yyyyMMdd");
    final String formattedSelectedDay = formatter.format(selectedDay);

    try {
      QuerySnapshot querySnapshot = await firestore.collection('users').doc(userId).collection('payment').doc(formattedSelectedDay).collection('data').get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        double dayAmount = data['dayAmount'] ?? 0.0;
        String dayTag = data['dayTag']?.isEmpty ?? true ? '기타' : data['dayTag']!;
        String timeStamp = data['timeStamp']?.isEmpty ?? true ? '' : data['timeStamp']!;
        

        selectedDayExpenses.add(CashFlowModel(basDtm: selectedDay, amount: dayAmount, tag: dayTag, timeStamp: timeStamp));
      }
    } catch (e) {
      print('Error getting day amount and tag: $e');
    }
    expenses_list_date.value = selectedDay;
    expenses_list.assignAll(selectedDayExpenses);
  }

/* 3월의 소비 내역을 가져오기
  onPressed: () async {
          await expenseController.getExpensesByMonth('your_user_id', 2023, 3);
        },


  onPressed: () async {
  await cashFlowController.saveMonthAmountAndTag('your_user_id', 1000, 'Some Purpose', 2023, 3);
},      
*/

/*
// firestore의 변수가 변경되면 stream 기능으로 이를 감지하여 자동으로 변수를 변경해주는 기능 
void _bindData(String userId) {
  // Firestore 데이터베이스에서 스트림을 가져옵니다.
  FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('payment')
      .snapshots()
      .listen((snapshot) {
    // 데이터베이스에서 변경 사항이 감지되면 Rx 변수를 업데이트합니다.
    // 이 경우, Firestore의 'payment' 컬렉션의 일부 문서가 변경될 때마다
    // 월별 및 일별 소비 데이터를 다시 가져옵니다.

    // 현재 코드에서는 연도와 월이 하드코딩되어 있습니다.
    // 필요에 따라 이 부분을 수정할 수 있습니다.
    final int currentYear = 2023;
    final int currentMonth = 4;

    getExpensesByMonth(userId, currentYear, currentMonth);
  });
}
*/


}