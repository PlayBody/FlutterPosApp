import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/notification.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions/datetimes.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/pos/manage/shifts/settingshiftinit.dart';
import 'package:staff_pos_app/src/interface/pos/shifts/dlgshiftapply.dart';
import 'package:staff_pos_app/src/interface/style/style_const.dart';
import 'package:staff_pos_app/src/interface/style/textstyles.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';

import 'dlgshiftsubmit.dart';
import 'dlgshiftaction.dart';
import 'viewshiftdialog.dart';
import 'shiftmanager.dart';

class Shift extends StatefulWidget {
  const Shift({Key? key}) : super(key: key);

  @override
  _Shift createState() => _Shift();
}

class _Shift extends State<Shift> {
  late Future<List> loadData;

  DateTime selectedDate = DateTime.now();

  List<TimeRegion> regions = <TimeRegion>[];
  List<Appointment> appointments = <Appointment>[];
  List<OrganModel> organList = [];

  Appointment? selappoint;
  String? selOrganId;

  bool isLock = false;

  String showFromDate = DateFormat('yyyy-MM-dd').format(
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)));
  String showToDate = DateFormat('yyyy-MM-dd').format(DateTime.now()
      .add(Duration(days: DateTime.daysPerWeek - DateTime.now().weekday)));
  String mode = '';
  String initPattern = '1';

  bool isHideBannerBar = false;

  int viewFromHour = 0;
  int viewToHour = 0;
  DateTime? requestFromTime;
  DateTime? requestToTime;

  @override
  void initState() {
    super.initState();
    loadData = loadShiftData();
  }

  Future<List> loadShiftData() async {
    print('okokokokokokokokokokokokokokokokokokokokokok');
    regions = [];
    appointments = [];
    String vFromDateTime = showFromDate + ' 00:00:00';
    String vToDateTime = showToDate + ' 23:59:59';

    organList = await ClOrgan().loadOrganList(context, '', globals.staffId);
    if (organList.length < 1) return [];
    if (selOrganId == null) selOrganId = organList.first.organId;

    isLock = await ClShift()
        .loadShiftLock(context, selOrganId!, showFromDate, showToDate);
    var minMaxHour = await ClOrgan().loadOrganShiftMinMaxHour(
        context, selOrganId!, vFromDateTime, vToDateTime);

    viewFromHour = int.parse(minMaxHour['start'].toString());
    viewToHour = int.parse(minMaxHour['end'].toString());

    regions = await loadRegions();

    appointments.addAll(await ClShift().loadStaffShift(
        context, globals.staffId, selOrganId!, vFromDateTime, vToDateTime,
        mode: mode, pattern: initPattern));

    appointments.addAll(await ClShift().loadStaffReserve(
        context, globals.staffId, selOrganId!, vFromDateTime, vToDateTime));

    mode = '';

    ClNotification().removeBadge(context, globals.staffId, '11');
    ClNotification().removeBadge(context, globals.staffId, '12');
    ClNotification().removeBadge(context, globals.staffId, '13');
    ClNotification().removeBadge(context, globals.staffId, '15');
    print('okokokokokokokokokokokokokokokokokokokokokok');
    setState(() {});
    return [];
  }

  Future<List<TimeRegion>> loadRegions() async {
    String _fromTime = showFromDate + ' 00:00:00';
    String _toTime = showToDate + ' 23:59:59';

    List<TimeRegion> _regions = [];
    if (!DateTime.parse(_toTime).isBefore(DateTime.now())) {
      _regions = await ClShift()
          .loadActiveShiftRegions(context, selOrganId!, showFromDate);
    }

    //load shift_counts
    _regions.addAll(await ClShift()
        .loadColorShiftCountsByWeek(context, selOrganId!, _fromTime, _toTime));
    return _regions;
  }

  Future<void> changeViewCalander(DateTime _date) async {
    showFromDate = DateFormat('yyyy-MM-dd')
        .format(_date.subtract(Duration(days: _date.weekday - 1)));
    showToDate = DateFormat('yyyy-MM-dd').format(
        _date.add(Duration(days: DateTime.daysPerWeek - _date.weekday)));

    // Dialogs().loaderDialogNormal(context);
    await loadShiftData();
    // Navigator.pop(context);
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> loadShiftStatus(_date) async {
    String selDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(_date);

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadShiftStatus, {
      'staff_id': globals.staffId,
      'organ_id': globals.organId,
      'select_datetime': selDateTime,
    }).then((v) => {results = v});

    regions = [];
    if (results['isLoad']) {
      if (results['status'] == '0') {
        //submitShift(_date);
      }

      if (results['status'] == '1') {
        // if (results['admin'] == '1') {
        actionShift(_date, results);
        // } else {
        // viewShift(selDate, results);
        // }
      }

      if (results['status'] == '2' || results['status'] == '3') {
        // viewShift(selDate, results);
      }
    }
    return;
  }

  Future<void> setSubmitShift(_date) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgShiftSubmit(
            organId: selOrganId!,
            selection: _date,
            isLock: isLock,
          );
        }).then((_) async {
      Dialogs().loaderDialogNormal(context);
      await loadShiftData();
      Navigator.pop(context);
    });
  }

  Future<void> actionShift(_date, params) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgActionShift(
            selectDate: DateFormat('yyyy-MM-dd').format(_date),
            param: params,
          );
        }).then((_) async {
      Dialogs().loaderDialogNormal(context);
      await loadShiftData();
      Navigator.pop(context);
    });
  }

  Future<void> viewShift(String selDate, params) async {
    String txtStatus = '';
    if (params['status'] == '1') txtStatus = '申請中'; // Requesting
    if (params['status'] == '2') txtStatus = '承認'; // Accepted
    if (params['status'] == '3') txtStatus = '保留'; // Rejected

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ViewShiftDialog(
            selectDate: selDate,
            txtStatus: txtStatus,
            param: params,
          );
        }).then((_) async {
      Dialogs().loaderDialogNormal(context);
      await loadShiftData();
      Navigator.pop(context);
    });
  }

  Future<void> resetToInit() async {
    String selPattern = await Dialogs().confirmWithSelectNumberDialog(
        context, qShiftFormat, "パターンを選択してください。", 5);
    if (int.parse(selPattern) > 0) {
      initPattern = selPattern.toString();
      mode = 'init';

      Dialogs().loaderDialogNormal(context);
      await loadShiftData();
      Navigator.pop(context);
    }
  }

  Future<void> pushShiftManage() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ShiftManager(
        initOrgan: this.selOrganId!,
        initDate: selectedDate,
      );
    }));

    Dialogs().loaderDialogNormal(context);
    await loadShiftData();
    Navigator.pop(context);
  }

  void pushInitSetting() {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return SettingShiftInit();
    }));
  }

  Future<void> rejectAppoint(Appointment appoint) async {
    if (appoint.notes!.split(',').first == 'reserve') {
      bool conf = await Dialogs().confirmDialog(context, '予約を拒否しますか？');
      if (!conf) return;
      Map<dynamic, dynamic> results = {};
      await Webservice().loadHttp(context, apiRejectReserveDataUrl, {
        'staff_id': globals.staffId,
        'from_time':
            DateFormat('yyyy-MM-dd HH:mm:ss').format(appoint.startTime),
        'to_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(appoint.endTime)
      }).then((value) => results = value);

      if (results['isReject']) {
        Dialogs().loaderDialogNormal(context);
        await loadShiftData();
        Navigator.pop(context);
      } else {
        Dialogs().infoDialog(context, errServerActionFail);
      }
    }

    if (appoint.notes!.split(',').first == 'manager') {
      applyOrRejectRequestShift(appoint, '-2');
    }
  }

  Future<void> applyAppoint(Appointment appoint) async {
    if (appoint.notes!.split(',').first == 'reserve') {
      bool conf = await Dialogs().confirmDialog(context, '予約を承認しますか？');
      if (!conf) return;
      Map<dynamic, dynamic> results = {};
      await Webservice().loadHttp(context, apiApplyReserveDataUrl, {
        'staff_id': globals.staffId,
        'from_time':
            DateFormat('yyyy-MM-dd HH:mm:ss').format(appoint.startTime),
        'to_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(appoint.endTime)
      }).then((value) => results = value);

      if (results['isApply']) {
        Dialogs().loaderDialogNormal(context);
        await loadShiftData();
        Navigator.pop(context);
      } else {
        Dialogs().infoDialog(context, errServerActionFail);
      }
    }

    if (appoint.notes!.split(',').first == 'manager') {
      applyOrRejectRequestShift(appoint, '3');
    }
  }

  Future<void> applyOrRejectRequestShift(
      Appointment appoint, String updateType) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgShiftApply(
              shiftId: appoint.notes!.split(',').last,
              selectDate: DateFormat('yyyy-MM-dd').format(appoint.startTime),
              fromTime: DateFormat('HH:mm:ss').format(appoint.startTime),
              toTime: DateFormat('HH:mm:ss').format(appoint.endTime),
              updateType: updateType);
        });
    Dialogs().loaderDialogNormal(context);

    await loadShiftData();
    Navigator.pop(context);
  }

  Future<void> refreshLoad() async {
    Dialogs().loaderDialogNormal(context);
    await loadShiftData();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'シフト'; // Shift
    return MainBodyWdiget(
        fullScreenButton: _fullScreenContainer(),
        isFullScreen: isHideBannerBar,
        render: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                color: bodyColor,
                child: Column(
                  children: [
                    _getTopButtons(),
                    _getOrganDropDown(),
                    Expanded(child: _getCalendar()),
                    if (selappoint != null) _getAddApplyContent(),
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

  var labelTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  Widget _fullScreenContainer() {
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

  Widget _getOrganDropDown() {
    return Row(
      children: [
        SizedBox(width: 16),
        InputLeftText(label: '店名', rPadding: 8, width: 60), //Store name
        Expanded(
            child: DropDownModelSelect(
          contentPadding: EdgeInsets.symmetric(vertical: 7),
          value: selOrganId,
          items: [
            ...organList.map((e) => DropdownMenuItem(
                  child: Text(e.organName),
                  value: e.organId,
                ))
          ],
          tapFunc: (v) async {
            selOrganId = v.toString();

            Dialogs().loaderDialogNormal(context);
            await loadShiftData();
            Navigator.pop(context);
          },
        )),
        SizedBox(width: 8),
        if (globals.auth > constAuthStaff)
          WhiteButton(
              label: 'シフト管理',
              tapFunc: () => pushShiftManage()), // Shift Management
        SizedBox(width: 30)
      ],
    );
  }

  Widget _getTopButtons() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 5, left: 8, right: 8),
      child: Row(children: [
        Expanded(
          child: SubHeaderText(
            label: DateTimes().convertJPYMFromString(showFromDate),
          ),
        ),
        Container(
          child: WhiteButton(
            label: '標準設定適用', // Apply Standard Settings
            tapFunc: DateTime.parse(showToDate + ' 23:59:59')
                    .isBefore(DateTime.now())
                ? null
                : () => resetToInit(),
          ),
        ),
        SizedBox(width: 8),
        Container(
          child: WhiteButton(
              label: '設定画面へ',
              tapFunc: () => pushInitSetting()), // Push To Settings
        )
      ]),
    );
  }

  Widget _getAddApplyContent() {
    return Container(
      color: selappoint!.notes == 'reserve' ? Colors.white : Colors.orange,
      child: Row(children: [
        SizedBox(width: 4),
        InputLeftText(
            label: selappoint!.notes == 'reserve' ? '予約申込' : '出勤要請',
            width: 60,
            rPadding: 2),
        Text(
            DateFormat('yyyy-MM-dd HH:mm~').format(selappoint!.startTime) +
                DateFormat('HH:mm').format(selappoint!.endTime),
            style: bodyTextStyle),
        SizedBox(width: 4),
        PrimaryButton(label: '承認', tapFunc: () => applyAppoint(selappoint!)),
        SizedBox(width: 4),
        DeleteButton(label: '拒否', tapFunc: () => rejectAppoint(selappoint!)),
        SizedBox(width: 4),
      ]),
    );
  }

  Widget _getCalendar() {
    return SfCalendar(
      view: CalendarView.week,
      firstDayOfWeek: 1,
      headerHeight: 0,
      cellBorderColor: timeSlotCellBorderColor,
      selectionDecoration: timeSlotSelectDecoration,
      timeSlotViewSettings: TimeSlotViewSettings(
          startHour: viewFromHour.toDouble(),
          endHour: viewToHour.toDouble(),
          timeIntervalHeight: timeSlotCellHeight.toDouble(),
          dayFormat: 'E',
          timeInterval: Duration(minutes: 15),
          timeFormat: 'H:mm',
          timeTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black.withOpacity(0.5),
          )),
      appointmentTextStyle: TextStyle(
          fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
      timeRegionBuilder:
          (BuildContext context, TimeRegionDetails timeRegionDetails) {
        return Container(
          padding: EdgeInsets.only(top: 5),
          color: timeRegionDetails.region.color,
          alignment: Alignment.topCenter,
          child: Text(
            timeRegionDetails.region.text.toString(),
            style: TextStyle(fontSize: 25, color: Colors.grey),
          ),
        );
      },
      // viewNavigationMode: ViewNavigationMode.none,
      onTap: calendarTapped,
      specialRegions: regions,
      dataSource: _AppointmentDataSource(appointments),
      onLongPress: (d) =>
          (DateTime.parse(showToDate + ' 23:59:59').isBefore(DateTime.now()))
              ? null
              : setSubmitShift(d.date),
      onViewChanged: (d) => changeViewCalander(d.visibleDates[1]),
    );
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement == CalendarElement.appointment) {
      selappoint = calendarTapDetails.appointments![0];

      if (selappoint == null || selappoint!.notes == null) {
        selappoint = null;
      } else {
        List<String> pointNotes = selappoint!.notes!.split(',');
        if (pointNotes.first == 'reserve' || pointNotes.first == 'manager') {
        } else {
          selappoint = null;
        }
      }
    } else {
      selappoint = null;
    }
    setState(() {});
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
