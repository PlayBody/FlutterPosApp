import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions/datetimes.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/pos/shifts/dlgshiftmanager.dart';
import 'package:staff_pos_app/src/interface/pos/shifts/shiftday.dart';
import 'package:staff_pos_app/src/interface/style/style_const.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/shift_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';

class ShiftManager extends StatefulWidget {
  final String initOrgan;
  final DateTime initDate;
  const ShiftManager(
      {required this.initOrgan, required this.initDate, Key? key})
      : super(key: key);

  @override
  _ShiftManager createState() => _ShiftManager();
}

class _ShiftManager extends State<ShiftManager> {
  late Future<List> loadData;
  String orderAmount = '';
  String dateYearValue = '2020';
  String dateMonthValue = '5';
  DateTime selectedDate = DateTime.now();
  bool isLock = false;

  List<TimeRegion> regions = <TimeRegion>[];
  List<Appointment> appointments = <Appointment>[];

  String? selOrganId;
  List<OrganModel> organList = [];

  String _fromDate = '';
  String _toDate = '';
  String mode = '';

  Color shiftColor = Colors.white;
  String shiftText = '';

  bool loadStatus = false;

  List<TimeRegion> selectRegions = <TimeRegion>[];
  List<ShiftSumModel> shiftSums = [];

  bool isHideBannerBar = false;
  int viewFromHour = 0;
  int viewToHour = 0;

  var shiftCounts = [];

