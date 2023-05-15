import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/business/staffs.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/functions/utils.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/shift_manage_model.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/model/shift_model.dart';

class ShiftHelper {
  List<ShiftManageModel> getCleanShiftManageModels(
      var staffs, List<ShiftManageModel> datas) {
    for (int i = 0; i < datas.length; i++) {
      List<ShiftModel> ms = [];
      for (var sta in staffs) {
        ShiftModel? tempShift = datas[i]
                .shifts
                .where((element) => element.staffId == sta.staffId)
                .isNotEmpty
            ? datas[i]
                .shifts
                .where((element) => element.staffId == sta.staffId)
                .first
            : null;
        if (tempShift != null) {
          if (constShiftUsingList.contains(tempShift.shiftType)) {
            ms.add(tempShift);
          }
        }
      }
      datas[i].shifts = ms;
    }
    return datas;
  }

  Future<bool> autoShiftSet(context, organId, fromTime, toTime) async {
    var datas =
        await ClShift().loadShiftManagePsg(context, organId, fromTime, toTime);

    globals.saveControlShifts = [];
    Map<dynamic, dynamic> results = {};

    var staffs = await ClStaff().loadStaffs(context, {'organ_id': organId});

    /*
      ShiftManageModel: [
        apply: int
        count: int
        fromTime: DateTime
        toTime: DateTime
        shift: int
        shifts: ShiftModel [
          fromTime: DateTime
          organId: 4
          shiftId: 42
          shiftType: 1
          staffId: 1
          toTime: DateTime
        ]
      ]
    */

    // datas = getCleanShiftManageModels(staffs, datas);

    WorkTime.cleanHoursOnWeek();
    List<List<ShiftModel>> models = [];
    for (ShiftManageModel data in datas) {
      List<ShiftModel> shifts = await ClShift().loadShifts(context, {
        'organ_id': organId,
        'in_from_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.fromTime),
        'in_to_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.toTime)
      });

      List<ShiftModel> ms = [];
      for (var sta in staffs) {
        ShiftModel? tempShift = shifts
                .where((element) => element.staffId == sta.staffId)
                .isNotEmpty
            ? shifts.where((element) => element.staffId == sta.staffId).first
            : null;
        if (tempShift != null) {
          if (constShiftUsingList.contains(tempShift.shiftType)) {
            WorkTime.updateHoursOnWeek(
                sta.staffId ?? '_', tempShift.getDurationByMinute());
            ms.add(tempShift);
          }
        }
      }
      models.add(ms);
    }

    for (int i = 0; i < datas.length; i++) {
      ShiftManageModel data = datas[i];
      models[i] = ShiftManageModel.autoAssignTimes(
          models[i], data.fromTime, data.toTime);

      for (var element in models[i]) {
        await ClShift().updateShiftTime(context, element.shiftId,
            element.fromTime.toString(), element.toTime.toString());
        await ClShift()
            .updateShiftStatus(context, element.shiftId, element.shiftType);
      }
    }

    return true;

    //     int allCnt = 0;
    // for (var element in data.shifts) {
    //   if (element.shiftType == constShiftRequest ||
    //       element.shiftType == constShiftMeReply ||
    //       element.shiftType == constShiftApply ||
    //       element.shiftType == constShiftMeApply) allCnt++;
    // }
    // // 신청관련의 근무형태이면 개수를 세여놓는다.
    // if (allCnt == data.count) {
    //   // 모든것이 신청관련인 경우에는 그만둔다.
    //   for (var item in data.shifts) {
    //     String staffId = item.staffId;
    //     String? shiftType;
    //     shiftType = getResponseShiftStatus(item.shiftType, 'equal');
    //     if (shiftType == null) continue;
    //     globals.saveControlShifts.add({
    //       'staff_id': staffId,
    //       'from_time':
    //           DateFormat('yyyy-MM-dd HH:mm:ss').format(data.fromTime),
    //       'to_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.toTime),
    //       'shift_type': shiftType
    //     });
    //   }
    //   continue;
    // }
    //  results = await Webservice().loadHttp(context, apiAutoControlShift, {
    //   'organ_id': organId,
    //   'from_time': fromTime,
    //   'to_time': toTime,
    //   'in_from_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.fromTime),
    //   'in_to_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.toTime),
    //   'type': allCnt > data.count ? 'over' : 'mistake'
    // });
    //     print(results);
    // if (results['data'] == null) continue;
    // int cnt = allCnt;
    // for (var item in results['data']) {
    //   String staffId = item['staff_id'] ?? '';
    //   String? shiftType;
    //   var staffShifts =
    //       data.shifts.where((element) => element.staffId == staffId);
    //   if (cnt > data.count) {
    //     if (staffShifts.isEmpty) continue;
    //     shiftType =
    //         getResponseShiftStatus(staffShifts.first.shiftType, 'over');
    //   } else if (cnt < data.count) {
    //     if (staffShifts.isNotEmpty) {
    //       shiftType =
    //           getResponseShiftStatus(staffShifts.first.shiftType, 'mistake');
    //     } else {
    //       shiftType = constShiftRequest;
    //     }
    //   } else {
    //     if (staffShifts.isNotEmpty) {
    //       shiftType =
    //           getResponseShiftStatus(staffShifts.first.shiftType, 'equal');
    //     }
    //   }
    //   if (shiftType == null) continue;
    //   if (cnt < data.count) {
    //     cnt++;
    //   } else if (cnt > data.count) {
    //     cnt--;
    //   }

    //   globals.saveControlShifts.add({
    //     'staff_id': staffId,
    //     'from_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.fromTime),
    //     'to_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.toTime),
    //     'shift_type': shiftType
    //   });
    //   //if (cnt == data.count) break;
    // }
//    }
  }

  void autoSetSave(staffId, fromTime, toTime, type) {
    globals.saveControlShifts.add({
      'staff_id': staffId,
      'from_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(fromTime),
      'to_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(toTime),
      'shift_type': type
    });
  }

  String? getResponseShiftStatus(String curStatus, String convertType) {
    switch (curStatus) {
      case constShiftSubmit:
        return convertType == 'mistake' ? constShiftApply : constShiftReject;

      case constShiftReject:
        if (convertType == 'mistake') return constShiftApply;
        break;

      case constShiftOut:
        if (convertType == 'mistake') return constShiftRequest;
        break;

      case constShiftRest:
        break;

      case constShiftRequest:
        if (convertType == 'over') return constShiftMeReject;
        break;

      case constShiftMeReject:
        break;

      case constShiftMeReply:
        return convertType != 'mistake'
            ? constShiftMeApply
            : constShiftMeReject;

      case constShiftMeApply:
        if (convertType == 'over') return constShiftMeReject;
        break;

      case constShiftApply:
        if (convertType == 'over') return constShiftReject;
        break;
      default:
    }

    return null;
  }
}
