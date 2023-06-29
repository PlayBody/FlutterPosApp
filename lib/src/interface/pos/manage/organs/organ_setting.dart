import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/company.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/functions/seletattachement.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/radios.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/pos/manage/organs/settingorgantime.dart';
import 'package:staff_pos_app/src/interface/style/textstyles.dart';
import 'package:staff_pos_app/src/model/companymodel.dart';
import 'package:staff_pos_app/src/model/organavaliabletimmodel.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/organsettablemodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/organspecialshifttimemodel.dart';
import 'package:staff_pos_app/src/model/organspecialtimemodel.dart';

class OrganSetting extends StatefulWidget {
  final String? organId;
  const OrganSetting({this.organId, Key? key}) : super(key: key);

  @override
  _OrganSetting createState() => _OrganSetting();
}

class _OrganSetting extends State<OrganSetting> {
  late Future<List> loadData;
  var txtSetTimeController = TextEditingController();
  var txtSetAmountController = TextEditingController();
  var txtTableAmountController = TextEditingController();
  var txtActiveStartController = TextEditingController();
  var txtActiveEndController = TextEditingController();
  var txtZipCodeController = TextEditingController();
  var txtAddressController = TextEditingController();
  var txtTelController = TextEditingController();
  var txtLatController = TextEditingController();
  var txtLonController = TextEditingController();
  var txtDistanceController = TextEditingController();
  var txtOpenBalanceController = TextEditingController();
  var txtCommentController = TextEditingController();

  // setting point text Controller
  var txtBusinessWeightController = TextEditingController();
  var txtDividePointController = TextEditingController();
  var txtPromotionalPointController = TextEditingController();
  var txtOptionPointController = TextEditingController();
  var txtNextPointController = TextEditingController();
  var txtExtenstionPointController = TextEditingController();
  var txtOpenPointController = TextEditingController();
  var txtClosePointController = TextEditingController();
  var txtCheckinTiecketController = TextEditingController();
  var txtSNSUrlController = TextEditingController();
  var txtAccessController = TextEditingController();
  var txtParkingController = TextEditingController();
  var txtPtResponse1Controller = TextEditingController();
  var txtPtResponse2Controller = TextEditingController();
  var txtPtAttendController = TextEditingController();
  var txtPtGrade1Controller = TextEditingController();
  var txtPtGrade2Controller = TextEditingController();
  var txtPtGrade3Controller = TextEditingController();
  var txtPtEndtering1Controller = TextEditingController();
  var txtPtEndtering2Controller = TextEditingController();
  var txtPtEndtering3Controller = TextEditingController();
  var txtPtEndtering4Controller = TextEditingController();
  var txtPtEndtering5Controller = TextEditingController();

  String organTitle = '';
  String? selOrganId;
  String? selTableCount;
  String selSetNumber = '1';
  bool isUseSet = false;

  bool isShowDistance = true;

  List<OrganModel> organList = [];

  DateTime? _activeStartTime;
  DateTime? _activeEndTime;
  DateTime? _setTime;
  String organNumber = '';

  List<OrganAvaliableTimeModel> bussinessTimes = [];
  List<OrganAvaliableTimeModel> shiftTimes = [];
  List<OrganSpecialTimeModel> specialTimes = [];
  List<OrganSpecialShiftTimeModel> specialShiftTimes = [];

  String? printLogoUrl;
  String? uploadPrintLogoUrl;
  List<CompanyModel> companies = [];

  bool isPhoto = false;
  late File _photoFile;
  String? organImage;

  String checkInType = constCheckinTypeNone;
  String checkInTypeReserve = constCheckinReserveRiRa;

  @override
  void initState() {
    super.initState();
    selOrganId = widget.organId;
    loadData = loadSettingData();
  }

