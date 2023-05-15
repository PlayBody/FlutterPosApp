class StaffListModel {
  final String? staffId;
  final String? staffFirstName;
  final String? staffLastName;
  final String staffNick;
  final String? auth;

  const StaffListModel(
      {this.staffId,
      this.staffFirstName,
      this.staffLastName,
      required this.staffNick,
      this.auth});

  factory StaffListModel.fromJson(Map<String, dynamic> json) {
    return StaffListModel(
      staffId: json['staff_id'],
      staffFirstName: json['staff_first_name'],
      staffLastName: json['staff_last_name'],
      staffNick: json['staff_nick'] ?? '',
      auth: json['staff_auth'],
    );
  }
}
