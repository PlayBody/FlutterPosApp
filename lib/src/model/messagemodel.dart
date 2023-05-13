class MessageModel {
  final String content;
  final String type;
  final String createDate;
  final String fileType;
  final String fileUrl;
  final String fileName;
  final String? videoUrl;
  final String organName;
  final String staffName;
  final String? userId;
  final String userName;
  final bool readflag;

  const MessageModel(
      {required this.content,
      required this.type,
      required this.createDate,
      required this.fileType,
      required this.fileUrl,
      this.videoUrl,
      required this.fileName,
      required this.organName,
      required this.staffName,
      this.userId,
      required this.userName,
      required this.readflag});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
        content: json['content'],
        type: json['type'],
        createDate: json['create_date'],
        fileType: json['file_type'] == null ? '' : json['file_type'].toString(),
        fileUrl: json['file_url'] ?? '',
        fileName: json['file_name'] ?? '',
        videoUrl: json['video_url'],
        organName: json['organ_name'] ?? '',
        staffName: json['staff_name'] ?? '',
        userName: json['user_name'] ?? '',
        userId: json['user_id'],
        readflag: json['read_flag'] == null
            ? false
            : json['read_flag'] == '1'
                ? true
                : false);
  }
}
