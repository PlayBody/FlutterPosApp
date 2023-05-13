import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions/shifts.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/pos/manage/shifts/dlgsettingcountshift.dart';
import 'package:staff_pos_app/src/interface/style/style_const.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';

class SettingShiftCount extends StatefulWidget {
  const SettingShiftCount({Key? key}) : super(key: key);

  @override
  _SettingShiftCount createState() => _SettingShiftCount();
}

class _SettingShiftCount extends State<SettingShiftCount> {
  late Future<List> loadData;
  String orderAmount = '';
  String dateYearValue = '2020';
  String dateMonthValue = '5';
  DateTime selectedDate = DateTime.now();

  List<TimeRegion> regions = <TimeRegion>[];
  List<Appointment> appointments = <Appointment>[];
  List<OrganModel> organList = [];

  String _fromDate = '';
  String _toDate = '';
  String? selOrganId;

  Color shiftColor = Colors.white;
  String shiftText = '';

  bool loadStatus = false;

  List<TimeRegion> selectRegions = <TimeRegion>[];

  int positionCount = 0;
  double selColor = 15;

  bool isHideBannerBar = false;
  int viewFromHour = 0;
  int viewToHour = 0;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    loadData = loadShiftData();
  }

  Future<List> loadShiftData() async {
    loadStatus = true;

    _fromDate = DateFormat('yyyy-MM-dd').format(
        getDate(selectedDate.subtract(Duration(days: selectedDate.weekday))));

    // print(_fromDate);
    _toDate = DateFormat('yyyy-MM-dd').format(selectedDate
        .add(Duration(days: DateTime.daysPerWeek - selectedDate.weekday)));

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadCountShift, {
      'staff_id': globals.staffId,
      'organ_id': selOrganId == null ? '' : selOrganId,
      'from_date': _fromDate,
      'to_date': _toDate
    }).then((v) => {results = v});

    organList = [];
    if (results['isLoad']) {
      for (var item in results['organ_list']) {
        organList.add(OrganModel.fromJson(item));
      }
      selOrganId = results['organ_id'];
    }

    var selOrgan = await ClOrgan().loadOrganInfo(context, selOrganId!);
    positionCount = selOrgan.tableCount;

    regions = [];
    appointments = [];
    // setRegions(results);
    setApppointment(results);
    regions = [];
    if (!DateTime.parse(_toDate + ' 23:59:59').isBefore(DateTime.now())) {
      regions = await ClShift()
          .loadActiveShiftRegions(context, selOrganId!, _fromDate);
    }
    print(regions);
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
    setState(() {});
    return regions;
  }

  Future<void> setCountShift(_date) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgSettingCountShift(
            selMax: positionCount,
            organId: selOrganId!,
            selection: _date,
          );
        }).then((_) {
      setState(() {
        loadData = loadShiftData();
      });
    });
  }

  void changeViewCalander(_date) {
    String _cFromDate = DateFormat('yyyy-MM-dd')
        .format(getDate(_date.subtract(Duration(days: _date.weekday))));

    if (_cFromDate == _fromDate) return;

    selectedDate = _date;
    loadData = loadShiftData();

    setState(() {});
  }

  Future<void> copyShiftCount() async {
    bool conf = await Dialogs().confirmDialog(context, 'シフト枠をコピーしますか？');
    if (!conf) return;

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiCopyShiftCountUrl, {
      'organ_id': selOrganId,
      'from_date': DateFormat('yyyy-MM-dd')
          .format(getDate(DateTime.parse(_fromDate).add(Duration(days: 1)))),
      'to_date': _toDate
    }).then((value) => results = value);
    print(_toDate);
    if (results['isCopy']) {
      loadShiftData();
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  void setRegions(results) {
    if (DateTime.parse(_toDate + ' 23:59:59').isBefore(DateTime.now())) return;

    var firstDate = DateFormat('yyyy-MM-dd')
        .format(getDate(DateTime.parse(_fromDate).add(Duration(days: 1))));

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
    for (var item in results['shifts']) {
      appointments.add(Appointment(
        startTime: DateTime.parse(item['from_time']),
        endTime: DateTime.parse(item['to_time']),
        subject: item['count'],
        color: Color(FuncShifts()
            .getLevelColorValue(int.parse(item['count']), positionCount)),
        startTimeZone: '',
        endTimeZone: '',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'シフト枠設定';
    return MainBodyWdiget(
        fullScreenButton: Column(children: [
          FullScreenButton(
            icon: isHideBannerBar ? Icons.fullscreen_exit : Icons.fullscreen,
            tapFunc: () {
              isHideBannerBar = !isHideBannerBar;
              setState(() {});
            },
          )
        ]),
        isFullScreen: isHideBannerBar,
        render: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                color: bodyColor,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    _getOrganDropDown(),
                    Expanded(child: _getCalendar())
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }

  var organLabelTextStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  Widget _getOrganDropDown() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 5, right: 10),
      child: Row(children: [
        SizedBox(width: 16),
        InputLeftText(label: '店名', rPadding: 8, width: 60),
        Expanded(
          child: DropDownModelSelect(
            value: selOrganId,
            items: [
              ...organList.map((e) =>
                  DropdownMenuItem(child: Text(e.organName), value: e.organId))
            ],
            tapFunc: (v) {
              selOrganId = v!.toString();
              loadShiftData();
            },
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 5),
          child: PrimaryColButton(
            label: '前週コピー',
            tapFunc:
                DateTime.parse(_toDate + ' 23:59:59').isBefore(DateTime.now())
                    ? null
                    : () => copyShiftCount(),
          ),
        ),
      ]),
    );
  }

  Widget _getCalendar() {
    return SfCalendar(
      firstDayOfWeek: 1,
      view: CalendarView.week,
      cellBorderColor: timeSlotCellBorderColor,
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
      dataSource: _AppointmentDataSource(appointments),
      onLongPress: (d) => setCountShift(d.date),
      onViewChanged: (d) => changeViewCalander(d.visibleDates[1]),
    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
