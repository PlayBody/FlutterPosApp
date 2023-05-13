class VariationBackStaffModel {
  final String backId;
  final String backName;
  final String type;

  const VariationBackStaffModel(
      {required this.backId, required this.backName, required this.type});

  factory VariationBackStaffModel.fromJson(Map<String, dynamic> json) {
    return VariationBackStaffModel(
        backId: json['staff_id'].toString(),
        backName: json['staff_name'] ?? json['sort_name'],
        type: 'staff');
  }

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'back_id': backId,
        'back_name': backName,
        'type': type
      };
}
