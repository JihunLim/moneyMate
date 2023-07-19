import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../../models/cash_flow_model.dart';
import '../../models/user_info_model.dart';
import 'date_picker.dart';

class PayInfoEnrollWidget extends StatefulWidget {
  final int gnMonth;
  final String gsPayinfo;
  final String gsGoalinfo;
  final int gnPercent;

  const PayInfoEnrollWidget({super.key, required this.gnMonth, required this.gsPayinfo, required this.gsGoalinfo, required this.gnPercent, } );
  
  @override
  State<PayInfoEnrollWidget> createState() => _PayInfoEnrollWidgetState();

  //static Widget payInfoWidget({required int gnMonth, required String gsPayinfo, required String gsGoalinfo, required int gnPercent}) {}
}

class _PayInfoEnrollWidgetState extends State<PayInfoEnrollWidget> {
  late final int _gnMonth;
  late final String _gsPayinfo;
  late final String _gsGoalinfo;
  late final int _gnPercent;
  int widrawAm = 0;
  String widrawTag = "";
  UserInfo? user;

  final cashFlowController = Get.find<CashFlowController>();
  final userInfoController = Get.find<UserInfoController>();

  final Widget datePickerWidget = const DatePickerWidget();
  
  DateTime _selectedDate = DateTime.now();
  final GlobalKey<DatePickerWidgetState> _datePickerKey = GlobalKey();


  // set var...
   final String androidTestId = 'ca-app-pub-6523753930426193/4625339787';
   //test_id : ca-app-pub-3940256099942544/6300978111
   //own_id  : ca-app-pub-6523753930426193/4625339787
  final _formKey = GlobalKey<FormState>();

  //BannerAd? banner;

  var logger = Logger(
    printer: PrettyPrinter(),
  );

    @override
  void initState() {
    super.initState();
    user = userInfoController.getUserInfo();

    _gnMonth = widget.gnMonth;
    _gsPayinfo = widget.gsPayinfo;
    _gsGoalinfo = widget.gsGoalinfo;
    _gnPercent = widget.gnPercent;

    
  }

  /*
  
  String? _validateTitle(String? value) {
    if(value == null){
      return 'The E-mail Address must be a valid email address.';
    }

    if(value.isEmpty){
      return 'The E-mail Address must be a valid email address.';
    }

    return null;
  }

  String? _validateWorkTime(String? value) {
    if(value!.isEmpty){
      HapticFeedback.lightImpact(); //진동효과 주기
      return '[오류] 시간을 입력해주세요!';
    }
    if(double.tryParse(value) == null){
      HapticFeedback.lightImpact(); //진동효과 주기
      return '[오류] 숫자를 입력해주세요!';
    }else{
      if(int.tryParse(value)! > 1440){
        HapticFeedback.lightImpact(); //진동효과 주기
        return '[오류] 24시간을 넘길수는 없습니다. 1440분 아래로 입력해주세요!';
      }
    }
    return null;
  }

  String? _validateRestTime(String? value) {
    if(value!.isEmpty){
      HapticFeedback.lightImpact(); //진동효과 주기
      return '[오류] 시간을 입력해주세요!';
    }
    if(double.tryParse(value) == null){
      HapticFeedback.lightImpact(); //진동효과 주기
      return '[오류] 숫자를 입력해주세요!';
    }else{
      if(int.tryParse(value)! > 1440){
        HapticFeedback.lightImpact(); //진동효과 주기
        return '[오류] 24시간을 넘길수는 없습니다. 1440분 아래로 입력해주세요!';
      }
    }
    return null;
  }

  String? _validatePpomoCnt(String? value) {
    if(value!.isEmpty){
      HapticFeedback.lightImpact(); //진동효과 주기
      return '[오류] 횟수를 입력해주세요!';
    }
    if(double.tryParse(value) == null){
      HapticFeedback.lightImpact(); //진동효과 주기
      return '[오류] 횟수를 입력해주세요!';
    }else{
      if(int.tryParse(value)! > 100){
        HapticFeedback.lightImpact(); //진동효과 주기
        return '[오류] 100번을 넘길수는 없습니다. 100번 아래로 입력해주세요!';
      }
    }
    return null;
  }
  */

