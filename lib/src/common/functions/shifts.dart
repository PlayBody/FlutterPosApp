import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/model/order_model.dart';
import 'package:staff_pos_app/src/model/shift_init_model.dart';
import 'package:staff_pos_app/src/model/shift_manage_model.dart';
import 'package:staff_pos_app/src/model/shift_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;

class FuncShifts {
  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  int getLevelColorValue(int curPos, int allCnt) {
    int level = curPos * (255 * 5) ~/ allCnt;
    int g = level ~/ 255;
    int gLevel = level - g * 255;

    if (g == 0) {
      String hx = gLevel.toRadixString(16);
      hx = hx.length == 1 ? ('0$hx') : hx;
      return int.parse('FF00${hx}FF', radix: 16);
    }

    if (g == 1) {
      String hx = (255 - gLevel).toRadixString(16);
      hx = hx.length == 1 ? ('0$hx') : hx;
      return int.parse('FF00FF$hx', radix: 16);
    }

    if (g == 2) {
      String hx = gLevel.toRadixString(16);
      hx = hx.length == 1 ? ('0$hx') : hx;
      return int.parse('FF${hx}FF00', radix: 16);
    }
    if (g == 3) {
      String hx = (255 - gLevel).toRadixString(16);
      hx = hx.length == 1 ? ('0$hx') : hx;
      return int.parse('FFFF${hx}00', radix: 16);
    }
    if (g == 4) {
      String hx = gLevel.toRadixString(16);
      hx = hx.length == 1 ? ('0$hx') : hx;
      return int.parse('FFFF00$hx', radix: 16);
    }
    if (g == 5) return int.parse('FFFF00FF', radix: 16);

    return int.parse('FFFF00FF', radix: 16);
  }

  List<Appointment> getAppoinsFromList(List<ShiftModel> shifts) {
    List<Appointment> appointments = [];

    for (var shift in shifts) {
      appointments.add(Appointment(
          startTime: shift.fromTime,
          endTime: shift.toTime,
          subject: constShiftAppoints[shift.shiftType]!['subject']!,
          color:
              Color(int.parse(constShiftAppoints[shift.shiftType]!['color']!))
                  .withOpacity(0.9),
          startTimeZone: '',
          endTimeZone: '',
          notes: constShiftAppoints[shift.shiftType]!['note']!));
    }

    appointments.sort((a, b) => a.startTime.compareTo(b.startTime));

    return appointments;
  }

  List<Appointment> getAppoinsFromReserveList(List<OrderModel> reserves) {
    List<Appointment> appointments = [];

    for (var reserve in reserves) {
      String subject =
          reserve.status == constOrderStatusReserveApply ? '予約済み' : '予約申込';
      var color = reserve.status == constOrderStatusReserveApply
          ? Colors.cyan
          : Colors.orange;
      appointments.add(Appointment(
          startTime: DateTime.parse(reserve.fromTime),
          endTime: DateTime.parse(reserve.toTime),
          subject: subject,
          color: color.withOpacity(0.9),
          startTimeZone: '',
          endTimeZone: '',
          notes: 'reserve_${reserve.status}:${reserve.orderId}'));
    }

    appointments.sort((a, b) => a.startTime.compareTo(b.startTime));

    return appointments;
  }

