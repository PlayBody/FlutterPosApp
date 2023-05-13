class StaffPointAddModel {
  final String pointId;
  final DateTime pointDate;
  final String comment;
  final String weight;
  final String value;
  final String status;
  final String cdate;
  final String staffId;
  final String staffName;
  final int pointType;

  const StaffPointAddModel({
    required this.pointId,
    required this.pointDate,
    required this.comment,
    required this.weight,
    required this.value,
    required this.status,
    required this.cdate,
    required this.staffId,
    required this.staffName,
    required this.pointType,
  });

  factory StaffPointAddModel.fromJson(Map<String, dynamic> json) {
    return StaffPointAddModel(
      pointId: json['id'].toString(),
      pointDate: DateTime.parse(json['point_date']),
      comment: json['comment'],
      weight: json['point_weight'].toString(),
      value: json['value'].toString(),
      status: json['status'].toString(),
      cdate: json['create_date'].toString(),
      staffId: json['staff_id'] == null ? '' : json['staff_id'].toString(),
      pointType: json['type'] == null ? 1 : int.parse(json['type'].toString()),
      staffName:
          json['staff_name'] == null ? '' : json['staff_name'].toString(),
    );
  }
}