  void _showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> submit(BuildContext context) async {
    bool isSaved = false;
    // First validate form.
    if (_formKey.currentState!.validate()) {
      setState(() {
        _selectedDate = _datePickerKey.currentState!.getSelectedDate();
      });
      _formKey.currentState?.save(); // Save our form now.

      logger.d('Printing the data.');
      logger.d('UID: ${user?.uID}');
      logger.d('date: ${_selectedDate.toString()}');
      logger.d('RestTime: $widrawAm : $widrawTag');
      //logger.d('PpomoCnt: ${_data.ppomoCnt}');

      /* //월 목표금액 설정하는 로직
      if(user != null){
        if(user!.uID != null){
          String uid = user!.uID!;
          String year = _selectedDate.year.toString();
          String month = _selectedDate.month.toString();
          await cashFlowController.saveMonthAmountAndTag(uid, widrawAm.toDouble(), widrawTag, int.parse(year), int.parse(month));
          isSaved = true;

          _showToast('목표금액이 저장되었습니다.');
        }
      }
      */

      if(user != null){
        if(user!.uID != null){
          String uid = user!.uID!;
          String year = _selectedDate.year.toString();
          String month = _selectedDate.month.toString();
          String baseDt = DateFormat('yyyyMMdd').format(_selectedDate);
          await cashFlowController.saveDayAmountAndTag(uid, widrawAm.toDouble(), widrawTag, baseDt);
          isSaved = true;

          _showToast('소비금액이 추가되었습니다.');
        }
      }

      if(!isSaved){
        _showToast('문제가 발생했습니다. 버그가 수정되기 전까지 기다려주세요~');
      }


      /* go next page
      Navigator.push(context, 
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
        ),
      );
      */
    }
  }



  Widget payInfoEnrollWidget(int nMonth, String sPayinfo, String sGoalinfo, int nPercent){
    final Size screenSize = MediaQuery.of(context).size;
    
    return SizedBox(
        height: screenSize.height - 300,
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(211, 255, 255, 255),
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
                  child: Stack(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        //height: screenSize.height,
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children:  <Widget>[
                              /* 입력 폼 시작 */
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  DatePickerWidget(key: _datePickerKey),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    obscureText: false,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      //hintText: '',
                                      labelText: '지출금액',
                                      //helperText: '',
                                    ),
                                    //initialValue: '60',
                                    //validator: _validateWorkTime,
                                    onSaved: (String? value) {
                                      int tmp = int.parse(value!);
                                      widrawAm = tmp;
                                      //_data.workTime = tmp * 60;
                                    }
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    obscureText: false,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      //hintText: '',
                                      labelText: '소비태그',
                                      //helperText: '',
                                    ),
                                    //initialValue: '10',
                                    //validator: _validateRestTime,
                                    onSaved: (String? value) {
                                      widrawTag = (value != null) ? value : '기타';
                                      //_data.restTime = tmp * 60;
                                    }
                                  ),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Container(
                                    width: screenSize.width-100,
                                    margin: const EdgeInsets.only(
                                      top: 20.0
                                    ),
                                    child: ElevatedButton(
                                      onPressed: (){submit(context);},
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25.0, vertical: 10.0), backgroundColor: Colors.teal[500],
                                          shape: const StadiumBorder(),
                                        ),
                                      child: const Text(
                                        '저장하기',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 5.0,
                                              color: Colors.white,
                                              offset: Offset(0, 0),
                                            )
                                          ]
                                        ),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      /*Positioned(
                        bottom: 0,
                        child: SizedBox(
                          width: screenSize.width,
                          height: 55.0,
                          child: AdWidget(ad: banner!),
                        ),
                      ), */
                    ],
                  ),
              ),
            ],
          ),
        ),
      );
  }


  @override
  Widget build(BuildContext context) {
    return payInfoEnrollWidget(_gnMonth, _gsPayinfo, _gsGoalinfo, _gnPercent);
  }
}