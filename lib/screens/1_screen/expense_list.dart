import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moneymate/models/cash_flow_model.dart';
import 'package:intl/intl.dart';
import 'package:moneymate/models/user_info_model.dart';
import 'package:moneymate/screens/0_common/utility.dart';

class ExpensesList extends StatelessWidget {
  final CashFlowController cashFlowController = Get.find<CashFlowController>();
  final UserInfoController userInfoController = Get.find<UserInfoController>();

  ExpensesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var user = userInfoController.getUserInfo();
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(),
                              Text(
                                '￦ ${NumberFormat("#,###").format(expense.amount!.round())}',
                                style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                expense.timeStamp ?? '',
                                style: const TextStyle(fontSize: 9.0, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 26,
                            child: IconButton(
                              icon: const Icon(Icons.more_vert),
                              padding: const EdgeInsets.all(3),
                              onPressed: () {
                                final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                                final RenderBox button = context.findRenderObject() as RenderBox;
                                final RelativeRect position = RelativeRect.fromRect(
                                  Rect.fromPoints(
                                    button.localToGlobal(Offset.zero, ancestor: overlay),
                                    button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                                  ),
                                  Offset.zero & overlay.size,
                                );
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Wrap(
                                      children: <Widget>[
                                        // 추가 구현하기. 
                                        // ListTile(
                                        //   leading: const Icon(Icons.check, color: Colors.green),
                                        //   title: const Text('확인하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                        //   onTap: () {
                                        //     Navigator.pop(context, 'check');
                                        //   },
                                        //   tileColor: Colors.blueGrey[50],  // 배경색 설정
                                        // ),
                                        ListTile(
                                          leading: const Icon(Icons.delete, color: Colors.red),
                                          title: const Text('삭제하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                          onTap: () {
                                            Navigator.pop(context, 'delete');
                                          },
                                          tileColor: Colors.blueGrey[50],  // 배경색 설정
                                        ),
                                      ],
                                    );
                                  },
                                ).then((value) async {
                                  if (value == 'check') {
                                    // "확인하기"를 선택했을 때의 로직
                                  } else if (value == 'delete') {
                                    // "삭제하기"를 선택했을 때의 로직
                                    String userId = user.uID!; // 사용자 ID
                                    DateTime selectedDate = cashFlowController.expenses_list_date.value;
                                    String docId = expense.docId ?? '';
                          
                                    bool success = await cashFlowController.deleteExpenseForSelectedDay(userId, selectedDate, docId);
                                    if(success){
                                      cashFlowController.expenses_list.remove(expense);  // 리스트에서 삭제된 항목을 제거
                                      showToast("소비기록이 삭제되었습니다.");
                                    }else{
                                      showToast("문제가 발생했습니다. 잠시후에 다시 시도해주세요.");
                                    }

                                    
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      dense: true,
                    ),
                    const Divider(color: Colors.grey, thickness: 0.5),
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





