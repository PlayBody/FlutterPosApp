import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/menu.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/business/staffs.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/checkboxs.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/radios.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/pos/staffs/stafflist.dart';
import 'package:staff_pos_app/src/interface/pos/staffs/staffpoint.dart';
import 'package:staff_pos_app/src/interface/pos/staffs/staffpointsubmit.dart';
import 'package:staff_pos_app/src/interface/style/textstyles.dart';
import 'package:staff_pos_app/src/model/menumodel.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/staff_model.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:image_picker/image_picker.dart';

class StaffEdit extends StatefulWidget {
  final String? selectStaffId;
  const StaffEdit({this.selectStaffId, Key? key}) : super(key: key);

  @override
  State<StaffEdit> createState() => _StaffEdit();
}

class _StaffEdit extends State<StaffEdit> {
  late Future<List> loadData;
  String? editStaffId;

  var txtFirstNameController = TextEditingController();
  var txtLastNameController = TextEditingController();
  var txtNickController = TextEditingController();
  var txtPhoneController = TextEditingController();
  var txtMailController = TextEditingController();
  var txtShiftController = TextEditingController();
  var txtSalMonthController = TextEditingController();
  var txtSalDayController = TextEditingController();
  var txtSalTimeController = TextEditingController();
  var txtPwdController = TextEditingController();
  var txtPwdConfController = TextEditingController();
  var txtCommentController = TextEditingController();

  String sexValue = '1';
  String gradeLevel = '';
  String nationalLevel = '';

  String? selStaffAuth;
  File? imageFile;

  bool isphoto = false;
  late File _photoFile;

  List<String> yearsList = [];
  List<String> monthsList = [];
  int maxday = Funcs().getMaxDay(null, null);

  String selectYear = DateTime.now().year.toString();
  String selectMonth = DateTime.now().month.toString();
  String selectDay = DateTime.now().day.toString();
  String selEnteringDateYear = DateTime.now().year.toString();
  String selEnteringDateMonth = DateTime.now().month.toString();

  String? selectSalaryMin;
  String? selTablePosition;

  bool isMonthSalary = false;
  bool isDaySalary = false;
  bool isHourSalary = false;
  bool isEditable = true;

  StaffModel staffInfo = StaffModel.fromJson({});
  List<OrganModel> organList = []; // view organs
  List<String> staffOrgans = []; // staff's owner
  List<OrganModel> ownerOrgans = [];
  List<MenuModel> menus = [];
  String? menuOrganSelId;
  List<String> enableMenus = [];

  String? allMenuValue;
  var txtAddRateController = TextEditingController();

  var txtTestRateController = TextEditingController();
  var txtQualityRateController = TextEditingController();

  @override
  void initState() {
    dropTableCount = [];
    for (var i = 1; i < 100; i++) {
      dropTableCount.add(i.toString());
    }

    if (widget.selectStaffId != null) editStaffId = widget.selectStaffId;
    super.initState();
    loadData = loadStaffInfoData();
  }

  Future<List> loadStaffInfoData() async {
    if (this.editStaffId != null) {
      staffInfo = await ClStaff().loadStaffInfo(context, this.editStaffId);

      ownerOrgans =
          await ClOrgan().loadOrganList(context, '', this.editStaffId!);

      for (var item in ownerOrgans) {
        staffOrgans.add(item.organId);
      }

      if (menuOrganSelId == null && ownerOrgans.length > 0) {
        menuOrganSelId = ownerOrgans.first.organId;
        loadStaffEnableMenus(menuOrganSelId);
      }
    }

    selStaffAuth = staffInfo.auth;
    selTablePosition = staffInfo.tablePosition;
    txtFirstNameController.text = staffInfo.firstName;
    txtLastNameController.text = staffInfo.lastName;
    txtNickController.text = staffInfo.nick;
    txtPhoneController.text = staffInfo.tel;
    txtMailController.text = staffInfo.mail;
    txtShiftController.text = staffInfo.shift;
    sexValue = staffInfo.sex;
    selectYear = staffInfo.birthday.year.toString();
    selectMonth = staffInfo.birthday.month.toString();
    maxday = Funcs().getMaxDay(selectYear, selectMonth);
    selectDay = staffInfo.birthday.day.toString();
    if (staffInfo.enteringDate != null) {
      var enterings = staffInfo.enteringDate.toString().split('-');
      selEnteringDateYear = enterings[0];
      selEnteringDateMonth = int.parse(enterings[1]).toString();
    }
    txtSalMonthController.text = staffInfo.salaryMonth;
    txtSalDayController.text = staffInfo.salaryDay;
    txtSalTimeController.text = staffInfo.salaryTime;
    selectSalaryMin = staffInfo.salaryMinute;
    isMonthSalary = staffInfo.salaryMonth != '';
    isDaySalary = staffInfo.salaryDay != '';
    isHourSalary = staffInfo.salaryMinute != null;
    gradeLevel = staffInfo.gradeLevel;
    nationalLevel = staffInfo.nationalLevel;
    txtCommentController.text = staffInfo.comment;

    allMenuValue = staffInfo.menuResponse;
    txtAddRateController.text = staffInfo.addRate;
    txtTestRateController.text = staffInfo.testRate;
    txtQualityRateController.text = staffInfo.qualityRate;

    organList = await ClOrgan().loadOrganList(context, globals.companyId, '');
    menus = await ClMenu().loadCompanyUserMenus(context, globals.companyId);

    setState(() {});

    return [];
  }

