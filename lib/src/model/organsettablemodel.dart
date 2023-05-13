import 'package:intl/intl.dart';

class OrganSetTableModel {
  final String id;
  final String organId;
  final String setNum;
  final DateTime? setTime;
  final String setAmount;
  final String tableAmount;

  const OrganSetTableModel(
      {required this.id,
      required this.organId,
      required this.setNum,
      required this.setTime,
      required this.setAmount,
      required this.tableAmount});

  factory OrganSetTableModel.fromJson(Map<String, dynamic> json) {
    return OrganSetTableModel(
      id: json['organ_set_table_id'] == null
          ? ''
          : json['organ_set_table_id'].toString(),
      organId: json['organ_id'] == null ? '' : json['organ_id'].toString(),
      setNum: json['set_number'] == null ? '' : json['set_number'].toString(),
      setTime: json['set_time'] == null
          ? null
          : DateFormat('HH:mm').parse(json['set_time']),
      setAmount:
          json['set_amount'] == null ? '' : json['set_amount'].toString(),
      tableAmount:
          json['table_amount'] == null ? '' : json['table_amount'].toString(),
    );
  }
}
