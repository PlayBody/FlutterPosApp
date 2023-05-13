class OrganPointSettingModel {
  final String id;
  final String organId;
  final String title;
  final String point;
  final int type;

  const OrganPointSettingModel({
    required this.id,
    required this.organId,
    required this.title,
    required this.point,
    required this.type,
  });

  factory OrganPointSettingModel.fromJson(Map<String, dynamic> json) {
    return OrganPointSettingModel(
        id: json['organ_point_id'].toString(),
        organId: json['organ_id'].toString(),
        title: json['point_title'],
        point: json['point_value'],
        type: int.parse(json['point_type'].toString()));
  }
}
