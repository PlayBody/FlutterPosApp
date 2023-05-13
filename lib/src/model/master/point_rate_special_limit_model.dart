class PointRateSpecialLimitModel {
  final String id;
  final String organId;
  final String type;
  final String value;
  final String rate;

  const PointRateSpecialLimitModel({
    required this.id,
    required this.organId,
    required this.type,
    required this.value,
    required this.rate,
  });

  factory PointRateSpecialLimitModel.fromJson(Map<String, dynamic> json) {
    return PointRateSpecialLimitModel(
        id: json['id'].toString(),
        organId: json['organ_id'].toString(),
        type: json['type'].toString(),
        value: json['value'],
        rate: json['rate']);
  }
}
