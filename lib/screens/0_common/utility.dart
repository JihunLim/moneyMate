import 'package:intl/intl.dart';

///숫자에 콤마(,)를 더해주는 함수
///입력: int 출력: String
String formatNumberWithComma(int number) {
  final formatter = NumberFormat('###,###');
  return formatter.format(number);
}