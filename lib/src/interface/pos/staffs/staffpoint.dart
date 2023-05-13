import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/notification.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/business/staffs.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/model/menuvariationmodel.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/staffpointaddmodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';

class StaffPoint extends StatefulWidget {
  final String staffId;
  const StaffPoint({required this.staffId, Key? key}) : super(key: key);

  @override
  _StaffPoint createState() => _StaffPoint();
}

class _StaffPoint extends State<StaffPoint> {
  late Future<List> loadData;

  String selYear = DateFormat('yyyy').format(DateTime.now());
  String selMonth = DateFormat('MM').format(DateTime.now());

  List<OrganModel> organs = [];
  String? selOrgan;

  List<StaffPointAddModel> points = [];
  String sumPoints = '0';

  String? selQuantity;
  MenuVariationModel? record;

  String? testAdditionalRate;
  String? qualityAdditionalRate;

  String? settingId;
  String? allMenuValue;

  var txtAddRateController = TextEditingController();
  var txtTestRateController = TextEditingController();
  var txtQualityRateController = TextEditingController();
  var txtPointCommentController = TextEditingController();
  var txtPointValueController = TextEditingController();
  bool isAddPoint = false;

  @override
  void initState() {
    super.initState();
    loadData = loadPointData();
  }

  Future<List> loadPointData() async {
    if (selOrgan == null) {
      organs = await ClOrgan().loadOrganList(context, '', widget.staffId);
      if (organs.length > 0) selOrgan = organs.first.organId;
    }

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadStaffPointUrl, {
      'staff_id': widget.staffId,
      'organ_id': selOrgan == null ? '' : selOrgan,
      'setting_year': selYear,
      'setting_month': selMonth
    }).then((v) => results = v);

    points = [];
    if (results['isLoad']) {
      var pointSetting = results['point_setting'];
      if (pointSetting != null) {
        settingId = pointSetting['id'].toString();
        allMenuValue = pointSetting['menu_response'];
        txtTestRateController.text = pointSetting['test_rate'] == null
            ? ''
            : pointSetting['test_rate'].toString();
        txtQualityRateController.text = pointSetting['quality_rate'] == null
            ? ''
            : pointSetting['quality_rate'].toString();
        txtAddRateController.text = pointSetting['add_rate'] == null
            ? ''
            : pointSetting['add_rate'].toString();
      } else {
        settingId = null;
        allMenuValue = null;
        txtTestRateController.text = '';
        txtQualityRateController.text = '';
        txtAddRateController.text = '';
      }

      for (var item in results['point_add_list']) {
        points.add(StaffPointAddModel.fromJson(item));
      }

      // allMenuValue = results['staff']['staff_all_menu_response'];
      // testAdditionalRate = results['staff']['staff_test_additional_rate'];
      // qualityAdditionalRate = results['staff']['staff_quality_additional_rate'];
      setState(() {});
    }

