import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/radios.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/components/timepicker.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/model/shift_count_model.dart';
import 'package:staff_pos_app/src/model/shift_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DlgShiftEdit extends StatefulWidget {
  final DateTime selection;
  final String organId;
  final bool isLock;

  const DlgShiftEdit({
    Key? key,
    required this.selection,
    required this.organId,
    required this.isLock,
  }) : super(key: key);

  @override
  State<DlgShiftEdit> createState() => _DlgShiftEdit();
}

class _DlgShiftEdit extends State<DlgShiftEdit> {
  String fromTime = '';
  String toTime = '';
  String? shiftId;
  String selectDate = '';
  String shiftType = constShiftSubmit;
  String oldType = "";
  bool isApply = false;

  @override
  void initState() {
    super.initState();

    loadInitData();
  }

  Future<void> loadInitData() async {
    selectDate = DateFormat('yyyy-MM-dd').format(widget.selection);

    List<ShiftModel> shifts = await ClShift().loadShifts(context, {
      'organ_id': widget.organId,
      'staff_id': globals.staffId,
      'select_datetime':
          DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.selection)
    });

    if (shifts.isNotEmpty) {
      fromTime = DateFormat('HH:mm').format(shifts.first.fromTime);
      toTime = DateFormat('HH:mm').format(shifts.first.toTime);
      shiftId = shifts.first.shiftId;
      shiftType = shifts.first.shiftType;
    } else {
      List<ShiftCountModel> counts =
          // ignore: use_build_context_synchronously
          await ClShift().loadshiftCountList(context, {
        'organ_id': widget.organId,
        'select_time':
            DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.selection)
      });

