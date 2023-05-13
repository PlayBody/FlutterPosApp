class OrganAvaliableTimeModel {
  final String id;
  final String organId;
  final String weekday;
  final String fromTime;
  final String toTime;

  const OrganAvaliableTimeModel(
      {required this.id,
      required this.organId,
      required this.fromTime,
      required this.toTime,
      required this.weekday});

  factory OrganAvaliableTimeModel.fromJson(Map<String, dynamic> json) {
    return OrganAvaliableTimeModel(
      id: json['id'],
      fromTime: json['from_time'],
      toTime: json['to_time'],
      organId: json['organ_id'].toString(),
      weekday: json['weekday'],
    );
  }
}
