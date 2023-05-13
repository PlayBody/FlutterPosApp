import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/interface/admin/component/adminbutton.dart';
import 'package:staff_pos_app/src/interface/admin/style/borders.dart';
import 'package:staff_pos_app/src/interface/admin/style/inputformfields.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/model/usermodel.dart';

import '../../../common/globals.dart' as globals;
import 'admin_user_edit.dart';

class AdminGroupEdit extends StatefulWidget {
  final String? groupId;
  final List<String> groupUsers;
  final List<UserModel> users;
  const AdminGroupEdit(
      {this.groupId, required this.groupUsers, required this.users, Key? key})
      : super(key: key);

  @override
  _AdminGroupEdit createState() => _AdminGroupEdit();
}

class _AdminGroupEdit extends State<AdminGroupEdit> {
  String? selGroupId;

  late Future<List> loadData;

  var txtGroupNameController = TextEditingController();
  String groupName = '';
  String? errGroupName;

  List<UserModel> userList = [];

  @override
  void initState() {
    super.initState();
    selGroupId = widget.groupId;
    loadData = loadGroupUsers();
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'グループ名';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Container(
                color: bodyColor,
                padding: paddingMainContent,
                child: Column(
                  children: [
                    Container(
                      padding: paddingDivideBottom20,
                      child: AdminInputFormField(
                        hintText: 'グループ名',
                        callback: (v) => groupName = v,
                        txtController: txtGroupNameController,
                        errorText: errGroupName,
                      ),
                    ),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text('メンバー', style: stylePageSubtitle)),
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...widget.users
                              .map((e) => (widget.groupUsers.contains(e.userId)
                                  ? AdminGroupsListItem(
                                      userName: e.userNick == null
                                          ? e.userFirstName! +
                                              ' ' +
                                              e.userLastName!
                                          : e.userNick!,
                                      tapFunc: () {
                                        pushUserEdit(e.userId);
                                      },
                                    )
                                  : Container()))
                        ],
                      ),
                    )),
                    AdminPrimaryBtn(
                      label: '作成',
                      tapFunc: () => saveGroup(),
                    )
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<List> loadGroupUsers() async {
    txtGroupNameController.clear();
    if (widget.groupId == null) return [];
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadGroupInfoUrl,
        {'group_id': selGroupId}).then((value) => results = value);
    if (results['isLoad']) {
      txtGroupNameController.text = results['group']['group_name'];
    }

    setState(() {});
    return [];
  }

  Future<void> saveGroup() async {
    groupName = txtGroupNameController.text;
    if (groupName == '') {
      setState(() {
        errGroupName = warningCommonInputRequire;
      });
      return;
    }

    setState(() {
      errGroupName = null;
    });

    bool conf = await Dialogs().confirmDialog(context, qCommonSave);
    if (!conf) return;

    Map<dynamic, dynamic> results = {};

    await Webservice().loadHttp(context, apiSaveGroupNameUrl, {
      'group_id': widget.groupId == null ? '' : widget.groupId,
      'company_id': globals.companyId,
      'staff_id': globals.staffId,
      'group_users': jsonEncode(widget.groupUsers),
      'group_name': groupName
    }).then((value) => results = value);

    if (results['isSave']) {
      // selGroupId = results['group_id'].toString();
      // await Navigator.push(context, MaterialPageRoute(builder: (_) {
      //   return AdminGroupUser(
      //     groupId: results['group_id'].toString(),
      //   );
      // }));
      // loadGroupUsers();
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> pushUserEdit(userId) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return AdminUserEdit(userId: userId);
    }));
    loadGroupUsers();
  }
}

class AdminGroupsListItem extends StatelessWidget {
  final String userName;
  final tapFunc;
  const AdminGroupsListItem(
      {required this.userName, required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: new EdgeInsets.symmetric(vertical: 8.0),
        decoration: borderAllRadius8,
        padding: paddingUserNameGruop,
        child: Container(
            padding: paddingUserNameGruop,
            child: Row(children: [
              Text(
                userName,
                style: styleUserName1,
              )
            ])),
      ),
      onTap: tapFunc,
    );
  }
}
