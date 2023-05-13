class SaleDetailModel {
  final String id;
  final String startTime;
  final String position;
  final String amount;
  final String menuCount;
  final String tablePoistion;
  final String personCount;

  const SaleDetailModel(
      {required this.id,
      required this.startTime,
      required this.position,
      required this.amount,
      required this.menuCount,
      required this.tablePoistion,
      required this.personCount});

  factory SaleDetailModel.fromJson(Map<String, dynamic> json) {
    String thour = DateTime.parse(json['from_time']).hour < 10
        ? '0${DateTime.parse(json['from_time']).hour}'
        : DateTime.parse(json['from_time']).hour.toString();
    String tminute = DateTime.parse(json['from_time']).minute < 10
        ? '0${DateTime.parse(json['from_time']).minute}'
        : DateTime.parse(json['from_time']).minute.toString();
    return SaleDetailModel(
      id: json['id'],
      startTime: '$thour:$tminute',
      position: json['table_position'].toString(),
      amount: double.parse(json['amount'].toString()).toInt().toString(),
      menuCount: json['menu_count'].toString(),
      tablePoistion: json['table_position'].toString(),
      personCount: json['user_count'] ?? '',
    );
  }
}
