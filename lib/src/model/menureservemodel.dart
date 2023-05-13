class MenuReserveModel {
  final String menuTitle;
  final String quantity;
  final String menuPrice;
  final String? menuId;
  final String? variationId;
  final dynamic useTickets;

  const MenuReserveModel(
      {required this.menuTitle,
      required this.quantity,
      required this.menuPrice,
      this.menuId,
      this.useTickets,
      this.variationId});

  factory MenuReserveModel.fromJson(Map<String, dynamic> json) {
    return MenuReserveModel(
      menuTitle: json['menu_title'],
      quantity: json['quantity'],
      menuPrice: json['menu_price'],
      menuId: json['menu_id'],
      variationId: json['variation_id'],
      useTickets: json['use_tickets'],
    );
  }
}
