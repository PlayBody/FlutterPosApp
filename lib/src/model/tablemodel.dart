// class TableModel {
//   final String orderId;
//   final String userId;
//   final String tableTitle;
//   final String staffName;
//   final String userName;
//   final String seatno;
//   final int amount;
//   final String status;
//   final String fromTime;
//   final String toTime;
//   final int flowTime;

//   const TableModel({
//     required this.orderId,
//     required this.userId,
//     required this.tableTitle,
//     required this.staffName,
//     required this.userName,
//     required this.status,
//     required this.seatno,
//     required this.fromTime,
//     required this.toTime,
//     required this.amount,
//     required this.flowTime,
//   });

//   factory TableModel.fromJson(Map<String, dynamic> json) {
//     return TableModel(
//       orderId: json['id'].toString(),
//       userId: json['user_id'] == null ? '0' : json['user_id'].toString(),
//       tableTitle: json['table_name'],
//       staffName: json['staff_name'] == null ? '' : json['staff_name'],
//       userName: json['user_input_name'] == null ? '' : json['user_input_name'],
//       seatno: json['table_position'].toString(),
//       status: json['status'].toString(),
//       fromTime: json['from_time'] == null ? '' : json['from_time'].toString(),
//       toTime: json['to_time'] == null ? '' : json['to_time'].toString(),
//       amount: json['amount'] == null ? 0 : int.parse(json['amount'].toString()),
//       flowTime: json['flow_time'] == null
//           ? 0
//           : int.parse(json['flow_time'].toString()),
//     );
//   }
// }
