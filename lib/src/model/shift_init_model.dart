import 'package:staff_pos_app/src/common/const.dart';

class InitShiftModel {
  final String id;
  final String organId;
  final String staffId;
  final String fromTime;
  final String toTime;
  final int weekday;
  final String shiftType;

  InitShiftModel({
    required this.id,
    required this.organId,
    required this.staffId,
    required this.fromTime,
    required this.toTime,
    required this.weekday,
    required this.shiftType,
  });

  factory InitShiftModel.fromJson(Map<String, dynamic> json) {
    return InitShiftModel(
        id: json['id'].toString(),
        organId: json['organ_id'].toString(),
        staffId: json['staff_id'].toString(),
        fromTime: json['from_time'],
        toTime: json['to_time'],
        weekday: int.parse(json['weekday'].toString()),
        shiftType: json['shift_type'] == null
            ? constShiftSubmit
            : json['shift_type'].toString());
  }
}
