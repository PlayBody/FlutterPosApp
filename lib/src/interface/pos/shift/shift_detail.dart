// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/orders.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/business/staffs.dart';
import 'package:staff_pos_app/src/common/functions.dart';

import 'package:staff_pos_app/src/interface/components/buttons.dart';

import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/model/order_model.dart';
import 'package:staff_pos_app/src/model/shift_model.dart';
import 'package:staff_pos_app/src/model/stafflistmodel.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'dlg_shift_time_edit.dart';

class ShiftDetail extends StatefulWidget {
  final String shiftCount;
  final String organId;
  final DateTime from;
  final DateTime to;
  const ShiftDetail(
      {required this.shiftCount,
      required this.organId,
      required this.from,
      required this.to,
      Key? key})
      : super(key: key);

  @override
  State<ShiftDetail> createState() => _ShiftDetail();
}

class _ShiftDetail extends State<ShiftDetail> {
  late Future<List> loadData;

  List<ShiftModel> shifts = [];
  List<StaffListModel> staffs = [];
  List<OrderModel> orders = [];

  List<Map<String, dynamic>> detailData = [];
  String fromDate = '';
  String toDate = '';

  @override
  void initState() {
    super.initState();

    fromDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.from);
    toDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.to);
    loadData = loadInitData();
  }

  Future<List> loadInitData() async {
    staffs = await ClStaff().loadStaffs(context, {'organ_id': widget.organId});
    shifts = await ClShift().loadShifts(context, {
      'organ_id': widget.organId,
      'in_from_time': fromDate,
      'in_to_time': toDate
    });

    // shift update: from auto control shift

    for (var e in globals.saveShiftFromAutoControl) {
      if (e.fromTime.day != DateTime.parse(fromDate).day) {
        continue;
      } else {
        if (e.shiftId == '-1') {
          shifts.add(e);
        } else {
          for (int i = 0; i < shifts.length; i++) {
            if (shifts[i].shiftId == e.shiftId &&
                shifts[i].staffId == e.staffId &&
                shifts[i].organId == e.organId) {
              shifts[i] = e;
              break;
            }
          }
        }
      }
    }

    orders = await ClOrder().loadOrderList(context, {
      'organ_id': widget.organId,
      'in_from_time': fromDate,
      'in_to_time': toDate
    });

    detailData = [];
    for (var sta in staffs) {
      Map<String, dynamic> data = {};
      data['staff_name'] = sta.staffNick != ''
          ? sta.staffNick
          : ('${sta.staffFirstName} ${sta.staffLastName}');
      data['staff_id'] = sta.staffId;
      data['auth'] = sta.auth;
      data['staff_shift'] = sta.staffShift;
      ShiftModel? tempShift =
          shifts.where((element) => element.staffId == sta.staffId).isNotEmpty
              ? shifts.where((element) => element.staffId == sta.staffId).first
              : null;
      if (tempShift != null) {
        data['shift_id'] = tempShift.shiftId;
        data['date'] = DateFormat('yyyy-MM-dd').format(tempShift.fromTime);
        data['from_time'] = DateFormat('HH:mm').format(tempShift.fromTime);
        data['to_time'] = DateFormat('HH:mm').format(tempShift.toTime);
        data['shift_type'] = tempShift.shiftType;
        data['limit_from_time'] = DateFormat('HH:mm').format(widget.from);
        data['limit_to_time'] = DateFormat('HH:mm').format(widget.to);
      }
      var searchReserves =
          orders.where((element) => element.staffId == sta.staffId);
      if (searchReserves.isNotEmpty) {
        data['reserve_type'] = searchReserves.first.status;
      }
      detailData.add(data);
    }
    // 정렬기준: 신청, 재요청, 강제요청, 자체승인은 우선.
    // 우선시 시작시간순으로 정렬해서 보여준다.
    // 빈 사람들은 그다음.
    // 다음 나머지.
    detailData.sort((m1, m2) {
      int ss = -((m1['staff_shift'] ?? 0).compareTo(m2['staff_shift'] ?? 0));
      if (ss == 0) {
        List<String> reqs = ['1', '5', '7', '9', '10', '2', '3', '4', '6'];
        var st1 = m1['shift_type'];
        var st2 = m2['shift_type'];
        if (st1 == null) {
          if (st2 == null) {
            return m1['staff_id'].compareTo(m2['staff_id']);
          } else {
            if (reqs.contains(st2)) {
              return 1;
            } else {
              return -1;
            }
          }
        } else {
          if (st2 == null) {
            if (reqs.contains(st1)) {
              return -1;
            } else {
              return 1;
            }
          } else {
            if (st1.compareTo(st2) != 0) {
              int aa, bb;
              aa = reqs.indexOf(st1);
              bb = reqs.indexOf(st2);
              return aa == bb
                  ? 0
                  : aa < bb
                      ? -1
                      : 1;
            }
            if (m1['from_time'] != null && m2['from_time'] != null) {
              return m1['from_time'].compareTo(m2['from_time']);
            }
            return m1['staff_id'].compareTo(m2['staff_id']);
          }
        }
      } else {
        return ss;
      }
    });

    setState(() {});
    return [];
  }

  Future<void> changeTimeZone(_index, e) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgShiftTimeEdit(
            shiftId: e['shift_id'],
            selectDate: e['date'],
            fromTime: e['from_time'],
            toTime: e['to_time'],
            limitFromTime: e['limit_from_time'],
            limitToTime: e['limit_to_time'],
          );
        }).then((_) => loadInitData());
  }

  void onTapClose() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _getBodyContent();
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _getBodyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 36),
        _getTitleContent(),
        Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.5)))),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('シフト枠     ${widget.shiftCount}'),
        ),
        _getContents(),
      ],
    );
  }

  Widget _getTitleContent() {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          const Text('シフト詳細'),
          Expanded(
              child: Container(
                  alignment: Alignment.center,
                  child: Column(children: [
                    Text(Funcs().dateFormatJP1(
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.from))),
                    Text(DateFormat('HH:mm').format(widget.from) +
                        ' ~ ' +
                        DateFormat('HH:mm').format(widget.to))
                  ]))),
          IconButton(
              onPressed: () => onTapClose(), icon: const Icon(Icons.close))
        ],
      ),
    );
  }

  Widget _getContents() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...detailData.map((e) => _getRowContent(e)),
          ],
        ),
      ),
    );
  }

  Widget _getRowContent(e) {
    var _appointments = constShiftAppoints[e['shift_type']];
    String _subject = '';
    var _color = Colors.black;
    if (_appointments != null) {
      if (_appointments['subject'] != null)
        _subject = _appointments['subject']!;
      if (_appointments['color'] != null)
        _color = Color(int.parse(_appointments['color']!));
    }
    String _shiftType = e['shift_type'] == null ? '' : e['shift_type'];
    var _search = globals.saveControlShifts.where((element) =>
        element['staff_id'] == e['staff_id'] &&
        element['from_time'] == fromDate &&
        element['to_time'] == toDate);
    var _saveRow = _search.length > 0 ? _search.first : null;

    String _changeType = '';
    int? _index;
    if (_saveRow != null) {
      _changeType = _saveRow['shift_type'];
      _index = globals.saveControlShifts.indexOf(_saveRow);
    }

    String _reserveStatus = '';
    if (e['reserve_type'] != null && e['reserve_type'] == constReserveRequest)
      _reserveStatus = '予約申込';

    if (e['reserve_type'] != null && e['reserve_type'] == constReserveApply)
      _reserveStatus = '予約済み';

    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.5)))),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        child: Row(children: [
          Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.3)))),
              width: MediaQuery.of(context).size.width * 0.3,
              child: Text('${e['staff_name']} (${e['staff_shift']})')),
          Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.3)))),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.2,
              child: Text(_subject, style: TextStyle(color: _color))),
          // Container(
          //     decoration: BoxDecoration(
          //         border: Border(
          //             right: BorderSide(color: Colors.grey.withOpacity(0.3)))),
          //     alignment: Alignment.center,
          //     width: 100,
          //     child: Text(_subject, style: TextStyle(color: _color))),
          GestureDetector(
            onTap: e['from_time'] != null
                ? () {
                    changeTimeZone(_index, e);
                  }
                : null,
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.3)))),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.25 - 20,
              child: Text(
                e['from_time'] != null
                    ? '${e['from_time']} ~ ${e['to_time']}'
                    : '',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    decoration: TextDecoration.underline),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (_shiftType == constShiftSubmit || _shiftType == constShiftReject)
            _getIconButtonItem(Icons.check, Colors.green, constShiftApply,
                _changeType, _index, e['staff_id']),
          if (_shiftType == constShiftMeReply ||
              _shiftType == constShiftMeApply)
            _getIconButtonItem(Icons.close, Colors.red, constShiftMeReject,
                _changeType, _index, e['staff_id']),
          if (_shiftType == constShiftMeReply)
            _getIconButtonItem(Icons.check, Colors.green, constShiftMeApply,
                _changeType, _index, e['staff_id']),
          if (_shiftType == constShiftMeApply)
            const Icon(Icons.check, color: Colors.orange),
          if (_shiftType == constShiftSubmit || _shiftType == constShiftApply)
            _getIconButtonItem(Icons.close, Colors.red, constShiftReject,
                _changeType, _index, e['staff_id']),
          if (_shiftType == constShiftOut ||
              _shiftType == '' ||
              _shiftType == constShiftRest)
            _getIconButtonItem(Icons.send, Colors.blue, constShiftRequest,
                _changeType, _index, e['staff_id']),
          if (_shiftType == constShiftRequest)
            _getIconButtonItem(Icons.close, Colors.red, constShiftMeReject,
                _changeType, _index, e['staff_id']),
          // _getIconButtonItem(Icons.cancel, Colors.orange, '0', _changeType,
          //     _index, e['staff_id']),
        ]));
  }

  Widget _getIconButtonItem(icon, color, trueValue, value, index, staffId) =>
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 25,
        child: IconWhiteButton(
          icon: icon,
          backColor: trueValue == value ? Colors.grey : null,
          color: trueValue == value ? Colors.white : color,
          tapFunc: () => onTapAction(trueValue, value, index, staffId),
        ),
      );

  void onTapAction(trueValue, value, index, staffId) {
    if (trueValue == value && index == null) return;
    if (index == null) {
      globals.saveControlShifts.add({
        'staff_id': staffId,
        'from_time': fromDate,
        'to_time': toDate,
        'shift_type': trueValue
      });
    } else {
      if (trueValue == value) {
        globals.saveControlShifts.removeAt(index);
      } else {
        globals.saveControlShifts.elementAt(index)['shift_type'] = trueValue;
      }
    }
    print(globals.saveControlShifts);
    setState(() {});
  }
}
