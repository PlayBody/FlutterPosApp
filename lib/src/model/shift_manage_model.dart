import 'package:staff_pos_app/src/model/shift_model.dart';

class ShiftManageModel {
  final DateTime fromTime;
  final DateTime toTime;
  final int count;
  final int apply;
  final int shift;
  final List<ShiftModel> shifts;

  ShiftManageModel({
    required this.fromTime,
    required this.toTime,
    required this.count,
    required this.apply,
    required this.shift,
    required this.shifts,
  });

  factory ShiftManageModel.fromJson(Map<String, dynamic> json) {
    List<ShiftModel> shifts = [];
    if (json['shifts'] != null) {
      for (var item in json['shifts']) {
        shifts.add(ShiftModel.fromJson(item));
      }
    }
    return ShiftManageModel(
        fromTime: DateTime.parse(json['from_time']),
        toTime: DateTime.parse(json['to_time']),
        count: int.parse(json['count'].toString()),
        apply: int.parse(json['apply'].toString()),
        shift: int.parse(json['shift'].toString()),
        shifts: shifts);
  }
}
