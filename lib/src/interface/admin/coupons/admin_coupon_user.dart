import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/model/couponmodel.dart';
import 'package:staff_pos_app/src/interface/admin/style/buttonstyles.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/model/groupmodel.dart';
import 'package:staff_pos_app/src/model/usermodel.dart';

import '../../../common/globals.dart' as globals;
import 'admin_coupon_confirm.dart';

class AdminCouponUsers extends StatefulWidget {
  final List<CouponModel> selectCoupons;
  const AdminCouponUsers({required this.selectCoupons, Key? key})
      : super(key: key);

  @override
  State<AdminCouponUsers> createState() => _AdminCouponUsers();
}

class _AdminCouponUsers extends State<AdminCouponUsers> {
  late Future<List> loadData;
  bool isGroupView = false;
  List<GroupModel> groupList = [];
  List<UserModel> userList = [];
  List<String> selectUsers = [];
  List<String> selectGroups = [];
  List<UserModel> completeUsers = [];
  bool isAllSelect = false;

  @override
  void initState() {
    super.initState();
    loadData = loadinitData();
  }

  Future<List> loadinitData() async {
    Map<dynamic, dynamic> groupResults = {};
    await Webservice().loadHttp(context, apiLoadGroupListUrl, {
      'company_id': globals.companyId
    }).then((value) => groupResults = value);

    groupList = [];
    if (groupResults['isLoad']) {
      for (var item in groupResults['groups']) {
        groupList.add(GroupModel.fromJson(item));
      }
    }

    Map<dynamic, dynamic> userResults = {};
    await Webservice().loadHttp(context, apiLoadUserListUrl,
        {'company_id': globals.companyId}).then((value) => userResults = value);

    userList = [];
    if (userResults['isLoad']) {
      for (var item in userResults['users']) {
        userList.add(UserModel.fromJson(item));
      }
    }
    setState(() {});

    return groupList;
  }

  Future<void> searchUser(String search) async {
    var param = {
      'company_id': globals.companyId,
    };
    if (search != '') {
      param['condition'] = jsonEncode({'user_name': search});
    }
    Map<dynamic, dynamic> userResults = {};
    await Webservice().loadHttp(context, apiLoadUserListUrl, {
      'company_id': globals.companyId,
      'condition': jsonEncode({'user_name': search})
    }).then((value) => userResults = value);

    userList = [];
    if (userResults['isLoad']) {
      for (var item in userResults['users']) {
        userList.add(UserModel.fromJson(item));
      }
    }
    setState(() {});
  }

  void pushConfirm() {
    if (selectUsers.isEmpty) {
      Dialogs().infoDialog(context, '1人以上のユーザーを選択します。');
      return;
    }

    completeUsers = [];
    for (var element in userList) {
      if (selectUsers.contains(element.userId)) {
        completeUsers.add(element);
      }
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return AdminCouponConfirm(
          selectCoupons: widget.selectCoupons, selectUsers: completeUsers);
    }));
  }

  @override
  Widget build(BuildContext context) {
    globals.adminAppTitle = 'ユーザー選択';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Container(
                color: Colors.white,
                padding: paddingMainContent,
                child: Column(
                  children: [
                    Container(
                      padding: paddingAdminSearchBottom,
                      child: TextFormField(
                        decoration: decorationSearch,
                        onChanged: (value) => searchUser(value),
                      ),
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _getAllUserButton(),
                        _getGroupButton(),
                        if (isGroupView) _getGroupList(),
                        ...userList.map((e) => _getUserItem(e)),
                      ],
                    ))),
                    RowButtonGroup(widgets: [
                      PrimaryButton(label: '確認', tapFunc: () => pushConfirm())
                    ])
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _getAllUserButton() {
    return ElevatedButton(
      child: const Text('すべてのユーザー'),
      onPressed: () {
        isAllSelect = !isAllSelect;
        selectGroups = [];
        selectUsers = [];
        if (isAllSelect) {
          for (var element in groupList) {
            selectGroups.add(element.groupId);
          }
          for (var element in userList) {
            selectUsers.add(element.userId);
          }
        }
        setState(() {});
      },
    );
  }

  Widget _getGroupButton() {
    return ListTile(
      trailing: isGroupView
          ? const Icon(Icons.keyboard_arrow_up)
          : const Icon(Icons.keyboard_arrow_down),
      title: const Text('グループ分け'),
      onTap: () {
        setState(() {
          isGroupView = !isGroupView;
        });
      },
    );
  }

  Widget _getGroupList() {
    return Container(
      padding: paddingDivideBottom20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...groupList.map((e) => GestureDetector(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: selectGroups.contains(e.groupId)
                          ? const Color(0xffDBDBDB)
                          : Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.groupName,
                              style: styleItemGroupTitle,
                            ),
                          ),
                          Text(
                            '(${e.userCnt == null ? '0' : e.userCnt!})',
                            style: styleItemGroupTitle,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  Map<dynamic, dynamic> results = {};
                  await Webservice().loadHttp(
                      context, apiLoadUserWithGroupUrl, {
                    'company_id': globals.companyId,
                    'group_id': e.groupId
                  }).then((value) => results = value);
                  List<UserModel> groupUsers = [];
                  if (results['isLoad']) {
                    for (var item in results['users']) {
                      groupUsers.add(UserModel.fromJson(item));
                    }
                  }

                  if (selectGroups.contains(e.groupId)) {
                    selectGroups.remove(e.groupId);
                    isAllSelect = false;
                    for (var element in groupUsers) {
                      if (element.groupId != null &&
                          element.groupId == e.groupId) {
                        if (selectUsers.contains(element.userId)) {
                          selectUsers.remove(element.userId);
                        }
                      }
                    }
                  } else {
                    selectGroups.add(e.groupId);
                    for (var element in groupUsers) {
                      if (element.groupId != null &&
                          element.groupId == e.groupId) {
                        if (!selectUsers.contains(element.userId)) {
                          selectUsers.add(element.userId);
                        }
                      }
                    }
                  }
                  setState(() {});
                },
              )),
        ],
      ),
    );
  }

  Widget _getUserItem(UserModel user) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        child: ElevatedButton(
          style: styleGroupButton,
          onPressed: () {
            if (selectUsers.contains(user.userId)) {
              selectUsers.remove(user.userId);
              isAllSelect = false;
            } else {
              selectUsers.add(user.userId);
            }
            setState(() {});
          },
          child: Container(
              color: selectUsers.contains(user.userId)
                  ? const Color(0xffDBDBDB)
                  : Colors.white,
              padding: paddingUserNameGruop,
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    user.userFirstName == ''
                        ? user.userNick!
                        : ('${user.userFirstName!} ${user.userLastName!}'),
                    style: styleUserName1,
                  )),
                  Text(
                    user.userBirth == null
                        ? ''
                        : '${DateTime.now().year - DateTime.parse(user.userBirth!).year}歳${user.groupId == null ? '' : user.groupId!}',
                    style: styleUserName1,
                  )
                ],
              )),
        ));
  }
}
