import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/functions/datetimes.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/radios.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/components/timepicker.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DlgShiftSubmit extends StatefulWidget {
  final DateTime selection;
  final String organId;
  final bool isLock;

  const DlgShiftSubmit({
    Key? key,
    required this.selection,
    required this.organId,
    required this.isLock,
  }) : super(key: key);

  @override
  _DlgShiftSubmit createState() => _DlgShiftSubmit();
}

class _DlgShiftSubmit extends State<DlgShiftSubmit> {
  String fromTime = '';
  String toTime = '';
  String? shiftId;
  String selectDate = '';
  int shiftType = 1;
  double _start = 0;
  double _end = 24;

  @override
  void initState() {
    super.initState();

    loadShift();
  }

  Future<void> loadShift() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadShiftStatus, {
      'staff_id': globals.staffId,
      'organ_id': widget.organId,
      'select_datetime':
          DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.selection),
    }).then((v) => {results = v});

    if (results['isLoad']) {
      if (results['status'] == '0') {
        if (results['count_shift'] != null) {
          fromTime = DateFormat('HH:mm:ss')
              .format(DateTime.parse(results['count_shift']['from_time']));
          toTime = DateFormat('HH:mm:ss')
              .format(DateTime.parse(results['count_shift']['to_time']));
        } else {
          fromTime = DateFormat('HH:mm:ss').format(widget.selection);
          if (widget.selection.hour >= 22) {
            toTime = '23:59:59';
          } else {
            toTime = DateFormat('HH:mm:ss')
                .format(widget.selection.add(Duration(hours: 2)));
          }
        }
      } else {
        fromTime = DateFormat('HH:mm:ss')
            .format(DateTime.parse(results['shift']['from_time']));
        toTime = DateFormat('HH:mm:ss')
            .format(DateTime.parse(results['shift']['to_time']));
        shiftId = results['shift']['shift_id'];
        shiftType = int.parse(results['shift']['shift_type']);
      }
      selectDate = DateFormat('yyyy-MM-dd').format(widget.selection);

      _start = double.parse(fromTime.split(':')[0]) +
          double.parse(fromTime.split(':')[1]) / 60;
      _end = double.parse(toTime.split(':')[0]) +
          double.parse(toTime.split(':')[1]) / 60;
    }
    setState(() {});
    return;
  }

  Future<void> saveShift() async {
    if (fromTime == '') return;
    if (toTime == '') return;
    Map<dynamic, dynamic> results = {};
    Dialogs().loaderDialogNormal(context);
    await Webservice().loadHttp(context, apiSubmitShiftStatus, {
      'shift_id': this.shiftId == null ? '' : shiftId,
      'staff_id': globals.staffId,
      'organ_id': widget.organId,
      'from_time': selectDate + ' ' + fromTime,
      'to_time':
          selectDate + ' ' + (toTime == '24:00:00' ? '23:59:59' : toTime),
      'shift_type': shiftType.toString(),
    }).then((v) => {results = v});
    Navigator.pop(context);

    if (results['isUpdate']) {
      Navigator.pop(context);
    } else {
      if (results['msg'] == 'area_error') {
        Dialogs().infoDialog(context, errShiftTimeAreaErr);
      } else if (results['msg'] == 'exist_error') {
        Dialogs().infoDialog(context, errShiftTimeDuplicateErr);
      } else {
        Dialogs().infoDialog(context, errServerActionFail);
      }
    }
  }

  Future<void> deleteShift() async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;

    if (shiftId == null) {
      Navigator.of(context).pop();
      return;
    }
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiDeleteShift, {
      'shift_id': shiftId!,
    }).then((v) => {results = v});

    if (results['isDelete']) {
      Navigator.of(context).pop();
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  void sliderChange(v) {
    _start = v.start;
    _end = v.end;
    fromTime = DateTimes().convertTimeFromDouble(_start);
    toTime = DateTimes().convertTimeFromDouble(_end);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
        render: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PosDlgHeaderText(label: 'シフト設定'),
        PosDlgSubHeaderText(label: selectDate),
        if (shiftType != 6) _getTimeRow(),
        SizedBox(height: 12),
        if (shiftType == 1 || shiftType == -3 || shiftType == 6)
          _getSubmitType(),
        SizedBox(height: 26),
        _getButtons(),
      ],
    ));
  }

  Widget _getTimeRow() {
    return PosTimeRange(
      selectDate: selectDate,
      fromTime: fromTime,
      toTime: toTime,
      confFromFunc: (date) {
        fromTime = Funcs().getDurationTime(date);
        setState(() {});
      },
      confToFunc: (date) {
        toTime = Funcs().getDurationTime(date);
        setState(() {});
      },
    );
  }

  Widget _getSubmitType() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 30),
          child: RadioNomal(
            value: '1',
            groupValue: shiftType.toString(),
            tapFunc: () {
              shiftType = 1;
              setState(() {});
            },
            label: 'A店内勤務',
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.only(left: 30),
          child: RadioNomal(
            value: '-3',
            groupValue: shiftType.toString(),
            tapFunc: () {
              shiftType = -3;
              setState(() {});
            },
            label: 'B店外待機',
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.only(left: 30),
          child: RadioNomal(
            value: '6',
            groupValue: shiftType.toString(),
            tapFunc: () {
              shiftType = 6;
              setState(() {});
            },
            label: 'C休み',
          ),
        ),
      ],
    );
  }

  Widget _getButtons() {
    return Container(
      child: Row(children: [
        PrimaryColButton(
            label: '保存する',
            tapFunc: (shiftId != null && (shiftType > 1 || widget.isLock))
                ? null
                : () => saveShift()),
        Container(width: 12),
        DeleteColButton(
            label: '削除',
            tapFunc: (shiftId == null || (shiftType > 1 || widget.isLock))
                ? null
                : () => deleteShift()),
        Container(width: 12),
        CancelColButton(label: 'キャンセル', tapFunc: () => Navigator.pop(context)),
      ]),
    );
  }
}
