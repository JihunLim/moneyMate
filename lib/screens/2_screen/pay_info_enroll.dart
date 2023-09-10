import 'package:country_currency_pickers/country.dart';
import 'package:country_currency_pickers/currency_picker_dialog.dart';
import 'package:country_currency_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:moneymate/screens/0_common/utility.dart';
import '../../models/cash_flow_model.dart';
import '../../models/user_info_model.dart';
import 'date_picker.dart';

class PayInfoEnrollWidget extends StatefulWidget {
  final int gnMonth;
  final String gsPayinfo;
  final String gsGoalinfo;
  final int gnPercent;

  const PayInfoEnrollWidget({
    super.key,
    required this.gnMonth,
    required this.gsPayinfo,
    required this.gsGoalinfo,
    required this.gnPercent,
  });

  @override
  State<PayInfoEnrollWidget> createState() => _PayInfoEnrollWidgetState();

  //static Widget payInfoWidget({required int gnMonth, required String gsPayinfo, required String gsGoalinfo, required int gnPercent}) {}
}

class _PayInfoEnrollWidgetState extends State<PayInfoEnrollWidget> {
  final _tagController = TextEditingController();
  late final _amountController; // = TextEditingController();
  late FocusNode myFocusNode;

  String exchangedFormattedValue = '0';
  String selectedCountryCode = "KR";
  Country _selectedDialogCurrency =
      CountryPickerUtils.getCountryByCurrencyCode('KRW');

  late final int _gnMonth;
  late final String _gsPayinfo;
  late final String _gsGoalinfo;
  late final int _gnPercent;
  int widrawAm = 0;
  String widrawTag = "";
  UserInfo? user;
  int maxValue = 999999999999; // 9999억...
  String _previousValue = ''; // 이전 값을 저장하기 위한 변수 선언
  double exchangeRate = 1; //환율
  double exchangeMoney = 0; //환전된 돈(최종 저장할 값)

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

    //현재 locale을 기반으로 나라 선택 후 환율정보 가져오기.

    //컨트롤러 초기화
    _amountController = TextEditingController();
    myFocusNode = FocusNode();

