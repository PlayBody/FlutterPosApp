import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';

import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/components/timepicker.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DlgOrderFromChange extends StatefulWidget {
  final String date;

  const DlgOrderFromChange({
    Key? key,
    required this.date,
  }) : super(key: key);

  @override
  _DlgOrderFromChange createState() => _DlgOrderFromChange();
}

class _DlgOrderFromChange extends State<DlgOrderFromChange> {
  DateTime _date = DateTime.now();
  @override
  void initState() {
    super.initState();
    _date = DateTime.parse(widget.date);
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
        render: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PosDlgHeaderText(label: qChangeInputTime),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                child: PosDlgSubHeaderText(
              label: '入店時間',
              bottomPadding: 0,
            )),
            PosTimePicker(
                date: DateFormat('HH:mm').format(_date),
                confFunc: (date) {
                  String _time = Funcs()
                      .getDurationTime(date, isShowSecond: false, duration: 5);
                  _date = DateTime.parse(
                      DateFormat('yyyy-MM-dd').format(_date) +
                          ' ' +
                          _time +
                          ':00');

                  setState(() {});
                })
          ],
        ),
        SizedBox(height: 24),
        _getButtons(),
      ],
    ));
  }

  Widget _getButtons() {
    return Container(
      child: Row(children: [
        Expanded(child: Container()),
        PrimaryColButton(
            label: '変更',
            tapFunc: () => Navigator.pop(
                context, DateFormat('yyyy-MM-dd HH:mm:ss').format(_date))),
        Container(width: 12),
        CancelColButton(label: 'キャンセル', tapFunc: () => Navigator.pop(context)),
      ]),
    );
  }
}
