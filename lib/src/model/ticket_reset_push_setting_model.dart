class TicketResetPushSettingModel {
  final String id;
  final String ticketId;
  final String beforeDay;
  final String pushTime;

  const TicketResetPushSettingModel({
    required this.id,
    required this.ticketId,
    required this.beforeDay,
    required this.pushTime,
  });

  factory TicketResetPushSettingModel.fromJson(Map<String, dynamic> json) {
    return TicketResetPushSettingModel(
      id: json['id'],
      ticketId: json['ticket_id'].toString(),
      beforeDay: json['before_day'].toString(),
      pushTime: json['push_time'],
    );
  }
}