  Future<List> loadSettingData() async {
    companies = await ClCompany().loadCompanyList(context);
    // organList = [];
    organList = await ClOrgan().loadOrganList(context, '', globals.staffId);
    if (selOrganId == null) selOrganId = organList.first.organId;

    OrganModel organ = await ClOrgan().loadOrganInfo(context, selOrganId!);
    organTitle = organ.organName;
    organNumber = organ.organNumber;
    selTableCount = organ.tableCount.toString();
    txtZipCodeController.text = organ.organZipCode;
    txtAddressController.text = organ.organAddress;
    txtTelController.text = organ.organPhone;
    txtLatController.text = organ.lat;
    txtLonController.text = organ.lon;
    txtDistanceController.text = organ.distance;
    isShowDistance = organ.distance_status;
    txtOpenBalanceController.text = organ.openBalance;
    txtCheckinTiecketController.text = organ.ticketConsumption;
    txtCommentController.text = organ.organComment;
    isUseSet = organ.isUseSet;

    txtBusinessWeightController.text = organ.bussinessWeight;
    txtDividePointController.text = organ.dividePoint;
    txtPromotionalPointController.text = organ.promotionalPoint;
    txtOptionPointController.text = organ.opionalPoint;
    txtNextPointController.text = organ.nextPoint;
    txtExtenstionPointController.text = organ.extensionPoint;
    txtOpenPointController.text = organ.openPoint;
    txtClosePointController.text = organ.closePoint;
    txtSNSUrlController.text = organ.snsUrl;
    txtAccessController.text = organ.access;
    txtParkingController.text = organ.parking;

    txtPtResponse1Controller.text = organ.pointResponse1 ?? '';
    txtPtResponse2Controller.text = organ.pointResponse2 ?? '';
    txtPtAttendController.text = organ.pointAttend ?? '';
    txtPtGrade1Controller.text = organ.pointGrade1 ?? '';
    txtPtGrade2Controller.text = organ.pointGrade2 ?? '';
    txtPtGrade3Controller.text = organ.pointGrade3 ?? '';
    txtPtEndtering1Controller.text = organ.pointEntering1 ?? '';
    txtPtEndtering2Controller.text = organ.pointEntering2 ?? '';
    txtPtEndtering3Controller.text = organ.pointEntering3 ?? '';
    txtPtEndtering4Controller.text = organ.pointEntering4 ?? '';
    txtPtEndtering5Controller.text = organ.pointEntering5 ?? '';

    isUseSet = organ.isUseSet;
    checkInType = organ.isNoReserve;
    checkInTypeReserve = organ.isNoReserveType;

    printLogoUrl = organ.printLogoUrl;
    organImage = organ.organImage;
    await setOrganSetTableData(selSetNumber);

    bussinessTimes =
        await ClOrgan().loadOrganTimes(context, selOrganId!, 'bussiness');
    shiftTimes = await ClOrgan().loadOrganTimes(context, selOrganId!, 'shift');
    specialTimes = await ClOrgan().loadOrganSpecialTime(context, selOrganId);
    specialShiftTimes =
        await ClOrgan().loadOrganSpecialShiftTime(context, selOrganId);
    setState(() {});
    return [];
  }

  Future<void> setOrganSetTableData(String setNum) async {
    selSetNumber = setNum;
    OrganSetTableModel setData =
        await ClOrgan().loadOrganSetTableData(context, selOrganId!, setNum);
    txtTableAmountController.text = setData.tableAmount;
    txtSetAmountController.text = setData.setAmount;
    _setTime = setData.setTime;
    setState(() {});
  }

  Future<void> changeDistanceStatus(bool value) async {}

