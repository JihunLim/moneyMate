import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

///숫자에 콤마(,)를 더해주는 함수
///입력: int 출력: String
String formatNumberWithComma(int number) {
  final formatter = NumberFormat('###,###');
  return formatter.format(number);
}

///환율정보 얻기(USD, KRW)
Future<double> getExchangeRate(String fromCurrency, String toCurrency) async {
  const appId = '7755b4242f2946cdb5dc12f85b36d651';
  const url = 'https://openexchangerates.org/api/latest.json?app_id=$appId';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    double fromRate = (data['rates'][fromCurrency] as num).toDouble();
    double toRate = (data['rates'][toCurrency] as num).toDouble();
    return toRate / fromRate;
  } else {
    //throw Exception('Failed to load exchange rate');
    showToast("사용량이 많아 환율정보를 가져올 수 없습니다. 직접 확인해주세요.");
    return -1;
  }
}

///Toast 메시지 출력
void showToast(String text) {
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

///비밀번호 유효성 검사
bool chkPwdOk = false;
bool validatePassword(String password) {
  // 비밀번호가 6자 이상이며 영문과 숫자를 포함해야 함
  RegExp regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d\S]{6,}$');
  if(regex.hasMatch(password)) chkPwdOk = true;
  return regex.hasMatch(password);
}

///이메일 유효성 검사
bool chkEmailOk = false;
bool isValidEmail(String email) {
  final RegExp regex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$"
  );
  if(regex.hasMatch(email)) chkEmailOk = true;
  return regex.hasMatch(email);
}
