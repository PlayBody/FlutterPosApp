import 'package:intl/intl.dart';

class OrganSpecialTimeModel {
  final String id;
  final String organId;
  final String date;
  final String fromTime;
  final String toTime;

  const OrganSpecialTimeModel(
      {required this.id,
      required this.organId,
      required this.fromTime,
      required this.toTime,
      required this.date});

  factory OrganSpecialTimeModel.fromJson(Map<String, dynamic> json) {
    String yobi = DateFormat('EEE').format(DateTime.parse(json['from_time']));
    if (yobi == 'Mon') yobi = '月';
    if (yobi == 'Tue') yobi = '火';
    if (yobi == 'Wed') yobi = '水';
    if (yobi == 'Thu') yobi = '木';
    if (yobi == 'Fri') yobi = '金';
    if (yobi == 'Sat') yobi = '土';
    if (yobi == 'Sun') yobi = '日';

    return OrganSpecialTimeModel(
      id: json['organ_special_time_id'],
      fromTime: DateFormat('HH:mm').format(DateTime.parse(json['from_time'])),
      toTime: DateFormat('HH:mm').format(DateTime.parse(json['to_time'])),
      organId: json['organ_id'].toString(),
      date: DateFormat('yyyy-MM-dd($yobi)')
          .format(DateTime.parse(json['from_time'])),
    );
  }
}