  Future<void> saveSetting() async {
    if (selOrganId == null) return;
    Dialogs().loaderDialogNormal(context);

    String imagename = '';
    if (uploadPrintLogoUrl != null) {
      imagename = 'print-logo-' +
          DateTime.now()
              .toString()
              .replaceAll(':', '')
              .replaceAll('-', '')
              .replaceAll('.', '')
              .replaceAll(' ', '') +
          '.png';
      await Webservice().callHttpMultiPart(
          'picture', apiUploadPrintLogoUrl, uploadPrintLogoUrl!, imagename);
    }

    String organImageName = '';
    if (isPhoto) {
      organImageName = 'organs-' +
          DateTime.now()
              .toString()
              .replaceAll(':', '')
              .replaceAll('-', '')
              .replaceAll('.', '')
              .replaceAll(' ', '') +
          '.jpg';
      await Webservice().callHttpMultiPart(
          'picture', apiUploadOrganPhoto, _photoFile.path, organImageName);
    }

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiSaveSettingUrl, {
      'organ_id': selOrganId,
      'table_count': selTableCount == null ? '' : selTableCount,
      'set_number': selSetNumber,
      'is_use_set': isUseSet ? '1' : '0',
      'is_no_reserve': checkInType,
      'is_no_reserve_type': checkInTypeReserve,
      'set_time': _setTime == null ? '' : Funcs().getTimeFormatHMM00(_setTime),
      'set_amount': txtSetAmountController.text,
      'table_amount': txtTableAmountController.text,
      'active_start_time': _activeStartTime == null
          ? ''
          : Funcs().getTimeFormatHHMM(_activeStartTime),
      'active_end_time': _activeEndTime == null
          ? ''
          : Funcs().getTimeFormatHHMM(_activeEndTime),
      'zip_code': txtZipCodeController.text,
      'address': txtAddressController.text,
      'tel_phone': txtTelController.text,
      'lat': txtLatController.text,
      'lon': txtLonController.text,
      'distance': txtDistanceController.text,
      'distance_status': isShowDistance ? '1' : '0',
      'open_balance': txtOpenBalanceController.text,
      'comment': txtCommentController.text,
      'sns_url': txtSNSUrlController.text,
      'access': txtAccessController.text,
      'parking': txtParkingController.text,
      'reserve_menu_response_1_point': txtPtResponse1Controller.text,
      'reserve_menu_response_2_point': txtPtResponse2Controller.text,
      'attend_point': txtPtAttendController.text,
      'grade_1_point': txtPtGrade1Controller.text,
      'grade_2_point': txtPtGrade2Controller.text,
      'grade_3_point': txtPtGrade3Controller.text,
      'entering_1_point': txtPtEndtering1Controller.text,
      'entering_2_point': txtPtEndtering2Controller.text,
      'entering_3_point': txtPtEndtering3Controller.text,
      'entering_4_point': txtPtEndtering4Controller.text,
      'entering_5_point': txtPtEndtering5Controller.text,
      // 'business_weight': txtBusinessWeightController.text,
      // 'divide_point': txtDividePointController.text,
      // 'promotional_point': txtPromotionalPointController.text,
      // 'optional_acquisition_point': txtOptionPointController.text,
      // 'next_reservation_point': txtNextPointController.text,
      // 'extension_point': txtExtenstionPointController.text,
      // 'open_business_point': txtOpenPointController.text,
      // 'close_business_point': txtClosePointController.text,
      'checkin_ticket_consumption': txtCheckinTiecketController.text,
      'print_logo_file': imagename,
      'image': organImageName
    }).then((v) => {results = v});

    Navigator.pop(context);

