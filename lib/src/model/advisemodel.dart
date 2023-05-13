import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';

class AdviseModel {
  final String adviseId;
  final String question;
  final String? answer;
  final String userName;
  final String? teacherName;
  final String? movieFile;
  final String updateDate;
  final VideoPlayerController? videoController;

  const AdviseModel(
      {required this.adviseId,
      required this.question,
      this.answer,
      required this.userName,
      this.teacherName,
      this.movieFile,
      required this.updateDate,
      this.videoController});

  factory AdviseModel.fromJson(Map<String, dynamic> json) {
    var userNameLabel = json['user_nick'] ?? '';
    if (userNameLabel == '') {
      userNameLabel = (json['user_first_name'] ?? '') +
          ' ' +
          (json['user_last_name'] ?? '');
    }

    return AdviseModel(
        adviseId: json['advise_id'],
        question: json['question'],
        answer: json['answer'],
        userName: userNameLabel,
        teacherName: json['teacher_name'],
        movieFile: json['movie_file'],
        updateDate: DateFormat('yyyy/MM/dd')
            .format(DateTime.parse(json['update_date'])),
        videoController: json['controller']);
  }
}
