class CompanyModel {
  final String companyId;
  final String companyName;
  final String companyDomain;
  final String ecUrl;
  final String companyReceiptNumber;
  final String companyPrintOrder;
  final String visible;

  const CompanyModel({
    required this.companyId,
    required this.companyName,
    required this.companyDomain,
    required this.ecUrl,
    required this.companyReceiptNumber,
    required this.companyPrintOrder,
    required this.visible,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyId: json['company_id'],
      companyName: json['company_name'],
      companyDomain: json['company_domain'],
      ecUrl: json['ec_site_url'] ?? '',
      companyReceiptNumber: json['company_receipt_number'] ?? '',
      companyPrintOrder: json['print_order_number'] == null
          ? ''
          : json['print_order_number'].toString(),
      visible: json['visible'] == null ? '' : json['visible'].toString(),
    );
  }
}
