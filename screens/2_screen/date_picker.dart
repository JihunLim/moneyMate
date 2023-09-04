import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget({super.key});

  @override
  DatePickerWidgetState createState() => DatePickerWidgetState();
}

class DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  DateTime getSelectedDate() {
    return _selectedDate;
  } 

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: TextEditingController(
          text: DateFormat('yyyyMMdd').format(_selectedDate)),
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Select a date',
        labelText: '날짜 선택',
      ),
      onSaved: (String? value) {
        // Save the date value in the desired format
      },
    );
  }
}