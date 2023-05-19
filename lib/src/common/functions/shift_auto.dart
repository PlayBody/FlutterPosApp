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

    globals.saveControlShifts = [];

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

    List<List<ShiftModel>> models = [];
    List<List<ShiftModel>> skipModels = [];
    for (ShiftManageModel data in datas) {
      List<ShiftModel> shifts = await ClShift().loadShifts(context, {
        'organ_id': organId,
        'in_from_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.fromTime),
        'in_to_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.toTime)
      });

      for (Worker w in workers) {
        ShiftModel? tempShift = shifts
                .where((element) => element.staffId == w.meta.staffId)
                .isNotEmpty
            ? shifts.where((element) => element.staffId == w.meta.staffId).first
            : null;

        w.setShift(tempShift);
      }
      plans[data.fromTime.weekday - 1]
          .appendPlan(data.fromTime, data.toTime, data.count);
    }

    List<WorkTime> workTimes = WorkControl.assignWorkTime(
        workers, plans, organId, DateTime.parse(fromTime));
    globals.saveShiftFromAutoControl = [];
    for (WorkTime wt in workTimes) {
      globals.saveShiftFromAutoControl.add(ShiftModel.fromWorkTime(wt));
    }
    return true;

    // for (int i = 0; i < datas.length; i++) {
    //   ShiftManageModel data = datas[i];
    //   //  개수변수를 앞으로 리용해야 한다.: data.count;
    //   models[i] = ShiftManageModel.autoAssignTimes(models[i], data.fromTime,
    //       data.toTime, data.count, staffs, skipModels[i], organId);

    //   for (ShiftModel element in models[i]) {
    //     globals.saveShiftFromAutoControl.add(element);
    //     // await ClShift().forceSaveShift(
    //     //     context,
    //     //     element.staffId,
    //     //     element.organId,
    //     //     element.shiftId,
    //     //     element.fromTime.toString(),
    //     //     element.toTime.toString(),
    //     //     element.shiftType);
    //     // await ClShift().updateShiftTime(context, element.shiftId,
    //     //     element.fromTime.toString(), element.toTime.toString());
    //     // await ClShift()
    //     //     .updateShiftStatus(context, element.shiftId, element.shiftType);
    //   }
    // }
  }

  // void autoSetSave(staffId, fromTime, toTime, type) {
  //   globals.saveControlShifts.add({
  //     'staff_id': staffId,
  //     'from_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(fromTime),
  //     'to_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(toTime),
  //     'shift_type': type
  //   });
  // }

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
