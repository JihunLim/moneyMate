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
      var sortedExpenses = List<CashFlowModel>.from(cashFlowController.expenses_list)
      ..sort((a, b) {
        if (a.timeStamp == null && b.timeStamp == null) return 0;
        if (a.timeStamp == null) return 1;
        if (b.timeStamp == null) return -1;
        return b.timeStamp!.compareTo(a.timeStamp!);
      });
      cashFlowController.expenses_list.assignAll(sortedExpenses);

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
                  padding: const EdgeInsets.all(5.0),
                  color: const Color.fromARGB(255, 203, 226, 241),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("   ${DateFormat('yyyy.MM.dd').format(cashFlowController.expenses_list_date.value)}",
                                  style: const TextStyle(fontSize: 12.0),
                    ),
                  ),
                ), 
                /* 소비내역 출력 */
                ...cashFlowController.expenses_list.map((expense) {
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.only(left: 5.0, top: 3.0, bottom: 1.0, right: 5.0),
                        title: Text('${expense.tag} ', style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,  // 오른쪽 정렬
                          mainAxisAlignment: MainAxisAlignment.center,  // 세로 방향으로 가운데 정렬
                          children: [
                            const Spacer(),  // 이 Spacer 위젯은 금액을 중앙으로 밀어줍니다.
                            Text(
                              '￦ ${NumberFormat("#,###").format(expense.amount!.round())}', 
                              style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)
                            ),
                            const Spacer(),  
                            Text(
                              expense.timeStamp ?? '',
                              style: const TextStyle(fontSize: 9.0, color: Colors.grey)  // 작은 글씨로 표시
                            ),
                          ],
                        ),
                        dense: true,
                      ),
                      const Divider(color: Colors.grey, thickness: 0.5)
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





