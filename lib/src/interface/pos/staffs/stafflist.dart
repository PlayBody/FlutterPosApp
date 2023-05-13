import 'package:flutter/material.dart';

import 'package:staff_pos_app/src/common/business/staffs.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/pos/manage/organs/organ_setting.dart';
import 'package:staff_pos_app/src/interface/pos/staffs/staffedit.dart';
import 'package:staff_pos_app/src/model/stafforgangroupmodel.dart';

import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;

class StaffList extends StatefulWidget {
  const StaffList({Key? key}) : super(key: key);

  @override
  _StaffList createState() => _StaffList();
}

class _StaffList extends State<StaffList> {
  late Future<List> loadData;
  List<StaffOrganGroupModel> staffList = [];

  bool isPermision = false;

  @override
  void initState() {
    super.initState();
    loadData = loadStaffData();
  }

  Future<List> loadStaffData() async {
    staffList = await ClStaff().loadStaffByGroupList(context);

    setState(() {});
    return staffList;
  }

  void pushOrganSetting(String organId) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return OrganSetting(organId: organId);
    }));
  }

  Future<void> pushStaffEdit(String? staffId) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return StaffEdit(selectStaffId: staffId);
    }));

    loadStaffData();
  }

  Future<void> exchangeMenuSort(moveId, targetId) async {
    Dialogs().loaderDialogNormal(context);
    await ClStaff().exchangeStaffSort(context, moveId, targetId);

    loadStaffData();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'スタッフ一覧';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _getBodyContent();
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  var organTitleStyle = TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF117fc1));
  var organSettingStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
      color: Color(0xFF919191));
  var staffNameStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff454545));
  var staffSettingStyle = TextStyle(
      fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF919191));

  Widget _getBodyContent() {
    return Container(
      color: Colors.white,
      child: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...staffList.map((e) => _getOrganGroup(e)),
              ],
            ),
          ),
        ),
        _getBottomButtons()
      ]),
    );
  }

  Widget _getOrganGroup(organ) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _getOrganTitle(organ),
          _getOrganTitleBar(),
          ...organ.staffs.map((ee) => LongPressDraggable(
                data: ee.staffId,
                child: DragTarget(
                  builder: (context, candidateData, rejectedData) =>
                      _getStaffItem(ee),
                  onAccept: (staffId) => exchangeMenuSort(staffId, ee.staffId),
                ),
                feedback: Container(
                  color: Colors.grey.withOpacity(0.3),
                  child: Text(
                    ee.staffNick == ''
                        ? ee.staffFirstName + '　' + ee.staffLastName
                        : ee.staffNick,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _getOrganTitle(organ) {
    return Container(
      color: Color(0xfff9f9f9),
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 20, bottom: 20, left: 18),
                child: Text(organ.organName, style: organTitleStyle),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 4, left: 80),
              child: Text('店舗設定', style: organSettingStyle),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.lock, color: Color(0xFFfc6101), size: 28),
            )
          ],
        ),
        onTap: () => pushOrganSetting(organ.organId),
      ),
    );
  }

  Widget _getOrganTitleBar() {
    return Row(
      children: [
        Expanded(child: Container(height: 4, color: Color(0xff117fc1))),
        Expanded(child: Container(height: 4, color: Color(0xFFbbbbbb)))
      ],
    );
  }

  Widget _getStaffItem(staff) {
    return Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xffdfdfdf)))),
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(20, 12, 24, 12),
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Color(0xffdddddd),
              image: DecorationImage(
                image: NetworkImage(apiGetStaffAvatarUrl + staff.staffId),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          title: Row(children: [
            staff.staffNick == ''
                ? Text(staff.staffFirstName + '　' + staff.staffLastName,
                    style: staffNameStyle)
                : Text(staff.staffNick, style: staffNameStyle),
            Expanded(child: Container()),
            Text('スタッフ管理', style: staffSettingStyle),
            SizedBox(width: 8),
            Image.asset('images/icon/right_sharp.png', scale: 1.6)
          ]),
          onTap: () => pushStaffEdit(staff.staffId),
        ));
  }

  Widget _getBottomButtons() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(width: 30),
          PrimaryButton(label: '新規登録', tapFunc: () => pushStaffEdit(null)),
          SizedBox(width: 30),
          CancelButton(label: '戻る', tapFunc: () => Navigator.pop(context)),
          SizedBox(width: 30),
        ],
      ),
    );
  }
}