  @override
  void initState() {
    selOrganId = widget.initOrgan;
    selectedDate = widget.initDate;
    super.initState();
    loadData = loadShiftData();
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<List> loadShiftData() async {
    loadStatus = true;
    _fromDate = DateFormat('yyyy-MM-dd').format(getDate(
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1))));
    _toDate = DateFormat('yyyy-MM-dd').format(selectedDate
        .add(Duration(days: DateTime.daysPerWeek - selectedDate.weekday)));

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadShiftManage, {
      'staff_id': globals.staffId,
      'organ_id': selOrganId == null ? globals.organId : selOrganId,
      'from_date': _fromDate,
      'to_date': _toDate
    }).then((v) => {results = v});

    organList = [];
    regions = [];
    appointments = [];
    if (results['isLoad']) {
      for (var item in results['organ_list']) {
        organList.add(OrganModel.fromJson(item));
      }
      setRegions(results);
      shiftCounts = results['shift_counts'];
      globals.organShifts = results['shifts'];
      clacCountingShift();
      //setApppointment(results);
    }
    regions = [];
    if (!DateTime.parse(_toDate + ' 23:59:59').isBefore(DateTime.now())) {
      regions = await ClShift()
          .loadActiveShiftRegions(context, selOrganId!, _fromDate);
    }

    if (regions.length > 0) {
      viewFromHour = 23;
      viewToHour = 0;
      regions.forEach((element) {
        if (viewFromHour > element.startTime.hour)
          viewFromHour = element.startTime.hour;
        if (viewToHour < element.endTime.hour)
          viewToHour = element.endTime.hour;
      });
      viewToHour++;
    }
    isLock =
        await ClShift().loadShiftLock(context, selOrganId!, _fromDate, _toDate);

    setState(() {});
    return regions;
  }

  Future<void> viewShift(_date) async {
    var _start;
    var _end;
    for (var item in shiftSums) {
      if (_date.isBefore(DateTime.parse(item.fromTime)) ||
          _date.isAfter(DateTime.parse(item.toTime))) continue;

      _start = DateTime.parse(item.fromTime);
      _end = DateTime.parse(item.toTime);
    }
    if (_start == null || _end == null) return;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgShiftManager(
            organId: selOrganId!,
            selection: _date,
            selectionFrom: _start,
            selectionTo: _end,
            // shiftSums: shiftSums,
          );
        }).then((_) {
      clacCountingShift();
      setState(() {});
    });
  }

  void changeViewCalander(_date) {
    String _cFromDate = DateFormat('yyyy-MM-dd')
        .format(getDate(_date.subtract(Duration(days: _date.weekday - 1))));

    if (_cFromDate == _fromDate) return;

    selectedDate = _date;

    refreshLoad();
  }

  Future<void> refreshLoad() async {
    Dialogs().loaderDialogNormal(context);
    await loadShiftData();
    Navigator.pop(context);
  }

  void setRegions(results) {
    if (DateTime.parse(_toDate + ' 23:59:59').isBefore(DateTime.now())) return;

    var firstDate = DateFormat('yyyy-MM-dd').format(getDate(
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1))));

    for (var item in results['shift_times']) {
      var _startDate = DateTime.parse(firstDate + ' ' + item['from_time'])
          .add(Duration(days: int.parse(item['weekday']) - 1));
      var _endDate = DateTime.parse(firstDate + ' ' + item['to_time'])
          .add(Duration(days: int.parse(item['weekday']) - 1));
      regions.add(TimeRegion(
          startTime: _startDate,
          endTime: _endDate,
          enablePointerInteraction: true,
          // recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
          color: Color(0xffffc3bf), //shiftOrganDisableColor,
          text: ''));
    }
  }

  void setApppointment(results) {
    if (results['divide_shift'] == null) return;
    for (var item in results['divide_shift']) {
      var shiftColor = Colors.blue;
      if (item['exist_count'].toString() != item['count'].toString())
        shiftColor = Colors.yellow;
      appointments.add(Appointment(
        startTime: DateTime.parse(item['from']),
        endTime: DateTime.parse(item['to']),
        subject:
            item['exist_count'].toString() + '/' + item['count'].toString(),
        color: shiftColor,
        startTimeZone: '',
        endTimeZone: '',
      ));
    }
  }

  Future<void> sendRequestNotification() async {
    if (selOrganId == null) return;
    bool conf = await Dialogs().confirmDialog(context, 'シフト入力を促しますか？');
    if (!conf) return;

    Dialogs().loaderDialogNormal(context);
    bool isSend = await ClShift()
        .sendRequestInput(context, selOrganId!, _fromDate, _toDate);

    Navigator.pop(context);

    if (isSend) {
      Dialogs().infoDialog(context, 'シフト入力を要請しました。');
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> autoControl() async {
    Dialogs().loaderDialogNormal(context);

    for (var element in shiftSums) {
      if (int.parse(element.count) < int.parse(element.shiftCount)) {
        await calcOverFlow(element);
      }
      if (int.parse(element.count) > int.parse(element.shiftCount)) {
        await calcMistake(element);
      }
    }

    Navigator.pop(context);
  }

  Future<void> calcOverFlow(element) async {
    var ctlCnt = int.parse(element.shiftCount) - int.parse(element.count);
    for (var item in globals.organShifts) {
      if (int.parse(item['shift_type']) < 1) continue;
      Map<dynamic, dynamic> resultsStaff = {};
      await Webservice().loadHttp(context, apiLoadStaffInfoUrl,
          {'staff_id': item['staff_id']}).then((value) => resultsStaff = value);
      int hopeShiftTime = resultsStaff['staff_shift'] == null
          ? 0
          : int.parse(resultsStaff['staff_shift']);

      var sumTimes = 0;

      Map<dynamic, dynamic> resultOther = {};
      await Webservice().loadHttp(context, apiLoadShiftOtherOrganExistUrl, {
        'staff_id': item['staff_id'],
        'cur_organ_id': selOrganId,
        'from_time': element.fromTime,
        'to_time': element.toTime
      }).then((value) => resultOther = value);
      sumTimes = sumTimes + int.parse(resultOther['all_time'].toString());

      for (var eshift in globals.organShifts) {
        if (eshift['staff_id'] != item['staff_id']) continue;
        var _to = DateTime.parse(eshift['to_time']);
        if (_to.second == 59) _to = _to.add(Duration(seconds: 1));
        sumTimes = sumTimes +
            (_to.difference(DateTime.parse(eshift['from_time'])).inMinutes);
      }
      item['diff'] = sumTimes - hopeShiftTime * 60;
    }
    globals.organShifts.sort((a, b) {
      if (a['diff'] == null) a['diff'] = 0;
      if (b['diff'] == null) b['diff'] = 0;
      return b['diff'].compareTo(a['diff']);
    });
    for (var item in globals.organShifts) {
      if (DateTime.parse(element.fromTime)
              .isBefore(DateTime.parse(item['from_time'])) ||
          DateTime.parse(element.toTime)
              .isAfter(DateTime.parse(item['to_time']))) continue;
      if (item['diff'] > 0) {
        ctlCnt--;
        if (item['shift_type'] == '5')
          item['shift_type'] = '-5';
        else
          item['shift_type'] = '-4';
      }
      if (ctlCnt == 0) break;
    }
    var tmp = [];

    for (var item in globals.organShifts) {
      if (int.parse(item['shift_type']) > -5) tmp.add(item);
    }

    globals.organShifts = tmp;
  }

  Future<void> calcMistake(element) async {
    var ctlCnt = int.parse(element.count) - int.parse(element.shiftCount);

    var tmp = [];
    //reserve staff
    Map<dynamic, dynamic> resultsReserveStaff = {};
    await Webservice().loadHttp(context, apiLoadReserveStaffsUrl, {
      'from_time': element.fromTime,
      'to_time': element.toTime,
      'organ_id': selOrganId
    }).then((value) => resultsReserveStaff = value);
    if (resultsReserveStaff['isLoad']) {
      for (var item in resultsReserveStaff['staffs']) {
        if (ctlCnt < 1) continue;
        bool isReject =
            await isStaffReject(item, element.fromTime, element.toTime);
        if (isReject) continue;
        bool isExist = false;
        for (var tmpShift in globals.organShifts) {
          if (tmpShift['staff_id'] != item) continue;
          var _iFrom = DateTime.parse(element.fromTime);
          var _iTo = DateTime.parse(element.toTime);
          var _tFrom = DateTime.parse(tmpShift['from_time']);
          var _tTo = DateTime.parse(tmpShift['to_time']);
          if (((_tFrom == _iFrom || _tFrom.isAfter(_iFrom)) &&
                  (_tFrom.isBefore(_iTo))) ||
              ((_tTo.isAfter(_iFrom)) &&
                  (_tTo == _iTo || _tTo.isBefore(_iTo)))) {
            isExist = true;
            break;
          }
        }
        if (isExist) continue;
        ctlCnt--;
        tmp.add({
          'staff_id': item,
          'from_time': element.fromTime,
          'to_time': element.toTime,
          'shift_type': '5'
        });
      }
    }

    for (var item in tmp) {
      globals.organShifts.add(item);
    }

    //Nextの仕事があるスタッフの検索
    tmp = [];
    if (ctlCnt < 1) return;
    //以前の仕事があるスタッフの検索
    for (var item in globals.organShifts) {
      tmp.add(item);
      if (ctlCnt < 1) continue;
      if (int.parse(item['shift_type']) < 1) continue;
      bool isReject = await isStaffReject(
          item['staff_id'], element.fromTime, element.toTime);
      if (isReject) continue;

      var _to = DateTime.parse(item['to_time']);
      if (_to.second == 59) _to = _to.add(Duration(seconds: 1));
      if (_to == DateTime.parse(element.fromTime)) {
        bool isExist = false;
        for (var tmpShift in globals.organShifts) {
          if (tmpShift['staff_id'] != item['staff_id']) continue;
          var _iFrom = DateTime.parse(element.fromTime);
          var _iTo = DateTime.parse(element.toTime);
          var _tFrom = DateTime.parse(tmpShift['from_time']);
          var _tTo = DateTime.parse(tmpShift['to_time']);
          if (((_tFrom == _iFrom || _tFrom.isAfter(_iFrom)) &&
                  (_tFrom.isBefore(_iTo))) ||
              ((_tTo.isAfter(_iFrom)) &&
                  (_tTo == _iTo || _tTo.isBefore(_iTo)))) {
            isExist = true;
            break;
          }
        }
        if (isExist) continue;
        Map<dynamic, dynamic> resultOther = {};
        await Webservice().loadHttp(context, apiLoadShiftOtherOrganExistUrl, {
          'staff_id': item['staff_id'],
          'cur_organ_id': selOrganId,
          'from_time': element.fromTime,
          'to_time': element.toTime
        }).then((value) => resultOther = value);
        if (int.parse(resultOther['all_time'].toString()) > 0) continue;
        ctlCnt--;
        tmp.add({
          'staff_id': item['staff_id'],
          'from_time': element.fromTime,
          'to_time': element.toTime,
          'shift_type': '5'
        });
      }
    }
    globals.organShifts = tmp;
    //Nextの仕事があるスタッフの検索

    if (ctlCnt < 1) return;
    tmp = [];
    for (var item in globals.organShifts) {
      tmp.add(item);
      if (ctlCnt < 1) continue;
      if (int.parse(item['shift_type']) < 1) continue;
      bool isReject = await isStaffReject(
          item['staff_id'], element.fromTime, element.toTime);
      if (isReject) continue;
      var _to = DateTime.parse(element.toTime);
      if (_to.second == 59) _to = _to.add(Duration(seconds: 1));
      if (_to == DateTime.parse(item['from_time'])) {
        bool isExist = false;
        for (var tmpShift in globals.organShifts) {
          if (tmpShift['staff_id'] != item['staff_id']) continue;
          var _iFrom = DateTime.parse(element.fromTime);
          var _iTo = DateTime.parse(element.toTime);
          var _tFrom = DateTime.parse(tmpShift['from_time']);
          var _tTo = DateTime.parse(tmpShift['to_time']);
          if (((_tFrom == _iFrom || _tFrom.isAfter(_iFrom)) &&
                  (_tFrom.isBefore(_iTo))) ||
              ((_tTo.isAfter(_iFrom)) &&
                  (_tTo == _iTo || _tTo.isBefore(_iTo)))) {
            isExist = true;
            break;
          }
        }
        if (isExist) continue;
        Map<dynamic, dynamic> resultOther = {};
        await Webservice().loadHttp(context, apiLoadShiftOtherOrganExistUrl, {
          'staff_id': item['staff_id'],
          'cur_organ_id': selOrganId,
          'from_time': element.fromTime,
          'to_time': element.toTime
        }).then((value) => resultOther = value);
        if (int.parse(resultOther['all_time'].toString()) > 0) continue;
        ctlCnt--;
        tmp.add({
          'staff_id': item['staff_id'],
          'from_time': element.fromTime,
          'to_time': element.toTime,
          'shift_type': '5'
        });
      }
    }
    globals.organShifts = tmp;
    if (ctlCnt < 1) return;
    //getStaffList
    Map<dynamic, dynamic> resultstaff = {};
    await Webservice().loadHttp(context, apiLoadShiftStatusManage, {
      'organ_id': selOrganId,
    }).then((v) => {resultstaff = v});

    tmp = [];
    for (var item in resultstaff['staffs']) {
      if (ctlCnt < 1) continue;
      bool isReject = await isStaffReject(
          item['staff_id'], element.fromTime, element.toTime);
      if (isReject) continue;
      bool isExist = false;
      // same Time Exist
      for (var tmpShift in globals.organShifts) {
        if (tmpShift['staff_id'] != item['staff_id']) continue;
        var _iFrom = DateTime.parse(element.fromTime);
        var _iTo = DateTime.parse(element.toTime);
        var _tFrom = DateTime.parse(tmpShift['from_time']);
        var _tTo = DateTime.parse(tmpShift['to_time']);
        if (((_tFrom == _iFrom || _tFrom.isAfter(_iFrom)) &&
                (_tFrom.isBefore(_iTo))) ||
            ((_tTo.isAfter(_iFrom)) && (_tTo == _iTo || _tTo.isBefore(_iTo)))) {
          isExist = true;
          break;
        }
      }

      if (isExist) continue;

      //otherOrgan same Time exist
      Map<dynamic, dynamic> resultOther = {};
      await Webservice().loadHttp(context, apiLoadShiftOtherOrganExistUrl, {
        'staff_id': item['staff_id'],
        'cur_organ_id': selOrganId,
        'from_time': element.fromTime,
        'to_time': element.toTime
      }).then((value) => resultOther = value);
      if (int.parse(resultOther['all_time'].toString()) > 0) continue;

      //getHopeTime
      Map<dynamic, dynamic> resultstaffinfo = {};
      await Webservice().loadHttp(context, apiLoadStaffInfoUrl, {
        'staff_id': item['staff_id']
      }).then((value) => resultstaffinfo = value);
      int hopeShiftTime = resultstaffinfo['staff_shift'] == null
          ? 0
          : int.parse(resultstaffinfo['staff_shift']);

      //getAllTime;
      var sumTimes = 0;

      await Webservice().loadHttp(context, apiLoadShiftOtherOrganExistUrl, {
        'staff_id': item['staff_id'],
        'cur_organ_id': selOrganId,
        'from_time': _fromDate + ' 00:00:00',
        'to_time': _toDate + ' 23:59:59'
      }).then((value) => resultOther = value);
      sumTimes = sumTimes + int.parse(resultOther['all_time'].toString());

      for (var eshift in globals.organShifts) {
        if (eshift['staff_id'] != item['staff_id']) continue;
        var _to = DateTime.parse(eshift['to_time']);
        if (_to.second == 59) _to = _to.add(Duration(seconds: 1));
        sumTimes = sumTimes +
            (_to.difference(DateTime.parse(eshift['from_time'])).inMinutes);
      }

      if (sumTimes >= hopeShiftTime) continue;
      ctlCnt--;
      tmp.add({
        'staff_id': item['staff_id'],
        'from_time': element.fromTime,
        'to_time': element.toTime,
        'shift_type': '5'
      });
    }
    for (var item in tmp) {
      globals.organShifts.add(item);
    }
  }

  Future<bool> isStaffReject(String staffId, fromTime, toTime) async {
    List<ShiftModel> shifts = await ClShift().loadShiftsByCondition(context, {
      'organ_id': selOrganId,
      'staff_id': staffId,
      'from_time': fromTime,
      'to_time': toTime,
      'shift_type': '-3'
    });
    return shifts.length > 0;
  }

  void clacCountingShift() {
    appointments = [];
    shiftSums = [];
    for (var item in shiftCounts) {
      List<DateTime> timeList = [];
      timeList.add(DateTime.parse(item['from_time']));
      timeList.add(DateTime.parse(item['to_time']));
      for (var shift in globals.organShifts) {
        if (DateTime.parse(shift['from_time'])
                .isBefore(DateTime.parse(item['from_time'])) ||
            DateTime.parse(shift['to_time'])
                .isAfter(DateTime.parse(item['to_time']))) continue;
        if (!timeList.contains(DateTime.parse(shift['from_time']))) {
          timeList.add(DateTime.parse(shift['from_time']));
        }
        if (!timeList.contains(DateTime.parse(shift['to_time']))) {
          timeList.add(DateTime.parse(shift['to_time']));
        }
      }
      timeList.sort((a, b) => a.compareTo(b));
      var _start;
      for (var timeItem in timeList) {
        if (_start != null) {
          int n = 0;
          int m = 0;
          for (var shift in globals.organShifts) {
            if (DateTime.parse(shift['from_time']).isAfter(_start) ||
                DateTime.parse(shift['to_time']).isBefore(timeItem)) continue;
            if (int.parse(shift['shift_type']) > 0) n++;
            if (int.parse(shift['shift_type']) == 2) m++;
          }
          setApppointments(_start, timeItem, item['count'].toString(),
              n.toString(), m.toString());
          shiftSums.add(
            ShiftSumModel(
              fromTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(_start),
              toTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(timeItem),
              count: item['count'].toString(),
              shiftCount: n.toString(),
            ),
          );
        }
        _start = timeItem;
      }
    }
  }

  void setApppointments(_start, _end, count, shiftCount, applyCount) {
    var shiftColor = Colors.blue;
    if (count != applyCount) shiftColor = Colors.yellow;
    // regions
    //     .add(TimeRegion(startTime: _start, endTime: _end, color: shiftColor));

    appointments.add(Appointment(
      startTime: _start,
      endTime: _end,
      subject: shiftCount.toString() + '/' + count.toString(),
      color: shiftColor.withOpacity(.5),
      startTimeZone: '',
      endTimeZone: '',
    ));
  }

  Future<void> saveShiftComplete() async {
    Dialogs().loaderDialogNormal(context);
    Map<dynamic, dynamic> results = {};
    for (var item in globals.organShifts) {
      if (item['shift_type'] == '2') continue;
      if (item['shift_type'] == '4') continue;
      if (item['shift_type'] == '-3') continue;
      results = {};
      await Webservice().loadHttp(context, apiSaveShiftCompleteUrl, {
        'cur_staff_id': globals.staffId,
        'organ_id': selOrganId,
        'staff_id': item['staff_id'],
        'shift_id': item['shift_id'] == null ? '' : item['shift_id'],
        'shift_type': item['shift_type'],
        'from_time': item['from_time'],
        'to_time': item['to_time']
      }).then((value) => results = value);

      if (!results['isSave']) {
        await Dialogs().waitDialog(context, errServerActionFail);
        return;
      }
    }
    loadShiftData();
    Navigator.pop(context);
  }

  Future<void> lockUpdate(bool _isLock) async {
    Dialogs().loaderDialogNormal(context);
    bool isUpdate = await ClShift()
        .updateShiftLock(context, selOrganId!, _fromDate, _toDate, _isLock);
    Navigator.pop(context);

    if (!isUpdate) {
      Dialogs().infoDialog(context, errServerActionFail);
      return;
    }

    loadShiftData();
  }

  void pushShiftDay() {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ShiftDay(
          isEdit: true,
          initOrgan: this.selOrganId!,
          initDate: DateTime.parse(_fromDate));
    }));
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'シフト管理';
    return MainBodyWdiget(
        fullScreenButton: _fullScreenContent(),
        fullscreenTop: 60,
        isFullScreen: isHideBannerBar,
        render: LoadBodyWdiget(
          loadData: loadData,
          render: Container(
            color: bodyColor,
            child: Column(
              children: [
                _getTopContent(),
                Expanded(child: _getCalendar()),
                _getLockContent(),
                _getBottomButtons()
              ],
            ),
          ),
        ));
  }

  Widget _fullScreenContent() {
    return Column(children: [
      FullScreenButton(icon: Icons.refresh, tapFunc: () => refreshLoad()),
      FullScreenButton(
        icon: isHideBannerBar ? Icons.fullscreen_exit : Icons.fullscreen,
        tapFunc: () {
          isHideBannerBar = !isHideBannerBar;
          setState(() {});
        },
      )
    ]);
  }

  Widget _getTopContent() {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
        child: Row(children: [
          Expanded(
              child: SubHeaderText(
                  label: DateTimes().convertJPYMFromDateTime(selectedDate))),
          InputLeftText(label: '店名', rPadding: 8, width: 60),
          Flexible(
              child: DropDownModelSelect(
            value: selOrganId,
            items: [
              ...organList.map((e) => DropdownMenuItem(
                    child: Text(e.organName),
                    value: e.organId,
                  ))
            ],
            tapFunc: (v) {
              setState(() {
                selOrganId = v!.toString();
                refreshLoad();
              });
            },
          )),
        ]));
  }

  Widget _getCalendar() {
    return SfCalendar(
      firstDayOfWeek: 1,
      view: CalendarView.week,
      initialSelectedDate: selectedDate,
      initialDisplayDate: selectedDate,
      headerHeight: 0,
      selectionDecoration: timeSlotSelectDecoration,
      timeSlotViewSettings: TimeSlotViewSettings(
          startHour: viewFromHour.toDouble(),
          endHour: viewToHour.toDouble(),
          timeIntervalHeight: timeSlotCellHeight.toDouble(),
          dayFormat: 'EEE',
          timeInterval: Duration(minutes: 15),
          timeFormat: 'H:mm',
          timeTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black.withOpacity(0.5),
          )),
      appointmentTextStyle: apppointmentsTextStyle,
      specialRegions: regions,
      onLongPress: (d) => viewShift(d.date),
      onViewChanged: (d) => changeViewCalander(d.visibleDates[1]),
      dataSource: _AppointmentDataSource(appointments),
    );
  }

  Widget _getLockContent() {
    return Container(
      child: Row(
        children: [
          SizedBox(width: 8),
          WhiteButton(label: '入力要請', tapFunc: () => sendRequestNotification()),
          // SizedBox(width: 8),
          // WhiteButton(label: '詳細を見る', tapFunc: () => pushShiftDay()),
          Expanded(child: Container()),
          Text('ロック', style: btnTxtStyle),
          Container(
              child: Switch(
            value: isLock,
            onChanged: (v) => lockUpdate(v),
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          )),
          SizedBox(width: 20)
        ],
      ),
    );
  }

  Widget _getBottomButtons() {
    return RowButtonGroup(widgets: [
      PrimaryButton(label: '保存', tapFunc: () => saveShiftComplete()),
      SizedBox(width: 8),
      // PrimaryButton(
      //     label: '自動調整',
      //     tapFunc: () async {
      //       await autoControl();
      //       clacCountingShift();
      //       setState(() {});
      //     }),
      SizedBox(width: 8),
      CancelButton(label: '戻る', tapFunc: () => Navigator.pop(context)),
    ]);
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

class ShiftSumModel {
  final String fromTime;
  final String toTime;
  final String count;
  final String shiftCount;

  const ShiftSumModel(
      {required this.fromTime,
      required this.toTime,
      required this.count,
      required this.shiftCount});

  // factory ShiftSumModel.fromJson(Map<String, dynamic> json) {
  //   return ShiftSumModel(
  //     fromTime: json['data']['title'],
  //     toTime: json['ischeck'],
  //     count: json['position'].toString(),
  //     shiftCount: json['position'].toString(),
  //   );
  // }
}
