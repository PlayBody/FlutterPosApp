import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/interface/admin/component/adminbutton.dart';
import 'package:staff_pos_app/src/interface/admin/users/admin_group_edit.dart';
import 'package:staff_pos_app/src/interface/admin/style/borders.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/model/usermodel.dart';

import '../../../common/globals.dart' as globals;

class AdminGroupUser extends StatefulWidget {
  final String? groupId;
  const AdminGroupUser({this.groupId, Key? key}) : super(key: key);

  @override
  _AdminGroupUser createState() => _AdminGroupUser();
}

class _AdminGroupUser extends State<AdminGroupUser> {
  late Future<List> loadData;
  List<UserModel> userList = [];
  List<String> groupUserIds = [];

  @override
  void initState() {
    super.initState();
    loadData = loadInitData();
  }

  Future<List> loadInitData() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadUserWithGroupUrl, {
      'company_id': globals.companyId,
      'group_id': widget.groupId == null ? '' : widget.groupId
    }).then((value) => results = value);

    userList = [];
    if (results['isLoad']) {
      for (var item in results['users']) {
        userList.add(UserModel.fromJson(item));
      }

      for (var item in results['group_users']) {
        groupUserIds.add(item['user_id']);
      }
    }
    setState(() {});
    return userList;
  }

  void updateUserGroup(userId) {
    if (groupUserIds.contains(userId)) {
      groupUserIds.remove(userId);
    } else {
      groupUserIds.add(userId);
    }
    setState(() {});
  }

  void pushGroupMake() {
    if (groupUserIds.length < 1) {
      Dialogs().infoDialog(context, 'ユーザーを選択してください。');
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return AdminGroupEdit(
        groupId: widget.groupId,
        groupUsers: groupUserIds,
        users: userList,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'メンバー選択';
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
                    padding: paddingAdminSearchBottom,
                    child: TextFormField(
                      decoration: decorationSearch,
                      onChanged: (value) {},
                    ),
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text('ユーザー', style: stylePageSubtitle)),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...userList.map((e) => Container(
                                margin: new EdgeInsets.symmetric(vertical: 8.0),
                                decoration: borderAllRadius8,
                                padding: paddingUserNameGruop,
                                child: Container(
                                    padding: paddingUserNameGruop,
                                    child: Row(children: [
                                      Expanded(
                                          child: Text(
                                        e.userFirstName == ''
                                            ? e.userNick!
                                            : (e.userFirstName! +
                                                '  ' +
                                                e.userLastName!),
                                        style: styleUserName1,
                                      )),
                                      Checkbox(
                                          value:
                                              groupUserIds.contains(e.userId),
                                          onChanged: (v) {
                                            updateUserGroup(e.userId);
                                          })
                                    ])),
                              ))
                        ]),
                  )),
                  AdminPrimaryBtn(label: '次へ', tapFunc: () => pushGroupMake())
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
    ));
  }
}