    if (results['isUpdate']) {
      Dialogs().infoDialog(context, successUpdateAction);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> updateTitle(
      String organId, String companyId, String _title) async {
    Navigator.of(context).pop();
    if (_title == '' || companyId == '') return;

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUpdateOrganTitleUrl, {
      'organ_id': organId,
      'company_id': companyId,
      'update_title': _title
    }).then((v) => {results = v});
    if (results['isUpdate']) {
      selOrganId = results['organ_id'].toString();
      loadSettingData();
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> onSelectOrgan(String organId) async {
    selOrganId = organId;
    Dialogs().loaderDialogNormal(context);
    await loadSettingData();
    Navigator.pop(context);
  }

  Future<void> onTapOrganTime(typeString) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return SettingOrganTime(selOrganId: selOrganId!, type: typeString);
    }));
    loadSettingData();
  }

  Future<void> deleteOrgan() async {
    if (selOrganId == null) return;
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);

    if (!conf) return;

    Dialogs().loaderDialogNormal(context);
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiDeleteOrganData,
        {'organ_id': selOrganId}).then((v) => {results = v});
    Navigator.pop(context);
    if (!results['isDelete']) {
      Dialogs().infoDialog(context, errServerActionFail);
    } else {
      selOrganId = null;

      loadSettingData();
    }
  }

  void titleChangeDialog(String organId, String txtInputTitle) {
    String companyId = globals.companyId;
    final _controller = TextEditingController();

    _controller.text = txtInputTitle;
    _controller.selection =
        TextSelection(baseOffset: 0, extentOffset: txtInputTitle.length);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(organId == '' ? '店舗の追加' : qChangeTitle),
        content: Container(
            height: 130,
            child: Column(
              children: [
                if (globals.auth == constAuthSystem && organId == '')
                  DropDownModelSelect(items: [
                    ...companies.map((e) => DropdownMenuItem(
                        child: Text(e.companyName), value: e.companyId))
                  ], tapFunc: (v) => companyId = v),
                SizedBox(height: 16),
                TextInputNormal(controller: _controller)
              ],
            )),
        actions: [
          TextButton(
            child: const Text('変更'),
            onPressed: () => updateTitle(organId, companyId, _controller.text),
          ),
          TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = '店舗設定';
    return MainBodyWdiget(
        resizeBottom: true,
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
        ));
  }

  var dropDwonContentPadding = const EdgeInsets.fromLTRB(8, 7, 0, 7);
  double hPadding = 20;

  Widget _getBodyContent() {
    return Container(
      color: const Color(0xfffbfbfb),
      child: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                if (globals.auth >= constAuthOwner)
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      PrimaryColButton(
                          label: '店舗の追加',
                          tapFunc: () => titleChangeDialog('', '')),
                      const SizedBox(width: 12),
                      DeleteColButton(
                          label: '店舗の削除', tapFunc: () => deleteOrgan()),
                    ],
                  ),
                const SizedBox(height: 12),
                _getAvatarContent(),
                const SizedBox(height: 12),
                _getOrganList(),
                const SizedBox(height: 12),
                Container(
                    padding: const EdgeInsets.only(left: 20),
                    child: RowLabelInput(
                      label: '店舗番号',
                      renderWidget: Text(organNumber),
                    )),
                const SizedBox(height: 12),
                _getPositionCountContent(),
                const SizedBox(height: 12),
                const PageSubHeader(label: 'セット設定'),
                _getSetGroupContent(),
                const SizedBox(height: 20),
                const PageSubHeader(label: '営業時間'),
                const SizedBox(height: 12),
                _getOrganTimeContent('営業時間設定', bussinessTimes, 'bussiness'),
                const SizedBox(height: 20),
                const PageSubHeader(label: '勤務可能時間'),
                const SizedBox(height: 12),
                _getOrganTimeContent('勤務可能時間', shiftTimes, 'shift'),
                const SizedBox(height: 20),
                const PageSubHeader(label: '基本情報'),
                const SizedBox(height: 12),
                _getMainInfoContent(),
                const PageSubHeader(label: '初期ポイント設定'),
                const SizedBox(height: 12),
                _getBasePointContent(),
                Container(height: 20),
                // PageSubHeader(label: '給与ポイント'),
                // SizedBox(height: 12),
                // _getPointSettingContent(),
                // Container(height: 20),
                const PageSubHeader(label: '印刷ロゴ画像'),
                const SizedBox(height: 12),
                _getPrintLogoContent(),
                const SizedBox(height: 24),
              ],
            ),
          )),
          RowButtonGroup(widgets: [
            const SizedBox(width: 30),
            PrimaryButton(label: '保存する', tapFunc: () => saveSetting()),
            const SizedBox(width: 30),
          ]),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _getAvatarContent() {
    return Container(
      // height: 150,
      child: Column(
        children: [
          SizedBox(
            height: 130,
            child: isPhoto
                ? Image.file(_photoFile)
                : organImage == null
                    ? Image.asset('images/no_image.jpg')
                    : Image.network(organImageUrl + organImage!),
          ),
          Container(
            padding: const EdgeInsets.only(right: 30),
            alignment: Alignment.topRight,
            child: DropdownButton(
              items: [
                DropdownMenuItem(
                  value: 1,
                  child: Text("カメラ撮る"),
                ),
                DropdownMenuItem(
                  child: Text("アルバム"),
                  value: 2,
                )
              ],
              onChanged: (int? v) {
                if (v == 1 || v == 2) {
                  _getFromPhoto(v!);
                }
              },
              hint: const Text("画像変更"),
            ),
          ),
        ],
      ),
    );
  }

  _getFromPhoto(int _libType) async {
    XFile? image;

    if (_libType == 1) {
      image = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker().pickImage(source: ImageSource.gallery);
    }

    final path = image!.path;
    setState(() {
      isPhoto = true;
      _photoFile = File(path);
    });
  }

  Widget _getOrganList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: DropDownModelSelect(
              contentPadding: EdgeInsets.fromLTRB(20, 7, 0, 7),
              value: selOrganId,
              items: [
                ...organList.map((e) => DropdownMenuItem(
                    child: Text(e.organName), value: e.organId))
              ],
              tapFunc: (v) => onSelectOrgan(v.toString()),
            ),
          ),
          SizedBox(width: 8),
          WhiteButton(
              label: '店名変更',
              tapFunc: () => titleChangeDialog(selOrganId!, organTitle)),
        ],
      ),
    );
  }

  Widget _getPositionCountContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: RowLabelInput(
          label: '席数',
          renderWidget: DropDownNumberSelect(
            contentPadding: dropDwonContentPadding,
            value: selTableCount,
            max: 99,
            tapFunc: (v) => selTableCount = v.toString(),
          )),
    );
  }

  Widget _getSetGroupContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Column(
        children: [
          SizedBox(height: 12),
          RowLabelInput(
            label: 'セット使用',
            renderWidget: Switch(
                value: isUseSet,
                onChanged: (v) {
                  isUseSet = v;
                  setOrganSetTableData('1');
                  setState(() {});
                }),
          ),
          SizedBox(height: 12),
          RowLabelInput(
            label: 'セット番号',
            renderWidget: DropDownNumberSelect(
                value: selSetNumber,
                contentPadding: dropDwonContentPadding,
                max: 5,
                tapFunc: isUseSet ? (v) => setOrganSetTableData(v) : null),
          ),
          SizedBox(height: 12),
          RowLabelInput(
              label: '入店料金',
              renderWidget: TextInputNormal(
                contentPadding: 12,
                controller: txtTableAmountController,
                inputType: TextInputType.number,
              )),
          SizedBox(height: 12),
          Container(
              padding: EdgeInsets.only(bottom: 30),
              child: Row(
                children: [
                  InputLeftText(label: '1延長の時間', rPadding: 4),
                  ElevatedButton(
                    onPressed: () {
                      DatePicker.showTimePicker(
                        context,
                        locale: LocaleType.jp,
                        // theme: timePickerTheme,
                        showSecondsColumn: false,
                        showTitleActions: true,
                        currentTime: _setTime,
                        onConfirm: (time) {
                          setState(() {
                            _setTime = time;
                          });
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.black,
                        textStyle: TextStyle(fontSize: 16)),
                    child: Text(Funcs().getTimeFormatHMM00(_setTime)),
                  ),
                ],
              )),
          RowLabelInput(
              label: '延長料金',
              renderWidget: TextInputNormal(
                contentPadding: 12,
                controller: txtSetAmountController,
                inputType: TextInputType.number,
              ))
        ],
      ),
    );
  }

  Widget _getOrganTimeContent(label, times, typeString) {
    return Container(
        child: Column(
      children: [
        for (int i = 1; i <= 7; i++)
          _getWeekDayTime(weekAry[i - 1].toString() + '曜日',
              times.where((element) => element.weekday == i.toString())),
        SizedBox(height: 12),
        if (typeString == 'bussiness')
          ...specialTimes.map((e) => _getSpecialTime(e)),
        if (typeString == 'shift')
          ...specialShiftTimes.map((e) => _getSpecialTime(e)),
        Container(
            child: WhiteButton(
                label: label, tapFunc: () => onTapOrganTime(typeString))),
      ],
    ));
  }

  Widget _getWeekDayTime(weekLabel, data) {
    return Container(
      width: 250,
      padding: EdgeInsets.only(top: 6, bottom: 6),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffcfcfcf)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(right: 10),
            width: 120,
            child: Text(weekLabel, style: bodyTextStyle),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...data.map(
                  (e) => _getOpenTimeRow(e),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _getSpecialTime(item) {
    return Container(
      width: 250,
      padding: EdgeInsets.only(top: 6, bottom: 6),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffcfcfcf)))),
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(right: 10),
            width: 120,
            child: Text(item.date, style: bodyTextStyle),
          ),
          _getOpenTimeRow(item)
        ],
      ),
    );
  }

  Widget _getOpenTimeRow(item) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      width: 120,
      child: Text(item.fromTime + ' ~ ' + item.toTime, style: bodyTextStyle),
    );
  }

  Widget _getRowHeight() {
    return const SizedBox(height: 8);
  }

  Widget _getMainInfoContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Column(
        children: [
          _rowNumber('郵便番号', txtZipCodeController),
          _getRowHeight(),
          _rowText('住所', txtAddressController),
          _getRowHeight(),
          _rowNumber('固定電話番号', txtTelController),
          _getRowHeight(),
          Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  const InputLeftText(label: 'GPS座標'),
                  Text('Lat', style: bodyTextStyle),
                  Flexible(
                    child: TextInputNormal(
                      controller: txtLatController,
                      contentPadding: 12,
                      inputType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text('Lon', style: bodyTextStyle),
                  Flexible(
                    child: TextInputNormal(
                      controller: txtLonController,
                      contentPadding: 12,
                      inputType:
                          const TextInputType.numberWithOptions(decimal: true),
                      // errText: _nickError,
                    ),
                  ),
                ],
              )),
          _rowNumber('位置偏差の範囲(m)', txtDistanceController),
          RowLabelInput(
            label: '距離表示',
            renderWidget: Switch(
                value: isShowDistance,
                onChanged: (v) {
                  // setOrganSetTableData('1');
                  setState(() {
                    isShowDistance = v;
                  });
                }),
          ),
          _getRowHeight(),
          _rowNumber('オープン時レジ現金残高', txtOpenBalanceController),
          _getRowHeight(),
          _rowNumber('チェックインチケット消費数', txtCheckinTiecketController),
          RowLabelInput(
              label: '予約チェックイン',
              renderWidget: Row(
                children: [
                  RadioNomal(
                    label: '予約',
                    value: constCheckinTypeOnlyReserve,
                    groupValue: checkInType,
                    tapFunc: () => setState(() {
                      checkInType = constCheckinTypeOnlyReserve;
                    }),
                  ),
                  const SizedBox(width: 4),
                  RadioNomal(
                    label: 'オフ',
                    value: constCheckinTypeNone,
                    groupValue: checkInType,
                    tapFunc: () => setState(() {
                      checkInType = constCheckinTypeNone;
                    }),
                  ),
                  const SizedBox(width: 4),
                  RadioNomal(
                    label: '併用',
                    value: constCheckinTypeBoth,
                    groupValue: checkInType,
                    tapFunc: () => setState(() {
                      checkInType = constCheckinTypeBoth;
                    }),
                  ),
                ],
              )),
          // if (checkInType == constCheckinTypeOnlyReserve)
            RowLabelInput(
                label: '',
                renderWidget: Row(
                  children: [
                    RadioNomal(
                      label: '出勤スタッフ',
                      value: constCheckinReserveRiRa,
                      groupValue: checkInTypeReserve,
                      tapFunc: () => setState(() {
                        checkInTypeReserve = constCheckinReserveRiRa;
                      }),
                    ),
                    const SizedBox(width: 4),
                    RadioNomal(
                      label: 'シフト枠',
                      value: constCheckinReserveShift,
                      groupValue: checkInTypeReserve,
                      tapFunc: () => setState(() {
                        checkInTypeReserve = constCheckinReserveShift;
                      }),
                    ),
                  ],
                )),
          RowLabelInput(
              label: '備考 ',
              labelPadding: 4,
              renderWidget: TextInputNormal(
                multiLine: 4,
                contentPadding: 12,
                controller: txtCommentController,
                inputType: TextInputType.multiline,
              )),
          _rowNumber('SNS URL', txtSNSUrlController),
          _rowText('アクセス', txtAccessController),
          _rowText('駐車場', txtParkingController),
        ],
      ),
    );
  }

  Widget _getBasePointContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SubHeaderText(label: '施術'),
          _rowPoint('全メニュー未修了', txtPtResponse2Controller),
          _getRowHeight(),
          _rowPoint('全メニュー修了', txtPtResponse1Controller),
          const SubHeaderText(label: '業務'),
          _getRowHeight(),
          _rowPoint('行った業務に対して', txtPtAttendController),
          const SubHeaderText(label: '検定'),
          _rowPointRate('関連国家資格　1件', txtPtGrade1Controller),
          _rowPointRate('協会　1級', txtPtGrade2Controller),
          _rowPointRate('協会　2級', txtPtGrade3Controller),
          const SubHeaderText(label: '入社'),
          _rowPointRate('～1年', txtPtEndtering1Controller),
          _rowPointRate('1年～3年', txtPtEndtering2Controller),
          _rowPointRate('4年～5年', txtPtEndtering3Controller),
          _rowPointRate('6年～10年', txtPtEndtering4Controller),
          _rowPointRate('11年～', txtPtEndtering5Controller),
        ],
      ),
    );
  }

  Widget _rowText(s, c) => _rowLabelInputItem(s, c, TextInputType.text);
  Widget _rowNumber(s, c) => _rowLabelInputItem(s, c, TextInputType.text);
  Widget _rowPoint(s, c) => RowLabelInput(
      label: s,
      labelPadding: 4,
      labelWidth: 150,
      renderWidget: Row(children: [
        const InputLeftText(label: '1分 ', width: 40, rPadding: 0),
        Flexible(
            child: TextInputNormal(
          contentPadding: 12,
          controller: c,
          inputType: TextInputType.number,
        )),
        const InputLeftText(label: ' Pt', width: 40, rPadding: 0)
      ]));
  Widget _rowPointRate(s, c) => RowLabelInput(
      label: s,
      labelPadding: 4,
      labelWidth: 150,
      renderWidget: TextInputNormal(
        contentPadding: 12,
        controller: c,
        inputType: TextInputType.number,
      ));

  Widget _rowLabelInputItem(label, _controller, inputType) {
    return RowLabelInput(
        label: label,
        labelPadding: 4,
        renderWidget: TextInputNormal(
          contentPadding: 12,
          controller: _controller,
          inputType: inputType,
        ));
  }

  // Widget _getPointSettingContent() {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: hPadding),
  //     child: Column(
  //       children: [
  //         _getRowHeight(),
  //         _rowPointContent('飛び込みポイント', txtDividePointController),
  //         _getRowHeight(),
  //         _rowPointContent('販促ポイント', txtPromotionalPointController),
  //         _getRowHeight(),
  //         _rowPointContent('オプション獲得ポイント', txtOptionPointController),
  //         _getRowHeight(),
  //         _rowPointContent('次回予約ポイント', txtNextPointController),
  //         _getRowHeight(),
  //         _rowPointContent('延長ポイント', txtExtenstionPointController),
  //         _getRowHeight(),
  //         _rowPointContent('オープン業務ポイント', txtOpenPointController),
  //         _getRowHeight(),
  //         _rowPointContent('クローズ業務ポイント', txtClosePointController),
  //       ],
  //     ),
  //   );
  // }

  Widget _getPrintLogoContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Column(
        children: [
          Container(
              child: uploadPrintLogoUrl == null
                  ? (printLogoUrl == null
                      ? Text(
                          '印刷用ロゴ画像が設定されていません。',
                          style: bodyTextStyle,
                        )
                      : Image(
                          image: NetworkImage(apiPrintLogoUrl + printLogoUrl!)))
                  : Image.file(File(uploadPrintLogoUrl!))),
          Container(
            width: 150,
            child: WhiteButton(
              label: 'ロゴ画像変更',
              tapFunc: () async {
                final sel = await SelectAttachments().selectImage();
                if (sel != '') uploadPrintLogoUrl = sel;
                setState(() {});
              },
            ),
          )
        ],
      ),
    );
  }

  // Widget _rowPointContent(label, txtController) {
  //   return RowLabelInput(
  //     label: label,
  //     labelWidth: 170,
  //     labelPadding: 4,
  //     renderWidget: TextInputNormal(
  //       contentPadding: 12,
  //       controller: txtController,
  //       inputType: TextInputType.numberWithOptions(decimal: true),
  //     ),
  //   );
  // }
}
