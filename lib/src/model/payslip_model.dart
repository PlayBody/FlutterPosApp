import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/staffpointaddmodel.dart';

class PaySlipModel {
  final OrganModel organ;
  final int attendTime;
  final int reserveTime;
  final int defualtAmount;
  final int monthlyAmount;
  final int reserveCost;
  final int attendCost;
  final double rate;
  final int sumAddPoint;
  final List<StaffPointAddModel> addPoints;

  const PaySlipModel({
    required this.organ,
    required this.attendTime,
    required this.reserveTime,
    required this.defualtAmount,
    required this.monthlyAmount,
    required this.attendCost,
    required this.reserveCost,
    required this.rate,
    required this.sumAddPoint,
    required this.addPoints,
  });

  factory PaySlipModel.fromJson(Map<String, dynamic> json) {
    List<StaffPointAddModel> addPoints = [];
    if (json['add_points'] != null) {
      for (var item in json['add_points']) {
        addPoints.add(StaffPointAddModel.fromJson(item));
      }
    }
    return PaySlipModel(
      organ: OrganModel.fromJson(json['organ']),
      attendTime: int.parse(json['attend_time'].toString()),
      reserveTime: int.parse(json['reserve_time'].toString()),
      defualtAmount: int.parse(json['default_amount'].toString()),
      monthlyAmount: int.parse(json['monthly_amount'].toString()),
      reserveCost: int.parse(json['reserve_time'].toString()) == 0
          ? 0
          : (int.parse(json['monthly_amount'].toString()) ~/
              int.parse(json['reserve_time'].toString())),
      attendCost: int.parse(json['attend_time'].toString()) == 0
          ? 0
          : (int.parse(json['monthly_amount'].toString()) ~/
              int.parse(json['attend_time'].toString())),
      rate: double.parse(json['rate'].toString()),
      sumAddPoint: int.parse(json['sum_add_point'].toString()),
      addPoints: addPoints,
    );
  }
}
