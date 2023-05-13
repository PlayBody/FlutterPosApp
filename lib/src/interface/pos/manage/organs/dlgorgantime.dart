import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';

import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';

class DlgOrganTime extends StatefulWidget {
  final String organId;
  final String weekday;
  final String startTime;
  final String endTime;
  final String? timeId;
  final String type;
  const DlgOrganTime(
      {required this.organId,
      required this.weekday,
      required this.startTime,
      required this.endTime,
      this.timeId,
      required this.type,
      Key? key})
      : super(key: key);

  @override
  _DlgOrganTime createState() => _DlgOrganTime();
}

class _DlgOrganTime extends State<DlgOrganTime> {
  double _start = 0;
  double _end = 24;
  String _startTime = '';
  String _endTime = '';

  @override
  void initState() {
    super.initState();
    _start = double.parse(widget.startTime.split(':')[0]) +
        double.parse(widget.startTime.split(':')[1]) / 60;
    _end = double.parse(widget.endTime.split(':')[0]) +
        double.parse(widget.endTime.split(':')[1]) / 60;
    _startTime = widget.startTime;
    _endTime = widget.endTime;
  }

  void setStringTime() {
    _startTime = (_start.toInt() < 10
            ? '0' + _start.toInt().toString()
            : _start.toInt().toString()) +
        ':' +
        (((_start - _start.toInt()) * 60).toInt() < 10
            ? '0' + ((_start - _start.toInt()) * 60).toInt().toString()
            : ((_start - _start.toInt()) * 60).toInt().toString());

    _endTime = (_end.toInt() < 10
            ? '0' + _end.toInt().toString()
            : _end.toInt().toString()) +
        ':' +
        (((_end - _end.toInt()) * 60).toInt() < 10
            ? '0' + ((_end - _end.toInt()) * 60).toInt().toString()
            : ((_end - _end.toInt()) * 60).toInt().toString());
  }

  Future<void> saveOrganTime() async {
    String apiUrl = apiBase + '/apiorgans/saveOrganTime';
    if (widget.type == 'shift')
      apiUrl = apiBase + '/apiorgans/saveOrganShiftTime';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'time_id': widget.timeId == null ? '' : widget.timeId,
      'organ_id': widget.organId,
      'weekday': widget.weekday,
      'from_time': _startTime,
      'to_time': _endTime
    }).then((value) => results = value);
    if (results['isSave']) {
      Navigator.pop(context);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
      render: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PosDlgHeaderText(
              label: widget.type == 'bussiness' ? '営業時間設定' : '勤務可能時間設定'),
          PosDlgSubHeaderText(label: _startTime + ' ~ ' + _endTime),
          RangeSlider(
            activeColor: Colors.blue,
            inactiveColor: Colors.blue[100],
            min: 0,
            max: 24,
            divisions: 48,
            onChanged: (v) {
              _start = v.start;
              _end = v.end;
              setStringTime();
              setState(() {});
            },
            values: RangeValues(_start, _end),
          ),
          RowButtonGroup(widgets: [
            SizedBox(width: 8),
            PrimaryColButton(label: '保存する', tapFunc: () => saveOrganTime()),
            SizedBox(width: 8),
            CancelColButton(
                label: 'キャンセル', tapFunc: () => Navigator.of(context).pop())
          ]),
        ],
      ),
    );
  }
}
