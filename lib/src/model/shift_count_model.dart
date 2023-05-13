class ShiftCountModel {
  final String coutId;
  final String organId;
  final DateTime fromTime;
  final DateTime toTime;
  final int count;

  ShiftCountModel({
    required this.coutId,
    required this.organId,
    required this.fromTime,
    required this.toTime,
    required this.count,
  });

  factory ShiftCountModel.fromJson(Map<String, dynamic> json) {
    return ShiftCountModel(
        coutId: json['id_id'].toString(),
        organId: json['organ_id'].toString(),
        fromTime: DateTime.parse(json['from_time']),
        toTime: DateTime.parse(json['to_time']),
        count: int.parse(json['count'].toString()));
  }
}
