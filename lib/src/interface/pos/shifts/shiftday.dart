import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:staff_pos_app/src/common/business/common.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/business/staffs.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/functions/datetimes.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/admin/users/admin_user_info.dart';

import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/components/timepicker.dart';
import 'package:staff_pos_app/src/interface/pos/shifts/dlgupdatereserve.dart';

import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/shiftdaymodel.dart';
import 'package:staff_pos_app/src/model/stafflistmodel.dart';

import 'dlgshiftsubmit.dart';

class ShiftDay extends StatefulWidget {
  final bool isEdit;
  final String? initOrgan;
  final DateTime initDate;
  const ShiftDay(
      {required this.isEdit, this.initOrgan, required this.initDate, Key? key})
      : super(key: key);

  @override
  _ShiftDay createState() => _ShiftDay();
}

class _ShiftDay extends State<ShiftDay> {
  late Future<List> loadData;
  DateTime selectedDate = DateTime.now();

  String? selOrganId;
  List<OrganModel> organList = [];

  var times = [];
  bool isHideBannerBar = false;

  List<ShiftDayModel> shifts = [];
  List<ShiftDayModel> reserves = [];
  List<String> staffs = [];
  dynamic staffNames = {};
  double timeWidth = 60;
  List<String> showSorts = [];

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  bool isDetail = false;
  bool isApply = false;
  bool isReschedule = false;
  ShiftDayModel? detailData;

  List<StaffListModel> organStaffs = [];
  List<String> addStaffs = [];
  String shiftScheduleFromTime = "";
  String shiftScheduleToTime = "";
  String shiftScheduleDate = "";

  @override
  void initState() {
    selOrganId = widget.initOrgan;
    selectedDate = widget.initDate;
    super.initState();
    addStaffs = [];
    loadData = loadShiftData();
  }

  Future<List> loadShiftData() async {
    isDetail = false;
    organList = await ClOrgan()
        .loadOrganList(context, globals.companyId, globals.staffId);
    if (selOrganId == null) selOrganId = organList.first.organId;
    organStaffs = await ClStaff()
        .loadStaffs(context, {'organ_id': selOrganId.toString()});
    times = await ClOrgan().loadOrganShiftTime(
        context, selOrganId!, DateFormat('yyyy-MM-dd').format(selectedDate));

    shifts = await ClShift().loadDayDetail(
        context, selOrganId!, DateFormat('yyyy-MM-dd').format(selectedDate));

    showSorts = await ClCommon().loadStaffShiftSort(context, globals.staffId);

    staffs = [];
    staffNames = {};
    shifts.forEach((element) {
      if (!staffs.contains(element.staffId)) {
        staffs.add(element.staffId);
        staffNames[element.staffId] = element.staffName;

        if (!showSorts.contains(element.staffId))
          showSorts.add(element.staffId);
      }
    });
    organStaffs.forEach((e) {
      if (addStaffs.contains(e.staffId)) {
        staffs.add(e.staffId.toString());

        staffNames[e.staffId] = (e.staffNick == ''
            ? (e.staffFirstName! + ' ' + e.staffLastName!)
            : e.staffNick);

        if (!showSorts.contains(e.staffId)) showSorts.add(e.staffId.toString());
      }
    });

    reserves = await ClShift().loadDayReserve(
        context, selOrganId!, DateFormat('yyyy-MM-dd').format(selectedDate));
    reserves.forEach((element) {
      if (!staffs.contains(element.staffId)) {
        staffs.add(element.staffId);
        staffNames[element.staffId] = element.staffName;
        if (!showSorts.contains(element.staffId))
          showSorts.add(element.staffId);
      }
    });

    await ClCommon().saveStaffShiftSort(context, globals.staffId, showSorts);
    staffs.sort((a, b) => showSorts.indexOf(a).compareTo(showSorts.indexOf(b)));

    setState(() {});
    return [];
  }

  Future<void> refreshLoad() async {
    Dialogs().loaderDialogNormal(context);
    await loadShiftData();
    Navigator.pop(context);
  }

  Future<void> selectDateMove() async {
    addStaffs = [];
    final DateTime? selected = await showDatePicker(
      locale: const Locale("ja"),
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );

    if (selected != null && selected != selectedDate) {
      selectedDate = selected;
      setState(() {});
      refreshLoad();
    }
  }

