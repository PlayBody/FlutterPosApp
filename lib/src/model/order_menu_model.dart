class OrderMenuModel {
  final String? id;
  final String menuTitle;
  final String quantity;
  final String menuPrice;
  final String? menuId;
  final String? variationId;
  final dynamic useTickets;

  const OrderMenuModel(
      {this.id,
      required this.menuTitle,
      required this.quantity,
      required this.menuPrice,
      this.menuId,
      this.useTickets,
      this.variationId});

  factory OrderMenuModel.fromJson(Map<String, dynamic> json) {
    return OrderMenuModel(
      // ignore: prefer_null_aware_operators
      id: json['id'] == null ? null : json['id'].toString(),
      menuTitle: json['menu_title'],
      quantity: json['quantity'],
      menuPrice: json['menu_price'],
      menuId: json['menu_id'],
      variationId: json['variation_id'],
      useTickets: json['use_tickets'],
    );
  }
}
