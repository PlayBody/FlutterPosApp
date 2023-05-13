import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions/shifts.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/style/style_const.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/shift_init_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;

import 'dlgsettinginitshift.dart';

class SettingShiftInit extends StatefulWidget {
  const SettingShiftInit({Key? key}) : super(key: key);

  @override
  State<SettingShiftInit> createState() => _SettingShiftInit();
}

class _SettingShiftInit extends State<SettingShiftInit> {
  late Future<List> loadData;

  List<TimeRegion> regions = <TimeRegion>[];
  List<Appointment> appointments = <Appointment>[];
  List<OrganModel> organList = [];

  String? selOrganId;

  String pattern = '1';

  int viewFromHour = 0;
  int viewToHour = 24;

  @override
  void initState() {
    super.initState();
    loadData = loadShiftData();
  }

  Future<List> loadShiftData() async {
    organList = await ClOrgan()
        .loadOrganList(context, globals.companyId, globals.staffId);

    if (selOrganId == null) {
      selOrganId = organList.first.organId;
    }

    List<InitShiftModel> shifts = await ClShift().loadInitShifts(context, {
      'organ_id': selOrganId,
      'staff_id': globals.staffId,
      'pattern': pattern
    });

    appointments = FuncShifts().getAppoinsFromInitList(shifts);

    regions = await ClShift().loadActiveShiftRegions(
        context,
        selOrganId!,
        DateFormat('yyyy-MM-dd').format(DateTime.now()
            .subtract(Duration(days: DateTime.now().weekday - 1))));

    var minMaxHour =
        await ClOrgan().loadOrganShiftMinMaxHour(context, selOrganId!, '', '');

    viewFromHour = int.parse(minMaxHour['start'].toString());
    viewToHour = int.parse(minMaxHour['end'].toString());

    setState(() {});
    return [];
  }

  Future<void> setInitShift(_date) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgSettingInitShift(
            organId: selOrganId!,
            selection: _date,
            pattern: pattern,
          );
        }).then((_) {
      setState(() {
        loadData = loadShiftData();
      });
    });
    Dialogs().loaderDialogNormal(context);
    await loadShiftData();
    Navigator.pop(context);
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'シフト初期設定';
    return MainBodyWdiget(
      render: LoadBodyWdiget(
        loadData: loadData,
        render: Container(
            color: bodyColor,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Column(
              children: [
                _getOrgans(),
                Expanded(child: _getCalendar()),
              ],
            )),
      ),
    );
  }

  Widget _getOrgans() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 5, right: 10),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const InputLeftText(label: '店名', rPadding: 8, width: 60),
          Expanded(
            child: DropDownModelSelect(
              value: selOrganId,
              items: [
                ...organList.map((e) => DropdownMenuItem(
                    child: Text(e.organName), value: e.organId))
              ],
              tapFunc: (v) async {
                selOrganId = v!.toString();
                Dialogs().loaderDialogNormal(context);
                await loadShiftData();
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(width: 5),
          const SizedBox(width: 60, child: Text('パターン')),
          SizedBox(
              width: 50,
              child: DropDownNumberSelect(
                  value: pattern,
                  max: 5,
                  tapFunc: (v) async {
                    pattern = v;
                    Dialogs().loaderDialogNormal(context);
                    await loadShiftData();
                    Navigator.pop(context);
                  }))
        ],
      ),
    );
  }

  Widget _getCalendar() {
    return SfCalendar(
      cellBorderColor: Colors.grey.withOpacity(0.8),
      firstDayOfWeek: 1,
      view: CalendarView.week,
      headerHeight: 0,
      todayHighlightColor: Colors.transparent,
      todayTextStyle: const TextStyle(color: Colors.black),
      selectionDecoration: timeSlotSelectDecoration,
      viewNavigationMode: ViewNavigationMode.none,
      timeSlotViewSettings: TimeSlotViewSettings(
          startHour: viewFromHour.toDouble(),
          endHour: viewToHour.toDouble(),
          timeIntervalHeight: timeSlotCellHeight.toDouble(),
          dayFormat: 'E',
          dateFormat: ' ',
          timeInterval: const Duration(minutes: 15),
          timeFormat: 'H:mm',
          timeTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black.withOpacity(0.5),
          )),
      specialRegions: regions,
      dataSource: _AppointmentDataSource(appointments),
      onLongPress: (d) => setInitShift(d.date),
    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