    //리스터 추가하기
    _amountController.addListener(() {
      // 값이 비어있거나 "0"일 경우 exchangedFormattedValue를 "0"으로 설정
      String val = _amountController.value.text;
      print("test : $val");
      if (_previousValue.isEmpty || _previousValue == "0" || val == "") {
        exchangedFormattedValue = "0";
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    myFocusNode.dispose();
    super.dispose();
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
      gravity: ToastGravity.SNACKBAR,
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
      logger.d('RestTime: $exchangeMoney : $widrawTag');
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

      if (user != null) {
        if (user!.uID != null) {
          String uid = user!.uID!;
          String year = _selectedDate.year.toString();
          String month = _selectedDate.month.toString();
          String baseDt = DateFormat('yyyyMMdd').format(_selectedDate);
          String dateTime =
              DateFormat('yyyy.MM.dd HH:mm:ss').format(DateTime.now());

          //소비금액이 없는 경우 반환
          if (exchangeMoney == 0) {
            showToast('소비금액을 입력해주세요!');
            myFocusNode.requestFocus();
            return;
          }

          await cashFlowController.saveDayAmountAndTag(
              uid, exchangeMoney, widrawTag, baseDt, dateTime);
          isSaved = true;

          showToast('소비금액이 저장되었습니다.');
        }
      }

      if (!isSaved) {
        showToast('문제가 발생했습니다. 버그가 수정되기 전까지 기다려주세요~');
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

  void setTagValue(String tagValue) {
    setState(() {
      widrawTag = tagValue;
    });
  }

  void onCountryChange(CountryCode countryCode) {
    //TODO : manipulate the selected country code here
    print("New Country selected: $countryCode");
  }

  String formatToKoreanNumber(int value) {
    String result = "";

    if (value >= 100000000) {
      int eok = value ~/ 100000000;
      result += "$eok억";
      value = value % 100000000;
    }

    if (value >= 10000) {
      int man = value ~/ 10000;
      result += "$man만";
      value = value % 10000;
    }

    if (value >= 1000) {
      int cheon = value ~/ 1000;
      result += "$cheon천";
      value = value % 1000;
    }

    if (value >= 100) {
      int baek = value ~/ 100;
      result += "$baek백";
      value = value % 100;
    }

    if (value > 0) {
      result += "$value";
    } else if (result.isNotEmpty) {
      result += "";
    } else {
      result = "0";
    }

    return result;
  }

  Future<void> handleCountryCodeChange(String countryCode) async {
    //선택된 나라로 환율정보 가져오기
    exchangeRate = await getExchangeRate(countryCode, 'KRW');
    print("환율 : $exchangeRate");
    setState(() {
      // 상태 변경 코드
    });
  }

  Widget buildTagButtons() {
    List<String> tags = ['식비', '카페•커피', '쇼핑', '교통•자동차', '취미•여가', '기타'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tags.map((tag) {
          return GestureDetector(
            onTap: () {
              _tagController.text = tag;
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.grey[300],
              ),
              child: Text(
                tag,
                style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold), // 태그 사이즈를 줄였습니다.
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrencyDropdownItem(Country country) => Container(
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            const SizedBox(
              width: 8.0,
            ),
            Text("${country.currencyCode}"),
          ],
        ),
      );

  Widget _buildCurrencyDialogItem(Country country) => Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          const SizedBox(width: 8.0),
          Text("${country.currencyCode}"),
        ],
      );

  void _openCurrencyPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.pink),
            child: CurrencyPickerDialog(
                titlePadding: const EdgeInsets.all(8.0),
                searchCursorColor: Colors.pinkAccent,
                searchInputDecoration: const InputDecoration(hintText: '검색...'),
                isSearchable: true,
                title: const Text('통화를 선택하세요'),
                onValuePicked: (Country country) => setState(() {
                      // 상태 변경 코드
                      _selectedDialogCurrency = country;
                      //선택된 나라로 환율정보 가져오기
                      handleCountryCodeChange(
                          _selectedDialogCurrency.currencyCode!.toUpperCase());
                      print(
                          "선택된통화 : ${_selectedDialogCurrency.currencyCode!.toUpperCase()}");
                      _amountController.value = TextEditingValue(
                        text: "0",
                        selection: TextSelection.fromPosition(
                            TextPosition(offset: _previousValue.length)),
                      );
                    }),
                itemBuilder: _buildCurrencyDialogItem)),
      );

  Widget payInfoEnrollWidget(
      int nMonth, String sPayinfo, String sGoalinfo, int nPercent) {
    final Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SizedBox(
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
                          children: <Widget>[
                            /* 입력 폼 시작 */
                            const SizedBox(
                              height: 10,
                            ),
                            DatePickerWidget(key: _datePickerKey),
                            const SizedBox(
                              height: 30,
                            ),
                            TextField(
                              controller: _amountController,
                              focusNode: myFocusNode,
                              textAlign: TextAlign.right,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (value) {
                                setState(() {
                                  int? intValue =
                                      int.tryParse(value.replaceAll(',', ''));
                                  if (intValue != null) {
                                    // 입력값이 최대값을 초과하는 경우
                                    if (intValue > maxValue) {
                                      Fluttertoast.showToast(
                                        msg: "허용가능한 금액을 초과했습니다.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.grey,
                                        textColor: Colors.white,
                                      );

                                      _amountController.value =
                                          TextEditingValue(
                                        text: _previousValue,
                                        selection: TextSelection.fromPosition(
                                            TextPosition(
                                                offset: _previousValue.length)),
                                      );
                                    } else {
                                      String formattedValue =
                                          NumberFormat("#,###")
                                              .format(intValue);
                                      _amountController.value =
                                          TextEditingValue(
                                        text: formattedValue,
                                        selection: TextSelection.fromPosition(
                                            TextPosition(
                                                offset: formattedValue.length)),
                                      );

                                      _previousValue =
                                          formattedValue; // 현재 값을 저장
                                    }
                                    //최종값 저장
                                    exchangeMoney = (double.tryParse(
                                                _previousValue.replaceAll(
                                                    ',', '')) ??
                                            0.0) *
                                        exchangeRate;
                                    if (_previousValue == "" ||
                                        _previousValue == "0") {
                                      exchangeMoney = 0;
                                    }
                                    print(
                                        "환전 : $exchangeMoney , 환율 : $exchangeRate, 값: $_previousValue");
                                    exchangedFormattedValue = exchangeMoney == 0
                                        ? "0"
                                        : "${formatToKoreanNumber(exchangeMoney.toInt())} 원";
                                    if (value == "") {
                                      exchangedFormattedValue = "0";
                                    }
                                  }
                                });
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    right: 10.0,
                                    left: 10,
                                    top: 1,
                                    bottom:
                                        5), //symmetric(vertical: 5.0, horizontal: 10.0), // 패딩 조절
                                border: const OutlineInputBorder(),
                                labelText: '지출금액',
                                prefixIcon: Column(
                                  children: [
                                    GestureDetector(
                                      // <-- GestureDetector 추가
                                      onTap:
                                          _openCurrencyPickerDialog, // <-- onTap 이벤트 핸들러를 여기에 추가합니다.
                                      child: SizedBox(
                                        height: 60, // CountryCodePicker의 크기 조절
                                        width: 85,
                                        child: Transform.translate(
                                          offset: const Offset(5, 0),
                                          child: _buildCurrencyDialogItem(
                                              _selectedDialogCurrency),
                                        ),
                                      ),
                                    ),
                                    // SizedBox(
                                    //   height: 60, // CountryCodePicker의 크기 조절
                                    //   width: 100,
                                    //   child: Transform.translate(
                                    //     offset: const Offset(5, 0),
                                    //     child:  _buildCurrencyDialogItem(_selectedDialogCurrency),
                                    //     // CurrencyPickerDropdown(
                                    //     //   initialValue: 'KRW',
                                    //     //   itemBuilder: _buildCurrencyDialogItem,//_buildCurrencyDropdownItem,
                                    //     //   onValuePicked: (Country? country) {
                                    //     //     print("${country?.name}");
                                    //     //   },
                                    //     // ),
                                    //     /*CountryCodePicker(
                                    //       onChanged: (countryCode) {
                                    //         setState(() {
                                    //           selectedCountryCode = countryCode.code.toString();
                                    //         });
                                    //         //선택된 나라로 환율정보 가져오기
                                    //         handleCountryCodeChange('USD');
                                    //         //print("$selectedCountryCode"); // 선택된 국가 코드를 출력합니다.
                                    //       },
                                    //       padding: const EdgeInsets.all(2),
                                    //       initialSelection: 'KR',
                                    //       favorite: const [
                                    //         '+82',  // 한국
                                    //         '+81',  // 일본
                                    //         'US',   // 미국
                                    //         '+63',  // 필리핀
                                    //         '+84',  // 베트남
                                    //         '+886', // 대만
                                    //         '+66',  // 태국
                                    //       ],
                                    //       showCountryOnly: true,
                                    //       showOnlyCountryWhenClosed: true,
                                    //       textStyle: const TextStyle(fontSize: 0),
                                    //       alignLeft: false,
                                    //     ),*/
                                    //   )
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: exchangedFormattedValue == "0"
                                  ? null
                                  : Text(
                                      //"${formatToKoreanNumber(int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0)} 원", // 현재의 금액 값을 가져옴 (원하는 형식에 따라 수정 가능)
                                      exchangedFormattedValue,
                                      style: const TextStyle(
                                        fontSize: 16, // 글자 크기 조절
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),

                            const SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                                controller: _tagController,
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
                                }),
                            const SizedBox(
                              height: 10,
                            ),
                            buildTagButtons(), //tags
                            const SizedBox(
                              height: 40,
                            ),
                            Container(
                              width: screenSize.width - 100,
                              margin: const EdgeInsets.only(top: 20.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  submit(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 10.0),
                                  backgroundColor: Colors.teal[500],
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
                                          blurRadius: 1.0,
                                          color: Colors.white,
                                          offset: Offset(0, 0),
                                        )
                                      ]),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return payInfoEnrollWidget(_gnMonth, _gsPayinfo, _gsGoalinfo, _gnPercent);
  }
}