  Future<void> saveStaffInfo() async {
    String txtFirstName = txtFirstNameController.text;
    String txtLastName = txtLastNameController.text;
    String txtPhone = txtPhoneController.text;
    String txtMail = txtMailController.text;
    String txtShift = txtShiftController.text;
    String txtSalaryMonths = txtSalMonthController.text;
    String txtSalaryDays = txtSalDayController.text;
    String txtSalaryTimes = txtSalTimeController.text;

    if (selStaffAuth == '0' && selTablePosition == null) {
      Fluttertoast.showToast(msg: "座席を選択してください。");
      return;
    }

    if (txtFirstName == '') {
      Fluttertoast.showToast(msg: "氏名を入力してください。");
      return;
    }
    if (txtLastName == '') {
      Fluttertoast.showToast(msg: "氏名を入力してください。");
      return;
    }
    if (txtPhone == '') {
      Fluttertoast.showToast(msg: "電話番号を入力してください。");
      return;
    }
    if (txtMail == '') {
      Fluttertoast.showToast(msg: "メールアドレスを入力してください。");
      return;
    } else if (!txtMail.contains('@') || !txtMail.contains('.')) {
      Fluttertoast.showToast(msg: "メール形式を正確に入力してください。");
      return;
    }
    if (txtShift == '') {
      Fluttertoast.showToast(msg: "週間希望勤務時間を入力してください。");
      return;
    }

    if (txtPwdConfController.text != txtPwdController.text) {
      Fluttertoast.showToast(msg: "パスワードとパスワード確認は同一の内容をを入力してください。");
      return;
    }

    if (!isMonthSalary) {
      txtSalaryMonths = '';
    } else {
      if (txtSalaryMonths == '') {
        Fluttertoast.showToast(msg: "毎月の給与を入力します。");
        return;
      }
    }
    if (!isDaySalary) {
      txtSalaryDays = '';
    } else {
      if (txtSalaryDays == '') {
        Fluttertoast.showToast(msg: "毎日の給与を入力します。");
        return;
      }
    }
    if (!isHourSalary) {
      selectSalaryMin = null;
      txtSalaryTimes = '';
    } else {
      if (txtSalaryTimes == '') {
        Fluttertoast.showToast(msg: "給与時間を選択してください。");
        return;
      }
      if (selectSalaryMin == null) {
        Fluttertoast.showToast(msg: "毎時給与を入力します。");
        return;
      }
    }

    setState(() {});

    if (staffOrgans.length == 0) {
      Dialogs().infoDialog(context, warningSelectOrgan);
      return;
    }

    String imagename = '';
    if (isphoto) {
      if (isphoto) {
        imagename = 'avator-' +
            DateTime.now()
                .toString()
                .replaceAll(':', '')
                .replaceAll('-', '')
                .replaceAll('.', '')
                .replaceAll(' ', '') +
            '.jpg';
        await Webservice().callHttpMultiPart(
            'picture', apiStaffUploadAvatorUrl, _photoFile.path, imagename);
      }
    }

    Map<dynamic, dynamic> results = {};
    // if (widget.selectStaffId == null) {
    Dialogs().loaderDialogNormal(context);
    await Webservice().loadHttp(context, apiSaveStaffInfoUrl, {
      'staff_id': this.editStaffId == null ? '' : this.editStaffId,
      'staff_auth': selStaffAuth == null ? '' : selStaffAuth,
      'table_position': selTablePosition == null ? '' : selTablePosition,
      'staff_first_name': txtFirstName,
      'staff_last_name': txtLastName,
      'staff_nick': txtNickController.text,
      'staff_tel': txtPhone,
      'staff_mail': txtMail,
      'staff_shift': txtShift,
      'staff_password': txtPwdController.text,
      'staff_sex': sexValue,
      'staff_birthday': selectYear + '-' + selectMonth + '-' + selectDay,
      'staff_entering_date': selEnteringDateYear +
          '-' +
          (int.parse(selEnteringDateMonth) < 10 ? '0' : '') +
          selEnteringDateMonth,
      'grade_level': gradeLevel,
      'national_level': nationalLevel,
      'staff_organs': jsonEncode(staffOrgans),
      'staff_salary_months': txtSalaryMonths,
      'staff_salary_days': txtSalaryDays,
      'staff_salary_minutes': selectSalaryMin == null ? '' : selectSalaryMin,
      'staff_salary_times': txtSalaryTimes,
      'staff_avatar': imagename,
      'staff_comment': txtCommentController.text,
      'menu_response': allMenuValue == null ? '' : allMenuValue,
      'add_rate': txtAddRateController.text,
      'test_rate': txtTestRateController.text,
      'quality_rate': txtQualityRateController.text
    }).then((v) => {results = v});
    Navigator.pop(context);

    if (results['isSave']) {
      setState(() {
        this.editStaffId = results['staff_id'].toString();
        txtPwdController.text = '';
        txtPwdConfController.text = '';

        if (widget.selectStaffId != globals.staffId) {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return StaffList();
          }));
        } else {
          Dialogs().infoDialog(context, successUpdateAction);
        }
      });
    } else {
      if (results['err_type'] == 'organ_input_err') {
        Dialogs().infoDialog(context, warningStaffOrganOtherCompany);
      } else if (results['err_type'] == 'mail_input_err') {
        Dialogs().infoDialog(context, warningStaffMailDuplicate);
      }
    }
  }

  Future<void> deleteStaffInfo() async {
    if (this.editStaffId == null) return;

    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;

    Map<dynamic, dynamic> results = {};
    // if (widget.selectStaffId == null) {
    Dialogs().loaderDialogNormal(context);
    await Webservice().loadHttp(context, apiDeleteStaffInfoUrl, {
      'staff_id': this.editStaffId,
      'login_staff_id': globals.staffId
    }).then((v) => {results = v});

    Navigator.pop(context);
    if (results['isDelete']) {
      Navigator.pop(context);
    } else {
      if (results['msg'] == null) {
        Dialogs().infoDialog(context, errServerActionFail);
      } else if (results['msg'] == 'organ_contain_err') {
        Dialogs().infoDialog(context, errStaffOrganContain);
      }
    }
  }

  Future<void> passwordClear() async {
    // Map<dynamic, dynamic> results = {};
    // await Webservice().callHttp(context, AppConst.apiFormatStaffPasswordUrl,
    //     {'staff_id': widget.selectStaffId}).then((v) => {results = v});

    // if (results['isUpdate']) {
    //   Dialogs().infoDialog(context, '初期化されました。');
    // }
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
      isphoto = true;
      _photoFile = File(path);
    });
  }

  Future<void> loadStaffEnableMenus(organId) async {
    menuOrganSelId = organId;
    enableMenus = await ClStaff()
        .loadStaffEnableMenus(context, widget.selectStaffId, menuOrganSelId);
    setState(() {});
  }

  void pushPointSubmit() {
    if (editStaffId == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return StaffPointSubmit(selectStaffId: editStaffId!);
    }));
  }

  void pushPersionalPoint() {
    if (editStaffId == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return StaffPoint(staffId: editStaffId!);
    }));
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'スタッフ管理';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                _getBodyContent(),
                _getBottomButtons(),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  var dropDownInputDecoration = const InputDecoration(
    contentPadding: EdgeInsets.fromLTRB(7, 7, 0, 7),
    fillColor: Colors.white,
    filled: true,
    isDense: true,
    border: OutlineInputBorder(),
  );

  double lineSpacing = 16;

  Widget _getBodyContent() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (editStaffId == globals.staffId) _getAvatarContent(),
            Container(
              color: const Color(0xfffbfbfb),
              // padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  const PageSubHeader(label: '基本情報'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        _getRowHeight(),
                        if (globals.staffId != editStaffId)
                          _getPermissionContent(),
                        if (globals.staffId != editStaffId) _getRowHeight(),
                        _getStaffName(),
                        _getRowHeight(),
                        _getTextInputContent(
                            'ニックネーム', txtNickController, TextInputType.text),
                        _getRowHeight(),
                        _getTextInputContent(
                            '電話番号', txtPhoneController, TextInputType.number),
                        _getRowHeight(),
                        _getTextInputContent('メールアドレス', txtMailController,
                            TextInputType.emailAddress),
                        if (editStaffId == globals.staffId || globals.auth > constAuthStaff) _getRowHeight(),
                        if (editStaffId == globals.staffId || globals.auth > constAuthStaff)
                          _getPasswordContent(),
                        if (editStaffId == globals.staffId || globals.auth > constAuthStaff) _getRowHeight(),
                        if (editStaffId == globals.staffId || globals.auth > constAuthStaff)
                          _getPasswordConfirmContent(),
                        _getRowHeight(),
                        _getTextInputContent('週間希望勤務時間', txtShiftController,
                            TextInputType.number),
                        _getRowHeight(),
                        _getGenderContent(),
                        _getRowHeight(),
                        _getBirthDayContent(),
                      ],
                    ),
                  ),
                  const PageSubHeader(label: '所属店舗'),
                  _getOrganListContent(),
                  const PageSubHeader(label: 'アピール文'),
                  _getCommentText(),
                  const PageSubHeader(label: '資格情報'),
                  _getRowHeight(),
                  _getInputCompany(),
                  _getRowHeight(),
                  _getGradeContent(),
                  _getRowHeight(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RowLabelInput(
                      label: '国家資格',
                      renderWidget: CheckNomal(
                        label: '',
                        value: nationalLevel == '1',
                        scale: 1.5,
                        tapFunc: globals.auth > constAuthStaff
                            ? (v) {
                                setState(() {
                                  nationalLevel = v ? '1' : '';
                                });
                              }
                            : null,
                      ),
                    ),
                  ),
                  _getRowHeight(),
                  const PageSubHeader(label: '給与設定'),
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _getSalaryMonthContent(),
                        _getRowHeight(),
                        _getSalaryDayContent(),
                        _getRowHeight(),
                        _getSalaryHourContent(),
                        _getRowHeight(),
                        const SizedBox(height: 8),
                        _getAllMenuSelect(),
                        const SizedBox(height: 8),
                        _getPersionalRate(),
                        const SizedBox(height: 8),
                        _getTestAdditionalRate(),
                        const SizedBox(height: 8),
                        _getQualityAdditionalRate(),
                        const SizedBox(height: 8),
                        // if (widget.selectStaffId != null) _getStaffPointButton()
                      ],
                    ),
                  ),
                  _getRowHeight(),
                  const PageSubHeader(label: '施術可能コース一覧'),
                  _getEnableMenus(),
                ],
              ),
            )
          ],
        ),
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
        tapFunc: globals.auth > constAuthStaff
            ? (v) => allMenuValue = v.toString()
            : null,
      ),
    );
  }

  Widget _getPersionalRate() {
    return RowLabelInput(
      label: '個人レート',
      labelWidth: 130,
      renderWidget: TextInputNormal(
        isEnable: globals.auth > constAuthStaff,
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
        isEnable: globals.auth > constAuthStaff,
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
        isEnable: globals.auth > constAuthStaff,
        contentPadding: 10,
        controller: txtQualityRateController,
        inputType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  Widget _getRowHeight() {
    return const SizedBox(height: 16);
  }

  Widget _getBottomButtons() {
    return RowButtonGroup(
      widgets: [
        PrimaryButton(
            label: '保存',
            tapFunc: () {
              saveStaffInfo();
            }),
        if (editStaffId != globals.staffId) const SizedBox(width: 16),
        if (editStaffId != globals.staffId)
          CancelButton(
              label: '保存せず戻る',
              tapFunc: () {
                Navigator.pop(context);
              }),
        if (editStaffId != globals.staffId) const SizedBox(width: 16),
        if (editStaffId != globals.staffId)
          DeleteButton(
            label: '削除',
            tapFunc: globals.editMenuId == ''
                ? null
                : () {
                    deleteStaffInfo();
                  },
          ),
      ],
    );
  }

  Widget _getAvatarContent() {
    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.only(top: 25),
              child: null,
              decoration: BoxDecoration(
                color: const Color(0xffcecece),
                image: isphoto
                    ? DecorationImage(
                        image: FileImage(_photoFile),
                        fit: BoxFit.contain,
                      )
                    : DecorationImage(
                        image: editStaffId == null
                            ? NetworkImage(apiGetStaffAvatarUrl)
                            : NetworkImage(apiGetStaffAvatarUrl + editStaffId!),
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(right: 30),
              alignment: Alignment.topRight,
              child: DropdownButton(
                items: [
                  DropdownMenuItem(
                    child: Text("カメラ撮る"),
                    value: 1,
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
          )
        ],
      ),
    );
  }

  Widget _getPermissionContent() {
    return Row(
      children: <Widget>[
        const InputLeftText(label: 'アクセス権限', rPadding: 4),
        Flexible(
          flex: 3,
          child: DropDownModelSelect(
            value: selStaffAuth,
            items: _getPermissionList(),
            tapFunc: globals.auth < constAuthManager
                ? null
                : (v) {
                    selStaffAuth = v.toString();
                    setState(() {});
                  },
          ),
        ),
        if (selStaffAuth != null && int.parse(selStaffAuth!) < 1)
          const SizedBox(width: 20),
        if (selStaffAuth != null && int.parse(selStaffAuth!) < 1)
          const InputLeftText(label: '座席', width: 40, rPadding: 8),
        if (selStaffAuth != null && int.parse(selStaffAuth!) < 1)
          const SizedBox(width: 10),
        if (selStaffAuth != null && int.parse(selStaffAuth!) < 1)
          Flexible(
            flex: 2,
            child: DropDownModelSelect(
              value: selTablePosition,
              items: [
                ...dropTableCount.map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
              ],
              tapFunc: (v) {
                selTablePosition = v.toString();
                setState(() {});
              },
            ),
          ),
      ],
    );
  }

  List<DropdownMenuItem<dynamic>> _getPermissionList() {
    List optionList = [];
    for (var item in authList) {
      if (globals.auth > int.parse(item['value'])) {
        optionList.add(item);
      }
    }
    return [
      ...optionList.map((e) => DropdownMenuItem(
            value: e['value'],
            child: Text(e['label']),
          ))
    ];
  }

  Widget _getStaffName() {
    return Row(children: <Widget>[
      const InputLeftText(label: '氏名', rPadding: 4),
      SizedBox(
          width: 100,
          child: TextInputNormal(
              controller: txtFirstNameController,
              inputType: TextInputType.text)),
      SizedBox(child: Container(width: 10)),
      SizedBox(
          width: 100,
          child: TextInputNormal(
              controller: txtLastNameController,
              inputType: TextInputType.text)),
    ]);
  }

  Widget _getTextInputContent(label, controller, inputType) {
    return RowLabelInput(
      label: label,
      labelPadding: 4,
      renderWidget: TextInputNormal(
        controller: controller,
        inputType: inputType,
      ),
    );
  }

  Widget _getPasswordContent() {
    return RowLabelInput(
      label: 'パスワード',
      labelPadding: 4,
      renderWidget: TextInputNormal(
        controller: txtPwdController,
        inputType: TextInputType.visiblePassword,
        obscureText: true,
      ),
    );
  }

  Widget _getPasswordConfirmContent() {
    return RowLabelInput(
      label: 'パスワード確認',
      labelPadding: 4,
      renderWidget: TextInputNormal(
        controller: txtPwdConfController,
        inputType: TextInputType.visiblePassword,
        obscureText: true,
      ),
    );
  }

  Widget _getGenderContent() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            const InputLeftText(label: '性別'),
            Flexible(
              child: Row(
                children: [
                  RadioNomal(
                    label: '男',
                    value: '1',
                    groupValue: sexValue,
                    tapFunc: () => setState(() {
                      sexValue = '1';
                    }),
                  ),
                  const SizedBox(width: 30),
                  RadioNomal(
                    label: '女',
                    value: '2',
                    groupValue: sexValue,
                    tapFunc: () => setState(() {
                      sexValue = '2';
                    }),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _getInputCompany() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const InputLeftText(label: '入社日', rPadding: 8),
          SizedBox(
            width: 100,
            child: DropDownNumberSelect(
                value: selEnteringDateYear,
                min: 2010,
                max: 2050,
                tapFunc: globals.auth > constAuthStaff
                    ? (v) {
                        selEnteringDateYear = v;
                      }
                    : null),
          ),
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text('年', style: bodyTextStyle),
          ),
          SizedBox(
            width: 80,
            child: DropDownNumberSelect(
                value: selEnteringDateMonth,
                max: 12,
                tapFunc: globals.auth > constAuthStaff
                    ? (v) {
                        selEnteringDateMonth = v;
                      }
                    : null),
          ),
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text('月', style: bodyTextStyle),
          ),
        ],
      ),
    );
  }

  Widget _getBirthDayContent() {
    return Container(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: <Widget>[
            const InputLeftText(label: '生年月日'),
            SizedBox(
                width: 80,
                child: DropDownNumberSelect(
                    value: selectYear,
                    min: 1940,
                    max: 2050,
                    tapFunc: (v) {
                      setState(() {
                        selectYear = v.toString();
                        maxday = Funcs().getMaxDay(selectYear, selectMonth);
                      });
                    })),
            Expanded(
                child: Container(
                    alignment: Alignment.center,
                    child: Text('年', style: bodyTextStyle))),
            SizedBox(
                width: 60,
                child: DropDownNumberSelect(
                    value: selectMonth,
                    max: 12,
                    tapFunc: (v) {
                      setState(() {
                        selectMonth = v.toString();
                        maxday = Funcs().getMaxDay(selectYear, selectMonth);
                      });
                    })),
            Expanded(
                child: Container(
                    alignment: Alignment.center,
                    child: Text('月', style: bodyTextStyle))),
            SizedBox(
                width: 60,
                child: DropDownNumberSelect(
                    value: selectDay,
                    max: maxday,
                    tapFunc: (v) {
                      setState(() {
                        selectDay = v.toString();
                      });
                    })),
            Expanded(
                child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '日',
                      style: bodyTextStyle,
                    ))),
          ],
        ));
  }

  Widget _getOrganListContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 4,
          children: [
            ...organList.map(
              (e) => CheckNomal(
                label: e.organName.length > 7 ? '${e.organName.substring(0,7)}...' : e.organName,
                value: staffOrgans.contains(e.organId) ? true : false,
                scale: 1.4,
                tapFunc: (globals.auth < constAuthBoss &&
                        editStaffId == globals.staffId)
                    ? null
                    : (v) {
                        setState(() {
                          if (v!) {
                            staffOrgans.add(e.organId);
                          } else {
                            staffOrgans.remove(e.organId);
                          }
                        });
                      },
              ),
            ),
          ]),
    );
  }

  Widget _getSalaryMonthContent() {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: CheckNomal(
            label: '月給',
            value: isMonthSalary,
            scale: 1.4,
            tapFunc: globals.staffId == editStaffId
                ? null
                : (v) {
                    setState(() {
                      isMonthSalary = v!;
                    });
                  },
          ),
        ),
        Flexible(
          child: TextInputNormal(
            controller: txtSalMonthController,
            inputType: TextInputType.number,
          ),
        ),
        Container(
            alignment: Alignment.center,
            width: 30,
            child: Text('円', style: bodyTextStyle))
      ],
    );
  }

  Widget _getSalaryDayContent() {
    return Row(
      children: [
        SizedBox(
            width: 140,
            child: CheckNomal(
              label: '日給',
              value: isDaySalary,
              scale: 1.4,
              tapFunc: globals.staffId == editStaffId
                  ? null
                  : (v) {
                      setState(() {
                        isDaySalary = v!;
                      });
                    },
            )),
        Flexible(
          child: TextInputNormal(
            controller: txtSalDayController,
            inputType: TextInputType.number,
          ),
        ),
        Container(
            alignment: Alignment.center,
            width: 30,
            child: Text('円', style: bodyTextStyle))
      ],
    );
  }

  Widget _getSalaryHourContent() {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: CheckNomal(
            label: '時給',
            value: isHourSalary,
            scale: 1.4,
            tapFunc: globals.staffId == editStaffId
                ? null
                : (v) {
                    setState(() {
                      isHourSalary = v!;
                    });
                  },
          ),
        ),
        Container(
          width: 80,
          padding: const EdgeInsets.only(right: 10),
          child: DropDownNumberSelect(
              value: selectSalaryMin,
              min: 5,
              max: 90,
              diff: 5,
              tapFunc: globals.staffId != editStaffId && isHourSalary
                  ? (v) {
                      setState(() {
                        selectSalaryMin = v.toString();
                      });
                    }
                  : null),
        ),
        Flexible(
          child: TextInputNormal(
            controller: txtSalTimeController,
            inputType: TextInputType.number,
          ),
        ),
        Container(
            alignment: Alignment.center,
            width: 30,
            child: Text('円', style: bodyTextStyle))
      ],
    );
  }

  // Widget _getStaffPointButton() {
  //   return Row(
  //     children: [
  //       SizedBox(width: 20),
  //       if (globals.staffId == widget.selectStaffId)
  //         Expanded(
  //             child: WhiteButton(
  //                 label: 'ポイント申請', tapFunc: () => pushPointSubmit())),
  //       SizedBox(width: 12),
  //       if (globals.auth > AUTH_STAFF)
  //         Expanded(
  //             child: WhiteButton(
  //                 label: 'ポイント設定', tapFunc: () => pushPersionalPoint())),
  //       SizedBox(width: 20),
  //     ],
  //   );
  // }

  Widget _getCommentText() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: TextInputNormal(
          multiLine: 5,
          controller: txtCommentController,
          hintText: '本文を入力してください。',
        ));
  }

  Widget _getGradeContent() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: <Widget>[
          const InputLeftText(label: '検定'),
          Flexible(
            child: Row(
              children: [
                RadioNomal(
                  label: 'なし',
                  value: '',
                  groupValue: gradeLevel,
                  tapFunc: globals.auth > constAuthStaff
                      ? () => setState(() {
                            gradeLevel = '';
                          })
                      : null,
                ),
                const SizedBox(width: 5),
                RadioNomal(
                  label: '1級',
                  value: '1',
                  groupValue: gradeLevel,
                  tapFunc: globals.auth > constAuthStaff
                      ? () => setState(() {
                            gradeLevel = '1';
                          })
                      : null,
                ),
                const SizedBox(width: 5),
                RadioNomal(
                  label: '2級',
                  value: '2',
                  groupValue: gradeLevel,
                  tapFunc: globals.auth > constAuthStaff
                      ? () => setState(() {
                            gradeLevel = '2';
                          })
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getEnableMenus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(children: [
        Row(children: [
          const Text('お店名'),
          const SizedBox(width: 8),
          Flexible(
              child: DropDownModelSelect(
                  value: menuOrganSelId,
                  items: [
                    ...ownerOrgans.map((e) => DropdownMenuItem(
                          value: e.organId,
                          child: Text(e.organName),
                        ))
                  ],
                  tapFunc: (v) => loadStaffEnableMenus(v)))
        ]),
        if (menus.where((element) => element.organId == menuOrganSelId).isEmpty)
          Container(
              margin: const EdgeInsets.symmetric(vertical: 36),
              child: const Text('表示するメニューはありません。',
                  style: TextStyle(fontSize: 18))),
        ...menus.where((element) => element.organId == menuOrganSelId).map(
            (ee) => CheckNomal(
                tapFunc: globals.auth > constAuthStaff
                    ? (v) async {
                        await ClStaff().updateStaffEnableMenu(
                            context, widget.selectStaffId, ee.menuId);
                        loadStaffEnableMenus(menuOrganSelId);
                      }
                    : null,
                label: ee.menuTitle.length > 20
                    ? ('${ee.menuTitle.substring(0, 18)}...')
                    : ee.menuTitle,
                value: enableMenus.contains(ee.menuId)))
      ]),
    );
  }
}
