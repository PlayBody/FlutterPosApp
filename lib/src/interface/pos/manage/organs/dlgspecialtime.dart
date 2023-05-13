import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/functions/datetimes.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';

import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/components/timepicker.dart';

class DlgSpecialTime extends StatefulWidget {
  final String organId;
  final String? date;
  final String startTime;
  final String endTime;
  final String? timeId;
  final String type;
  const DlgSpecialTime(
      {required this.organId,
      this.date,
      required this.startTime,
      required this.endTime,
      this.timeId,
      required this.type,
      Key? key})
      : super(key: key);

  @override
  _DlgSpecialTime createState() => _DlgSpecialTime();
}

class _DlgSpecialTime extends State<DlgSpecialTime> {
  double _start = 0;
  double _end = 24;
  String _startTime = '';
  String _endTime = '';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.date != null) selectedDate = DateTime.parse(widget.date!);
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
    String apiUrl = apiBase + '/apiorgans/saveOrganSpecialTime';

    if (_startTime == '24:00') _startTime = '23:59:59';
    if (_endTime == '24:00') _endTime = '23:59:59';
    String from =
        DateFormat('yyyy-MM-dd').format(selectedDate) + ' ' + _startTime;
    String to = DateFormat('yyyy-MM-dd').format(selectedDate) + ' ' + _endTime;

    if (DateTime.parse(to).isBefore(DateTime.parse(from))) {
      Dialogs().infoDialog(context, '時間を正確に入力してください。');
      return;
    }

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'organ_id': widget.organId,
      'from_time': from,
      'to_time': to
    }).then((value) => results = value);
    if (results['isSave']) {
      Navigator.pop(context);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> saveShiftTime() async {
    String apiUrl = apiBase + '/apiorgans/saveOrganSpecialShiftTime';

    String from =
        DateFormat('yyyy-MM-dd').format(selectedDate) + ' ' + _startTime;
    String to = DateFormat('yyyy-MM-dd').format(selectedDate) + ' ' + _endTime;

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'time_id': widget.timeId,
      'from_time': from,
      'to_time': to
    }).then((value) => results = value);
    if (results['isSave']) {
      Navigator.pop(context);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> selectDateMove() async {
    final DateTime? selected = await showDatePicker(
      locale: const Locale("ja"),
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );

    if (selected != null && selected != selectedDate) {
      selectedDate = selected;
      setState(() {});
      // refreshLoad();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
      render: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PosDlgHeaderText(
              label: widget.type == 'bussiness' ? '特別営業日' : '勤務可能時間設定'),
          _getSelectDate(),
          SizedBox(height: 20),
          _getTimeRow(),
          // PosDlgSubHeaderText(label: _startTime + ' ~ ' + _endTime),
          RowButtonGroup(widgets: [
            SizedBox(width: 8),
            PrimaryColButton(
                label: '保存する',
                tapFunc: widget.type == 'bussiness'
                    ? () => saveOrganTime()
                    : () => saveShiftTime()),
            SizedBox(width: 8),
            CancelColButton(
                label: 'キャンセル', tapFunc: () => Navigator.of(context).pop())
          ]),
        ],
      ),
    );
  }

  Widget _getSelectDate() {
    return Row(
      children: [
        Expanded(child: Container()),
        Container(
            child: SubHeaderText(
                label: DateTimes()
                    .convertJPYMDFromDateTime(selectedDate, isFull: true))),
        IconButton(
            onPressed: () => selectDateMove(),
            icon: Icon(Icons.calendar_today, color: Colors.blue)),
        Expanded(child: Container()),
      ],
    );
  }

  Widget _getTimeRow() {
    return PosTimeRange(
      selectDate: '2020-01-01',
      fromTime: _startTime,
      toTime: _endTime,
      confFromFunc: (date) {
        _startTime =
            Funcs().getDurationTime(date, duration: 30, isShowSecond: false);
        setState(() {});
      },
      confToFunc: (date) {
        _endTime =
            Funcs().getDurationTime(date, duration: 30, isShowSecond: false);
        setState(() {});
      },
    );
  }
}
