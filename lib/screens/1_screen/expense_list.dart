import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moneymate/models/cash_flow_model.dart';
import 'package:intl/intl.dart';

class ExpensesList extends StatelessWidget {
  final CashFlowController cashFlowController = Get.put(CashFlowController());

  ExpensesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (cashFlowController.expenses_list.isEmpty) {
        //return const Center(child: CircularProgressIndicator());
        return Text(
          " 이용내역이 없습니다",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        );
      } else {
        return SingleChildScrollView(
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
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      " 이용내역",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  color: Colors.blueGrey[50],
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("  ${DateFormat('yyyy.MM.dd').format(cashFlowController.expenses_list_date.value)}",
                                  style: const TextStyle(fontSize: 13.0),
                    ),
                  ),
                ), 
                ...cashFlowController.expenses_list.map((expense) {
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        title: Text('${expense.tag} ', style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                        trailing: Text(
                          '￦ ${NumberFormat("#,###").format(expense.amount!.round())}', 
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)
                        ),
                      ),
                      const Divider(color: Colors.grey, thickness: 0.5 )  // Add this line
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }
    });
  }
}





