import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/orders.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions/datetimes.dart';
import 'package:staff_pos_app/src/common/functions/shifts.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/pos/manage/shifts/settingshiftinit.dart';
import 'package:staff_pos_app/src/interface/pos/shift/shift_manage.dart';
import 'package:staff_pos_app/src/model/order_model.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/shift_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../common/business/notification.dart';
import 'dlg_shift_edit.dart';

class ShiftMake extends StatefulWidget {
  const ShiftMake({Key? key}) : super(key: key);

  @override
  State<ShiftMake> createState() => _ShiftMake();
}

class _ShiftMake extends State<ShiftMake> {
  late Future<List> loadData;

  bool isLock = false;

  String? selOrganId;
  List<OrganModel> organList = [];
  List<TimeRegion> regions = <TimeRegion>[];
  List<Appointment> appointments = <Appointment>[];

  String showFromDate = DateFormat('yyyy-MM-dd').format(
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)));
  String showToDate = DateFormat('yyyy-MM-dd').format(DateTime.now()
      .add(Duration(days: DateTime.daysPerWeek - DateTime.now().weekday)));
  int viewFromHour = 0;
  int viewToHour = 24;
  int showTimeDuring = 15;
  bool isHideBannerBar = false;
  bool isShowReservePan = false;
  DateTime? reserveFrom;
  DateTime? reserveTo;
  String? reserveId;

