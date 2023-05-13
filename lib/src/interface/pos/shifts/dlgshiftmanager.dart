import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/shiftstaffmodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:flutter/material.dart';

class DlgShiftManager extends StatefulWidget {
  final DateTime selection;
  final DateTime selectionFrom;
  final DateTime selectionTo;
  final String organId;

  const DlgShiftManager({
    Key? key,
    required this.selection,
    required this.selectionFrom,
    required this.selectionTo,
    required this.organId,
  }) : super(key: key);

  @override
  _DlgShiftManager createState() => _DlgShiftManager();
}

class _DlgShiftManager extends State<DlgShiftManager> {
  List<ShiftStaffModel> list = [];
  DateTime? fromTime;
  DateTime? toTime;
  String? shiftId;
  String selectDate = '';

  @override
  void initState() {
    super.initState();
    loadShift();
  }

  Future<void> loadShift() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadShiftStatusManage, {
      'organ_id': widget.organId,
      'select_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.selection),
    }).then((v) => {results = v});
    list = [];
    for (var item in results['staffs']) {
      for (var shift in globals.organShifts) {
        if (widget.selectionFrom.isBefore(DateTime.parse(shift['from_time'])) ||
            widget.selectionTo.isAfter(DateTime.parse(shift['to_time'])))
          continue;

        if (item['staff_id'] != shift['staff_id']) continue;

        item['from_time'] = shift['from_time'];
        item['to_time'] = shift['to_time'];
        item['shift_type'] = shift['shift_type'];
        break;
      }

      // for (var shift in globals.organShifts) {
      //   if (item['from_time'] == shift['to_time']) {
      //     item['is_before'] = true;
      //     break;
      //   }

      //   if (item['to_time'] == shift['from_time']) {
      //     item['is_after'] = true;
      //     break;
      //   }
      // }
      list.add(ShiftStaffModel.fromJson(item));
    }

    setState(() {});
    return;
  }

  void editStaffShift(v, e) {
    if (v!) {
      var tmp = [];
      bool isAdd = false;
      for (var item in globals.organShifts) {
        if (int.parse(item['shift_type']) > 0) {
          tmp.add(item);
          continue;
        }
        if (item['staff_id'] != e.staffId) {
          tmp.add(item);
          continue;
        }
        if (widget.selectionFrom.isBefore(DateTime.parse(item['from_time'])) ||
            widget.selectionTo.isAfter(DateTime.parse(item['to_time']))) {
          tmp.add(item);
          continue;
        } else {
          isAdd = true;
          item['shift_type'] = '5';
          tmp.add(item);
        }
        // tmp.add(item);
      }
      if (!isAdd)
        globals.organShifts.add({
          'staff_id': e.staffId,
          'shift_type': '5',
          'from_time':
              DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.selectionFrom),
          'to_time':
              DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.selectionTo)
        });
    } else {
      var tmp = [];

      for (var item in globals.organShifts) {
        if (item['staff_id'] == e.staffId) {
          if (widget.selectionFrom
                  .isBefore(DateTime.parse(item['from_time'])) ||
              widget.selectionTo.isAfter(DateTime.parse(item['to_time']))) {
            tmp.add(item);
          } else {
            if (item['shift_id'] != null) {
              item['shift_type'] = '-4';
              tmp.add(item);
            }
          }
          // tmp.add(item);
        } else {
          tmp.add(item);
        }
        globals.organShifts = tmp;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        _getBody(),
      ],
    );
  }

  Widget _getBody() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 40, 10, 40),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
          ]),
      child: SingleChildScrollView(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _getDateLabel(),
          _getShiftList(),
          _getButtons(),
        ],
      )),
    );
  }

  Widget _getDateLabel() {
    return Container(
      padding: EdgeInsets.only(bottom: 15),
      child: Text(
        DateFormat('yyyy-MM-dd').format(widget.selection),
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _getShiftList() {
    return Column(children: [
      ...list.map((e) => Row(
            children: [
              Container(
                child: Checkbox(
                  value: int.parse(e.shiftType) > 0,
                  onChanged: (v) {
                    editStaffShift(v, e);
                    loadShift();
                  },
                ),
              ),
              Container(
                  width: 70,
                  child: Text(
                    e.staffName,
                    style: TextStyle(fontSize: 12),
                  )),
              Container(
                  width: 32,
                  child: Text(
                      e.fromTime == ''
                          ? ''
                          : Funcs()
                              .getTimeFormatHHMM(DateTime.parse(e.fromTime)),
                      style: TextStyle(fontSize: 12))),
              Container(width: 12, child: Text('~')),
              Container(
                  width: 32,
                  child: Text(
                      e.fromTime == ''
                          ? ''
                          : Funcs().getTimeFormatHHMM(DateTime.parse(e.toTime)),
                      style: TextStyle(fontSize: 12))),
              SizedBox(width: 10),
              if (e.shiftType == '1')
                Container(child: Text('申請中', style: TextStyle(fontSize: 12))),
              if (e.shiftType == '2')
                Container(child: Text('承認済み', style: TextStyle(fontSize: 12))),
              if (e.shiftType == '4')
                Container(child: Text('出勤要請', style: TextStyle(fontSize: 12))),
              if (e.shiftType == '3')
                Container(child: Text('回答済み', style: TextStyle(fontSize: 12))),
              if (e.shiftType == '5')
                Container(
                    child: Text('一時追加',
                        style: TextStyle(color: Colors.blue, fontSize: 12))),
              if (e.shiftType == '-2')
                Container(
                    child: Text('拒否',
                        style: TextStyle(color: Colors.red, fontSize: 12))),
              if (e.shiftType == '-4')
                Container(
                    child: Text('一時店外待機',
                        style: TextStyle(color: Colors.red, fontSize: 12))),
              if (e.shiftType == '-3')
                Container(
                    child: Text('店外待機',
                        style: TextStyle(color: Colors.red, fontSize: 12))),
            ],
          )),
    ]);
  }

  Widget _getButtons() {
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: Row(
        children: [
          Expanded(child: Container()),
          // ElevatedButton(
          //     onPressed: () => {},
          //     child: Text("保存する", style: TextStyle(fontSize: 14))),
          Container(width: 12),
          // ElevatedButton(
          //   onPressed: shiftId == null ? null : () {},
          //   child: Text("削除", style: TextStyle(fontSize: 14)),
          //   style: ElevatedButton.styleFrom(primary: Colors.red),
          // ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("閉じる", style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(primary: Colors.grey),
          ),
          Container(width: 24),
        ],
      ),
    );
  }
}
