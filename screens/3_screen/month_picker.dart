import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
//import 'package:flutter_date_pickers/flutter_date_pickers.dart';

class MonthPickerWidget extends StatefulWidget {
  const MonthPickerWidget({super.key});

  @override
  MonthPickerWidgetState createState() => MonthPickerWidgetState();
}

class MonthPickerWidgetState extends State<MonthPickerWidget> {
  DateTime _selectedDate = DateTime.now();

  
  //month_year_picker 패키지 사용 시 아래 코드 사용 
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showMonthYearPicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_selectedDate.year-5),
      lastDate: DateTime(_selectedDate.year+5),
      //locale: const Locale('ko'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  //flutter_date_picker 패키지 사용
  /*
  Future<void> _selectDate(BuildContext context) async {
    MonthPicker.single(
      selectedDate: _selectedDate,
      firstDate: DateTime(_selectedDate.year-5),
      lastDate: DateTime(_selectedDate.year+5),
      onChanged: _onSelectedDateChanged,
      //locale: const Locale('ko'),
    );
  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }
  */
  DateTime getSelectedDate() {
    return _selectedDate;
  } 

  

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: TextEditingController(
          text: DateFormat('yyyyMM').format(_selectedDate)),
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Select a month',
        labelText: '월 선택',
      ),
      onSaved: (String? value) {
        // Save the date value in the desired format
      },
    );
  }
}