//  String? applicationShiftTime = '';

  @override
  void initState() {
    super.initState();
    loadData = loadInitData();
  }

  Future<List> loadInitData() async {
    isShowReservePan = false;
    String fromTime = '$showFromDate 00:00:00';
    String toTime = '$showToDate 23:59:59';

    organList = await ClOrgan().loadOrganList(context, '', globals.staffId);
    selOrganId ??= organList.first.organId;

    bool isLoad = await ClShift()
        .loadStaffShiftTime(context, globals.staffId, selOrganId!);

    regions = await ClShift()
        .loadActiveShiftRegions(context, selOrganId!, showFromDate);
    regions.addAll(await ClShift()
        .loadColorShiftCountsByWeek(context, selOrganId!, fromTime, toTime));

    List<ShiftModel> shifts = await ClShift().loadShifts(context, {
      'organ_id': selOrganId,
      'staff_id': globals.staffId,
      'from_time': fromTime,
      'to_time': toTime
    });

    appointments = FuncShifts().getAppoinsFromList(shifts);
    var minMaxHour = await ClOrgan().loadOrganShiftMinMaxHour(
        context, selOrganId!, showFromDate, showToDate);

    List<OrderModel> reserves = await ClOrder().loadOrderList(context, {
      'organ_id': selOrganId,
      'staff_id': globals.staffId,
      'from_time': fromTime,
      'to_time': toTime,
      'is_reserve_active': '1',
    });
    appointments.addAll(FuncShifts().getAppoinsFromReserveList(reserves));

    viewFromHour = int.parse(minMaxHour['start'].toString());
    viewToHour = int.parse(minMaxHour['end'].toString());

    isLock =
        await ClShift().loadShiftLock(context, selOrganId!, fromTime, toTime);

    ClNotification().removeBadge(context, globals.staffId, '11');
    ClNotification().removeBadge(context, globals.staffId, '12');
    // ClNotification().removeBadge(context, globals.staffId, '13');
    ClNotification().removeBadge(context, globals.staffId, '15');
    setState(() {});
    return [];
  }

  Future<void> onTapInitButton() async {
    if (!isOldDate()) return;
    String selPattern = await Dialogs().confirmWithSelectNumberDialog(
        context, qShiftFormat, "パターンを選択してください。", 5);
    Dialogs().loaderDialogNormal(context);
    if (int.parse(selPattern) > 0) {
      await ClShift().setInitShift(
          context, selOrganId, showFromDate, showToDate, selPattern.toString());
    }

    await loadInitData();
    Navigator.pop(context);
  }

  void onTapPushManage() {
    if (selOrganId == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ShiftManage(
          initOrgan: selOrganId!,
          initDate: DateTime.parse('$showFromDate 00:00:00'));
    }));
  }

  void onTapPushSetting() {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return const SettingShiftInit();
    }));
  }

  Future<void> onChangeCalander(DateTime _date) async {
    String _from = DateFormat('yyyy-MM-dd')
        .format(_date.subtract(Duration(days: _date.weekday - 1)));
    String _to = DateFormat('yyyy-MM-dd').format(
        _date.add(Duration(days: DateTime.daysPerWeek - _date.weekday)));
    if (_from == showFromDate) return;
    showFromDate = _from;
    showToDate = _to;

    refreshLoad();
  }

  void onChangeOrgan(String organId) {
    selOrganId = organId;
    refreshLoad();
  }

  void onLongTapCalander(_date) {
    if (!isOldDate()) return;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgShiftEdit(
            organId: selOrganId!,
            selection: _date,
            isLock: isLock,
          );
        }).then((_) => refreshLoad());
  }

  Future<void> refreshLoad() async {
    Dialogs().loaderDialogNormal(context);
    await loadInitData();
    Navigator.pop(context);
  }

  bool isOldDate() {
    DateTime _showEndDate = DateTime.parse(showToDate + ' 23:59:59');
    if (_showEndDate.isBefore(DateTime.now())) {
      Dialogs().infoDialog(context, '使用できません。');
      return false;
    }
    return true;
  }

  void onChangeCalanderDuring(v) {
    showTimeDuring = int.parse(v);
    setState(() {});
  }

  Future<void> onTapCalander(CalendarTapDetails calendarTapDetails) async {
    isShowReservePan = false;
    setState(() {});

    if (calendarTapDetails.targetElement != CalendarElement.appointment) return;
    Appointment? _selappoint = calendarTapDetails.appointments![0];
    if (_selappoint == null || _selappoint.notes == null) return;
    String _note = _selappoint.notes!;
    if (!_note.contains('reserve_1') || !_note.contains(':')) return;

    reserveId = _note.split(':')[1];
    reserveFrom = _selappoint.startTime;
    reserveTo = _selappoint.endTime;
    isShowReservePan = true;

    setState(() {});
  }

  Future<void> onTapReserveApply() async {
    if (reserveId == null) return;
    bool isSave =
        await ClOrder().applyReserveOrder(context, reserveId, globals.staffId);
    if (isSave) refreshLoad();
  }

  Future<void> onTapReserveReject() async {
    if (reserveId == null) return;
    bool isSave = await ClOrder().updateOrder(context, {
      'reserve_id': reserveId,
      'status': constOrderStatusReserveReject,
      'staff_id': globals.staffId
    });
    if (isSave) refreshLoad();
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'シフト';
    return MainBodyWdiget(
      fullScreenButton: _fullScreenContainer(),
      isFullScreen: isHideBannerBar,
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _getBodyContent();
          } else if (snapshot.hasError) return Text("${snapshot.error}");
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

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

  Widget _getBodyContent() {
    return Container(
      color: bodyColor,
      child: Column(children: [
        _getTopButtons(),
        _getOrganDropDown(),
        Expanded(child: _getCalendar()),
        if (isShowReservePan) _getAddApplyContent(),
      ]),
    );
  }

  Widget _getTopButtons() {
    int restPlanMinutes =
        globals.shiftWeekPlanMinute - globals.shiftWeekStaffMinute;
    restPlanMinutes = restPlanMinutes > 0 ? restPlanMinutes : 0;
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 5, left: 8),
      child: Row(children: [
        Expanded(
            // child: SubHeaderText(
            //     label: DateTimes().convertJPYMFromString(showFromDate)),
            // Approval Time , Job Application Time

            // child: Text(
            //     '承認時間 ${globals.shiftWeekPlanMinute} 分\n勤務申請時間 ${globals.shiftWeekStaffMinute} 分'),
            child: Text('週間出勤希望時間-(申請中+承認): $restPlanMinutes分')),
        // child: Text(
        //     'A: ${globals.shiftWeekPlanMinute} \nB: ${globals.shiftWeekStaffMinute}')),
        Container(
          child: WhiteButton(label: '標準設定適用', tapFunc: () => onTapInitButton()),
        ),
        SizedBox(width: 8),
        Container(
          child: WhiteButton(label: '設定画面へ', tapFunc: () => onTapPushSetting()),
        ),
        PopupMenuButton(
            onSelected: (v) => onChangeCalanderDuring(v),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                      value: '15',
                      child: Text('15分間間隔で表示', style: TextStyle(fontSize: 12))),
                  PopupMenuItem<String>(
                      value: '30',
                      child: Text('30分間間隔で表示', style: TextStyle(fontSize: 12))),
                  PopupMenuItem<String>(
                      value: '60',
                      child: Text('60分間間隔で表示', style: TextStyle(fontSize: 12))),
                ]),
      ]),
    );
  }

  Widget _getOrganDropDown() {
    return Row(children: [
      SizedBox(width: 16),
      InputLeftText(label: '店名', rPadding: 8, width: 60),
      Expanded(
          child: DropDownModelSelect(
        contentPadding: EdgeInsets.symmetric(vertical: 7),
        value: selOrganId,
        items: [
          ...organList.map((e) =>
              DropdownMenuItem(child: Text(e.organName), value: e.organId))
        ],
        tapFunc: (v) => onChangeOrgan(v),
      )),
      SizedBox(width: 8),
      if (globals.auth > constAuthStaff)
        WhiteButton(label: 'シフト管理', tapFunc: () => onTapPushManage()),
      SizedBox(width: 30)
    ]);
  }

  Widget _getCalendar() {
    return SfCalendar(
      view: CalendarView.week,
      firstDayOfWeek: 1,
      headerHeight: 0,
      specialRegions: regions,
      dataSource: _AppointmentDataSource(appointments),
      onTap: (CalendarTapDetails details) => onTapCalander(details),
      onViewChanged: (d) => onChangeCalander(d.visibleDates[1]),
      onLongPress: (d) => onLongTapCalander(d.date),
      timeSlotViewSettings: TimeSlotViewSettings(
        startHour: viewFromHour.toDouble(),
        endHour: viewToHour.toDouble(),
        timeInterval: Duration(minutes: showTimeDuring),
        timeFormat: 'H:mm',
        timeTextStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: Colors.black.withOpacity(0.5),
        ),
      ),
      appointmentTextStyle: TextStyle(
          fontSize: 12,
          color: Colors.black.withOpacity(0.5),
          fontWeight: FontWeight.bold),
      timeRegionBuilder:
          (BuildContext context, TimeRegionDetails timeRegionDetails) {
        return Container(
          padding: EdgeInsets.only(top: 5),
          color: timeRegionDetails.region.color,
          alignment: Alignment.topCenter,
          child: Text(timeRegionDetails.region.text.toString(),
              style: const TextStyle(fontSize: 25, color: Colors.black)),
        );
      },
    );
  }

  Widget _getAddApplyContent() {
    return Container(
      color: Colors.white,
      child: Row(children: [
        const SizedBox(width: 4),
        const InputLeftText(label: '予約申込', width: 60, rPadding: 2),
        Text(
            DateFormat('yyyy-MM-dd HH:mm ~').format(reserveFrom!) +
                DateFormat('HH:mm').format(reserveTo!),
            style: const TextStyle(color: Color(0xff454545), fontSize: 14)),
        const SizedBox(width: 4),
        PrimaryButton(label: '承認', tapFunc: () => onTapReserveApply()),
        const SizedBox(width: 4),
        DeleteButton(label: '拒否', tapFunc: () => onTapReserveReject()),
        const SizedBox(width: 4),
      ]),
    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
