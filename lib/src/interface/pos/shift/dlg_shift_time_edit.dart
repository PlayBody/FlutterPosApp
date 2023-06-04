import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions/time_util.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/components/timepicker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/model/shift_model.dart';

class DlgShiftTimeEdit extends StatefulWidget {
  final String shiftId;
  final String fromTime;
  // final String limitFromTime;
  // final String limitToTime;
  final String toTime;
  final String selectDate;

  //Coded By PSG
  final int uniqueId;
  final String staffId;
  final String organId;
  final String shiftType;

  const DlgShiftTimeEdit(
      {Key? key,
      required this.shiftId,
      required this.selectDate,
      required this.fromTime,
      required this.toTime,
      required this.uniqueId,
      required this.staffId,
      required this.organId,
      required this.shiftType})
      : super(key: key);

  @override
  State<DlgShiftTimeEdit> createState() => _DlgShiftTimeEdit();
}

class _DlgShiftTimeEdit extends State<DlgShiftTimeEdit> {
  String selectedFromTime = '';
  String selectedToTime = '';

  @override
  void initState() {
    super.initState();

    selectedFromTime = widget.fromTime;
    selectedToTime = widget.toTime;
  }

  void setDateFromSelect(varType, date) {
    // String strtime = Funcs().getDurationTime(date, isShowSecond: false);
    String strtime = DateFormat('HH:mm').format(date);
    if (varType == 'from') {
      selectedFromTime = strtime;
    } else if (varType == 'to') {
      selectedToTime = strtime;
    }
    // DateTime _date = DateTime.parse('${widget.selectDate} ' + strtime);
    // DateTime limitFromDate =
    //     DateTime.parse('${widget.selectDate} ' + widget.limitFromTime);
    // DateTime limitToDate =
    //     DateTime.parse('${widget.selectDate} ' + widget.limitToTime);
    // if (varType == 'from') {
    //   if (_date.compareTo(limitFromDate) >= 0 &&
    //       _date.compareTo(limitToDate) < 0) {
    //     selectedFromTime = strtime;
    //   } else {
    //     Fluttertoast.showToast(msg: 'シフト時間範囲で設定してください。');
    //   }
    // }
    // if (varType == 'to') {
    //   if (_date.compareTo(limitFromDate) >= 0 &&
    //       _date.compareTo(limitToDate) <= 0) {
    //     selectedToTime = strtime;
    //   } else {
    //     Fluttertoast.showToast(msg: 'シフト時間範囲で設定してください。');
    //   }
    // }
    setState(() {});
  }

  Future<void> saveShiftTime() async {
    DateTime fromDateTime =
        DateTime.parse('${widget.selectDate} ' + selectedFromTime);
    DateTime toDateTime =
        DateTime.parse('${widget.selectDate} ' + selectedToTime);
    if (fromDateTime.compareTo(toDateTime) >= 0) {
      Fluttertoast.showToast(msg: '開始時間は完了時間を超えることはできません。');
      return;
    }
    Dialogs().loaderDialogNormal(context);
    String strFrom = '${widget.selectDate} $selectedFromTime';
    String strTo = '${widget.selectDate} $selectedToTime';

    // await ClShift().forceSaveShift(context, widget.staffId, widget.organId,
    //     widget.shiftId, strFrom, strTo, widget.shiftType);

    if (widget.uniqueId >= 0) {
      //await ClShift().updateShiftTime(context, widget.shiftId, strFrom, strTo);
      for (int i = 0; i < globals.saveShiftFromAutoControl.length; i++) {
        if (globals.saveShiftFromAutoControl[i].uniqueId == widget.uniqueId) {
          globals.saveShiftFromAutoControl[i].fromTime =
              DateTime.parse(strFrom);
          globals.saveShiftFromAutoControl[i].toTime = DateTime.parse(strTo);
        }
      }
    } else {
      globals.saveShiftFromAutoControl.add(ShiftModel(
          shiftId: widget.shiftId,
          organId: widget.organId,
          staffId: widget.staffId,
          fromTime: DateTime.parse(strFrom),
          toTime: DateTime.parse(strTo),
          shiftType: widget.shiftType,
          uniqueId: WorkControl.getGenCounter()));
    }
    Navigator.of(context).pop();
    Navigator.pop(context, '');
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
        render: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const PosDlgHeaderText(label: '時間設定'),
        _getTimeRow(),
        const SizedBox(
          height: 10,
        ),
        _getButtons(),
      ],
    ));
  }

  Widget _getTimeRow() {
    return PosTimeRange(
      selectDate: widget.selectDate,
      fromTime: selectedFromTime,
      toTime: selectedToTime,
      confFromFunc: (date) => setDateFromSelect('from', date),
      confToFunc: (date) => setDateFromSelect('to', date),
    );
  }

  Widget _getButtons() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      PrimaryColButton(label: '設定', tapFunc: () => saveShiftTime()),
      Container(width: 12),
      CancelColButton(label: 'キャンセル', tapFunc: () => Navigator.pop(context)),
    ]);
  }
}
