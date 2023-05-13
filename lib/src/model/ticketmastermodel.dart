class TicketMasterModel {
  final String id;
  final String ticketName;
  final String companyId;

  const TicketMasterModel({
    required this.id,
    required this.ticketName,
    required this.companyId
  });

  factory TicketMasterModel.fromJson(Map<String, dynamic> json) {
    return TicketMasterModel(
      id: json['id'],
      ticketName: json['ticket_name'],
      companyId: json['company_id'],
    );
  }
}
