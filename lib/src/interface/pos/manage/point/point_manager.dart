import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/master.dart/point_settings.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/business/point.dart';
import 'package:staff_pos_app/src/common/business/staffs.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/bottom_input_form.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/pos/manage/point/dlg_point_submit.dart';
import 'package:staff_pos_app/src/model/master/point_rate_special_limit_model.dart';
import 'package:staff_pos_app/src/model/organ_point_setting_model.dart';
import 'package:staff_pos_app/src/model/master/point_rate_special_period_model.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/stafflistmodel.dart';
import 'package:staff_pos_app/src/model/staffpointaddmodel.dart';

class PointManager extends StatefulWidget {
  const PointManager({Key? key}) : super(key: key);

  @override
  State<PointManager> createState() => _PointManager();
}

class _PointManager extends State<PointManager> {
  late Future<List> loadData;

  List<OrganModel> organs = [];
  List<StaffPointAddModel> submitPoints = [];
  List<StaffPointAddModel> confirmPoints = [];
  List<OrganPointSettingModel> pointSettings = [];
  List<StaffListModel> confirmStaffs = [];

  DateTime submitDate = DateTime.now();
  String confirmDateYear = DateTime.now().year.toString();
  String confirmDateMonth = DateTime.now().month.toString();

  String? submitOrganId;
  String? confirmOrganId;
  String? settingOrganId;
  String? settingPoint;
  String? settingPointType;
  String? selConfirmStaff;
  String? selConfirmPointType;

  var txtSetTitleController = TextEditingController();
  int sumSubmitPoints = 0;

  String? speicalOrganId;
  List<PointRateSpecialPeriodModel> specialPeriodRates = [];
  List<PointRateSpecialLimitModel> specialLimitRates = [];
  PointRateSpecialLimitModel? speicialDayOverRate;
  PointRateSpecialLimitModel? speicialReserveOverRate;
  PointRateSpecialLimitModel? speicialTimeMinRate;
  PointRateSpecialLimitModel? speicialTimeOverRate;
  var txtPeriodDaysController = TextEditingController();
  var txtPeriodRateController = TextEditingController();
  String? selPeriodM1;
  String? selPeriodD1;
  String? selPeriodM2;
  String? selPeriodD2;
  String? selSepcialPeriodPointId;
  String? selSepcialLimitPointId;

