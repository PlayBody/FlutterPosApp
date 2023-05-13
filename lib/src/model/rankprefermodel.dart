class RankPreferModel {
  final String rankPreferId;
  final String rankId;
  final String menuName;
  final String couponName;
  String? stampCount;
  String? prefType;
  String? menuId;
  String? couponId;
  bool isDelete = false;

  RankPreferModel({
    required this.rankPreferId,
    required this.rankId,
    required this.menuName,
    required this.couponName,
  });

  factory RankPreferModel.fromJson(Map<String, dynamic> json) {
    RankPreferModel model = RankPreferModel(
      rankPreferId: json['rank_prefer_id'] == null
          ? ''
          : json['rank_prefer_id'].toString(),
      rankId: json['rank_id'] == null ? '' : json['rank_id'].toString(),
      menuName: json['menu_name'] == null ? '' : json['menu_name'].toString(),
      couponName:
          json['coupon_name'] == null ? '' : json['coupon_name'].toString(),
    );
    model.stampCount =
        // ignore: prefer_null_aware_operators
        json['stamp_count'] == null ? null : json['stamp_count'].toString();
    // ignore: prefer_null_aware_operators
    model.menuId = json['menu_id'] == null ? null : json['menu_id'].toString();
    model.couponId =
        json['coupon_id'] == null ? null : json['coupon_id'].toString();
    model.prefType = json['type'];
    model.isDelete = false;
    return model;
  }
}
