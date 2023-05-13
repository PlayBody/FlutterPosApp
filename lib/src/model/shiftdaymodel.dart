class ShiftDayModel {
  final String shiftId;
  final String reserveId;
  final String staffId;
  final String staffName;
  final double fromH;
  final double fromM;
  final String fromTime;
  final String toTime;
  final double length;
  final String type;
  final String payMethod;
  final String allAmount;
  final String couponAmount;
  final String userId;
  final String userName;
  final String userSex;
  final String strFromTime;
  final String strToTime;
  final String menus;
  final String reserveInterval;

  const ShiftDayModel(
      {required this.shiftId,
      required this.reserveId,
      required this.staffId,
      required this.staffName,
      required this.userName,
      required this.userId,
      required this.userSex,
      required this.fromH,
      required this.fromM,
      required this.length,
      required this.fromTime,
      required this.toTime,
      required this.strFromTime,
      required this.strToTime,
      required this.payMethod,
      required this.allAmount,
      required this.couponAmount,
      required this.menus,
      required this.reserveInterval,
      required this.type});

  factory ShiftDayModel.fromJson(Map<String, dynamic> json) {
    String tfrom = json['from_time'].toString().split(' ')[1];
    String tto = json['to_time'].toString().split(' ')[1];
    int tfH = int.parse(tfrom.split(':')[0]);
    int tfM = int.parse(tfrom.split(':')[1]);
    int ttH = int.parse(tto.split(':')[0]);
    int ttM = int.parse(tto.split(':')[1]);
    if (ttH == 23 && ttM == 59) {
      ttH = 24;
      ttM = 0;
    }

    if (ttM < tfM) {
      ttM = ttM + 60;
      ttH = ttH - 1;
    }

    String menunames = '';
    if (json['menus'] != null) {
      for (var item in json['menus']) {
        menunames += (menunames == '' ? '' : ',');
        menunames += item['menu_title'];
      }
    }

    return ShiftDayModel(
      shiftId: json['shift_id'] == null ? '' : json['shift_id'].toString(),
      reserveId:
          json['reserve_id'] == null ? '0' : json['reserve_id'].toString(),
      staffId: json['staff_id'] == null ? '0' : json['staff_id'].toString(),
      staffName:
          json['staff_name'] == null ? 'フリー' : json['staff_name'].toString(),
      userId: json['user_id'] == null ? '' : json['user_id'].toString(),
      userName: json['user_name'] == null ? '' : json['user_name'].toString(),
      userSex: (json['user_sex'] == null || json['user_sex'].toString() == '1')
          ? '男'
          : '女',
      fromH: tfH.toDouble(),
      fromM: tfM / 60,
      length: ttH - tfH + (ttM - tfM) / 60,
      type: json['shift_type'].toString(),
      fromTime: '${tfrom.split(':')[0]}:${tfrom.split(':')[1]}',
      toTime: '${tto.split(':')[0]}:${tto.split(':')[1]}',
      strFromTime: json['from_time'].toString(),
      strToTime: json['to_time'].toString(),
      payMethod:
          json['pay_method'] == null ? '2' : json['pay_method'].toString(),
      allAmount: json['amount'] == null ? '0' : json['amount'].toString(),
      menus: menunames,
      reserveInterval:
          json['sum_interval'] == null ? '0' : json['sum_interval'].toString(),
      couponAmount: json['coupon_use_amount'] == null
          ? '0'
          : json['coupon_use_amount'].toString(),
    );
  }
}