  String? selLimitValue;
  var txtLimitRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData = loadInitData();
  }

  Future<List> loadInitData() async {
    settingPointType = null;
    settingPoint = null;
    pointSettings = [];
    submitPoints = [];
    confirmPoints = [];
    sumSubmitPoints = 0;

    organs = await ClOrgan().loadOrganList(context, '', globals.staffId);

    if (organs.isNotEmpty) {
      submitOrganId ??= organs.first.organId;
      confirmOrganId ??= organs.first.organId;
      settingOrganId ??= organs.first.organId;
      speicalOrganId ??= organs.first.organId;
    }

    if (settingOrganId != null) {
      pointSettings =
          // ignore: use_build_context_synchronously
          await ClPoint().loadOrganPointSettings(context, settingOrganId);
    }

    if (submitOrganId != null) {
      // ignore: use_build_context_synchronously
      submitPoints = await ClPoint().loadStaffPoints(context, {
        'staff_id': globals.staffId,
        'organ_id': submitOrganId,
        'point_date': DateFormat('yyyy-MM-dd').format(submitDate),
        // 'status': '1'
      });

      for (var element in submitPoints) {
        sumSubmitPoints = sumSubmitPoints +
            int.parse(element.weight) * int.parse(element.value);
      }
    }
    confirmStaffs = [];
    if (confirmOrganId != null) {
      // ignore: use_build_context_synchronously
      confirmPoints = await ClPoint().loadStaffPoints(context, {
        'organ_id': confirmOrganId!,
        'staff_id': selConfirmStaff ?? '',
        'point_setting_id': selConfirmPointType ?? '',
        'point_month':
            '$confirmDateYear-${int.parse(confirmDateMonth) < 10 ? '0' : ''}$confirmDateMonth',
        //'status': '1'
      });

      confirmStaffs =
          // ignore: use_build_context_synchronously
          await ClStaff().loadStaffs(context, {'organ_id': confirmOrganId!});

      // confirmPoints.forEach((element) => sumSubmitPoints = sumSubmitPoints +
      // int.parse(element.weight) * int.parse(element.value));
    }

    txtSetTitleController.clear();
    settingPoint = '1';

    await loadPointSpecialSettings();

    setState(() {});
    return [];
  }

  Future<void> loadPointSpecialSettings() async {
    specialPeriodRates = await PointMaster()
        .loadPointSettingSpecialPeriod(context, speicalOrganId);
    // ignore: use_build_context_synchronously
    specialLimitRates = await PointMaster()
        .loadPointSettingSpecialLimit(context, speicalOrganId);

    speicialDayOverRate =
        specialLimitRates.where((element) => element.type == '3').isEmpty
            ? null
            : specialLimitRates.firstWhere((element) => element.type == '3');

    speicialReserveOverRate =
        specialLimitRates.where((element) => element.type == '4').isEmpty
            ? null
            : specialLimitRates.firstWhere((element) => element.type == '4');
    speicialTimeOverRate =
        specialLimitRates.where((element) => element.type == '2').isEmpty
            ? null
            : specialLimitRates.firstWhere((element) => element.type == '2');
    if (speicialTimeOverRate == null) {
      speicialTimeMinRate = null;
    } else {
      speicialTimeMinRate =
          specialLimitRates.where((element) => element.type == '1').isEmpty
              ? null
              : specialLimitRates.firstWhere((element) => element.type == '1');
    }
  }

  Future<void> addPointsettings() async {
    bool conf = await Dialogs().confirmDialog(context, qCommonSave);
    if (!conf) return;
    if (settingPointType == null) return;
    if (settingOrganId == null) return;
    if (txtSetTitleController.text == '') return;
    if (settingPoint == null) return;

    // ignore: use_build_context_synchronously
    Dialogs().loaderDialogNormal(context);
    // ignore: use_build_context_synchronously
    await ClPoint().saveOrganPointSetting(context, settingOrganId!,
        txtSetTitleController.text, settingPoint!, settingPointType!);
    loadInitData();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> deletePointsettings(_id) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;

    // ignore: use_build_context_synchronously
    Dialogs().loaderDialogNormal(context);
    // ignore: use_build_context_synchronously
    await ClPoint().deleteOrganPointSetting(context, _id);
    loadInitData();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> selectDateMove(type, date) async {
    final DateTime? selected = await showDatePicker(
      locale: const Locale("ja"),
      context: context,
      initialDate: date,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );

    if (selected != null) {
      if (type == 'submit') submitDate = selected;

      loadInitData();
    }
  }

  void doPointSubmit() {
    if (submitOrganId == null) return;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgPointSubmit(
              organId: submitOrganId!,
              pointDate: DateFormat('yyyy-MM-dd').format(submitDate));
        }).then((_) {
      loadInitData();
    });
  }

  Future<void> deletePointSubmit(_id) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;
    // ignore: use_build_context_synchronously
    Dialogs().loaderDialogNormal(context);
    // ignore: use_build_context_synchronously
    await ClPoint().deleteStaffPoint(context, _id);
    loadInitData();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> applyAndRecjectPoints(_id, _val) async {
    String strMsg = "承認しますか？";
    if (_val == '3') strMsg = "拒否しますか？";
    bool conf = await Dialogs().confirmDialog(context, strMsg);
    if (!conf) return;

    // ignore: use_build_context_synchronously
    Dialogs().loaderDialogNormal(context);
    // ignore: use_build_context_synchronously
    await ClPoint().updatePointStatus(context, _id, _val);
    await loadInitData();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> refreshLoad() async {
    Dialogs().loaderDialogNormal(context);
    await loadInitData();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> refreshSpecialSetting() async {
    Dialogs().loaderDialogNormal(context);
    await loadPointSpecialSettings();
    setState(() {});
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void onChangeConfirmDate(int moveVal) {
    int iMonth = int.parse(confirmDateMonth);
    iMonth = iMonth + moveVal;
    if (iMonth > 12 || iMonth < 1) {
      confirmDateYear = (int.parse(confirmDateYear) + moveVal).toString();
    }
    if (iMonth > 12) iMonth = 1;
    if (iMonth < 1) iMonth = 12;
    confirmDateMonth = iMonth.toString();
    refreshLoad();
  }

  void onChangeConfirmDateToToday() {
    confirmDateMonth = DateTime.now().month.toString();
    confirmDateYear = DateTime.now().year.toString();
    refreshLoad();
  }

  void onChangeConfirmStaff(String? staffId) {
    selConfirmStaff = staffId;
    refreshLoad();
  }

  void onChangeConfirmType(String? pointSettingId) {
    selConfirmPointType = pointSettingId;
    refreshLoad();
  }

  void onChangeSpecialOrganId(v) {
    speicalOrganId = v;
    refreshSpecialSetting();
  }

  Future<void> savePeriodRate() async {
    if (selPeriodM1 == null ||
        selPeriodD1 == null ||
        selPeriodM2 == null ||
        selPeriodD2 == null ||
        txtPeriodDaysController.text == '' ||
        txtPeriodRateController.text == '') {
      Dialogs().infoDialog(context, 'データを入力してください。');
      return;
    }

    String fdM1 =
        int.parse(selPeriodM1!) < 10 ? '0${selPeriodM1!}' : selPeriodM1!;
    String fdD1 =
        int.parse(selPeriodD1!) < 10 ? '0${selPeriodD1!}' : selPeriodD1!;
    String fdM2 =
        int.parse(selPeriodM2!) < 10 ? '0${selPeriodM2!}' : selPeriodM2!;
    String fdD2 =
        int.parse(selPeriodD2!) < 10 ? '0${selPeriodD2!}' : selPeriodD2!;

    // if (int.parse(fdM2 + fdD2) < int.parse(fdM1 + fdD1)) {
    //   Dialogs().infoDialog(context, '期間を正確に入力してください。');
    //   return;
    // }

    bool isConf = await Dialogs().confirmDialog(context, qCommonSave);
    if (!isConf) return;
    // ignore: use_build_context_synchronously
    Dialogs().loaderDialogNormal(context);
    // ignore: use_build_context_synchronously
    await PointMaster().savePointSettingSpecialPeriod(context, {
      'id': selSepcialPeriodPointId ?? '',
      'organ_id': speicalOrganId,
      'from_date': '$fdM1-$fdD1',
      'to_date': '$fdM2-$fdD2',
      'rate_days': txtPeriodDaysController.text,
      'rate': txtPeriodRateController.text
    });
    refreshSpecialSetting();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> deletePeriodRate() async {
    bool isConf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!isConf) return;
    // ignore: use_build_context_synchronously
    Dialogs().loaderDialogNormal(context);
    // ignore: use_build_context_synchronously
    await PointMaster()
        .deletePointSettingSpecialPeriod(context, selSepcialPeriodPointId);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    refreshSpecialSetting();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> saveLimitdRate(type) async {
    if (selLimitValue == null || txtLimitRateController.text == '') {
      Dialogs().infoDialog(context, 'データを入力してください。');
      return;
    }

    bool isConf = await Dialogs().confirmDialog(context, qCommonSave);
    if (!isConf) return;
    // ignore: use_build_context_synchronously
    Dialogs().loaderDialogNormal(context);
    // ignore: use_build_context_synchronously
    await PointMaster().savePointSettingSpecialLimit(context, {
      'id': selSepcialLimitPointId ?? '',
      'organ_id': speicalOrganId,
      'type': type,
      'value': selLimitValue,
      'rate': txtLimitRateController.text
    });
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    refreshSpecialSetting();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> deleteLimitRate() async {
    bool isConf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!isConf) return;
    // ignore: use_build_context_synchronously
    Dialogs().loaderDialogNormal(context);
    // ignore: use_build_context_synchronously
    await PointMaster()
        .deletePointSettingSpecialLimit(context, selSepcialLimitPointId);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    refreshSpecialSetting();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void onTapSpeicalPeriodShow(PointRateSpecialPeriodModel? rate) {
    if (rate == null) {
      selPeriodM1 = selPeriodD1 = selPeriodM2 = selPeriodD2 = null;
      txtPeriodDaysController.text = "";
      txtPeriodRateController.text = "0.05";
      selSepcialPeriodPointId = null;
    } else {
      selSepcialPeriodPointId = rate.id;
      selPeriodM1 = rate.fromDateMonth;
      selPeriodD1 = rate.fromDateDay;
      selPeriodM2 = rate.toDateMonth;
      selPeriodD2 = rate.toDateDay;
      txtPeriodDaysController.text = rate.rateDays;
      txtPeriodRateController.text = rate.rate;
    }
    showSpecialPeriodModal();
  }

  void onTapSpeicalLimitShow(type, PointRateSpecialLimitModel? rate) {
    if (rate == null) {
      selLimitValue = selSepcialLimitPointId = null;
      txtLimitRateController.text = "";
    } else {
      selSepcialLimitPointId = rate.id;
      selLimitValue = rate.value;
      txtLimitRateController.text = rate.rate;
    }
    if (type == '1') {
      txtLimitRateController.text = "0.05";
      showSpecialLimitModal(
          type,
          '同月の出勤時間レート',
          '出勤時間',
          int.parse(speicialTimeOverRate!.value),
          '時間 ~ ${speicialTimeOverRate!.value}時間  レート',
          txtLimitRateController);
    }
    if (type == '2') {
      txtLimitRateController.text = "0.1";
      showSpecialLimitModal(
          type, '同月の出勤時間レート', '出勤時間', 200, '時間以上  レート', txtLimitRateController);
    }
    if (type == '3') {
      selLimitValue = '12';
      txtLimitRateController.text = "0.05";
      showSpecialLimitModal(
          type, '同月の出勤日数レート', '出勤日数', 31, '時間以上  レート', txtLimitRateController);
    }
    if (type == '4') {
      selLimitValue = '50';
      txtLimitRateController.text = "0.05";
      showSpecialLimitModal(
          type, '施術レート', '月', 300, '施術以上  レート', txtLimitRateController);
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'ポイント管理';
    return MainBodyWdiget(
        render: FutureBuilder<List>(
      future: loadData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
              color: bodyColor,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const PageSubHeader(label: 'ポイント申請'),
                    _setSubmitPoints(),
                    const SizedBox(height: 24),
                    if (globals.auth > constAuthStaff)
                      const PageSubHeader(label: 'ポイント承認'),
                    if (globals.auth > constAuthStaff) _getConfirmPoints(),
                    const SizedBox(height: 24),
                    const PageSubHeader(label: '特別レート設定'),
                    _getSpecialContent(),
                    if (globals.auth > constAuthStaff)
                      const PageSubHeader(label: 'ポイント設定'),
                    if (globals.auth > constAuthStaff)
                      _getPointSettingContents(),
                    const SizedBox(height: 124),
                  ],
                ),
              ));
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    ));
  }

  Widget _setSubmitPoints() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RowLabelInput(
              label: '対象月',
              renderWidget: PosDatepicker(
                  selectedDate: submitDate,
                  tapFunc: () => selectDateMove('submit', submitDate))),
          RowLabelInput(
              label: '店名',
              renderWidget: DropDownModelSelect(
                  value: submitOrganId,
                  items: [
                    ...organs.map((e) => DropdownMenuItem(
                        value: e.organId, child: Text(e.organName)))
                  ],
                  tapFunc: (v) {
                    submitOrganId = v;
                    refreshLoad();
                  })),
          ...submitPoints.map((e) => Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                const SizedBox(width: 10),
                Expanded(child: Text(e.comment)),
                Container(
                    alignment: Alignment.centerRight,
                    width: 40,
                    child: Text(
                        '${e.value}${constPointUnit.elementAt(e.pointType - 1).toString()}')),
                Container(
                    alignment: Alignment.centerRight,
                    width: 50,
                    child: Text(
                        (int.parse(e.weight) * int.parse(e.value)).toString())),
                Container(
                    alignment: Alignment.center,
                    width: 80,
                    child: Text(
                        e.status == '1'
                            ? '申請中'
                            : (e.status == '2' ? '承認済み' : '保留'),
                        style: TextStyle(
                            color: e.status == '1'
                                ? Colors.blue
                                : (e.status == '2'
                                    ? Colors.green
                                    : Colors.red)))),
                SizedBox(
                    width: 30,
                    child: e.status == '2'
                        ? null
                        : IconWhiteButton(
                            color: redColor,
                            icon: Icons.delete,
                            tapFunc: () => deletePointSubmit(e.pointId),
                          ))
              ]))),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Text(
                  submitPoints.isNotEmpty
                      ? ('合計ポイント  :  ${sumSubmitPoints}pts')
                      : '申請ポイントはありません。',
                  style: const TextStyle(fontSize: 16))),
          WhiteButton(label: 'ポイント申請', tapFunc: () => doPointSubmit())
        ],
      ),
    );
  }

  Widget _getPointSettingContents() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      child: Column(
        children: [
          RowLabelInput(
              label: '店名',
              renderWidget: DropDownModelSelect(
                value: settingOrganId,
                items: [
                  ...organs.map((e) => DropdownMenuItem(
                      value: e.organId, child: Text(e.organName)))
                ],
                tapFunc: (v) {
                  settingOrganId = v;
                  refreshLoad();
                },
              )),
          Row(children: [
            Flexible(
                child: TextInputNormal(
              controller: txtSetTitleController,
              caption: 'ポイント内容',
            )),
            Flexible(
                child: DropDownNumberSelect(
                    caption: 'ポイント単価',
                    value: settingPoint,
                    max: 99,
                    tapFunc: (v) => settingPoint = v)),
            Flexible(
                child: DropDownModelSelect(
                    caption: 'ポイント単位',
                    value: settingPointType,
                    // ignore: prefer_const_literals_to_create_immutables
                    items: [
                      ...constPointUnit.map((e) => DropdownMenuItem(
                          value: (constPointUnit.indexOf(e) + 1).toString(),
                          child: Text(e))),
                      // const DropdownMenuItem(value: '1', child: Text('回')),
                      // const DropdownMenuItem(value: '2', child: Text('分')),
                      // const DropdownMenuItem(value: '3', child: Text('件')),
                    ],
                    tapFunc: (v) => settingPointType = v)),
            WhiteButton(label: '作成', tapFunc: () => addPointsettings())
          ]),
          ...pointSettings.map((e) => Container(
              margin: const EdgeInsets.symmetric(vertical: 0),
              child: Row(children: [
                const SizedBox(width: 12),
                Text(e.title),
                const SizedBox(width: 12),
                Expanded(
                    child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(e.point))),
                Container(
                    width: 40,
                    alignment: Alignment.center,
                    child:
                        Text(constPointUnit.elementAt(e.type - 1).toString())),
                const SizedBox(width: 24),
                DeleteColButton(
                    label: '削除', tapFunc: () => deletePointsettings(e.id))
              ])))
        ],
      ),
    );
  }

  Widget _getConfirmPoints() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RowLabelInput(
              label: '申請対象日',
              renderWidget: Row(
                children: [
                  SizedBox(
                      width: 40,
                      child: IconWhiteButton(
                          icon: Icons.keyboard_arrow_left,
                          tapFunc: () => onChangeConfirmDate(-1))),
                  const SizedBox(width: 8),
                  Text('$confirmDateYear年$confirmDateMonth月'),
                  const SizedBox(width: 8),
                  SizedBox(
                      width: 40,
                      child: IconWhiteButton(
                          icon: Icons.keyboard_arrow_right,
                          tapFunc: () => onChangeConfirmDate(1))),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 40,
                      child: IconWhiteButton(
                          color: Colors.blue,
                          icon: Icons.today,
                          tapFunc: () => onChangeConfirmDateToToday())),
                ],
              )),
          RowLabelInput(
              label: '店名',
              renderWidget: DropDownModelSelect(
                  value: confirmOrganId,
                  items: [
                    ...organs.map((e) => DropdownMenuItem(
                        value: e.organId, child: Text(e.organName)))
                  ],
                  tapFunc: (v) {
                    confirmOrganId = v;
                    loadInitData();
                  })),
          RowLabelInput(
              label: 'スタッフ',
              renderWidget: DropDownModelSelect(
                  value: selConfirmStaff,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('すべて'),
                    ),
                    ...confirmStaffs.map((e) => DropdownMenuItem(
                          value: e.staffId,
                          child: Text(e.staffNick == ''
                              ? ('${e.staffFirstName!} ${e.staffLastName!}')
                              : e.staffNick),
                        ))
                  ],
                  tapFunc: (v) => onChangeConfirmStaff(v))),
          RowLabelInput(
              label: 'ポイント種類',
              renderWidget: DropDownModelSelect(
                  value: selConfirmPointType,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('すべて'),
                    ),
                    ...pointSettings.map((e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.title),
                        ))
                  ],
                  tapFunc: (v) => onChangeConfirmType(v))),
          ...confirmPoints.map((e) => Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                SizedBox(width: 80, child: _listTextContent(e.staffName)),
                Container(
                    alignment: Alignment.center,
                    width: 40,
                    child: _listTextContent('${e.pointDate.day.toString()}日')),
                const SizedBox(width: 10),
                Expanded(child: _listTextContent(e.comment)),
                Container(
                    alignment: Alignment.centerRight,
                    width: 45,
                    child: _listTextContent(e.value +
                        constPointUnit.elementAt(e.pointType - 1).toString())),
                Container(
                    alignment: Alignment.centerRight,
                    width: 45,
                    child: _listTextContent(
                        (int.parse(e.weight) * int.parse(e.value)).toString())),
                const SizedBox(width: 10),
                // if (e.status == '2' || e.status == '3')
                //   Container(
                //       alignment: Alignment.center,
                //       width: 60,
                //       child: Text(
                //         e.status == '2' ? '承認' : '拒否',
                //         style: TextStyle(
                //             color: e.status == '2' ? Colors.green : Colors.red),
                //       )),
                SizedBox(
                    width: 30,
                    child: IconWhiteButton(
                      backColor: primaryColor,
                      color: e.status == '2' ? Colors.grey : Colors.white,
                      icon: Icons.check,
                      tapFunc: e.status == '2'
                          ? null
                          : () => applyAndRecjectPoints(e.pointId, '2'),
                    )),
                const SizedBox(width: 10),
                SizedBox(
                    width: 30,
                    child: IconWhiteButton(
                      backColor: redColor,
                      color: e.status == '3' ? Colors.grey : Colors.white,
                      icon: Icons.close,
                      tapFunc: e.status == '3'
                          ? null
                          : () => applyAndRecjectPoints(e.pointId, '3'),
                    ))
              ]))),
        ],
      ),
    );
  }

  Widget _listTextContent(String txt) => Text(
        txt,
        style: const TextStyle(fontSize: 12),
      );

  Widget _getSpecialContent() {
    return Container(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          RowLabelInput(
            label: '店名',
            renderWidget: DropDownModelSelect(
              value: speicalOrganId,
              items: [
                ...organs.map((e) => DropdownMenuItem(
                    value: e.organId, child: Text(e.organName)))
              ],
              tapFunc: (v) => onChangeSpecialOrganId(v),
            ),
          ),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            getSpecialLabel(100, '特定期間'),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...specialPeriodRates.map((rate) => GestureDetector(
                  onTap: () => onTapSpeicalPeriodShow(rate),
                  child: getSpecialContent(
                      '${rate.fromDate} ~ ${rate.toDate}  ${rate.rateDays}日以上　${rate.rate}'))),
              WhiteButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  label: 'レートを追加',
                  tapFunc: () => onTapSpeicalPeriodShow(null))
            ])
          ]),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getSpecialLabel(120, '同月の出勤時間'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                      onTap: speicialTimeOverRate == null
                          ? null
                          : () =>
                              onTapSpeicalLimitShow('1', speicialTimeMinRate),
                      child: getSpecialContent(
                          speicialTimeMinRate == null
                              ? '設定なし'
                              : '${speicialTimeMinRate!.value}時間以上  ${speicialTimeMinRate!.rate}',
                          showEdit: speicialTimeOverRate != null)),
                  GestureDetector(
                      onTap: () =>
                          onTapSpeicalLimitShow('2', speicialTimeOverRate),
                      child: getSpecialContent(speicialTimeOverRate == null
                          ? '設定なし'
                          : '${speicialTimeOverRate!.value}時間以上  ${speicialTimeOverRate!.rate}')),
                ],
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getSpecialLabel(120, '同月の出勤日数'),
              GestureDetector(
                  onTap: () => onTapSpeicalLimitShow('3', speicialDayOverRate),
                  child: getSpecialContent(speicialDayOverRate == null
                      ? '設定なし'
                      : '${speicialDayOverRate!.value}日以上　${speicialDayOverRate!.rate}')),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getSpecialLabel(120, '同月の施術'),
              GestureDetector(
                  onTap: () =>
                      onTapSpeicalLimitShow('4', speicialReserveOverRate),
                  child: getSpecialContent(speicialReserveOverRate == null
                      ? '設定なし'
                      : '月${speicialReserveOverRate!.value}施術以上　${speicialReserveOverRate!.rate}')),
            ],
          )
        ]));
  }

  Future showSpecialPeriodModal() async {
    return await BottomModal().inputFromDialog(
        context,
        'レート1',
        Container(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(
              children: [
                const SizedBox(width: 40, child: Text('期間')),
                Flexible(
                    child: DropDownNumberSelect(
                        value: selPeriodM1,
                        max: 12,
                        tapFunc: (v) => selPeriodM1 = v)),
                const Text('月'),
                Flexible(
                    child: DropDownNumberSelect(
                        value: selPeriodD1,
                        max: 31,
                        tapFunc: (v) => selPeriodD1 = v)),
                const Text('日 ～ '),
                Flexible(
                    child: DropDownNumberSelect(
                        value: selPeriodM2,
                        max: 12,
                        tapFunc: (v) => selPeriodM2 = v)),
                const Text('月'),
                Flexible(
                    child: DropDownNumberSelect(
                        value: selPeriodD2,
                        max: 31,
                        tapFunc: (v) => selPeriodD2 = v)),
                const Text('日'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 40, child: Text('')),
                Flexible(
                    child: TextInputNormal(
                        controller: txtPeriodDaysController,
                        inputType: TextInputType.number)),
                const Text('日以上    レート'),
                Flexible(
                    child: TextInputNormal(
                        controller: txtPeriodRateController,
                        inputType: const TextInputType.numberWithOptions(
                            decimal: true))),
              ],
            ),
            const SizedBox(height: 24),
            RowButtonGroup(widgets: [
              Expanded(child: Container()),
              PrimaryColButton(label: '保存する', tapFunc: () => savePeriodRate()),
              const SizedBox(width: 12),
              DeleteColButton(
                  label: '削除する',
                  tapFunc: selSepcialPeriodPointId == null
                      ? null
                      : () => deletePeriodRate()),
              Expanded(child: Container()),
            ])
          ]),
        ));
  }

  Future showSpecialLimitModal(
      type, title, desc1, valueMax, desc2, rateController) async {
    return await BottomModal().inputFromDialog(
        context,
        title,
        Container(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(
              children: [
                SizedBox(child: Text(desc1)),
                Flexible(
                    child: DropDownNumberSelect(
                        value: selLimitValue,
                        max: valueMax,
                        tapFunc: (v) => selLimitValue = v)),
                Text(desc2),
                Flexible(
                    child: TextInputNormal(
                        controller: rateController,
                        inputType: const TextInputType.numberWithOptions(
                            decimal: true))),
              ],
            ),
            const SizedBox(height: 24),
            RowButtonGroup(widgets: [
              Expanded(child: Container()),
              PrimaryColButton(
                  label: '保存する', tapFunc: () => saveLimitdRate(type)),
              const SizedBox(width: 12),
              DeleteColButton(
                  label: '削除する',
                  tapFunc: selSepcialLimitPointId == null
                      ? null
                      : () => deleteLimitRate()),
              Expanded(child: Container()),
            ])
          ]),
        ));
  }

  // Future showSpecialDayOverModal() async {
  //   return await BottomModal().inputFromDialog(
  //       context,
  //       '出勤日数',
  //       Container(
  //         padding: const EdgeInsets.all(12),
  //         child: Column(children: [
  //           Row(
  //             children: [
  //               const SizedBox(child: Text('同月中に出勤日数')),
  //               Flexible(
  //                   child: DropDownNumberSelect(
  //                       value: selLimitValue,
  //                       max: 50,
  //                       tapFunc: (v) => selLimitValue = v)),
  //               const Text('日以上    レート'),
  //               Flexible(
  //                   child: TextInputNormal(
  //                       controller: txtLimitRateController,
  //                       inputType: const TextInputType.numberWithOptions(
  //                           decimal: true))),
  //             ],
  //           ),
  //           const SizedBox(height: 24),
  //           RowButtonGroup(widgets: [
  //             Expanded(child: Container()),
  //             PrimaryColButton(
  //                 label: '保存する', tapFunc: () => saveLimitdRate('3')),
  //             const SizedBox(width: 12),
  //             DeleteColButton(
  //                 label: '削除する',
  //                 tapFunc: selSepcialLimitPointId == null
  //                     ? null
  //                     : () => deleteLimitRate()),
  //             Expanded(child: Container()),
  //           ])
  //         ]),
  //       ));
  // }

  // Future showSpecialReserveOverModal() async {
  //   return await BottomModal().inputFromDialog(
  //       context,
  //       '月施術',
  //       Container(
  //         padding: const EdgeInsets.all(12),
  //         child: Column(children: [
  //           Row(
  //             children: [
  //               const SizedBox(child: Text('同')),
  //               Flexible(
  //                   child: DropDownNumberSelect(
  //                       value: selLimitValue,
  //                       max: 50,
  //                       tapFunc: (v) => selLimitValue = v)),
  //               const Text('施術以上    レート'),
  //               Flexible(
  //                   child: TextInputNormal(
  //                       controller: txtLimitRateController,
  //                       inputType: const TextInputType.numberWithOptions(
  //                           decimal: true))),
  //             ],
  //           ),
  //           const SizedBox(height: 24),
  //           RowButtonGroup(widgets: [
  //             Expanded(child: Container()),
  //             PrimaryColButton(
  //                 label: '保存する', tapFunc: () => saveLimitdRate('4')),
  //             const SizedBox(width: 12),
  //             DeleteColButton(
  //                 label: '削除する',
  //                 tapFunc: selSepcialLimitPointId == null
  //                     ? null
  //                     : () => deleteLimitRate()),
  //             Expanded(child: Container()),
  //           ])
  //         ]),
  //       ));
  // }

  // Future showSpecialTimeOverModal() async {
  //   return await BottomModal().inputFromDialog(
  //       context,
  //       '月の出勤時間',
  //       Container(
  //         padding: const EdgeInsets.all(12),
  //         child: Column(children: [
  //           Row(
  //             children: [
  //               const SizedBox(child: Text('同月の出勤時間')),
  //               Flexible(
  //                   child: DropDownNumberSelect(
  //                       value: selLimitValue,
  //                       max: 300,
  //                       tapFunc: (v) => selLimitValue = v)),
  //               const Text('時間以上    レート'),
  //               Flexible(
  //                   child: TextInputNormal(
  //                       controller: txtLimitRateController,
  //                       inputType: const TextInputType.numberWithOptions(
  //                           decimal: true))),
  //             ],
  //           ),
  //           const SizedBox(height: 24),
  //           RowButtonGroup(widgets: [
  //             Expanded(child: Container()),
  //             PrimaryColButton(
  //                 label: '保存する', tapFunc: () => saveLimitdRate('2')),
  //             const SizedBox(width: 12),
  //             DeleteColButton(
  //                 label: '削除する',
  //                 tapFunc: selSepcialLimitPointId == null
  //                     ? null
  //                     : () => deleteLimitRate()),
  //             Expanded(child: Container()),
  //           ])
  //         ]),
  //       ));
  // }

  Widget getSpecialLabel(double w, String label) => SizedBox(
        width: w,
        child: Text(label),
      );
  Widget getSpecialContent(String content, {showEdit = true}) => Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        children: [
          Text(content),
          const SizedBox(width: 12),
          if (showEdit) const Icon(Icons.edit, size: 22, color: Colors.grey)
        ],
      ));
}
