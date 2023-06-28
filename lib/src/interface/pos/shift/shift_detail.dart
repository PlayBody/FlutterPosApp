// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/business/staffs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/functions/time_util.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';

import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/model/shift_model.dart';
import 'package:staff_pos_app/src/model/stafflistmodel.dart';
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

    DateTime from = DateTime.parse(fromDate);
    DateTime to = DateTime.parse(toDate);
    from = DateTime(from.year, from.month, from.day, 0, 0, 0);
    to = DateTime(to.year, to.month, to.day, 23, 59, 59);

    shifts = await ClShift().loadShifts(context, {
      'organ_id': widget.organId,
      'in_from_time': from.toString(),
      'in_to_time': to.toString()
    });

    shifts.removeWhere(
        (element) => element.fromTime.compareTo(element.toTime) >= 0);

    // shift update: from auto control shift

    for (var e in globals.saveShiftFromAutoControl) {
      if (e.fromTime.day != DateTime.parse(fromDate).day) {
        continue;
      } else {
        if (e.shiftId == '-1' || e.shiftId == '') {
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

    // orders = await ClOrder().loadOrderList(context, {
    //   'organ_id': widget.organId,
    //   'in_from_time': fromDate,
    //   'in_to_time': toDate
    // });

    detailData = [];
    for (var sta in staffs) {
      Map<String, dynamic> data = {};
      data['staff_name'] = sta.staffNick != ''
          ? sta.staffNick
          : ('${sta.staffFirstName} ${sta.staffLastName}');
      data['staff_id'] = sta.staffId;
      data['auth'] = sta.auth;
      data['staff_shift'] = sta.staffShift;
      List<ShiftModel> tempShiftList = shifts
              .where((element) => element.staffId == sta.staffId)
              .isNotEmpty
          ? shifts.where((element) => element.staffId == sta.staffId).toList()
          : [];
      data['shifts'] = [];
      if (tempShiftList.isNotEmpty) {
        for (var tempShift in tempShiftList) {
          var e = {};
          e['shift_id'] = tempShift.shiftId;
          e['date'] = DateFormat('yyyy-MM-dd').format(tempShift.fromTime);
          e['from_time'] = DateFormat('HH:mm').format(tempShift.fromTime);
          e['to_time'] = DateFormat('HH:mm').format(tempShift.toTime);
          e['shift_type'] = tempShift.shiftType;
          e['unique_id'] = tempShift.uniqueId;
          e['organ_id'] = tempShift.organId;
          e['staff_id'] = sta.staffId;
          e['from'] = tempShift.fromTime;
          e['to'] = tempShift.toTime;
          e['new_state'] = tempShift.metaType;
          if(tempShift.deleted == 1){
            continue;
          }
          data['shifts'].add(e);
        }
      }
      // var searchReserves =
      //     orders.where((element) => element.staffId == sta.staffId);
      // if (searchReserves.isNotEmpty) {
      //   data['reserve_type'] = searchReserves.first.status;
      // }
      detailData.add(data);
    }
    detailData.sort((m1, m2) {
      int ss = -((m1['staff_shift'] ?? 0).compareTo(m2['staff_shift'] ?? 0));
      if (ss == 0) {
        return m1['staff_id'].compareTo(m2['staff_id']);
      } else {
        return ss;
      }
    });

    setState(() {});
    return [];
  }

  Future<void> changeTimeZone(e) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgShiftTimeEdit(
            staffId: e['staff_id'],
            organId: e['organ_id'],
            shiftType: e['shift_type'],
            shiftId: e['shift_id'],
            selectDate: e['date'],
            fromTime: e['from_time'],
            toTime: e['to_time'],
            uniqueId: e['unique_id'],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: e['shifts'].isEmpty
                ? [_getRowContentOfOneStaff(e)]
                : [...e['shifts'].map((ee) => _getRowContentOfOneStaff(ee))],
          )
        ]));
  }

  Widget _getRowContentOfOneStaff(e) {
    var appointments = constShiftAppoints[e['shift_type']];
    String subject = '';
    var color = const Color.fromRGBO(0, 0, 0, 1);
    if (appointments != null) {
      if (appointments['subject'] != null) {
        subject = appointments['subject']!;
      }
      if (appointments['color'] != null) {
        color = Color(int.parse(appointments['color']!));
      }
    }
    String shiftType = e['shift_type'] ?? '';

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        alignment: Alignment.centerLeft,
        child: Row(children: [
          Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.3)))),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.2,
              child: Text(subject, style: TextStyle(color: color))),
          GestureDetector(
            onTap: e['from_time'] != null
                ? () {
                    changeTimeZone(e);
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
          if (shiftType == constShiftSubmit || shiftType == constShiftReject)
            _getIconButtonItem(Icons.check, Colors.green, constShiftApply, e),
          if (shiftType == constShiftMeReply || shiftType == constShiftMeApply)
            _getIconButtonItem(Icons.close, Colors.red, constShiftMeReject, e),
          if (shiftType == constShiftMeReply)
            _getIconButtonItem(Icons.check, Colors.green, constShiftMeApply, e),
          if (shiftType == constShiftMeApply)
            const Icon(Icons.check, color: Colors.orange),
          if (shiftType == constShiftSubmit || shiftType == constShiftApply)
            _getIconButtonItem(Icons.close, Colors.red, constShiftReject, e),
          if (shiftType == constShiftOut ||
              shiftType == '' ||
              shiftType == constShiftRest)
            _getIconButtonItem(Icons.send, Colors.blue, constShiftRequest, e),
          if (shiftType == constShiftRequest)
            _getIconButtonItem(Icons.close, Colors.red, constShiftMeReject, e),
        ]));
  }

  Widget _getIconButtonItem(icon, color, newState, e) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 25,
        child: IconWhiteButton(
          icon: icon,
          backColor: newState == e['new_state'] ? Colors.grey : null,
          color: newState == e['new_state'] ? Colors.white : color,
          tapFunc: () => onTapAction(newState, e),
        ),
      );

  void onTapAction(newState, e) {
    if (e['unique_id'] == null || e['unique_id'] == -1) {
      ShiftModel model = ShiftModel(
          staffId: e['staff_id'],
          organId: widget.organId,
          shiftId: e['shift_id'] ?? '',
          fromTime: e['from'] ?? widget.from,
          toTime: e['to'] ?? widget.to,
          shiftType: e['shift_type'] ?? '',
          uniqueId: WorkControl.getGenCounter());
      model.metaType = newState;
      globals.saveShiftFromAutoControl.add(model);
    } else {
      int index = globals.saveShiftFromAutoControl
          .indexWhere((element) => element.uniqueId == e['unique_id']);
      if (e['new_state'] != null && e['new_state'] == newState) {
        if (globals.saveShiftFromAutoControl[index].shiftType == '') {
          globals.saveShiftFromAutoControl.removeAt(index);
        } else {
          globals.saveShiftFromAutoControl[index].metaType = null;
        }
      } else {
        globals.saveShiftFromAutoControl[index].metaType = newState;
      }
    }
    loadInitData();
    setState(() {});
  }
}
