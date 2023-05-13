import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/event.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions/datetimes.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/pos/event/dlg_add_event.dart';
import 'package:staff_pos_app/src/interface/style/style_const.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;

class Event extends StatefulWidget {
  const Event({Key? key}) : super(key: key);

  @override
  _Event createState() => _Event();
}

class _Event extends State<Event> {
  late Future<List> loadData;

  DateTime selectedDate = DateTime.now();

  List<Appointment> appointments = <Appointment>[];
  List<OrganModel> organList = [];

  String _fromDate = DateFormat('yyyy-MM-dd').format(
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)));
  String _toDate = DateFormat('yyyy-MM-dd').format(DateTime.now()
      .add(Duration(days: DateTime.daysPerWeek - DateTime.now().weekday)));

  bool isHideBannerBar = false;

  @override
  void initState() {
    super.initState();
    loadData = loadEventData();
  }

  Future<List> loadEventData() async {
    selectedDate = DateTime.now();
    String vFromDateTime = _fromDate + ' 00:00:00';
    String vToDateTime = _toDate + ' 23:59:59';

    appointments = [];
    appointments = await ClEvent().loadEvents(context, {
      'company_id': globals.companyId,
      'from_time': vFromDateTime,
      'to_time': vToDateTime,
    });

    appointments.addAll(await ClEvent().loadEvents(context, {
      'company_id': globals.companyId,
      'from_time': vFromDateTime,
      'to_time': vToDateTime,
      'is_all_organ': '1'
    }));

    setState(() {});
    return [];
  }

  Future<void> changeViewCalander(DateTime _date) async {
    _fromDate = DateFormat('yyyy-MM-dd')
        .format(_date.subtract(Duration(days: _date.weekday - 1)));
    _toDate = DateFormat('yyyy-MM-dd').format(
        _date.add(Duration(days: DateTime.daysPerWeek - _date.weekday)));

    await refreshLoad();
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> refreshLoad() async {
    Dialogs().loaderDialogNormal(context);
    await loadEventData();
    Navigator.pop(context);
  }

  Future<void> addEvent(_date, eventId) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgAddEvent(selection: _date, eventId: eventId);
        }).then((_) async {
      Dialogs().loaderDialogNormal(context);
      await loadEventData();
      Navigator.pop(context);
    });
  }

  void calendarTapped(calendarTapDetails) {
    selectedDate = calendarTapDetails.date;
    if (calendarTapDetails.targetElement == CalendarElement.appointment) {
      String selEventId = calendarTapDetails.appointments![0].notes;

      addEvent(selectedDate, selEventId);
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'イベント';
    return MainBodyWdiget(
        fullscreenTop: 60,
        fullScreenButton: _fullScreenContainer(),
        isFullScreen: isHideBannerBar,
        render: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                // padding: EdgeInsets.only(bottom: 8),
                color: bodyColor,
                child: Column(
                  children: [
                    _getTopButtons(),
                    // _getOrganDropDown(),
                    Expanded(child: _getCalendar()),
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

  Widget _getTopButtons() {
    return Row(children: [
      SizedBox(width: 100),
      Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: SubHeaderText(
              label: DateTimes().convertJPYMFromString(_fromDate))),
      Expanded(child: Container()),
      WhiteButton(
          label: 'イベントの追加', tapFunc: () => addEvent(selectedDate, null)),
      SizedBox(width: 20)
    ]);
  }

  Widget _getCalendar() {
    return SfCalendar(
      view: CalendarView.week,
      firstDayOfWeek: 1,
      headerHeight: 0,
      cellBorderColor: timeSlotCellBorderColor,
      selectionDecoration: timeSlotSelectDecoration,
      timeSlotViewSettings: TimeSlotViewSettings(
          // startHour: viewFromHour.toDouble(),
          // endHour: viewToHour.toDouble(),
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
            style: TextStyle(fontSize: 25, color: Colors.black),
          ),
        );
      },
      // viewNavigationMode: ViewNavigationMode.none,
      // specialRegions: regions,
      dataSource: _AppointmentDataSource(appointments),
      onTap: (d) => selectedDate = d.date!,
      onLongPress: (d) => calendarTapped(d),
      onViewChanged: (d) => changeViewCalander(d.visibleDates[1]),
    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
