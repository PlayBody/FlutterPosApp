class UserModel {
  final String userId;
  final String? userNo;
  final String? userFirstName;
  final String? userLastName;
  final String? userNick;
  final String? userEmail;
  final String? userBirth;
  final String? userTel;
  final String? userSex;
  final String? userTicket;
  final String? groupId;
  final String? reserveCount;
  final String? visitCount;

  const UserModel({
    required this.userId,
    this.userNo,
    this.userFirstName,
    this.userLastName,
    this.userNick,
    this.userEmail,
    this.userTel,
    this.userBirth,
    this.userSex,
    this.userTicket,
    this.groupId,
    this.reserveCount,
    this.visitCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'].toString(),
      userNo: json['user_no'],
      userFirstName: json['user_first_name'] ?? '',
      userLastName: json['user_last_name'] ?? '',
      userNick: json['user_nick'],
      userEmail: json['user_email'],
      userTel: json['user_tel'],
      userBirth: json['user_birthday'],
      userSex: json['user_set'],
      userTicket: json['user_ticket'],
      groupId: json['group_id'],
      reserveCount: json['reserve_count'] == null
          ? '0'
          : json['reserve_count'].toString(),
      visitCount:
          json['visit_count'] == null ? '0' : json['visit_count'].toString(),
    );
  }
}
