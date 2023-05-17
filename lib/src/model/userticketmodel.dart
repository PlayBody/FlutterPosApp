import 'package:staff_pos_app/src/common/const.dart';

class UserTicketModel {
  final String id;
  final String userId;
  final String ticketId;
  final String name;
  final String title;
  final String price;
  final String price02;
  final String cost;
  final String tax;
  final String addCount;
  // final String count;
  // final String isReset;
  // final String resetTimeType;
  // final String resetTimeValue;
  // final String resetCount;
  String? count;
  String? usecount;
  String? isReset;
  String? resetTimeType;
  String? resetTimeValue;
  String? resetCount;
  String? maxCount;
  bool? isInfinityCount;

  UserTicketModel({
    required this.id,
    required this.userId,
    required this.ticketId,
    required this.name,
    required this.title,
    required this.price,
    required this.price02,
    required this.cost,
    required this.tax,
    required this.addCount,
    // required this.count,
    // required this.isReset,
    // required this.resetTimeType,
    // required this.resetTimeValue,
    // required this.resetCount,
  });

  factory UserTicketModel.fromJson(Map<String, dynamic> json) {
    UserTicketModel tmp = UserTicketModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      ticketId: json['ticket_id'].toString(),
      name: json['ticket_name'].toString(),
      title: json['ticket_title'].toString(),
      price:
          json['ticket_price'] == null ? '0' : json['ticket_price'].toString(),
      price02: json['ticket_price02'] == null
          ? '0'
          : json['ticket_price02'].toString(),
      cost: json['ticket_cost'] == null ? '0' : json['ticket_cost'].toString(),
      tax: json['ticket_tax'] == null ? '0' : json['ticket_tax'].toString(),
      addCount: json['add_count'] == null ? '0' : json['add_count'].toString(),
      // count: json['count'].toString(),
      // isReset: json['is_reset'].toString(),
      // resetTimeType: json['reset_time_type'].toString(),
      // resetTimeValue: json['reset_time_value'].toString(),
      // resetCount: json['reset_count'].toString(),
    );
    tmp.count = json['count'].toString();
    tmp.isReset = json['is_reset'].toString();
    tmp.resetTimeType = json['reset_time_type'].toString();
    tmp.resetTimeValue = json['reset_time_value'].toString();
    tmp.resetCount = json['reset_count'].toString();
    tmp.maxCount = json['max_count'] != 0
        ? json['max_count'].toString()
        : MAX_TICKET_COUNT.toString();
    tmp.isInfinityCount = false;
    // int.parse(json['max_count'].toString()) < 0 ? true : false;
    return tmp;
  }

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'id': id,
        'user_id': userId,
        'ticket_id': ticketId,
        'count': count,
        'is_reset': isReset,
        'reset_time_type': resetTimeType,
        'reset_time_value': resetTimeValue,
        'reset_count': resetCount,
        'max_count': maxCount,
      };
}
