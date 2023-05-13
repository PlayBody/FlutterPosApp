import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/business/staffs.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/staffpointaddmodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';

class StaffPointSubmit extends StatefulWidget {
  final String selectStaffId;
  const StaffPointSubmit({required this.selectStaffId, Key? key})
      : super(key: key);

  @override
  State<StaffPointSubmit> createState() => _StaffPointSubmit();
}

class _StaffPointSubmit extends State<StaffPointSubmit> {
  late Future<List> loadData;

  String selYear = DateFormat('yyyy').format(DateTime.now());
  String selMonth = DateFormat('MM').format(DateTime.now());

  List<OrganModel> organs = [];
  String? selOrgan;

  List<StaffPointAddModel> points = [];
  String sumPoints = '0';

  String? selProTime;

  @override
  void initState() {
    super.initState();
    loadData = loadStaffPointData();
  }

  Future<List> loadStaffPointData() async {
    selProTime = null;
    if (selOrgan == null) {
      organs = await ClOrgan().loadOrganList(context, '', widget.selectStaffId);

      if (organs.length > 0) {
        selOrgan = organs.first.organId;
      }
    }

    if (selOrgan != null) {
      var pointData = await ClStaff().loadStaffAddPoints(
          context, selOrgan!, widget.selectStaffId, selYear, selMonth);

      points = pointData['points'];
      sumPoints = pointData['sum_points'].toString();
    }

    setState(() {});
    return [];
  }

  Future<void> submitAddPoint(type) async {
    if (selOrgan == null) {
      Dialogs().infoDialog(context, '店舗を選択してください。');
      return;
    }

    if (type == '2' && selProTime == null) {
      Dialogs().infoDialog(context, '時間を選択してください。');
      return;
    }
    bool conf = await Dialogs().confirmDialog(context, '追加ポイントを申し込みますか？');
    if (!conf) return;

    Map<dynamic, dynamic> results = {};

    await Webservice().loadHttp(context, apiStaffAddpointSubmitUrl, {
      'staff_id': widget.selectStaffId,
      'organ_id': selOrgan,
      'date_year': selYear,
      'date_month': selMonth,
      'time': selProTime == null ? '1' : selProTime!,
      'point_type': type
    }).then((value) => results = value);

    if (results['isSave']) {
      loadStaffPointData();
    }
  }

  Future<void> deleteAddpoints(pointId) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;

    Dialogs().loaderDialogNormal(context);
    bool isDelete = await ClStaff().deleteStaffAddPoint(context, pointId);
    Navigator.pop(context);

    if (!isDelete) {
      Dialogs().infoDialog(context, errServerActionFail);
      return;
    }

