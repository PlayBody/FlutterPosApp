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
    staffs = await ClStaff().loadStaffs(context, {'organ_id': widget.organId});
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
      child: Column(
        children: [
          ...detailData.map((e) => _getRowContent(e)),
        ],
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
              child: Text(_subject, style: TextStyle(color: _color))),
          Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.3)))),
              alignment: Alignment.center,
              width: 60,
              child:
                  Text(_reserveStatus, style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 12),
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
        margin: EdgeInsets.symmetric(horizontal: 4),
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