    ClNotification().removeBadge(context, globals.staffId, '3');
    return [];
  }

  Future<void> savePointSetting() async {
    bool isCheck = true;
    if (allMenuValue == null) {
      Dialogs().infoDialog(context, warningStaffPointAllMenuSelect);
      return;
    }
    if (txtAddRateController.text == '') {
      isCheck = false;
    }
    if (txtTestRateController.text == '') {
      isCheck = false;
    }
    if (txtQualityRateController.text == '') {
      isCheck = false;
    }
    if (!isCheck) {
      Dialogs().infoDialog(context, warningFormInputErr);
      return;
    }

    Map<dynamic, dynamic> results = {};

    await Webservice().loadHttp(context, apiSaveStaffPointUrl, {
      'setting_id': settingId ?? '',
      'staff_id': widget.staffId.toString(),
      'setting_year': selYear,
      'setting_month': selMonth,
      'menu_response': allMenuValue,
      'add_rate': txtAddRateController.text,
      'test_rate': txtTestRateController.text,
      'quality_rate': txtQualityRateController.text,
    }).then((v) => results = v);

    if (results['isSave']) {
      Navigator.of(context).pop();
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> saveAddPoint() async {
    bool isCheck = true;
    if (selOrgan == null) {
      isCheck = false;
    }
    if (txtPointCommentController.text == '') {
      isCheck = false;
    }
    if (txtPointValueController.text == '') {
      isCheck = false;
    }
    if (!isCheck) {
      Dialogs().infoDialog(context, warningFormInputErr);
      return;
    }

    Map<dynamic, dynamic> results = {};

    await Webservice().loadHttp(context, apiSavePointAddUrl, {
      'point_setting_id': settingId,
      'organ_id': selOrgan,
      'comment': txtPointCommentController.text,
      'value': txtPointValueController.text
    }).then((v) => results = v);

    if (results['isSave']) {
      isAddPoint = false;
      txtPointCommentController.clear();
      txtPointValueController.clear();
      loadPointData();
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> deleteAddPoint(String delId) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;

    Map<dynamic, dynamic> results = {};

    await Webservice().loadHttp(context, apiDeletePointAddUrl,
        {'point_add_id': delId}).then((v) => results = v);

    if (results['isDelete']) {
      loadPointData();
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
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

    loadPointData();
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

    loadPointData();
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = '給与ポイント';
    return MainBodyWdiget(
        resizeBottom: true,
        render: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(child: _getContent());
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }

  Widget _getContent() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _getMonthNavContent(),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(children: [
            const PageSubHeader(label: 'ポイント設定'),
            const SizedBox(height: 12),
            _getPersionalSetting(),
            _getBottomButtons(),
            const PageSubHeader(label: '追加ポイント'),
            _getOrganList(),
            const SizedBox(height: 12),
            if (!isAddPoint && settingId != null) _getAddPointButton(),
            if (isAddPoint)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                color: const Color(0xFFf3f3f3),
                child: Column(
                  children: [
                    _getAddPointComment(),
                    const SizedBox(height: 12),
                    _getAddPointValue(),
                    const SizedBox(height: 12),
                    _getAddPointButtons(),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            _getAddPointList(),
            const SizedBox(height: 12),
          ])))
        ],
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

  Widget _getPersionalSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          _getAllMenuSelect(),
          const SizedBox(height: 8),
          _getPersionalRate(),
          const SizedBox(height: 8),
          _getTestAdditionalRate(),
          const SizedBox(height: 8),
          _getQualityAdditionalRate(),
        ],
      ),
    );
  }

  double gMargin = 45;
  double gSpacing = 12;

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
                loadPointData();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _getAllMenuSelect() {
    return RowLabelInput(
      label: '全メニュー対応',
      labelWidth: 130,
      renderWidget: DropDownModelSelect(
        value: allMenuValue,
        items: [
          ...constStaffPointAllMenu.map(
              (e) => DropdownMenuItem(value: e['key'], child: Text(e['val'])))
        ],
        tapFunc: (v) => allMenuValue = v.toString(),
      ),
    );
  }

  Widget _getPersionalRate() {
    return RowLabelInput(
      label: '個人レート',
      labelWidth: 130,
      renderWidget: TextInputNormal(
        contentPadding: 10,
        controller: txtAddRateController,
        inputType:
            const TextInputType.numberWithOptions(decimal: true, signed: true),
      ),
    );
  }

  Widget _getTestAdditionalRate() {
    return RowLabelInput(
      label: '試験追加レート',
      labelWidth: 130,
      renderWidget: TextInputNormal(
        contentPadding: 10,
        controller: txtTestRateController,
        inputType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  Widget _getQualityAdditionalRate() {
    return RowLabelInput(
      label: '資格追加レート',
      labelWidth: 130,
      renderWidget: TextInputNormal(
        contentPadding: 10,
        controller: txtQualityRateController,
        inputType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  Widget _getBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      child: Row(
        children: [
          PrimaryButton(label: "保存", tapFunc: () => savePointSetting()),
          Container(width: 12),
          CancelButton(
              label: "保存せず戻る", tapFunc: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  Widget _getAddPointButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      child: WhiteButton(
        label: 'ポイント個別追加',
        tapFunc: () {
          setState(() {
            isAddPoint = true;
          });
        },
      ),
    );
  }

  Widget _getAddPointComment() {
    return RowLabelInput(
        labelWidth: 130,
        label: '理由',
        renderWidget: TextInputNormal(
            controller: txtPointCommentController, contentPadding: 10));
  }

  Widget _getAddPointValue() {
    return RowLabelInput(
        labelWidth: 130,
        label: '追加ポイント',
        renderWidget: TextInputNormal(
          controller: txtPointValueController,
          inputType: TextInputType.number,
          contentPadding: 10,
        ));
  }

  Widget _getAddPointList() {
    return Column(
      children: [
        if (points.isNotEmpty) const Text('追加履歴'),
        ...points.map((e) => Row(
              children: [
                const SizedBox(width: 20),
                SizedBox(
                  width: 70,
                  child: Text(
                    DateFormat('MM月dd日').format(DateTime.parse(e.cdate)),
                  ),
                ),
                Expanded(child: Text(e.comment)),
                SizedBox(width: 90, child: Text('${e.value}ポイント')),
                SizedBox(
                  width: 70,
                  child: e.status == '1'
                      ? LabelButton(
                          label: '承認',
                          color: primaryColor,
                          tapFunc: () => applyAddpoints(e.pointId))
                      : LabelButton(
                          label: '削除',
                          color: redColor,
                          tapFunc: () => deleteAddPoint(e.pointId),
                        ),
                ),
                const SizedBox(width: 20),
              ],
            ))
      ],
    );
  }

  Widget _getAddPointButtons() {
    return Row(
      children: [
        const SizedBox(width: 30),
        PrimaryButton(label: '追加', tapFunc: () => saveAddPoint()),
        const SizedBox(width: 8),
        CancelButton(
          label: 'キャンセル',
          tapFunc: () {
            setState(() {
              isAddPoint = false;
            });
          },
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}
