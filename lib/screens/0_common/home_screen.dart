import 'package:flutter/material.dart';

import '../1_screen/dashbord.dart';
import '../2_screen/payment.dart';
import '../3_screen/purpose.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  int _selIdx = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    PaymentEnrollScreen(),
    PurposeSetScreen(), 
  ];

  void _onItemTapped(int index) {
    setState(
      () {
        _selIdx = index;
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selIdx),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '머니마인드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: '지출등록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '목표세우기',
          ),
        ],
        currentIndex: _selIdx,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}