    loadStaffPointData();
  }

  Future<void> applyAddpoints(pointId) async {
    bool conf = await Dialogs().confirmDialog(context, 'ポイント申請を承認しますか？');
    if (!conf) return;

    Dialogs().loaderDialogNormal(context);
    bool isUpdate = await ClStaff().applyStaffAddPoint(context, pointId);
    Navigator.pop(context);

    if (!isUpdate) {
      Dialogs().infoDialog(context, errServerActionFail);
      return;
    }

    loadStaffPointData();
  }

  Future<void> dateMove(type) async {
    int tmpMonth = int.parse(selMonth);
    int tmpYear = int.parse(selYear);
    if (type == 'prev') {
      if (tmpMonth <= 1) {
        tmpMonth = 12;
        tmpYear = tmpYear - 1;
      } else {
        tmpMonth = tmpMonth - 1;
      }
    }
    if (type == 'next') {
      if (tmpMonth >= 12) {
        tmpMonth = 1;
        tmpYear = tmpYear + 1;
      } else {
        tmpMonth = tmpMonth + 1;
      }
    }

    selMonth =
        tmpMonth < 10 ? ('0' + tmpMonth.toString()) : tmpMonth.toString();
    selYear = tmpYear.toString();

    setState(() {});

    loadStaffPointData();
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'ポイント申請';
    return MainBodyWdiget(
        render: FutureBuilder<List>(
      future: loadData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(child: _getBodyContent());
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return const Center(child: CircularProgressIndicator());
      },
    ));
  }

  double gMargin = 45;
  double gSpacing = 12;

  Widget _getBodyContent() {
    return Container(
      color: const Color(0xfffbfbfb),
      child: Column(
        children: [
          _getOrganList(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  if (widget.selectStaffId == globals.staffId)
                    Row(
                      children: [
                        SizedBox(width: gMargin),
                        _getPointButton('飛び込み\n獲得', () => submitAddPoint('1')),
                        SizedBox(width: gSpacing),
                        _getPointButtonWithDropDown(
                            '販促', 120, () => submitAddPoint('2')),
                        SizedBox(width: gMargin),
                      ],
                    ),
                  if (widget.selectStaffId == globals.staffId)
                    SizedBox(height: gSpacing),
                  if (widget.selectStaffId == globals.staffId)
                    Row(
                      children: [
                        SizedBox(width: gMargin),
                        _getPointButton('次回予約\n獲得', () => submitAddPoint('3')),
                        SizedBox(width: gSpacing),
                        _getPointButton('延長獲得', () => submitAddPoint('4')),
                        SizedBox(width: gMargin),
                      ],
                    ),
                  if (widget.selectStaffId == globals.staffId)
                    SizedBox(height: gSpacing),
                  if (widget.selectStaffId == globals.staffId)
                    Row(
                      children: [
                        SizedBox(width: gMargin),
                        _getPointButton('オプション\n獲得', () => submitAddPoint('5')),
                        const SizedBox(width: 16),
                        Expanded(child: Container()),
                        SizedBox(width: gMargin),
                      ],
                    ),
                  if (widget.selectStaffId == globals.staffId)
                    const SizedBox(height: 10),
                  _getMonthNavContent(),
                  const Text(
                    '獲得履歴',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '獲得ポイント合計　$sumPoints ポイント',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      ...points.map((e) => Row(
                            children: [
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  DateFormat('MM月dd日')
                                      .format(DateTime.parse(e.cdate)),
                                ),
                              ),
                              Expanded(child: Text(e.comment)),
                              SizedBox(
                                  width: 90, child: Text('${e.value}ポイント')),
                              if (widget.selectStaffId == globals.staffId)
                                SizedBox(
                                    width: e.status == '1' ? 50 : 80,
                                    child: e.status == '1'
                                        ? const LabelButton(label: '申請中')
                                        : const LabelButton(label: '承認済み')),
                              if (e.status == '1' &&
                                  widget.selectStaffId == globals.staffId)
                                Container(
                                    padding: const EdgeInsets.only(left: 5),
                                    width: 30,
                                    child: IconWhiteButton(
                                      icon: Icons.cancel,
                                      color: Colors.red,
                                      tapFunc: () => deleteAddpoints(e.pointId),
                                    )),
                              // Container(
                              //     padding: EdgeInsets.only(left: 5),
                              //     width: 30,
                              //     child: IconWhiteButton(
                              //       icon: Icons.check,
                              //       color: globals.auth > AUTH_STAFF && e.status == '1'
                              //           ? Colors.green
                              //           : Colors.grey,
                              //       tapFunc: globals.auth > AUTH_STAFF && e.status == '1'
                              //           ? () => applyAddpoints(e.pointId)
                              //           : null,
                              //     )),
                              const SizedBox(width: 20),
                            ],
                          ))
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getOrganList() {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '店舗',
              style: TextStyle(fontSize: 18, color: primaryColor),
            ),
          ),
          Expanded(
            child: DropDownModelSelect(
              value: selOrgan,
              items: [
                ...organs.map(
                  (e) => DropdownMenuItem(
                    value: e.organId,
                    child: Text(e.organName),
                  ),
                )
              ],
              tapFunc: (v) {
                selOrgan = v;
                loadStaffPointData();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _getPointButton(label, tamFunc) {
    return Expanded(
      child: GestureDetector(
        onTap: tamFunc,
        child: Container(
          alignment: Alignment.center,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xffd9e1e5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _getPointButtonWithDropDown(label, max, tamFunc) {
    return Expanded(
      child: GestureDetector(
        onTap: tamFunc,
        child: Container(
          alignment: Alignment.center,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xffd9e1e5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: [
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
                width: 60,
                child: DropDownNumberSelect(
                    value: selProTime,
                    max: max,
                    tapFunc: (v) {
                      selProTime = v;
                    },
                    contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8)))
          ]),
        ),
      ),
    );
  }

  Widget _getMonthNavContent() {
    return Row(
      children: [
        Expanded(child: Container()),
        TextButton(onPressed: () => dateMove('prev'), child: const Text('<<')),
        Text(
          '$selYear年 ${int.parse(selMonth)}月',
          style: const TextStyle(fontSize: 18),
        ),
        TextButton(onPressed: () => dateMove('next'), child: const Text('>>')),
        Expanded(child: Container()),
      ],
    );
  }
}
