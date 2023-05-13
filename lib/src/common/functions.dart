import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:staff_pos_app/src/model/order_menu_model.dart';
import '../interface/login.dart';
import 'globals.dart' as globals;
import 'messages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Funcs {
  Future<void> logout(BuildContext context) async {
    globals.isLogin = false;
    globals.staffId = '';
    globals.companyId = '';
    globals.auth = 0;
    globals.isAttendance = false;

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove(globals.isBiometricEnableKey);

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const Login();
    }));
  }

  bool orderInputListAdd(BuildContext context, OrderMenuModel item) {
    if (globals.orderMenus.length >= 50) {
      Dialogs().infoDialog(context, warningOrderReserveMenuMax);
      return false;
    }
    if (item.menuId == null) {
      globals.orderMenus.add(item);
    } else {
      List<OrderMenuModel> reserveList = [];
      bool isExist = false;
      for (var element in globals.orderMenus) {
        if (element.menuId == item.menuId &&
            element.variationId == item.variationId) {
          reserveList.add(OrderMenuModel(
              menuTitle: item.menuTitle,
              quantity: (int.parse(element.quantity) + int.parse(item.quantity))
                  .toString(),
              menuPrice: item.menuPrice,
              menuId: item.menuId,
              variationId: item.variationId,
              useTickets: item.useTickets));
          isExist = true;
        } else {
          reserveList.add(element);
        }
      }
      if (!isExist) {
        reserveList.add(item);
      }
      globals.orderMenus = reserveList;
    }
    return true;
  }

  String getTimeFormatHHMM(DateTime? time) {
    if (time == null) return '設定なし';

    String hour = time.hour < 10 ? '0${time.hour}' : time.hour.toString();
    String min = time.minute < 10 ? '0${time.minute}' : time.minute.toString();

    return '$hour:$min';
  }

  String getTimeFormatHMM00(DateTime? time) {
    if (time == null) return '設定なし';

    String hour = time.hour.toString();
    String min = time.minute < 10 ? '0${time.minute}' : time.minute.toString();

    return '$hour:$min:00';
  }

  bool isNumeric(String string) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

    return numericRegex.hasMatch(string);
  }

  String dateFormatJP1(String? dateString) {
    if (dateString == null) return '';
    DateTime date = DateTime.parse(dateString);
    return '${date.year}年${date.month}月${date.day}日';
  }

  String dateTimeFormatJP1(String? dateString) {
    if (dateString == null) return '';
    DateTime date = DateTime.parse(dateString);
    return '${date.month}月${date.day}日${date.hour}時${date.minute}分';
  }

  String dateTimeFormatJP2(String? dateString) {
    if (dateString == null) return '';
    return '${int.parse(dateString.split(":")[0])}時間${int.parse(dateString.split(":")[1])}分';
  }

  List<String> getYearSelectList(String min, String max) {
    List<String> results = [];

    for (int i = int.parse(min); i <= int.parse(max); i++) {
      results.add(i.toString());
    }
    return results;
  }

  List<String> getMonthSelectList() {
    List<String> results = [];

    for (int i = 1; i <= 12; i++) {
      results.add(i.toString());
    }
    return results;
  }

  int getMaxDay(String? year, String? month) {
    int maxDay = 31;

    if (year != null && month != null) {
      if (month == '12') {
        year = (int.parse(year) + 1).toString();
        month = '01';
      } else {
        month = (int.parse(month) + 1).toString();
        if (int.parse(month) < 10) month = '0$month';
      }
      DateTime nextMonthFirstDate = DateTime.parse('$year-$month-01');
      DateTime monthLastDate =
          nextMonthFirstDate.subtract(const Duration(days: 1));
      maxDay = monthLastDate.day;
    }
    return maxDay;
  }

  List<String> getMiniuteSelectList(
      String? min, String? max, String? dur, bool isEmpty) {
    List<String> results = [];
    if (isEmpty) results.add('');
    int fromT = min == null ? 0 : int.parse(min);
    int toT = max == null ? 90 : int.parse(max);
    int stepT = dur == null ? 5 : int.parse(dur);

    for (int i = fromT; i <= toT; i = i + stepT) {
      results.add(i.toString());
    }
    return results;
  }

  String currencyFormat(String param) {
    String result = '';

    int length = param.length;
    if (length < 4) return param;

    int commaCount = length ~/ 3;
    int mod = length % 3;

    if (mod == 0) {
      commaCount--;
      mod = 3;
    }
    for (var i = 0; i <= commaCount; i++) {
      if (i == 0) {
        result = param.substring(0, mod);
      } else {
        result = '$result,${param.substring((i - 1) * 3 + mod, i * 3 + mod)}';
      }
    }
    return result;
  }

  int clacDistance(LatLng pos1, LatLng pos2) {
    const double pi = 3.1415926535897932;
    const R = 6371e3; // metres
    var fLat1 = pos1.latitude * pi / 180; // φ, λ in radians
    var fLat2 = pos2.latitude * pi / 180;
    var si = (pos2.latitude - pos1.latitude) * pi / 180;
    var ra = (pos2.longitude - pos1.longitude) * pi / 180;

    var a = sin(si / 2) * sin(si / 2) +
        cos(fLat1) * cos(fLat2) * sin(ra / 2) * sin(ra / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double d = R * c;

    return d.floor();
  }

  String checkQrCode(Barcode scanData) {
    String format = describeEnum(scanData.format);
    String? code = scanData.code;

    if (code == null || format != 'qrcode') {
      return 'QRコードは正確ではありません。';
    }

    if (code.indexOf('!') < 1) {
      return '不正確なQRコードです。';
    }
    List<String> data = code.split('!');
    if (data.length != 5) {
      return '不正確なQRコードです。';
    }

    if (data[0] != 'connect') {
      return '不正確なQRコードです。';
    }

    String user = data[1];
    int sum = 0;
    for (var i = 0; i < user.length; i++) {
      sum = sum + int.parse(user.substring(i, i + 1));
    }

    if (sum.toString() != data[4]) {
      return '不正確なQRコードです。checksum';
    }

    return 'QROK';
  }

  String getDurationTime(DateTime date,
      {int duration = 15, isShowSecond = true}) {
    int minute = (date.minute ~/ duration) * duration;
    String strMin = minute < 10 ? '0$minute' : minute.toString();

    // if (date.hour == 23 && date.minute == 59)
    //   return '24:00' + (isShowSecond ? ':00' : '');

    return DateFormat('HH:$strMin${isShowSecond ? ':ss' : ''}').format(date);
  }
}
