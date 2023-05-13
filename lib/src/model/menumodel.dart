class MenuModel {
  final String menuId;
  final String organId;
  final String menuTitle;
  final String menuDetail;
  final String menuPrice;
  final String menuStock;
  final String menuCost;
  final String menuTax;
  final String menuComment;
  final String? menuTime;
  final String? menuInterval;
  final bool isUserMenu;
  final bool isGoods;
  final String? image;

  final List<String>? variations;

  const MenuModel({
    required this.menuId,
    required this.menuTitle,
    required this.organId,
    required this.menuPrice,
    required this.menuStock,
    required this.menuCost,
    required this.menuTax,
    required this.menuDetail,
    required this.menuComment,
    this.menuTime,
    this.menuInterval,
    required this.isUserMenu,
    required this.isGoods,
    this.image,
    this.variations,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
        menuId: json['menu_id'] ?? '',
        menuTitle: json['menu_title'] ?? '',
        organId: json['organ_id'] ?? '',
        menuPrice: json['menu_price'] ?? '',
        menuStock: json['menu_stock'] ?? '',
        menuCost: json['menu_cost'] ?? '',
        menuTax: json['menu_tax'] ?? '',
        menuDetail: json['menu_detail'] ?? '',
        menuComment: json['menu_comment'] ?? '',
        isUserMenu: (json['is_user_menu'] == null ||
                json['is_user_menu'].toString() != '1')
            ? false
            : true,
        isGoods:
            (json['is_goods'] == null || json['is_goods'].toString() != '1')
                ? false
                : true,
        menuTime: json['menu_time'],
        menuInterval: json['menu_interval'],
        image: json['menu_image'],
        // ignore: prefer_null_aware_operators
        variations: json['variation_titles'] == null
            ? null
            : json['variation_titles'].split(','));
  }
}
