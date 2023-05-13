class TicketModel {
  final String id;
  final String ticketId;
  final String companyId;
  final String name;
  final String title;
  final String detail;
  final String? image;
  final String price;
  final String cost;
  final String tax;
  final String disamount;
  final bool isPeriod;
  final String? periodMonth;
  final String cnt;

  const TicketModel({
    required this.id,
    required this.ticketId,
    required this.companyId,
    required this.name,
    required this.title,
    required this.detail,
    required this.image,
    required this.price,
    required this.cost,
    required this.tax,
    required this.disamount,
    required this.isPeriod,
    this.periodMonth,
    required this.cnt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    String masterName = json['ticket_name'] ?? '';
    return TicketModel(
      id: json['id'],
      ticketId: json['ticket_id'],
      companyId: json['company_id'],
      name: masterName,
      title: json['ticket_title'] ?? masterName,
      detail: json['ticket_detail'] ?? '',
      image: json['ticket_image'],
      price: json['ticket_price'],
      cost: json['ticket_cost'],
      tax: json['ticket_tax'],
      disamount: json['ticket_disamount'] ?? '',
      isPeriod:
          (json['is_period'] == null || json['is_period'].toString() == '0')
              ? false
              : true,
      periodMonth: json['period_month'],
      cnt: json['ticket_count'],
    );
  }
}
