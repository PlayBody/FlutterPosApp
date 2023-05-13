import 'package:staff_pos_app/src/model/order_menu_model.dart';

class OrderModel {
  final String orderId;
  final String organName;
  final String staffId;
  final String userId;
  final String tableTitle;
  final String staffName;
  final String userName;
  final String userInputName;
  final String seatno;
  final int amount;
  final String status;
  final String fromTime;
  final String toTime;
  final int flowTime;
  final String? payMethod;
  final List<OrderMenuModel> menus;

  const OrderModel({
    required this.orderId,
    required this.userId,
    required this.staffId,
    required this.organName,
    required this.tableTitle,
    required this.staffName,
    required this.userName,
    required this.userInputName,
    required this.status,
    required this.seatno,
    required this.fromTime,
    required this.toTime,
    required this.amount,
    required this.flowTime,
    this.payMethod,
    required this.menus,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderMenuModel> menus = [];
    if (json['menus'] != null) {
      for (var item in json['menus']) {
        menus.add(OrderMenuModel.fromJson(item));
      }
    }
    return OrderModel(
        orderId: json['id'].toString(),
        userId: json['user_id'] == null ? '0' : json['user_id'].toString(),
        staffId: json['select_staff_id'] == null
            ? ''
            : json['select_staff_id'].toString(),
        tableTitle: json['table_name'] ?? '',
        organName: json['organ_name'] ?? '',
        staffName: json['staff_name'] ?? '',
        userName: json['user_name'] ?? '',
        userInputName: json['user_input_name'] ?? '',
        seatno: json['table_position'].toString(),
        status: json['status'].toString(),
        fromTime: json['from_time'] == null ? '' : json['from_time'].toString(),
        toTime: json['to_time'] == null ? '' : json['to_time'].toString(),
        amount: json['amount'] == null
            ? 0
            : double.parse(json['amount'].toString()).toInt(),
        flowTime: json['flow_time'] == null
            ? 0
            : int.parse(json['flow_time'].toString()),
        payMethod:
            // ignore: prefer_null_aware_operators
            json['pay_method'] == null ? null : json['pay_method'].toString(),
        menus: menus);
  }
}
