class QuestionModel {
  final String questionId;
  final String userId;
  final String userName;
  final String? answerId;
  final String questionTitle;
  final String question;
  final String? answer;

  const QuestionModel(
      {required this.questionId,
      required this.userId,
      required this.question,
      required this.questionTitle,
      required this.userName,
      this.answerId,
      this.answer});

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    var userNameLabel = json['user_nick'] ?? '';
    if (userNameLabel == '') {
      userNameLabel = (json['user_first_name'] ?? '') +
          ' ' +
          (json['user_last_name'] ?? '');
    }
    return QuestionModel(
      questionId: json['question_id'],
      userId: json['user_id'],
      userName: userNameLabel,
      answerId: json['answer_id'],
      question: json['question'],
      questionTitle: json['question_title'],
      answer: json['answer'],
    );
  }
}
