import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/messages.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/components/timepicker.dart';

class DlgShiftApply extends StatefulWidget {
  final String selectDate;
  final String fromTime;
  final String toTime;
  final String shiftId;
  final String updateType;
  const DlgShiftApply({
    required this.selectDate,
    required this.fromTime,
    required this.toTime,
    required this.shiftId,
    required this.updateType,
    Key? key,
  }) : super(key: key);

  @override
  _DlgShiftApply createState() => _DlgShiftApply();
}

class _DlgShiftApply extends State<DlgShiftApply> {
  String _from = '';
  String _to = '';

  @override
  void initState() {
    super.initState();
    loadInit();
  }

  void loadInit() {
    _from = widget.fromTime;
    _to = widget.toTime;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
        render: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PosDlgHeaderText(
            label: widget.updateType == '3' ? '出勤要請を承認しますか？' : '出勤要請を拒否しますか？'),
        PosDlgSubHeaderText(label: widget.selectDate),
        if (widget.updateType == '3')
          PosTimeRange(
              selectDate: widget.selectDate,
              fromTime: _from,
              toTime: _to,
              confFromFunc: (date) {
                _from = Funcs().getDurationTime(date, isShowSecond: true);
                setState(() {});
              },
              confToFunc: (date) {
                _to = Funcs().getDurationTime(date, isShowSecond: true);
                setState(() {});
              }),
        RowButtonGroup(widgets: [
          PrimaryButton(
            label: 'はい',
            tapFunc: () => applyRequestShift(),
          ),
          SizedBox(width: 16),
          CancelButton(
            label: 'いいえ',
            tapFunc: () => Navigator.pop(context),
          ),
        ]),
      ],
    ));
  }

  Future<void> applyRequestShift() async {
    DateTime updateFrom = DateTime.parse(widget.selectDate + ' ' + _from);
    DateTime updateTo = DateTime.parse(widget.selectDate + ' ' + _to);
    DateTime requestFrom =
        DateTime.parse(widget.selectDate + ' ' + widget.fromTime);
    DateTime requestTo =
        DateTime.parse(widget.selectDate + ' ' + widget.toTime);

    if (updateFrom.isBefore(requestFrom) || updateTo.isAfter(requestTo)) {
      Dialogs().infoDialog(context, '申請された時間範囲で入力してください。');
      return;
    }
    if (updateTo.isBefore(updateFrom)) {
      Dialogs().infoDialog(context, '時間範囲を正確に入力してください。');
      return;
    }

    Dialogs().loaderDialogNormal(context);
    bool isUpdate = await ClShift().applyOrRejectRequestShift(
        context,
        widget.shiftId,
        widget.selectDate + ' ' + _from,
        widget.selectDate + ' ' + _to,
        widget.updateType);

    Navigator.pop(context);
    if (isUpdate) {
      Navigator.pop(context);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }
}
