import 'package:staff_pos_app/src/common/const.dart';

class OrganModel {
  final String organId;
  final String organName;
  final String isNoReserve;
  final String isNoReserveType;
  final String organNumber;
  final String organSetNum;
  final bool isUseSet;
  final String organAddress;
  final String organPhone;
  final String lat;
  final String lon;
  final String distance;
  final bool distance_status;
  final String organComment;
  final String snsUrl;
  final String? organImage;
  final String organZipCode;
  final int tableCount;
  final String openBalance;
  final String ticketConsumption;
  final String bussinessWeight;
  final String dividePoint;
  final String promotionalPoint;
  final String opionalPoint;
  final String nextPoint;
  final String extensionPoint;
  final String openPoint;
  final String closePoint;
  final String? printLogoUrl;
  final String access;
  final String parking;
  final String? pointResponse1;
  final String? pointResponse2;
  final String? pointAttend;
  final String? pointGrade1;
  final String? pointGrade2;
  final String? pointGrade3;
  final String? pointEntering1;
  final String? pointEntering2;
  final String? pointEntering3;
  final String? pointEntering4;
  final String? pointEntering5;

  const OrganModel({
    required this.organId,
    required this.organName,
    required this.isNoReserve,
    required this.isNoReserveType,
    required this.organNumber,
    required this.isUseSet,
    required this.organSetNum,
    required this.tableCount,
    required this.organAddress,
    required this.organPhone,
    required this.lat,
    required this.lon,
    required this.distance,
    this.distance_status = false,
    required this.organComment,
    required this.snsUrl,
    this.organImage,
    required this.organZipCode,
    required this.openBalance,
    required this.ticketConsumption,
    required this.bussinessWeight,
    required this.dividePoint,
    required this.promotionalPoint,
    required this.opionalPoint,
    required this.nextPoint,
    required this.extensionPoint,
    required this.openPoint,
    required this.closePoint,
    this.printLogoUrl,
    required this.access,
    required this.parking,
    required this.pointResponse1,
    required this.pointResponse2,
    required this.pointAttend,
    required this.pointGrade1,
    required this.pointGrade2,
    required this.pointGrade3,
    required this.pointEntering1,
    required this.pointEntering2,
    required this.pointEntering3,
    required this.pointEntering4,
    required this.pointEntering5,
  });

  factory OrganModel.fromJson(Map<String, dynamic> json) {
    return OrganModel(
        organId: json['organ_id'],
        organName: json['organ_name'],
        isNoReserve: json['is_no_reserve'] == null
            ? '0'
            : json['is_no_reserve'].toString(),
        isNoReserveType: json['is_no_reserve_type'] == null
            ? constCheckinReserveRiRa
            : json['is_no_reserve_type'].toString(),
        organNumber: json['organ_number'] ?? '',
        organSetNum: json['set_number'] ?? '1',
        isUseSet:
            (json['is_use_set'] == null || json['is_use_set'].toString() == '0')
                ? false
                : true,
        organAddress: json['address'] ?? '',
        organPhone: json['phone'] ?? '',
        lat: json['lat'] ?? '',
        lon: json['lon'] ?? '',
        distance: json['distance'] ?? '',
        distance_status: (json['distance_status'] == null ||
                json['distance_status'].toString() == '0')
            ? false
            : true,
        organComment: json['comment'] ?? '',
        snsUrl: json['sns_url'] ?? '',
        organImage: json['image'],
        organZipCode: json['zip_code'] ?? '',
        tableCount:
            json['table_count'] == null ? 7 : int.parse(json['table_count']),
        printLogoUrl: json['print_logo_file'],
        openBalance: json['open_balance'] ?? '',
        ticketConsumption: json['checkin_ticket_consumption'] ?? '0',
        bussinessWeight: json['business_weight'] ?? '',
        dividePoint: json['divide_point'] ?? '',
        promotionalPoint: json['promotional_point'] ?? '',
        opionalPoint: json['optional_acquisition_point'] ?? '',
        nextPoint: json['next_reservation_point'] ?? '',
        extensionPoint: json['extension_point'] ?? '',
        openPoint: json['open_business_point'] ?? '',
        closePoint: json['close_business_point'] ?? '',
        access: json['access'] ?? '',
        parking: json['parking'] ?? '',
        pointResponse1: json['reserve_menu_response_1_point'],
        pointResponse2: json['reserve_menu_response_2_point'],
        pointAttend: json['attend_point'] ?? '',
        pointGrade1: json['grade_1_point'],
        pointGrade2: json['grade_2_point'],
        pointGrade3: json['grade_3_point'],
        pointEntering1: json['entering_1_point'],
        pointEntering2: json['entering_2_point'],
        pointEntering3: json['entering_3_point'],
        pointEntering4: json['entering_4_point'],
        pointEntering5: json['entering_5_point']);
  }
}
