import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/pos/manage/organs/dlgorgantime.dart';
import 'package:staff_pos_app/src/interface/pos/manage/organs/dlgspecialtime.dart';
import 'package:staff_pos_app/src/model/organavaliabletimmodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/model/organspecialshifttimemodel.dart';
import 'package:staff_pos_app/src/model/organspecialtimemodel.dart';

class SettingOrganTime extends StatefulWidget {
  final String selOrganId;
  final String type;
  const SettingOrganTime(
      {required this.selOrganId, required this.type, Key? key})
      : super(key: key);

  @override
  _SettingOrganTime createState() => _SettingOrganTime();
}

class _SettingOrganTime extends State<SettingOrganTime> {
  late Future<List> loadData;

  List<OrganAvaliableTimeModel> organTimes = [];
  List<OrganSpecialTimeModel> specialTimes = [];
  List<OrganSpecialShiftTimeModel> specialShiftTimes = [];

  @override
  void initState() {
    super.initState();
    loadData = loadOrganTime();
  }

  Future<List> loadOrganTime() async {
    organTimes =
        await ClOrgan().loadOrganTimes(context, widget.selOrganId, widget.type);

    specialTimes =
        await ClOrgan().loadOrganSpecialTime(context, widget.selOrganId);
    specialShiftTimes =
        await ClOrgan().loadOrganSpecialShiftTime(context, widget.selOrganId);
    setState(() {});
    return [];
  }

  Future<void> deleteOrganTime(delId) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;

    await ClOrgan().deleteOrganTimes(context, delId, widget.type);
    loadOrganTime();
  }

  Future<void> deleteOrganSpecialTime(delId) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;

    Dialogs().loaderDialogNormal(context);
    await ClOrgan().deleteOrganSpecialTimes(context, delId);
    await loadOrganTime();
    Navigator.pop(context);
  }

  void editTime(OrganAvaliableTimeModel? item, weekday) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgOrganTime(
            timeId: item == null ? null : item.id,
            organId: widget.selOrganId,
            weekday: item == null ? weekday : item.weekday,
            startTime: item == null ? '00:00' : item.fromTime,
            endTime: item == null ? '24:00' : item.toTime,
            type: widget.type,
          );
        }).then((_) {
      loadOrganTime();
    });
  }

  void editSpecialTime(OrganSpecialTimeModel? item) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgSpecialTime(
            timeId: item == null ? null : item.id,
            organId: widget.selOrganId,
            startTime: item == null ? '00:00' : item.fromTime,
            endTime: item == null ? '24:00' : item.toTime,
            type: widget.type,
          );
        }).then((_) {
      loadOrganTime();
    });
  }

  void editSpecialShiftTime(OrganSpecialShiftTimeModel? item) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgSpecialTime(
            timeId: item == null ? null : item.id,
            organId: widget.selOrganId,
            startTime: item == null ? '00:00' : item.fromTime,
            endTime: item == null ? '24:00' : item.toTime,
            type: widget.type,
          );
        }).then((_) {
      loadOrganTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = widget.type == 'bussiness' ? '店舗営業時間' : '勤務可能時間';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _getBodyContent();
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  var headerStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  var contentStyle = TextStyle(fontSize: 18);

  Widget _getBodyContent() {
    return Container(
        color: Colors.white,
        child: SingleChildScrollView(
            child: Column(
          children: [
            PageSubHeader(
                label: widget.type == 'bussiness' ? '店舗営業時間' : '勤務可能時間'),
            for (int i = 1; i <= 7; i++)
              _getWeekDayTime(
                  weekAry[i - 1].toString() + '曜日',
                  i.toString(),
                  organTimes
                      .where((element) => element.weekday == i.toString())),
            PageSubHeader(label: '特別営業日'),
            if (widget.type == 'bussiness')
              ...specialTimes.map((e) => _getSpecialTimeRow(e.date, e)),
            if (widget.type == 'shift')
              ...specialShiftTimes.map((e) => _getSpecialTimeRow(e.date, e)),
            if (widget.type == 'bussiness')
              WhiteButton(
                  label: '特別営業日の追加', tapFunc: () => editSpecialTime(null))
          ],
        )));
  }

  Widget _getSpecialTimeRow(weekLabel, e) {
    return Container(
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 30),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 32),
            width: 155,
            child: Text(weekLabel, style: TextStyle(fontSize: 18)),
          ),
          _getOpenSpecialTimeRow(e)
        ],
      ),
    );
  }

  Widget _getWeekDayTime(weekLabel, weekday, data) {
    return Container(
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 32),
            width: 140,
            child: Text(weekLabel, style: TextStyle(fontSize: 18)),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...data.map(
                    (e) => _getOpenTimeRow(e, () => deleteOrganTime(e.id))),
                _getTimeNew(weekday)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _getOpenTimeRow(item, tapFunc) {
    return Container(
      child: Row(
        children: [
          GestureDetector(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(item.fromTime + ' ~ ' + item.toTime,
                    style: contentStyle)),
            onTap: () => editTime(item, ''),
          ),
          // if (widget.type == 'bussiness')
          IconButton(
              splashRadius: 16,
              onPressed: tapFunc,
              icon: Icon(Icons.delete, size: 22))
        ],
      ),
    );
  }

  Widget _getOpenSpecialTimeRow(item) {
    return Container(
      child: Row(
        children: [
          GestureDetector(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(item.fromTime + ' ~ ' + item.toTime,
                    style: contentStyle)),
            // onTap: () => editSpecialTime(item),
          ),
          if (widget.type == 'bussiness')
            IconButton(
                splashRadius: 16,
                onPressed: () => deleteOrganSpecialTime(item.id),
                icon: Icon(Icons.delete, size: 22)),
          if (widget.type == 'shift')
            IconButton(
                splashRadius: 16,
                onPressed: () => editSpecialShiftTime(item),
                icon: Icon(Icons.edit, size: 22))
        ],
      ),
    );
  }

  Widget _getTimeNew(weekday) {
    return Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
          child: Text('+ 追加', style: contentStyle),
          onPressed: () => editTime(null, weekday),
        ));
  }
}
