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

class ShiftDetailPannel extends StatefulWidget {
  final String shiftCount;
  final String organId;
  final DateTime from;
  final DateTime to;
  const ShiftDetailPannel(
      {required this.shiftCount,
      required this.organId,
      required this.from,
      required this.to,
      Key? key})
      : super(key: key);

  @override
  State<ShiftDetailPannel> createState() => _ShiftDetailPannel();
}

class _ShiftDetailPannel extends State<ShiftDetailPannel> {
  late Future<List> loadData;

  List<ShiftModel> shifts = [];
  List<StaffListModel> staffs = [];
  List<OrderModel> orders = [];

  List<dynamic> detailData = [];
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
    shifts = await ClShift().loadShifts(context, {
      'organ_id': widget.organId,
      'in_from_time': fromDate,
      'in_to_time': toDate
    });

    orders = await ClOrder().loadOrderList(context, {
      'organ_id': widget.organId,
      'in_from_time': fromDate,
      'in_to_time': toDate
    });

    detailData = [];
    staffs.forEach((_staff) {
      var _data = {};
      _data['staff_name'] = _staff.staffNick != ''
          ? _staff.staffNick
          : (_staff.staffFirstName! + ' ' + _staff.staffLastName!);
      _data['staff_id'] = _staff.staffId;
      ShiftModel? _shift = shifts
                  .where((element) => element.staffId == _staff.staffId)
                  .length >
              0
          ? shifts.where((element) => element.staffId == _staff.staffId).first
          : null;
      if (_shift != null) {
        // _data['from_time'] =
        //     DateFormat('yyyy-MM-dd HH:mm:ss').format(_shift.fromTime);
        // _data['to_time'] =
        //     DateFormat('yyyy-MM-dd HH:mm:ss').format(_shift.toTime);
        _data['shift_type'] = _shift.shiftType;
      }

      var _searchReserves =
          orders.where((element) => element.staffId == _staff.staffId);
      if (_searchReserves.length > 0) {
        _data['reserve_type'] = _searchReserves.first.status;
      }

      detailData.add(_data);
    });
    setState(() {});
    return [];
  }

  void onTapClose() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Text(
                        '${DateFormat('HH:mm').format(widget.from)} ~ ${DateFormat('HH:mm').format(widget.to)}')
                  ]))),
          IconButton(
              onPressed: () => onTapClose(), icon: const Icon(Icons.close))
        ],
      ),
    );
  }

  Widget _getContents() {
    return Expanded(
      child: Column(
        children: [
          ...detailData.map((e) => _getRowContent(e)),
        ],
      ),
    );
  }

  Widget _getRowContent(e) {
    var appointments = constShiftAppoints[e['shift_type']];
    String subject = '';
    var colorText = Colors.black;
    if (appointments != null) {
      if (appointments['subject'] != null) {
        subject = appointments['subject']!;
      }
      if (appointments['color'] != null) {
        colorText = Color(int.parse(appointments['color']!));
      }
    }
    String shiftType = e['shift_type'] ?? ''; // == null ? '' : e['shift_type'];
    var search = globals.saveControlShifts.where((element) =>
        element['staff_id'] == e['staff_id'] &&
        element['from_time'] == fromDate &&
        element['to_time'] == toDate);
    var saveRow = search.isNotEmpty ? search.first : null;

    String changeType = '';
    int? index;
    if (saveRow != null) {
      changeType = saveRow['shift_type'];
      index = globals.saveControlShifts.indexOf(saveRow);
    }

    String reserveStatus = '';
    if (e['reserve_type'] != null && e['reserve_type'] == constReserveRequest) {
      reserveStatus = '予約申込'; // 예약신청.
    }

    if (e['reserve_type'] != null && e['reserve_type'] == constReserveApply) {
      reserveStatus = '予約済み'; // 예약됨.
    }

    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.5)))),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(children: [
          Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.3)))),
              width: 100,
              child: Text(e['staff_name'])),
          Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.3)))),
              alignment: Alignment.center,
              width: 100,
              child: Text(subject, style: TextStyle(color: colorText))),
          Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.3)))),
              alignment: Alignment.center,
              width: 60,
              child: Text(reserveStatus, style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 12),
          if (shiftType == constShiftSubmit || shiftType == constShiftReject)
            _getIconButtonItem(Icons.check, Colors.green, constShiftApply,
                changeType, index, e['staff_id']),
          if (shiftType == constShiftMeReply || shiftType == constShiftMeApply)
            _getIconButtonItem(Icons.close, Colors.red, constShiftMeReject,
                changeType, index, e['staff_id']),
          if (shiftType == constShiftMeReply)
            _getIconButtonItem(Icons.check, Colors.green, constShiftMeApply,
                changeType, index, e['staff_id']),
          if (shiftType == constShiftMeApply)
            const Icon(Icons.check, color: Colors.orange),
          if (shiftType == constShiftSubmit || shiftType == constShiftApply)
            _getIconButtonItem(Icons.close, Colors.red, constShiftReject,
                changeType, index, e['staff_id']),
          if (shiftType == constShiftOut ||
              shiftType == '' ||
              shiftType == constShiftRest)
            _getIconButtonItem(Icons.send, Colors.blue, constShiftRequest,
                changeType, index, e['staff_id']),
          if (shiftType == constShiftRequest)
            _getIconButtonItem(Icons.close, Colors.red, constShiftMeReject,
                changeType, index, e['staff_id']),
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
    // print(globals.saveControlShifts);
    setState(() {});
  }
}
