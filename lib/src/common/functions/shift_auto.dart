import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/business/staffs.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/functions/time_util.dart';
import 'package:staff_pos_app/src/model/shift_manage_model.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/model/shift_model.dart';
import 'package:staff_pos_app/src/model/stafflistmodel.dart';

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
          if (constShiftAutoUsingList.contains(tempShift.shiftType)) {
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

    List<Worker> workers = [];
    List<WorkPlan> plans = [];
    for (int i = 0; i < WEEK_COUNT; i++) {
      plans.add(WorkPlan.newInstance());
    }

    List<StaffListModel> staffs =
        await ClStaff().loadStaffs(context, {'organ_id': organId});

    for (var sta in staffs) {
      workers.add(Worker.fromStaffList(sta));
    }

    globals.saveShiftFromAutoControl = [];
    for (ShiftManageModel data in datas) {
      plans[data.fromTime.weekday - 1]
          .appendPlan(data.fromTime, data.toTime, data.count);
    }

    List<ShiftModel> shifts = await ClShift().loadShifts(context,
        {'organ_id': organId, 'in_from_time': fromTime, 'in_to_time': toTime});

    for (Worker w in workers) {
      List<ShiftModel> ws =
          shifts.where((element) => element.staffId == w.meta.staffId).toList();
      var signs = List<bool>.generate(8, (index) => false);

      for (ShiftModel wws in ws) {
        if (constShiftAutoUsingList.contains(wws.shiftType) &&
            signs[wws.fromTime.weekday] == false) {
          w.setShift(wws);
          signs[wws.fromTime.weekday] = true;
        } else {
          if (constShiftAutoUsingList.contains(wws.shiftType)) {
            wws.shiftType = constShiftReject;
            wws.uniqueId = WorkControl.getGenCounter();
            globals.saveShiftFromAutoControl.add(wws);
          }
        }
      }
    }

    List<WorkTime> workTimes = WorkControl.assignWorkTime(
        workers, plans, organId, DateTime.parse(fromTime));
    for (WorkTime wt in workTimes) {
      globals.saveShiftFromAutoControl.add(ShiftModel.fromWorkTime(wt));
    }
    return true;
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
