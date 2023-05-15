import 'package:staff_pos_app/src/common/functions/utils.dart';

class ShiftModel {
  final String shiftId;
  final String organId;
  final String staffId;
  final DateTime fromTime;
  DateTime toTime;
  String shiftType;

  int getDurationByMinute() {
    return toTime.difference(fromTime).inMinutes;
  }

  ShiftModel({
    required this.shiftId,
    required this.organId,
    required this.staffId,
    required this.fromTime,
    required this.toTime,
    required this.shiftType,
  });

  factory ShiftModel.fromWorkTime(WorkTime work) {
    return ShiftModel(
        shiftId: work.meta.shiftId,
        organId: work.meta.organId,
        staffId: work.meta.staffId,
        fromTime: work.start,
        toTime: work.end,
        shiftType: work.meta.shiftType);
  }

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
        shiftId: json['shift_id'].toString(),
        organId: json['organ_id'].toString(),
        staffId: json['staff_id'].toString(),
        fromTime: DateTime.parse(json['from_time']),
        toTime: DateTime.parse(json['to_time']),
        shiftType: json['shift_type'].toString());
  }
}
