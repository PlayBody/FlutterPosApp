import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/functions/datetimes.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/components/timepicker.dart';

class DlgSettingCountShift extends StatefulWidget {
  final DateTime selection;
  final String organId;
  final int selMax;

  const DlgSettingCountShift({
    Key? key,
    required this.selection,
    required this.organId,
    required this.selMax,
  }) : super(key: key);

  @override
  _DlgSettingCountShift createState() => _DlgSettingCountShift();
}

class _DlgSettingCountShift extends State<DlgSettingCountShift> {
  String weekLabel = '';
  String fromTime = '';
  String toTime = '';
  String? settingId;
  String? sCount;
  double _start = 0;
  double _end = 24;

  @override
  void initState() {
    super.initState();
    loadShift();
  }

  Future<void> loadShift() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadCountShiftStatus, {
      'organ_id': widget.organId,
      'select_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.selection),
    }).then((v) => {results = v});
    if (results['isLoad']) {
      setState(() {
        if (results['status'] == '0') {
          fromTime = DateTimes().convertTimeFromDateTime(widget.selection);
          toTime =
              DateTimes().convertTimeFromDateTimeAddHour(widget.selection, 1);
        } else {
          fromTime =
              DateTimes().convertTimeFromString(results['shift']['from_time']);
          toTime =
              DateTimes().convertTimeFromString(results['shift']['to_time']);

          settingId = results['shift']['id'];

          sCount = results['shift']['count'];
        }
        _start = double.parse(fromTime.split(':')[0]) +
            double.parse(fromTime.split(':')[1]) / 60;
        _end = double.parse(toTime.split(':')[0]) +
            double.parse(toTime.split(':')[1]) / 60;
      });
    }
    return;
  }

  Future<void> saveShift() async {
    if (sCount == null) {
      Dialogs().infoDialog(context, 'シフト枠を選択します。');
      return;
    }
    // if (fromTime.isAfter(toTime)) {
    //   Dialogs().infoDialog(context, 'シフト枠を正確に入力してください。');
    //   return;
    // }
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiSaveCountShift, {
      'organ_id': widget.organId,
      'setting_id': settingId == null ? '' : settingId,
      'select_date': DateFormat('yyyy-MM-dd').format(widget.selection),
      'from_time': fromTime,
      'to_time': toTime,
      'count': sCount
    }).then((v) => {results = v});

    if (results['isUpdate']) {
      Navigator.of(context).pop();
    } else {
      if (results['err'] == 'active_err') {
        Dialogs().infoDialog(context, errShiftTimeActiveErr);
      } else if (results['err'] == 'duplicate_err') {
        Dialogs().infoDialog(context, errShiftTimeDuplicateErr);
      } else {
        Dialogs().infoDialog(context, errServerActionFail);
      }
    }
  }

  Future<void> deleteShift() async {
    if (settingId == null) {
      Navigator.of(context).pop();
      return;
    }
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiDeleteCountShift, {
      'setting_id': settingId!,
    }).then((v) => {results = v});

    if (results['isDelete']) {
      Navigator.of(context).pop();
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  void onChangeSlider(v) {
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
      children: [
        PosDlgHeaderText(label: 'シフト枠設定'),
        PosDlgSubHeaderText(
            label: DateFormat('yyyy-MM-dd').format(widget.selection)),
        _getTimeRow(),
        SizedBox(height: 12),
        RowLabelInput(
            hMargin: 30,
            label: 'シフト枠',
            renderWidget: DropDownNumberSelect(
                value: sCount,
                max: widget.selMax,
                tapFunc: (v) => sCount = v!.toString())),
        SizedBox(height: 12),
        _getButtons(),
      ],
    ));
  }

  Widget _getTimeRow() {
    return PosTimeRange(
      selectDate: DateFormat('yyyy-MM-dd').format(widget.selection),
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

  Widget _getButtons() {
    return Row(
      children: [
        PrimaryColButton(label: '保存する', tapFunc: () => saveShift()),
        SizedBox(width: 12),
        DeleteColButton(
            label: '削除',
            tapFunc: settingId == null ? null : () => deleteShift()),
        SizedBox(width: 12),
        CancelButton(label: 'キャンセル', tapFunc: () => Navigator.pop(context)),
      ],
    );
  }
}
