import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/functions/utils.dart';
import 'package:staff_pos_app/src/model/shift_model.dart';

class ShiftManageModel {
  final DateTime fromTime;
  final DateTime toTime;
  final int count;
  final int apply;
  final int shift;
  List<ShiftModel> shifts;

  ShiftManageModel({
    required this.fromTime,
    required this.toTime,
    required this.count,
    required this.apply,
    required this.shift,
    required this.shifts,
  });

  factory ShiftManageModel.fromJson(Map<String, dynamic> json) {
    List<ShiftModel> shifts = [];
    if (json['shifts'] != null) {
      for (var item in json['shifts']) {
        shifts.add(ShiftModel.fromJson(item));
      }
    }
    return ShiftManageModel(
        fromTime: DateTime.parse(json['from_time']),
        toTime: DateTime.parse(json['to_time']),
        count: int.parse(json['count'].toString()),
        apply: int.parse(json['apply'].toString()),
        shift: int.parse(json['shift'].toString()),
        shifts: shifts);
  }

  static dynamic autoAssignTimes(
      List<ShiftModel> shifts, DateTime fromTime, DateTime toTime) {
    List<WorkTime> works = [];
    for (var item in shifts) {
      works.add(WorkTime(item.fromTime, item.toTime)..meta = item);
    }
    List<WorkTime> newWorks =
        WorkTimeUtil.assignWorkRange(works, WorkTime(fromTime, toTime));
    List<ShiftModel> newShifts = [];

    for (var work in works) {
      int i;
      for (i = 0; i < newWorks.length; i++) {
        if (work.meta.shiftId.compareTo(newWorks[i].meta.shiftId) == 0) {
          break;
        }
      }
      if (i == newWorks.length) {
        work.meta.shiftType = constShiftReject;
        // if (work.meta.shiftType.compareTo(constShiftApply) == 0 ||
        //     work.meta.shiftType.compareTo(constShiftMeApply) == 0) {
        // }
        newShifts.add(ShiftModel.fromWorkTime(work));
      } else {
        var nw = newWorks[i];
        if (nw.isChanged()) {
          nw.meta.shiftType = constShiftRequest;
        } else {
          if (nw.meta.shiftType.compareTo(constShiftApply) == 0 ||
              nw.meta.shiftType.compareTo(constShiftMeApply) == 0) {
          } else {
            nw.meta.shiftType = constShiftMeApply;
          }
        }
        newShifts.add(ShiftModel.fromWorkTime(nw));
      }
    }

    return newShifts;
  }
}
