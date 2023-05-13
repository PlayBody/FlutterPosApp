import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/radios.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/components/timepicker.dart';

import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/model/shift_init_model.dart';

class DlgSettingInitShift extends StatefulWidget {
  final DateTime selection;
  final String organId;
  final String pattern;

  const DlgSettingInitShift({
    Key? key,
    required this.selection,
    required this.organId,
    required this.pattern,
  }) : super(key: key);

  @override
  State<DlgSettingInitShift> createState() => _DlgSettingInitShift();
}

class _DlgSettingInitShift extends State<DlgSettingInitShift> {
  String weekLabel = '';
  String fromTime = '';
  String toTime = '';
  String? settingId;

  String shiftType = constShiftSubmit;

  @override
  void initState() {
    super.initState();
    loadShift();
  }

  Future<void> loadShift() async {
    List<InitShiftModel> shifts = await ClShift().loadInitShifts(context, {
      'staff_id': globals.staffId,
      'organ_id': widget.organId,
      'pattern': widget.pattern,
      'weekday': widget.selection.weekday.toString(),
      'select_time': DateFormat('HH:mm:ss').format(widget.selection),
    });

    if (shifts.isNotEmpty) {
      fromTime = DateFormat('HH:mm')
          .format(DateTime.parse('2000-01-01 ${shifts.first.fromTime}'));
      toTime = DateFormat('HH:mm')
          .format(DateTime.parse('2000-01-01 ${shifts.first.toTime}'));
      settingId = shifts.first.id;
      shiftType = shifts.first.shiftType;
    } else {
      fromTime = DateFormat('HH:mm').format(widget.selection);
      if (widget.selection.hour >= 22) {
        toTime = '23:59';
      } else {
        toTime = DateFormat('HH:mm')
            .format(widget.selection.add(const Duration(hours: 2)));
      }
    }
    setState(() {});

    return;
  }

  Future<void> saveShift() async {
    String strFromTime = '$fromTime:00';
    String strToTime = toTime + (toTime == '23:59' ? ':59' : ':00');

    Dialogs().loaderDialogNormal(context);
    bool isSave = await ClShift().saveInitShift(context, {
      'staff_id': globals.staffId,
      'organ_id': widget.organId,
      'setting_id': settingId ?? '',
      'weekday': widget.selection.weekday.toString(),
      'from_time': strFromTime,
      'to_time': strToTime,
      'pattern': widget.pattern,
      'shift_type': shiftType.toString()
    });

    Navigator.of(context).pop();
    if (isSave) Navigator.of(context).pop();
  }

  Future<void> deleteShift() async {
    if (settingId == null) {
      Navigator.of(context).pop();
      return;
    }
    Dialogs().loaderDialogNormal(context);
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiDeleteInitShift, {
      'setting_id': settingId!,
    }).then((v) => {results = v});
    Navigator.of(context).pop();

    if (results['isDelete']) {
      Navigator.of(context).pop();
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  void onSelectType(_type) {
    shiftType = _type;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    for (var item in constWeeks) {
      if (item['key'] == DateFormat('E').format(widget.selection)) {
        weekLabel = item['val'];
      }
    }

    return PushDialogs(
        render: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const PosDlgHeaderText(label: 'シフト設定'),
        PosDlgSubHeaderText(label: weekLabel),
        _getTimeRow(),
        const SizedBox(height: 12),
        _getSubmitType(),
        const SizedBox(height: 24),
        _getButton(),
      ],
    ));
  }

  Widget _getTimeRow() {
    return PosTimeRange(
      selectDate: '2020-01-01',
      fromTime: fromTime,
      toTime: toTime,
      confFromFunc: (date) {
        fromTime = Funcs().getDurationTime(date, isShowSecond: false);
        setState(() {});
      },
      confToFunc: (date) {
        toTime = Funcs().getDurationTime(date, isShowSecond: false);
        setState(() {});
      },
    );
  }

  Widget _getSubmitType() {
    return Column(
      children: [
        _getSelectItem(constShiftSubmit, 'A 店内勤務'),
        const SizedBox(height: 8),
        _getSelectItem(constShiftOut, 'B 店外待機'),
        const SizedBox(height: 8),
        _getSelectItem(constShiftRest, 'C 休み'),
      ],
    );
  }

  Widget _getButton() {
    return Row(
      children: [
        PrimaryColButton(label: '保存する', tapFunc: () => saveShift()),
        const SizedBox(width: 12),
        DeleteColButton(
            label: '削除',
            tapFunc: settingId == null ? null : () => deleteShift()),
        const SizedBox(width: 12),
        CancelColButton(label: 'キャンセル', tapFunc: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _getSelectItem(v, label) => Container(
        padding: const EdgeInsets.only(left: 30),
        child: RadioNomal(
            value: v.toString(),
            groupValue: shiftType.toString(),
            tapFunc: () => onSelectType(v),
            label: label),
      );
}