  Future<void> updateShiftStatus(String shiftId, String status) async {
    isApply = false;
    Dialogs().loaderDialogNormal(context);
    bool isUpdate = await ClShift().updateShiftStatus(context, shiftId, status);
    if (isUpdate) {
      await loadShiftData();
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> updateShiftTime(String shiftId) async {
    bool conf = await Dialogs().confirmDialog(context, 'スケジュールを変更しますか？');
    if (!conf) return;
    Dialogs().loaderDialogNormal(context);
    // String _fromTime = shiftScheduleDate + ' ' + shiftScheduleFromTime;
    // String _toTime = shiftScheduleDate + ' ' + shiftScheduleToTime;

    // bool isUpdate =
    //     await ClShift().updateShiftTime(context, shiftId, _fromTime, _toTime);
    isReschedule = false;
    await loadShiftData();
    Navigator.pop(context);
  }

  Future<void> dragComplete(item, staffId) async {
    String key = item['key'];
    if (item['mode'] == 'staff_sort') {
      int itemIndex = showSorts.indexOf(key.toString());
      showSorts.remove(key);
      showSorts.insert(showSorts.indexOf(staffId) + 1, key.toString());
      showSorts.remove(staffId);
      showSorts.insert(itemIndex, staffId);
      staffs
          .sort((a, b) => showSorts.indexOf(a).compareTo(showSorts.indexOf(b)));

      Dialogs().loaderDialogNormal(context);
      await ClCommon()
          .exchangeStaffShiftSort(context, globals.staffId, key, staffId);
      Navigator.pop(context);
      setState(() {});
    }

    if (item['mode'] == 'reserve') {
      if (staffId == '0') return;
      Dialogs().loaderDialogNormal(context);
      await ClShift().updateReserveStaff(context, item['key'], staffId);
      await loadShiftData();
      Navigator.pop(context);
    }
  }

  void pushMoveDate(int intVal) {
    addStaffs = [];
    selectedDate = selectedDate.add(Duration(days: intVal));
    refreshLoad();
  }

  void setFullScreenMode() {
    isHideBannerBar = !isHideBannerBar;
    setState(() {});
  }

  void viewDetail(reserve) {
    isDetail = false;
    isApply = false;
    isReschedule = false;
    if (reserve.type == '0') {
      isDetail = true;
      detailData = reserve;
      setState(() {});
      return;
    }
    if (reserve.type == '1' && globals.auth >= constAuthBoss && widget.isEdit) {
      isApply = true;
      detailData = reserve;
      setState(() {});
      return;
    }
    if (reserve.type == '2' && globals.auth >= constAuthBoss && widget.isEdit) {
      isReschedule = true;
      detailData = reserve;

      shiftScheduleDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(detailData!.strFromTime));
      shiftScheduleFromTime = DateFormat('HH:mm:ss')
          .format(DateTime.parse(detailData!.strFromTime));
      shiftScheduleToTime =
          DateFormat('HH:mm:ss').format(DateTime.parse(detailData!.strToTime));
      setState(() {});
      return;
    }
    setState(() {});
  }

  Future<void> setSubmitShift(DateTime _date) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgShiftSubmit(
            organId: selOrganId!,
            selection: _date,
            isLock: true,
          );
        }).then((_) async {
      Dialogs().loaderDialogNormal(context);
      await loadShiftData();
      Navigator.pop(context);
    });
  }

  void addStaffList() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('スタッフの追加'),
        content: Container(
            child: SingleChildScrollView(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...organStaffs.map((e) => !staffs.contains(e.staffId)
                ? WhiteButton(
                    label: (e.staffNick == ''
                        ? (e.staffFirstName! + ' ' + e.staffLastName!)
                        : e.staffNick),
                    tapFunc: () {
                      addStaffs.add(e.staffId.toString());
                      Navigator.of(context).pop();
                    })
                : Container())
          ],
        ))),
        actions: [
          CancelColButton(
              label: 'キャンセル', tapFunc: () => Navigator.of(context).pop()),
        ],
      ),
    ).then((value) {
      refreshLoad();
    });
  }

  void updateShiftStaus(shiftId, shiftType) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('シフトの更新'),
        content: Container(
            child: DropDownModelSelect(
          value: shiftType,
          items: [
            DropdownMenuItem(child: Text('申請中'), value: '1'),
            DropdownMenuItem(child: Text('承認'), value: '2'),
            DropdownMenuItem(child: Text('店外待機'), value: '-3'),
            DropdownMenuItem(child: Text('出勤要請'), value: '4'),
            DropdownMenuItem(child: Text('拒否'), value: '-2'),
          ],
          tapFunc: (v) {
            shiftType = v;
          },
        )),
        actions: [
          PrimaryColButton(
              label: '更新',
              tapFunc: () async {
                await ClShift().updateShiftStatus(context, shiftId, shiftType);
                Navigator.pop(context);
              }),
          CancelColButton(
              label: 'キャンセル', tapFunc: () => Navigator.of(context).pop()),
        ],
      ),
    ).then((value) {
      refreshLoad();
    });
  }

  void updateReserveItem(ShiftDayModel data) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgUpdateReserve(
            reserveTime: data.strFromTime,
            organStaffs: organStaffs,
            reserveId: data.reserveId,
            staffId: data.staffId,
          );
        }).then((_) async {
      await refreshLoad();
    });
  }

  Future<void> freeAutoStaff() async {
    bool conf =
        await Dialogs().confirmDialog(context, 'フリーの施術（予約）をスタッフ自動選択しますか？');
    if (!conf) return;

    Dialogs().loaderDialogNormal(context);
    await ClShift().updateFreeReserveAuto(
        context,
        DateFormat('yyyy-MM-dd').format(selectedDate),
        selOrganId!,
        globals.staffId);
    await refreshLoad();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'シフト詳細';
    return MainBodyWdiget(
      fullScreenButton: _fullScreenButtons(),
      fullscreenTop: MediaQuery.of(context).size.width > 600 ? 40 : 95,
      isFullScreen: isHideBannerBar,
      render: LoadBodyWdiget(
        loadData: loadData,
        render: Container(
          color: bodyColor,
          child: Column(
            children: [
              _getTopContent(),
              _getDetailViewPanel(),
              if (widget.isEdit)
                RowButtonGroup(widgets: [
                  WhiteButton(label: 'スタッフの追加', tapFunc: () => addStaffList()),
                  SizedBox(width: 12),
                  WhiteButton(label: 'フリー自動', tapFunc: () => freeAutoStaff())
                ]),
              if (isDetail) _getDetailContent(),
              if (isApply) _getApplyContent(),
              if (isReschedule) _getReScheduleContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fullScreenButtons() {
    return Column(children: [
      FullScreenButton(icon: Icons.refresh, tapFunc: () => refreshLoad()),
      FullScreenButton(
          icon: isHideBannerBar ? Icons.fullscreen_exit : Icons.fullscreen,
          tapFunc: () => setFullScreenMode())
    ]);
  }

  Widget _getTopContent() {
    return Container(
        padding: EdgeInsets.all(5),
        child: MediaQuery.of(context).size.width > 600
            ? Row(children: [
                _getTopSelectDate(),
                Expanded(child: Container()),
                Container(width: 450, child: _getTopOrganSelect()),
              ])
            : Column(children: [
                _getTopSelectDate(),
                SizedBox(height: 12),
                Container(child: _getTopOrganSelect()),
              ]));
  }

  Widget _getTopSelectDate() {
    return Row(
      children: [
        IconButton(
            onPressed: () => pushMoveDate(-1),
            icon: Icon(Icons.arrow_back_ios)),
        Container(
            child: SubHeaderText(
                label: DateTimes().convertJPYMDFromDateTime(selectedDate))),
        IconButton(
            onPressed: () => pushMoveDate(1),
            icon: Icon(Icons.arrow_forward_ios)),
        IconButton(
            onPressed: () => selectDateMove(),
            icon: Icon(Icons.calendar_today, color: Colors.blue))
      ],
    );
  }

  Widget _getTopOrganSelect() {
    return Row(
      children: [
        SizedBox(width: 60),
        InputLeftText(label: '店名', width: 60, rPadding: 8),
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
            addStaffs = [];
            selOrganId = v!.toString();
            refreshLoad();
          },
        )),
        SizedBox(width: 8),
        if (widget.isEdit)
          Container(
              child: WhiteButton(
                  label: 'シフト申請 ', tapFunc: () => setSubmitShift(selectedDate)))
      ],
    );
  }

  Widget _getDetailViewPanel() {
    return Expanded(
        child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          _getTimeRow(),
          Expanded(child: SingleChildScrollView(child: _getShiftView()))
        ],
      ),
    ));
  }

  /* detail grid style start */
  var gridColor = Color(0xffadadad);
  double staffWidth = 90;
  double timeHeight = 40;
  double gridHeight = 60;
  double shiftHeight = 50;
  double reserveHeight = 40;

  Widget _getTimeRow() {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: gridColor))),
      child: Row(
        children: [
          Container(alignment: Alignment.center, width: staffWidth),
          ...times.map(
            (e) => Container(
              width: timeWidth,
              child: _getTimeContent(e.toString()),
              padding: EdgeInsets.only(bottom: 5),
              alignment: Alignment.bottomLeft,
              height: timeHeight,
            ),
          )
        ],
      ),
    );
  }

  Widget _getTimeContent(h) {
    return Container(
      width: 25,
      height: 25,
      child: Text(h, style: TextStyle(color: Colors.white, fontSize: 14)),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Color(0xff666666), borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _getShiftView() {
    return SafeArea(
        // child: SingleChildScrollView(
        //     scrollDirection: Axis.horizontal,
        child: Stack(
      children: [
        SizedBox(height: timeHeight),
        Column(
          children: [
            ...staffs.map(
              (e) => LongPressDraggable(
                data: {'mode': 'staff_sort', 'key': e},
                child: DragTarget(
                  builder: (context, candidateData, rejectedData) =>
                      _getGridRow(e),
                  onAccept: (item) => dragComplete(item, e),
                ),
                feedback: Container(
                    child: Text(
                  staffNames[e],
                  style: TextStyle(color: Colors.grey),
                )),
              ),
            ),
          ],
        ),
        ...shifts.map((e) => _getShiftContent(e)),
        ...reserves.map((e) => _getShiftContent(e)),
      ],
      // )
    ));
  }

  Widget _getGridRow(item) {
    return Container(
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            width: staffWidth,
            child: Text(staffNames[item]),
            height: gridHeight,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4),
              border: Border(
                bottom: BorderSide(width: 1, color: gridColor),
              ),
            ),
          ),
          ...times.map(
            (e) => Row(
              children: [
                for (int i = 0; i < 4; i++)
                  Container(
                    height: gridHeight,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                            width: (i == 0 ? 4 : (i == 2 ? 2 : 1)),
                            color: gridColor),
                        bottom: (times.indexOf(e) < times.length - 1 &&
                                times.elementAt((times.indexOf(e) + 1)) !=
                                    (e + 1))
                            ? BorderSide.none
                            : BorderSide(width: 1, color: gridColor),
                      ),
                    ),
                    width: timeWidth / 4,
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getShiftContent(e) {
    double _top = gridHeight * staffs.indexOf(e.staffId).toDouble() +
        (gridHeight - shiftHeight) / 2;
    double _left = staffWidth + (times.indexOf(e.fromH) + e.fromM) * timeWidth;
    num _length = timeWidth * e.length;
    var shiftColor = Colors.purple.withOpacity(0.5);
    String shiftComment = '';
    if (e.type == '1') {
      shiftColor = Colors.blue;
      shiftComment = '申請中';
    }
    if (e.type == '2') {
      shiftColor = Colors.green;
      shiftComment = '承認';
    }
    if (e.type == '-3') {
      shiftColor = Colors.red;
      shiftComment = '店外待機';
    }
    if (e.type == '4') {
      shiftColor = Colors.orange;
      shiftComment = '出勤要請';
    }
    if (e.type == '-2') {
      shiftColor = Colors.red;
      shiftComment = '拒否';
    }

    if (e.type == '0') {
      shiftColor = Colors.purple;
      shiftComment = '予約';
    }

    return Positioned(
        top: e.type == '0' ? _top + (shiftHeight - reserveHeight) : _top,
        left: _left,
        child: GestureDetector(
          child: e.type == '0' && e.staffId == '0' && widget.isEdit
              ? LongPressDraggable(
                  data: {'mode': 'reserve', 'key': e.reserveId},
                  feedback: Container(
                      child: Text(
                    e.userName,
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey,
                        decoration: TextDecoration.none),
                  )),
                  child: _getShiftEachContent(
                      e, shiftColor, shiftComment, _length),
                )
              : _getShiftEachContent(e, shiftColor, shiftComment, _length),
          onTap: () {
            viewDetail(e);
          },
          onLongPress: () {
            if (e.type != '0') updateShiftStaus(e.shiftId, e.type);
          },
        ));
  }

  Widget _getShiftEachContent(e, shiftColor, shiftComment, _length) {
    return Row(children: [
      Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            ' ' + shiftComment,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          if (e.type == '0')
            Text(
              e.fromTime + '~' + e.toTime,
              style: TextStyle(fontSize: 9),
            ),
        ]),
        height: e.type == '0' ? reserveHeight : shiftHeight,
        width: _length.toDouble(),
        decoration:
            BoxDecoration(color: shiftColor, border: Border.all(width: 0.2)),
      ),
      if (int.parse(e.reserveInterval) > 0)
        Container(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            if (e.type == '0')
              Text(
                e.reserveInterval + '分',
                style: TextStyle(fontSize: 9),
              ),
          ]),
          height: e.type == '0' ? reserveHeight : shiftHeight,
          width: timeWidth * (int.parse(e.reserveInterval) / 60),
          decoration:
              BoxDecoration(color: Colors.grey, border: Border.all(width: 0.2)),
        ),
    ]);
  }

  /* detail content style start */
  var amountTxtStyle = TextStyle(fontSize: 16);

  Widget _getDetailContent() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
          border: Border.all(width: 2, color: Color(0xffffbd79)),
          color: Color(0xfffaffce)),
      // height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(
              detailData!.userName + '(' + detailData!.userSex + ')',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return AdminUserInfo(userId: detailData!.userId);
                  }));
                },
                icon: Icon(Icons.link, color: Colors.blue)),
            Expanded(child: Container()),
            WhiteButton(
                label: '施術変更', tapFunc: () => updateReserveItem(detailData!)),
            IconButton(
                onPressed: () {
                  isDetail = false;
                  setState(() {});
                },
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey))
          ]),
          SizedBox(height: 8),
          Text(
              detailData!.menus.toString() +
                  '  ' +
                  Funcs().dateTimeFormatJP1(detailData!.strFromTime),
              style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Row(children: [
            Container(
                width: 120, child: Text('クレジット: ', style: amountTxtStyle)),
            Container(
                child: Text(
                    detailData!.payMethod == "1"
                        ? (Funcs().currencyFormat(detailData!.allAmount) + '円')
                        : '',
                    style: amountTxtStyle)),
          ]),
          Row(children: [
            Container(width: 120, child: Text('回数券: ', style: amountTxtStyle)),
            Container(child: Text('', style: amountTxtStyle)),
          ]),
          Row(children: []),
          Row(children: [
            Container(width: 120, child: Text('店払い: ', style: amountTxtStyle)),
            Container(
                child: Text(
                    detailData!.payMethod == "2"
                        ? (Funcs().currencyFormat(detailData!.allAmount) + '円')
                        : '',
                    style: amountTxtStyle)),
          ]),
        ],
      ),
    );
  }

  Widget _getApplyContent() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.grey),
          color: Colors.grey.withOpacity(0.3)),
      // height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text('次の申請を承認しますか？ '),
            Expanded(child: Container()),
            IconButton(
                onPressed: () {
                  isApply = false;
                  setState(() {});
                },
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey))
          ]),
          Row(
            children: [
              Text(
                detailData!.staffName,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 40),
              Text(detailData!.fromTime + '~' + detailData!.toTime,
                  style: TextStyle(fontSize: 16)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              PrimaryButton(
                  label: '承認',
                  tapFunc: () => updateShiftStatus(detailData!.shiftId, '2')),
              Expanded(child: Container()),
              DeleteButton(
                  label: '保留',
                  tapFunc: () => updateShiftStatus(detailData!.shiftId, '-2')),
            ],
          )
        ],
      ),
    );
  }

  Widget _getReScheduleContent() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.grey),
          color: Colors.grey.withOpacity(0.3)),
      // height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text('スケジュールの変更'),
            Expanded(child: Container()),
            IconButton(
                onPressed: () {
                  isReschedule = false;
                  setState(() {});
                },
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey))
          ]),
          Row(
            children: [
              Text(
                detailData!.staffName,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 40),
              Text('', //detailData!.fromTime + '~' + detailData!.toTime,
                  style: TextStyle(fontSize: 16)),
            ],
          ),
          PosTimeRange(
              selectDate: shiftScheduleDate,
              fromTime: shiftScheduleFromTime,
              toTime: shiftScheduleToTime,
              confFromFunc: (date) {
                shiftScheduleFromTime =
                    Funcs().getDurationTime(date, isShowSecond: true);
                setState(() {});
              },
              confToFunc: (date) {
                shiftScheduleToTime =
                    Funcs().getDurationTime(date, isShowSecond: true);
                setState(() {});
              }),
          SizedBox(height: 40),
          Row(
            children: [
              PrimaryButton(
                  label: '変更',
                  tapFunc: () => updateShiftTime(detailData!.shiftId)),
              Expanded(child: Container()),
              CancelButton(
                  label: 'キャンセル',
                  tapFunc: () {
                    isReschedule = false;
                    setState(() {});
                  }),
            ],
          )
        ],
      ),
    );
  }
}