  List<Appointment> getAppoinsFromInitList(List<InitShiftModel> shifts) {
    List<Appointment> appointments = [];

    for (var shift in shifts) {
      String type = shift.shiftType;

      if (int.parse(type) < 0) type = constShiftSubmit;
      String date = DateFormat('yyyy-MM-dd').format(getDate(DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday))
          .add(Duration(days: shift.weekday))));
      appointments.add(Appointment(
          startTime: DateTime.parse('$date ${shift.fromTime}'),
          endTime: DateTime.parse('$date ${shift.toTime}'),
          subject: type == '1' ? '店内勤務' : constShiftAppoints[type]!['subject']!,
          color: Color(int.parse(constShiftAppoints[type]!['color']!)),
          startTimeZone: '',
          endTimeZone: '',
          notes: constShiftAppoints[type]!['note']!));
    }

    appointments.sort((a, b) => a.startTime.compareTo(b.startTime));

    return appointments;
  }

  List<Appointment> getAppoinsFromManageList(List<ShiftManageModel> datas) {
    List<Appointment> appointments = [];

    for (var data in datas) {
      //   int cnt = 0;
      //   int colorCnt = 0;
      //   for (var shift in data.shifts) {
      //     var search = globals.saveControlShifts.where((element) =>
      //         element['staff_id'] == shift.staffId &&
      //         element['from_time'] ==
      //             DateFormat('yyyy-MM-dd HH:mm:ss').format(data.fromTime) &&
      //         element['to_time'] ==
      //             DateFormat('yyyy-MM-dd HH:mm:ss').format(data.toTime));
      //     String type = shift.shiftType;
      //     if (search.isNotEmpty) type = search.first['shift_type'];
      //     if (type == constShiftApply || type == constShiftMeApply) colorCnt++;
      //     if (type == constShiftApply ||
      //         type == constShiftMeApply ||
      //         type == constShiftMeReply ||
      //         type == constShiftRequest) cnt++;
      //   }

      //   var globalData = globals.saveControlShifts.where((element) =>
      //       element['from_time'] ==
      //           DateFormat('yyyy-MM-dd HH:mm:ss').format(data.fromTime) &&
      //       element['to_time'] ==
      //           DateFormat('yyyy-MM-dd HH:mm:ss').format(data.toTime));
      //   for (var element in globalData) {
      //     if (data.shifts
      //         .where((shift) => shift.staffId == element['staff_id'])
      //         .isEmpty) {
      //       String type = element['shift_type'];
      //       if (type == constShiftApply || type == constShiftMeApply) {
      //         colorCnt++;
      //       }
      //       if (type == constShiftApply ||
      //           type == constShiftMeApply ||
      //           type == constShiftMeReply ||
      //           type == constShiftRequest) cnt++;
      //     }
      //   }

      appointments.add(Appointment(
        startTime: data.fromTime,
        endTime: data.toTime,
        // subject: '$cnt/${data.count}',
        // color: data.count == colorCnt
        //     ? Colors.blue.withOpacity(0.8)
        //     : (data.count == cnt
        //         ? Colors.green.withOpacity(0.8)
        //         : Colors.yellow.withOpacity(0.8)),
        subject: '${data.apply}/${data.count}',
        color: data.count <= data.apply
            ? Colors.green.withOpacity(0.8)
            : Colors.yellow.withOpacity(0.8),
        notes: data.count.toString(),
      ));
    }

    appointments.sort((a, b) => a.startTime.compareTo(b.startTime));

    return appointments;
  }

  // List<Appointment> getShiftInitAppoints(List<ShiftInitModel> shifts) {
  //   List<Appointment> appointments = [];

  //   for (var shift in shifts) {
  //     String type = shift.shiftType;

  //     String curDate = DateFormat('yyyy-MM-dd').format(getDate(DateTime.now()
  //         .subtract(Duration(days: DateTime.now().weekday))
  //         .add(Duration(days: int.parse(shift.weekday)))));
  //     appointments.add(Appointment(
  //         startTime: DateTime.parse('$curDate ${shift.fromTime!}'),
  //         endTime: DateTime.parse('$curDate ${shift.toTime!}'),
  //         subject: constShiftAppoints[type]!['subject']!,
  //         color: Color(int.parse(constShiftAppoints[type]!['color']!)),
  //         startTimeZone: '',
  //         endTimeZone: '',
  //         notes: constShiftAppoints[type]!['note']!));
  //   }

  //   appointments.sort((a, b) => a.startTime.compareTo(b.startTime));

  //   return appointments;
  // }
}
