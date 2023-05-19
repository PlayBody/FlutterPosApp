import 'package:staff_pos_app/src/model/shift_model.dart';

class ShiftManageModel {
  final DateTime fromTime;
  final DateTime toTime;
  int count;
  int apply;
  int shift;
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
        apply: int.parse((json['apply'] ?? "0").toString()),
        shift: int.parse((json['shift'] ?? "0").toString()),
        shifts: shifts);
  }

  // static dynamic autoAssignTimes(
  //     List<ShiftModel> shifts,
  //     DateTime fromTime,
  //     DateTime toTime,
  //     int requireCount,
  //     List<StaffListModel> staffs,
  //     List<ShiftModel> skips,
  //     String organId) {
  //   List<WorkTime> works = [];
  //   for (var item in shifts) {
  //     works.add(WorkTime(item.fromTime, item.toTime)..meta = item);
  //   }
  //   List<dynamic> res = WorkTimeUtil.assignWorkRange(
  //       works, WorkTime(fromTime, toTime), requireCount);
  //   List<WorkTime> newWorks = res[0] as List<WorkTime>;
  //   int filledCount = res[1] as int;
  //   List<ShiftModel> newShifts = [];

  //   for (var work in works) {
  //     int i;
  //     for (i = 0; i < newWorks.length; i++) {
  //       if (work.meta.shiftId.compareTo(newWorks[i].meta.shiftId) == 0) {
  //         break;
  //       }
  //     }
  //     if (i == newWorks.length) {
  //       work.meta.shiftType = constShiftReject;
  //       // if (work.meta.shiftType.compareTo(constShiftApply) == 0 ||
  //       //     work.meta.shiftType.compareTo(constShiftMeApply) == 0) {
  //       // }
  //       newShifts.add(ShiftModel.fromWorkTime(work));
  //     } else {
  //       var nw = newWorks[i];
  //       if (nw.isChanged()) {
  //         nw.meta.shiftType = constShiftRequest;
  //       } else {
  //         if (nw.meta.shiftType.compareTo(constShiftApply) == 0 ||
  //             nw.meta.shiftType.compareTo(constShiftMeApply) == 0) {
  //         } else {
  //           nw.meta.shiftType = constShiftMeApply;
  //         }
  //       }
  //       newShifts.add(ShiftModel.fromWorkTime(nw));
  //     }
  //   }

  //   // If there is no auto control list do by using staff list
  //   // 자동조절할수 있는 요청목록이 없으면 요청목록을 강제로 만들어 내려보낸다.
  //   // 여기서 staffs 변수는 이미 sort된것이 들어온다고 가정한다.
  //   if (requireCount > filledCount) {
  //     for (var sta in staffs) {
  //       bool isFindSkip = false;
  //       for (var skip in skips) {
  //         if (skip.staffId == (sta.staffId ?? '')) {
  //           isFindSkip = true;
  //           break;
  //         }
  //       }
  //       if (isFindSkip) {
  //         continue;
  //       } else {
  //         ShiftModel m = ShiftModel(
  //             shiftId: '-1',
  //             organId: organId,
  //             staffId: sta.staffId ?? '',
  //             fromTime: fromTime,
  //             toTime: toTime,
  //             shiftType: constShiftRequest);
  //         newShifts.add(m);
  //         filledCount++;
  //         if (filledCount == requireCount) {
  //           break;
  //         }
  //       }
  //     }
  //   }

  //   return newShifts;
  // }
}
