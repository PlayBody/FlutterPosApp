class ShiftModel {
  final String shiftId;
  final String organId;
  final String staffId;
  final DateTime fromTime;
  final DateTime toTime;
  final String shiftType;

  ShiftModel({
    required this.shiftId,
    required this.organId,
    required this.staffId,
    required this.fromTime,
    required this.toTime,
    required this.shiftType,
  });

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
