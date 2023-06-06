import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions/shifts.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/shift_count_model.dart';
import 'package:staff_pos_app/src/model/shift_init_model.dart';
import 'package:staff_pos_app/src/model/shift_manage_model.dart';
import 'package:staff_pos_app/src/model/shift_model.dart';
import 'package:staff_pos_app/src/model/shiftdaymodel.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../common/globals.dart' as globals;

import '../apiendpoint.dart';

class ClShift {
  Future<bool> loadShiftLock(
      context, String organId, String fromDate, String toDate) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadShiftLockUrl, {
      'organ_id': organId,
      'from_time': '$fromDate 00:00:00',
      'to_time': '$toDate 23:59:59',
    }).then((v) => {results = v});

    if (results['isLoad']) {
      return results['is_lock'];
    }
    return false;
  }

  Future<bool> updateShiftLock(context, String organId, String fromDate,
      String toDate, bool isLock) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiSaveShiftLockUrl, {
      'organ_id': organId,
      'from_time': '$fromDate 00:00:00',
      'to_time': '$toDate 23:59:59',
      'lock_status': isLock ? '1' : '0'
    }).then((v) => {results = v});

    if (results['isSave']) {
      return true;
    }
    return false;
  }

  Future<dynamic> loadshiftCounts(
      context, String organId, String fromDateTime, String toDateTime) async {
    String apiUrl = '$apiBase/apishifts/getShiftCounts';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'organ_id': organId,
      'from_time': fromDateTime,
      'to_time': toDateTime,
    }).then((value) => results = value);

    return results['counts'];
  }

  Future<List<Appointment>> loadColorShiftCounts(
      context, String organId, String fromDateTime, String toDateTime) async {
    List<Appointment> appointments = [];

    dynamic results =
        await loadshiftCounts(context, organId, fromDateTime, toDateTime);

    OrganModel loadOrganInfo = await ClOrgan().loadOrganInfo(context, organId);

    int positionCount = loadOrganInfo.tableCount;
    for (var item in results) {
      appointments.add(Appointment(
        startTime: DateTime.parse(item['from_time']),
        endTime: DateTime.parse(item['to_time']),
        subject: item['count'],
        color: Color(FuncShifts()
                .getLevelColorValue(int.parse(item['count']), positionCount))
            .withOpacity(0.5),
        startTimeZone: '',
        endTimeZone: '',
      ));
    }

    appointments.sort((a, b) => a.startTime.compareTo(b.startTime));
    return appointments;
  }

  Future<List<Appointment>> loadStaffShift(context, String staffId,
      String organId, String fromDateTime, String toDateTime,
      {mode = '', pattern = ''}) async {
    List<Appointment> appointments = [];
    String apiUrl = '$apiBase/apishifts/getStaffShifts';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'staff_id': staffId,
      'organ_id': organId,
      'from_time': fromDateTime,
      'to_time': toDateTime,
      'mode': mode,
      'pattern': pattern
    }).then((value) => results = value);

    for (var item in results['shifts']) {
      var shiftColor = Colors.blue;
      var txtContent = '申請中';
      var notes = '';
      if (item['shift_type'] == '1') {
        shiftColor = Colors.blue;
        txtContent = '申請中';
      }
      if (item['shift_type'] == '2') {
        shiftColor = Colors.green;
        txtContent = '承認';
      }
      if (item['shift_type'] == '-2') {
        shiftColor = Colors.red;
        txtContent = '拒否';
      }
      if (item['shift_type'] == '-3') {
        shiftColor = Colors.red;
        txtContent = '店外待機';
      }
      if (item['shift_type'] == '3') {
        shiftColor = Colors.orange;
        txtContent = '回答済み';
        notes = 'manager,${item['shift_id']}';
      }
      if (item['shift_type'] == '4') {
        shiftColor = Colors.orange;
        txtContent = '出勤要請';
        notes = 'manager,${item['shift_id']}';
      }
      if (item['shift_type'] == '6') {
        shiftColor = Colors.grey;
        txtContent = '休み';
      }

      appointments.add(Appointment(
          startTime: DateTime.parse(item['from_time']),
          endTime: DateTime.parse(item['to_time']),
          subject: txtContent,
          color: shiftColor.withOpacity(0.7),
          startTimeZone: '',
          endTimeZone: '',
          notes: notes));
    }
    appointments.sort((a, b) => a.startTime.compareTo(b.startTime));

    return appointments;
  }

  Future<List<Appointment>> loadStaffReserve(context, String staffId,
      String organId, String fromDateTime, String toDateTime) async {
    List<Appointment> appointments = [];
    String apiUrl = '$apiBase/apishifts/getStaffReserves';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'staff_id': staffId,
      'organ_id': organId,
      'from_time': fromDateTime,
      'to_time': toDateTime,
    }).then((value) => results = value);
    for (var item in results['reserves']) {
      appointments.add(Appointment(
          startTime: DateTime.parse(item['reserve_time']),
          endTime: DateTime.parse(item['reserve_exit_time']),
          subject: item['reserve_status'].toString() == '2' ? '予約承認' : '予約申込',
          color: item['reserve_status'].toString() == '2'
              ? Colors.grey
              : Colors.white,
          startTimeZone: '',
          endTimeZone: '',
          notes: item['reserve_status'].toString() == '2'
              ? ''
              : ('reserve,${item['reserve_id']}')));
    }

    return appointments;
  }

  Future<bool> forceSaveShift(
      context,
      String staffId,
      String organId,
      String shiftId,
      String fromTime,
      String toTime,
      String shiftType,
      String deleted) async {
    String apiUrl = '$apiBase/apis/shift/shifts/forceSaveShift';

    await Webservice().loadHttp(context, apiUrl, {
      'staff_id': staffId,
      'organ_id': organId,
      'shift_id': shiftId,
      'from_time': fromTime,
      'to_time': toTime,
      'shift_type': shiftType,
      'deleted': deleted,
    }).then((value) => null);
    return true;
  }

  Future<bool> loadStaffShiftTime(
      context, String staffId, String organId) async {
    Map<dynamic, dynamic> results = {};

    String apiUrl = '$apiBase/apishifts/getStaffShiftTime';
    await Webservice().loadHttp(context, apiUrl, {
      'staff_id': staffId,
      'organ_id': organId
    }).then((value) => results = value);

    // if (results['isLoad']) {
    //   globals.shiftWeekPlanMinute = int.parse(results['staff_times']);
    //   return true;
    // }

    return false;
  }

  Future<List<TimeRegion>> loadActiveShiftRegions(
      context, String organId, String firstDate) async {
    List<TimeRegion> regions = [];
    Map<dynamic, dynamic> results = {};

    String apiUrl = '$apiBase/apishifts/getActiveShifts';

    await Webservice().loadHttp(context, apiUrl, {'organ_id': organId}).then(
        (value) => results = value);

    // List<WorkTime> ditv = List.empty(growable: true);

    for (var item in results['shift_times']) {
      var startDate = DateTime.parse('$firstDate ${item['from_time']}')
          .add(Duration(days: int.parse(item['weekday']) - 1));
      var endDate = DateTime.parse('$firstDate ${item['to_time']}')
          .add(Duration(days: int.parse(item['weekday']) - 1));

      // ditv.add(WorkTime(startDate, endDate));

      regions.add(TimeRegion(
          startTime: startDate,
          endTime: endDate,
          enablePointerInteraction: true,
          // recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
          color: const Color(0xffffc3bf), //shiftOrganDisableColor,
          text: ''));
    }

    results = {};
    apiUrl = '$apiBase/apiorgans/loadOrganSpecialTimes';
    String fromDateTime = '$firstDate 00:00:00';
    String toDateTime =
        '${DateFormat('yyyy-MM-dd').format(DateTime.parse(fromDateTime).add(const Duration(days: 7)))} 23:59:59';

    await Webservice().loadHttp(context, apiUrl, {
      'organ_id': organId,
      'from_time': fromDateTime,
      'to_time': toDateTime,
    }).then((value) => results = value);
    for (var item in results['times']) {
      var from = DateTime.parse(item['from_time']);
      var to = DateTime.parse(item['to_time']);

      // ditv.add(WorkTime(from, to));

      regions.add(TimeRegion(
          startTime: from,
          endTime: to,
          enablePointerInteraction: true,
          // recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
          color: const Color(0xffffc3bf), //shiftOrganDisableColor,
          text: ''));
    }

    // globals.shiftWeekStaffMinute = WorkTimeUtil.getTotalMinutes(ditv);

    return regions;
  }

  Future<bool> sendRequestInput(
      context, String organId, String fromTime, String toTime) async {
    Map<dynamic, dynamic> results = {};

    String apiUrl = '$apiBase/apishifts/sendNotificationToStaffInputRequest';
    await Webservice().loadHttp(context, apiUrl, {
      'organ_id': organId,
      'staff_id': globals.staffId,
      'from_time': fromTime,
      'to_time': toTime
    }).then((value) => results = value);

    return results['isSend'];
  }

  Future<List<ShiftDayModel>> loadDayDetail(
      context, String organId, String selDate) async {
    Map<dynamic, dynamic> results = {};
    String apiUrl = '$apiBase/apishifts/loadDailyDetail';
    await Webservice().loadHttp(context, apiUrl, {
      'organ_id': organId,
      'select_date': selDate
    }).then((value) => results = value);

    List<ShiftDayModel> shifts = [];
    for (var item in results['shifts']) {
      shifts.add(ShiftDayModel.fromJson(item));
    }
    return shifts;
  }

  Future<List<ShiftDayModel>> loadDayReserve(
      context, String organId, String selDate) async {
    String apiUrl = '$apiBase/apishifts/getStaffReserves';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      //'staff_id': globals.staffId,
      'organ_id': organId,
      'from_time': '$selDate 00:00:00',
      'to_time': '$selDate 23:59:59',
    }).then((value) => results = value);

    if (results['reserves'] == null) return [];
    List<ShiftDayModel> reserves = [];
    for (var item in results['reserves']) {
      item['from_time'] = item['reserve_time'];
      item['to_time'] = item['reserve_exit_time'];
      item['shift_type'] = '0';
      reserves.add(ShiftDayModel.fromJson(item));
    }
    return reserves;
  }

  Future<bool> applyOrRejectRequestShift(BuildContext context, String shiftId,
      String fromTime, String toTime, String updateType) async {
    String apiUrl = '$apiBase/apishifts/applyOrRejectRequestShift';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'shift_id': shiftId,
      'from_time': fromTime,
      'to_time': toTime,
      'update_shift_type': updateType
    }).then((value) => results = value);

    return results['isUpdate'];
  }

  Future<bool> updateShiftStatus(
      BuildContext context, String shiftId, String status) async {
    String apiUrl = '$apiBase/apishifts/updateShiftStatus';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'shift_id': shiftId,
      'status': status
    }).then((value) => results = value);

    return results['isUpdate'];
  }

  Future<bool> updateShiftTime(BuildContext context, String shiftId,
      String fromtime, String toTime) async {
    String apiUrl = '$apiBase/apishifts/updateShiftTime';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'shift_id': shiftId,
      'from_time': fromtime,
      'to_time': toTime
    }).then((value) => results = value);

    return results['isUpdate'];
  }

  Future<bool> updateReserveStaff(
      BuildContext context, String reserveId, String staffId) async {
    String apiUrl = '$apiBase/apishifts/updateReserveStaff';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'reserve_id': reserveId,
      'staff_id': staffId
    }).then((value) => results = value);

    return results['isUpdate'];
  }

  Future<bool> updateFreeReserveAuto(BuildContext context, String reserveDate,
      String organId, String staffId) async {
    String apiUrl = '$apiBase/apireserves/updateFreeReserveAuto';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'reserve_date': reserveDate,
      'organ_id': organId,
      'staff_id': staffId
    }).then((value) => results = value);

    return results['isUpdate'];
  }

  Future<bool> updateReserveItem(BuildContext context, String reseveId,
      String reserveTime, String updateStaffId) async {
    String apiUrl = '$apiBase/apireserves/updateReserveItem';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'reserve_id': reseveId,
      'reserve_time': reserveTime,
      'staff_id': updateStaffId
    }).then((value) => results = value);

    return results['isUpdate'];
  }

  Future<List<TimeRegion>> loadColorShiftCountsByWeek(
      context, String organId, String fromDateTime, String toDateTime) async {
    List<TimeRegion> regions = [];

    dynamic results =
        await loadshiftCounts(context, organId, fromDateTime, toDateTime);

    OrganModel loadOrganInfo = await ClOrgan().loadOrganInfo(context, organId);
    int positionCount = loadOrganInfo.tableCount;

    for (var item in results) {
      regions.add(TimeRegion(
          startTime: DateTime.parse(item['from_time']),
          endTime: DateTime.parse(item['to_time']),
          enablePointerInteraction: true,
          // recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
          color: Color(FuncShifts().getLevelColorValue(int.parse(item['count']),
              positionCount)), //shiftOrganDisableColor,
          text: item['count']));
    }

    return regions;
  }

  Future<List<ShiftModel>> loadShiftsByCondition(context, dynamic param) async {
    String apiUrl = '$apiBase/apishifts/loadShiftDataByParam';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl,
        {'condition': jsonEncode(param)}).then((value) => results = value);

    List<ShiftModel> shifts = [];
    for (var item in results['shifts']) {
      shifts.add(ShiftModel.fromJson(item));
    }
    return shifts;
  }

  Future<List<ShiftModel>> loadShifts(BuildContext context, param) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadShiftsUrl,
        {'condition': jsonEncode(param)}).then((value) => results = value);
    List<ShiftModel> shifts = [];
    for (var item in results['shifts']) {
      shifts.add(ShiftModel.fromJson(item));
    }
    return shifts;
  }

  Future<List<ShiftCountModel>> loadshiftCountList(context, param) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadShiftCountsUrl,
        {'condition': jsonEncode(param)}).then((value) => results = value);
    List<ShiftCountModel> counts = [];

    for (var item in results['counts']) {
      counts.add(ShiftCountModel.fromJson(item));
    }
    return counts;
  }

  Future<bool> saveShift(context, param) async {
    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiSaveShiftUrl, param)
        .then((value) => results = value);

    if (!results['isSave']) {
      String message = results['message'] ?? errServerActionFail;
      await Dialogs().waitDialog(context, message);
    }
    return results['isSave'];
  }

  Future<bool> setInitShift(context, organId, fromDate, toDate, pattern) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiInitShiftUrl, {
      'organ_id': organId,
      'staff_id': globals.staffId,
      'from_date': fromDate,
      'to_date': toDate,
      'pattern': pattern
    }).then((value) => results = value);

    if (!results['isSave']) {
      String message = results['message'] ?? errServerActionFail;
      await Dialogs().waitDialog(context, message);
    }
    return results['isSave'];
  }

  Future<bool> deleteShift(context, shiftId) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiDeleteShift, {
      'shift_id': shiftId,
    }).then((v) => {results = v});

    return results['isDelete'];
  }

  Future<List<InitShiftModel>> loadInitShifts(context, param) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadInitShift,
        {'condition': jsonEncode(param)}).then((value) => results = value);
    List<InitShiftModel> shifts = [];
    for (var item in results['shifts']) {
      shifts.add(InitShiftModel.fromJson(item));
    }
    return shifts;
  }

  Future<bool> saveInitShift(context, param) async {
    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiSaveInitShift, param)
        .then((value) => results = value);

    if (!results['isSave']) {
      String message = results['message'] ?? errServerActionFail;
      await Dialogs().waitDialog(context, message);
    }
    return results['isSave'];
  }

  // Future<bool> updateShiftChange(context, organId) async {
  //   List<dynamic> shifts = [];
  //   for (var item in globals.saveControlShifts) {
  //     if (item['shift_type'] == constShiftRequest ||
  //         item['shift_type'] == constShiftMeReply) {
  //       shifts.add(item);
  //       continue;
  //     }
  //     var temp = shifts.firstWhere(
  //         (element) =>
  //             element['staff_id'] == item['staff_id'] &&
  //             element['shift_type'] == item['shift_type'] &&
  //             element['to_time'] == item['from_time'],
  //         orElse: () => null);
  //     if (temp != null) {
  //       int preIndex = shifts.indexOf(temp);
  //       shifts[preIndex]['to_time'] = item['to_time'];

  //       var nextTemp = shifts.firstWhere(
  //           (element) =>
  //               element['staff_id'] == item['staff_id'] &&
  //               element['shift_type'] == item['shift_type'] &&
  //               element['from_time'] == item['to_time'],
  //           orElse: () => null);
  //       if (nextTemp != null) {
  //         shifts[preIndex]['to_time'] = nextTemp['to_time'];
  //         shifts.remove(nextTemp);
  //       }
  //       continue;
  //     } else {
  //       var nextTemp = shifts.firstWhere(
  //           (element) =>
  //               element['staff_id'] == item['staff_id'] &&
  //               element['shift_type'] == item['shift_type'] &&
  //               element['from_time'] == item['to_time'],
  //           orElse: () => null);
  //       if (nextTemp != null) {
  //         int nextIndex = shifts.indexOf(nextTemp);
  //         shifts[nextIndex]['from_time'] = item['from_time'];
  //         continue;
  //       }
  //     }
  //     shifts.add(item);
  //   }

  //   var param = {};
  //   int i = 0;
  //   for (var element in shifts) {
  //     param[i.toString()] = element;
  //     i++;
  //   }
  //   await Webservice().loadHttp(context, apiShiftSaveShiftManage, {
  //     'organ_id': organId,
  //     'sender_id': globals.staffId,
  //     'data': jsonEncode(param),
  //   });

  //   return true;
  // }

  //save Staff input Shifts
  Future<bool> saveStaffInputShift(context, param) async {
    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiShiftSaveStaffInput, param)
        .then((value) => results = value);

    if (!results['isSave']) {
      String message = results['message'] ?? errServerActionFail;
      await Dialogs().waitDialog(context, message);
    }
    return results['isSave'];
  }

  //load manage data
  Future<List<ShiftManageModel>> loadShiftManage(
      context, organId, fromTime, toTime) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiShiftLoadManage, {
      'organ_id': organId,
      'from_time': fromTime,
      'to_time': toTime,
    }).then((value) => results = value);
    List<ShiftManageModel> manages = [];
    for (var item in results['data']) {
      manages.add(ShiftManageModel.fromJson(item));
    }

    return manages;
  }

  Future<List<ShiftManageModel>> loadShiftManagePsg(
      context, organId, fromTime, toTime) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiShiftLoadManagePsg, {
      'organ_id': organId,
      'from_time': fromTime,
      'to_time': toTime,
    }).then((value) => results = value);
    List<ShiftManageModel> manages = [];
    for (var item in results['data']) {
      manages.add(ShiftManageModel.fromJson(item));
    }

    return manages;
  }
}
