class ShiftStaffModel {
  final String shiftId;
  final String fromTime;
  final String toTime;
  final String shiftType;
  final String staffId;
  final String staffName;
  final bool isBefore;
  final bool isAfter;

  const ShiftStaffModel({
    required this.shiftId,
    required this.fromTime,
    required this.toTime,
    required this.shiftType,
    required this.staffId,
    required this.staffName,
    required this.isBefore,
    required this.isAfter,
  });

  factory ShiftStaffModel.fromJson(Map<String, dynamic> json) {
    return ShiftStaffModel(
      shiftId: json['shift_id'] ?? '',
      fromTime: json['from_time'] ?? '',
      toTime: json['to_time'] ?? '',
      shiftType: json['shift_type'] ?? '0',
      staffId: json['staff_id'],
      staffName: (json['staff_first_name'] ?? '') +
          ' ' +
          (json['staff_last_name'] ?? ''),
      isBefore: json['is_before'] ?? false,
      isAfter: json['is_after'] ?? false,
    );
  }
}
