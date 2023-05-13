class FitnessModel {
  final String fitnessId;
  final String message;
  final String sendDate;
  final String fileType;
  final String fileUrl;
  final String? thumbUrl;

  const FitnessModel({
    required this.fitnessId,
    required this.message,
    required this.sendDate,
    required this.fileType,
    required this.fileUrl,
    this.thumbUrl,
  });

  factory FitnessModel.fromJson(Map<String, dynamic> json) {
    return FitnessModel(
      fitnessId: json['fitness_id'],
      message: json['message'],
      sendDate: json['update_date'],
      fileType: json['file_type'] == null ? '' : json['file_type'].toString(),
      fileUrl: json['file_url'] ?? '',
      thumbUrl: json['thumb_url'],
    );
  }
}
