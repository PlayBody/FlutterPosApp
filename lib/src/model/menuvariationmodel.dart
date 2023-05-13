import 'package:staff_pos_app/src/model/variationbackstaffmodel.dart';

class MenuVariationModel {
  final String variationId;
  final String menuId;
  final String variationTitle;
  final String variationPrice;
  final List<VariationBackStaffModel> backs;
  final String? variationAmount;
  final String? staffName;

  const MenuVariationModel({
    required this.variationId,
    required this.menuId,
    required this.variationTitle,
    required this.variationPrice,
    required this.backs,
    this.variationAmount,
    this.staffName,
  });

  factory MenuVariationModel.fromJson(Map<String, dynamic> json) {
    List<VariationBackStaffModel> backData = [];
    String names = '';
    if (json['backs'] != null) {
      for (var item in json['backs']) {
        backData.add(VariationBackStaffModel.fromJson(item));
        if (item['staff_name'] != null) {
          if (names != '') names = '$names  ';
          names = names + item['staff_name'];
        }
      }
    }

    return MenuVariationModel(
        variationId: json['variation_id'],
        menuId: json['menu_id'],
        variationTitle: json['variation_title'],
        variationPrice: json['variation_price'],
        backs: backData,
        variationAmount: json['variation_back_amount'] ?? '',
        staffName: names);
  }
}
