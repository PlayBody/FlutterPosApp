import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/shift_manage_model.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;

class ShiftHelper {
  Future<bool> autoShiftSet(
      context, List<ShiftManageModel> datas, organId, fromTime, toTime) async {
    globals.saveControlShifts = [];
    Map<dynamic, dynamic> results = {};

    for (ShiftManageModel data in datas) {
      int allCnt = 0;
      for (var element in data.shifts) {
        if (element.shiftType == constShiftRequest ||
            element.shiftType == constShiftMeReply ||
            element.shiftType == constShiftApply ||
            element.shiftType == constShiftMeApply) allCnt++;
      }
      if (allCnt == data.count) {
        for (var item in data.shifts) {
          String staffId = item.staffId;
          String? shiftType;
          shiftType = getResponseShiftStatus(item.shiftType, 'equal');

          if (shiftType == null) continue;
          globals.saveControlShifts.add({
            'staff_id': staffId,
            'from_time':
                DateFormat('yyyy-MM-dd HH:mm:ss').format(data.fromTime),
            'to_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.toTime),
            'shift_type': shiftType
          });
        }
        continue;
      }

      results = await Webservice().loadHttp(context, apiAutoControlShift, {
        'organ_id': organId,
        'from_time': fromTime,
        'to_time': toTime,
        'in_from_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.fromTime),
        'in_to_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.toTime),
        'type': allCnt > data.count ? 'over' : 'mistake'
      });

      //     print(results);
      if (results['data'] == null) continue;

      int cnt = allCnt;

      for (var item in results['data']) {
        String staffId = item['staff_id'] ?? '';
        String? shiftType;

        var staffShifts =
            data.shifts.where((element) => element.staffId == staffId);
        if (cnt > data.count) {
          if (staffShifts.isEmpty) continue;
          shiftType =
              getResponseShiftStatus(staffShifts.first.shiftType, 'over');
        } else if (cnt < data.count) {
          if (staffShifts.isNotEmpty) {
            shiftType =
                getResponseShiftStatus(staffShifts.first.shiftType, 'mistake');
          } else {
            shiftType = constShiftRequest;
          }
        } else {
          if (staffShifts.isNotEmpty) {
            shiftType =
                getResponseShiftStatus(staffShifts.first.shiftType, 'equal');
          }
        }

        if (shiftType == null) continue;
        if (cnt < data.count) {
          cnt++;
        } else if (cnt > data.count) {
          cnt--;
        }

        globals.saveControlShifts.add({
          'staff_id': staffId,
          'from_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.fromTime),
          'to_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(data.toTime),
          'shift_type': shiftType
        });
        //if (cnt == data.count) break;
      }
    }

    return true;
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