      if (counts.isNotEmpty) {
        fromTime = DateFormat('HH:mm').format(counts.first.fromTime);
        toTime = DateFormat('HH:mm').format(counts.first.toTime);
      } else {
        fromTime = DateFormat('HH:mm').format(widget.selection);
        if (widget.selection.hour >= 22) {
          toTime = '23:59';
        } else {
          toTime = DateFormat('HH:mm')
              .format(widget.selection.add(const Duration(hours: 2)));
        }
      }
    }
    isApply = shiftType == constShiftApply;
    setState(() {});
    return;
  }

  Future<void> saveShift() async {
    Dialogs().loaderDialogNormal(context);
    if (fromTime == '') return;
    if (toTime == '') return;

    String strfromTime = '$fromTime:00';
    String strtoTime = toTime + (toTime == '23:59' ? ':59' : ':00');

    DateTime fromDateTime = DateTime.parse('$selectDate $strfromTime');
    DateTime toDateTime = DateTime.parse('$selectDate $strtoTime');
    if (fromDateTime.compareTo(toDateTime) >= 0) {
      Fluttertoast.showToast(msg: '開始時間は完了時間を超えることはできません。');
      return;
    }

    bool isSave = await ClShift().saveStaffInputShift(context, {
      'shift_id': shiftId ?? '',
      'staff_id': globals.staffId,
      'organ_id': widget.organId,
      'from_time': '$selectDate $strfromTime',
      'to_time': '$selectDate $strtoTime',
      'shift_type': shiftType
    });

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    if (isSave) Navigator.pop(context);
  }

  Future<void> deleteShift() async {
    if (shiftId == null) return;
    Dialogs().loaderDialogNormal(context);
    bool isDelete = await ClShift().deleteShift(context, shiftId);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    if (isDelete) Navigator.pop(context);
  }

  void onSelectType(varType) {
    oldType = shiftType;
    shiftType = varType;
    setState(() {});
  }

  void setDateFromSelect(varType, date) {
    String strtime = Funcs().getDurationTime(date, isShowSecond: false);
    if (varType == 'from') fromTime = strtime;
    if (varType == 'to') toTime = strtime;
    setState(() {});
  }

  bool isSaveEnable() {
    if (widget.isLock && !isShowRequestType()) return false;
    //if (shiftType == constShiftApply) return false;
    return true;
  }

  bool isDeleteEnable() {
    if (widget.isLock) return false;
    if (oldType == constShiftRequest ||
        oldType == constShiftMeReply ||
        oldType == constShiftMeReject) return false;
    // if (shiftType == constShiftApply) return false;
    if (shiftType == constShiftRequest) return false;
    if (shiftType == constShiftMeReply) return false;
    if (shiftId == null) return false;
    return true;
  }

  bool isEditTimeEnable() {
    if (widget.isLock) return false;
    //if (shiftType == constShiftApply) return false;
    if (shiftType == constShiftRequest) return false;
    if (shiftType == constShiftRest) return false;
    return true;
  }

  bool isShowSubmitType() {
    if (oldType == constShiftRequest ||
        oldType == constShiftMeReply ||
        oldType == constShiftMeReject) return false;
    // if (widget.isLock) return false;
    if (shiftType == constShiftSubmit) return true;
    if (shiftType == constShiftApply) return true;
    if (shiftType == constShiftOut) return true;
    if (shiftType == constShiftRest) return true;
    if (shiftType == constShiftReject) return true;
    return false;
  }

  bool isShowRequestType() {
    if (oldType == constShiftRequest ||
        oldType == constShiftMeReply ||
        oldType == constShiftMeReject) {
      return true;
    }
    // if (widget.isLock) return false;
    if (shiftType == constShiftRequest) return true;
    if (shiftType == constShiftMeReply) return true;
    if (shiftType == constShiftMeReject) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
        render: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const PosDlgHeaderText(label: 'シフト設定'),
        PosDlgSubHeaderText(label: selectDate),
        if (shiftType != constShiftRest) _getTimeRow(),
        const SizedBox(height: 12),
        if (isShowSubmitType()) _getSubmitType(),
        if (isShowRequestType()) _getRequestType(),
        const SizedBox(height: 26),
        _getButtons(),
      ],
    ));
  }

  Widget _getTimeRow() {
    return PosTimeRange(
      selectDate: selectDate,
      fromTime: fromTime,
      toTime: toTime,
      confFromFunc: !isEditTimeEnable()
          ? null
          : (date) => setDateFromSelect('from', date),
      confToFunc:
          !isEditTimeEnable() ? null : (date) => setDateFromSelect('to', date),
    );
  }

  Widget _getSubmitType() {
    return Column(
      children: [
        if (isApply) _getSelectItem(constShiftApply, '承認済み'),
        const SizedBox(height: 8),
        _getSelectItem(constShiftSubmit, 'A 店内勤務'),
        const SizedBox(height: 8),
        _getSelectItem(constShiftOut, 'B 店外待機'),
        const SizedBox(height: 8),
        _getSelectItem(constShiftRest, 'C 休み'),
      ],
    );
  }

  Widget _getRequestType() {
    return Column(
      children: [
        _getSelectItem(constShiftMeReply, '了承'),
        const SizedBox(height: 8),
        _getSelectItem(constShiftMeReject, '拒否'),
        //   _getSelectItem(constShiftOut, 'B 店外待機'),
        //   SizedBox(height: 8),
        //   _getSelectItem(constShiftMeApply, '回答済み'),
      ],
    );
  }

  Widget _getButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
        children: [
      PrimaryColButton(
          label: '保存する', tapFunc: !isSaveEnable() || isApply  ? null : () => saveShift()),
      Container(width: 12),
      DeleteColButton(
          label: '削除', tapFunc: !isDeleteEnable() || isApply  ? null : () => deleteShift()),
      // const DeleteColButton(
      //     label: '削除', tapFunc: null),
      Container(width: 12),
      CancelColButton(label: 'キャンセル', tapFunc: () => Navigator.pop(context)),
    ]);
  }

  Widget _getSelectItem(v, label) => Container(
        padding: const EdgeInsets.only(left: 30),
        child: RadioNomal(
            value: v,
            groupValue: shiftType.toString(),
            tapFunc: () => onSelectType(v),
            label: label),
      );
}
