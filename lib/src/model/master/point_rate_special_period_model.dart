class PointRateSpecialPeriodModel {
  final String id;
  final String organId;
  final String fromDate;
  final String fromDateMonth;
  final String fromDateDay;
  final String toDate;
  final String toDateMonth;
  final String toDateDay;
  final String rateDays;
  final String rate;

  const PointRateSpecialPeriodModel({
    required this.id,
    required this.organId,
    required this.fromDate,
    required this.fromDateMonth,
    required this.fromDateDay,
    required this.toDate,
    required this.toDateMonth,
    required this.toDateDay,
    required this.rateDays,
    required this.rate,
  });

  factory PointRateSpecialPeriodModel.fromJson(Map<String, dynamic> json) {
    return PointRateSpecialPeriodModel(
        id: json['id'].toString(),
        organId: json['organ_id'].toString(),
        fromDate: json['from_date'],
        fromDateMonth:
            int.parse(json['from_date'].toString().split('-')[0]).toString(),
        fromDateDay:
            int.parse(json['from_date'].toString().split('-')[1]).toString(),
        toDate: json['to_date'],
        toDateMonth:
            int.parse(json['to_date'].toString().split('-')[0].toString())
                .toString(),
        toDateDay:
            int.parse(json['to_date'].toString().split('-')[1]).toString(),
        rateDays: json['rate_days'],
        rate: json['rate']);
  }
}
