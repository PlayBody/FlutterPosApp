import 'package:staff_pos_app/src/model/stafflistmodel.dart';

class CouponModel {
  final String couponId;
  final String couponName;
  final String couponCode;
  final String useDate;
  final String condition;
  final String useOrgan;
  final String comment;
  final String? discountRate;
  final String? upperAmount;
  final String? discountAmount;
  final String staffName;
  final bool visible;
  final bool isUse;
  final List<StaffListModel> staffs;

  const CouponModel(
      {required this.couponId,
      required this.couponName,
      required this.couponCode,
      required this.useDate,
      required this.condition,
      required this.useOrgan,
      required this.comment,
      this.discountRate,
      this.discountAmount,
      this.upperAmount,
      required this.staffName,
      required this.visible,
      required this.isUse,
      required this.staffs});

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    List<StaffListModel> staffs = [];
    for (var item in json['staffs']) {
      staffs.add(StaffListModel.fromJson(item));
    }

    return CouponModel(
        couponId: json['coupon_id'],
        couponName: json['coupon_name'],
        couponCode: json['coupon_code'] ?? '',
        useDate: json['use_date'],
        condition: json['condition'],
        useOrgan: json['use_organ_id'],
        comment: json['comment'],
        discountRate: json['discount_rate'],
        discountAmount: json['discount_amount'],
        upperAmount: json['upper_amount'],
        staffName: json['staff_name'] ?? '',
        visible:
            json['visible'] == null || json['visible'] == '0' ? false : true,
        isUse: json['is_use'] == '1' ? true : false,
        staffs: staffs);
  }
}
