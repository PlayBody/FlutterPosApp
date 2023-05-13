import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/business/staffs.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/pos/manage/shifts/settingshiftinit.dart';
import 'package:staff_pos_app/src/model/staff_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/globals.dart' as globals;

var txtAccountingController = TextEditingController();
var txtMenuCountController = TextEditingController();
var txtSetTimeController = TextEditingController();
var txtSetAmountController = TextEditingController();
var txtTableAmountController = TextEditingController();
var txtActiveStartController = TextEditingController();
var txtActiveEndController = TextEditingController();

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _Setting();
}

class _Setting extends State<Setting> {
  late Future<List> loadData;
  String isAdmin = '0';

  String organTitle = 'asd';

  bool isPush = true;
  bool isFace = false;
  bool isPosition = true;
  bool isCamera = true;

  @override
  void initState() {
    super.initState();
    loadData = loadSettingData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> changeBiometricStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      prefs.setString(globals.isBiometricEnableKey, 'yes');
    }else {
      prefs.setString(globals.isBiometricEnableKey, 'no');
    }
    setState(() {
      isFace = value;
    });
  }

  Future<List> loadSettingData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String faceIdStatus  = prefs.getString(globals.isBiometricEnableKey) ?? '';
    if (faceIdStatus == '' || faceIdStatus == 'yes') {
      isFace = true;
    }

    StaffModel staff = await ClStaff().loadStaffInfo(context, globals.staffId);
    //print(staff.isPush);
    isPush = staff.isPush;
    setState(() {});
    return [];
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = '設定';
    return MainBodyWdiget(
        render: FutureBuilder<List>(
      future: loadData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _getContentBody();
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return const Center(child: CircularProgressIndicator());
      },
    ));
  }

  Widget _getContentBody() {
    return Container(
      color: bodyColor,
      child: Column(
        children: [
          // _getContentPushRow('プロフィール', () {
          //   Navigator.push(context, MaterialPageRoute(builder: (_) {
          //     return StaffEdit(
          //       selectStaffId: globals.staffId,
          //     );
          //   }));
          // }),
          if (globals.auth < constAuthSystem)
            _getContentPushRow('標準シフト', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const SettingShiftInit();
              }));
            }),
          // _getContentPushRow('標準シフト', () {
          //   Navigator.push(context, MaterialPageRoute(builder: (_) {
          //     return const ShiftInit();
          //   }));
          // }),
          _getContentSwitchRow('プッシュ通知', isPush, (value) async {
            Dialogs().loaderDialogNormal(context);
            await ClStaff().updateStaffPush(context, value);
            Navigator.pop(context);
            loadSettingData();
          }),
          _getContentSwitchRow('生体認証', isFace, (value) {
            changeBiometricStatus(value);
          }),
          _getContentSwitchRow('位置情報の許可', isPosition, (value) {
            setState(() {
              isPosition = value;
            });
          }),
          _getContentSwitchRow('カメラの許可', isCamera, (value) async {
            setState(() {
              isCamera = value;
            });
          }),
        ],
      ),
    );
  }

  var rowDecoration = const BoxDecoration(
    border: Border(bottom: BorderSide(color: Color(0xFFd2dbe5), width: 1)),
  );
  var rowContentPadding =
      const EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 5);

  Widget _getContentPushRow(label, ontap) {
    return Container(
      decoration: rowDecoration,
      child: ListTile(
        trailing: const Icon(Icons.keyboard_arrow_right),
        contentPadding: rowContentPadding,
        title: Text(label),
        onTap: ontap,
      ),
    );
  }

  Widget _getContentSwitchRow(label, isCheck, onTap) {
    return Container(
      decoration: rowDecoration,
      child: ListTile(
        trailing: Switch(
          value: isCheck,
          onChanged: onTap,
          activeTrackColor: Colors.lightGreenAccent,
          activeColor: Colors.green,
        ),
        contentPadding: rowContentPadding,
        title: Text(label),
      ),
    );
  }
}
