class EventModel {
  final String eventId;
  final String companyId;
  final String organId;
  final String fromTime;
  final String toTime;
  final String comment;
  final String url;

  const EventModel({
    required this.eventId,
    required this.companyId,
    required this.organId,
    required this.fromTime,
    required this.toTime,
    required this.comment,
    required this.url,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventId: json['id'].toString(),
      companyId: json['company_id'].toString(),
      organId: json['organ_id'].toString(),
      fromTime: json['from_time'].toString(),
      toTime: json['to_time'].toString(),
      comment: json['comment'],
      url: json['event_url'],
    );
  }
}
