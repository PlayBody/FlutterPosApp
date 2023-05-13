import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/group.dart';
import 'package:staff_pos_app/src/common/business/user.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/admin/component/admin_texts.dart';
import 'package:staff_pos_app/src/interface/admin/messages/admin_messeage_make.dart';
import 'package:staff_pos_app/src/interface/admin/users/admin_group_user.dart';
import 'package:staff_pos_app/src/interface/admin/users/admin_user_info.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/admin/component/adminbutton.dart';
import 'package:staff_pos_app/src/interface/admin/style/borders.dart';
import 'package:staff_pos_app/src/interface/admin/style/buttonstyles.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:staff_pos_app/src/model/groupmodel.dart';
import 'package:staff_pos_app/src/model/usermodel.dart';

import '../../../common/globals.dart' as globals;

class AdminUserIndex extends StatefulWidget {
  List<String> userIds;
  AdminUserIndex({Key? key, required this.userIds}) : super(key: key);

  @override
  _AdminUserIndex createState() => _AdminUserIndex();
}

class _AdminUserIndex extends State<AdminUserIndex> {
  late Future<List> loadData;
  bool isGroupView = false;
  List<GroupModel> groupList = [];
  List<UserModel> userList = [];
  var txtSearchController = TextEditingController();
  String searchSex = '0';
  String? searchFromBirthMonth;
  String? searchFromBirthDay;
  String? searchToBirthMonth;
  String? searchToBirthDay;
  String? searchEnteringYear;
  String? searchEnteringMonth;
  String? searchEnteringDay;
  bool isShowSearchPannel = false;

  @override
  void initState() {
    super.initState();
    loadData = loadinitData();
  }

  Future<List> loadinitData() async {
    isShowSearchPannel = false;
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

    String strFromBirthday = '';
    if (searchFromBirthMonth != null) {
      strFromBirthday = (int.parse(searchFromBirthMonth!) < 10 ? '0' : '') +
          searchFromBirthMonth! +
          '-';

      if (searchFromBirthDay == null) {
        strFromBirthday += '01';
      } else {
        strFromBirthday += (int.parse(searchFromBirthDay!) < 10 ? '0' : '') +
            searchFromBirthDay!;
      }
    }

    String strToBirthday = '';
    if (searchToBirthMonth != null) {
      strToBirthday = (int.parse(searchToBirthMonth!) < 10 ? '0' : '') +
          searchToBirthMonth! +
          '-';

      if (searchToBirthDay == null) {
        strToBirthday += '31';
      } else {
        strToBirthday +=
            (int.parse(searchToBirthDay!) < 10 ? '0' : '') + searchToBirthDay!;
      }
    }

    String strVisitday = '';
    if (searchEnteringYear != null) {
      strVisitday = searchEnteringYear! + '-';
      if (searchEnteringMonth == null) {
        strVisitday += '01-01';
      } else {
        strVisitday += (int.parse(searchEnteringMonth!) < 10 ? '0' : '') +
            searchEnteringMonth! +
            '-';
        if (searchEnteringDay == null) {
          strVisitday += '01';
        } else {
          strVisitday += (int.parse(searchEnteringDay!) < 10 ? '0' : '') +
              searchEnteringDay!;
        }
      }
    }
    print(strVisitday);
    List<UserModel> allUserList = [];
    allUserList = await ClUser().loadUserList(context, globals.companyId, {
      'user_name': txtSearchController.text,
      'user_sex': searchSex,
      'user_search_birthday_from': strFromBirthday,
      'user_search_birthday_to': strToBirthday,
      'last_visit_date': strVisitday,
    });

    userList.clear();

    for(var el in allUserList) {
      if (widget.userIds.length > 0) {
        int searchIndex = widget.userIds.indexWhere((element) =>
        element == el.userId);
        if (searchIndex > -1) {
          userList.add(el);
        }
      }else {
        userList.add(el);
      }
    }

    setState(() {});

    return groupList;
  }

  Future<void> deleteGroup(groupId) async {
    if (groupId == null) return;
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;
    Dialogs().loaderDialogNormal(context);
    await ClGroup().deleteGroup(context, groupId);
    await loadinitData();
    Navigator.pop(context);
  }

  Future<void> loadRefresh() async {
    Dialogs().loaderDialogNormal(context);
    await loadinitData();
    Navigator.pop(context);
  }

  void onChangeSex(v) {
    searchSex = v;
    setState(() {});
  }

  void onClearCondition() {
    txtSearchController.clear();
    searchFromBirthMonth = null;
    searchFromBirthDay = null;
    searchToBirthMonth = null;
    searchToBirthDay = null;
    searchSex = '0';
    searchEnteringYear = null;
    searchEnteringMonth = null;
    searchEnteringDay = null;
    setState(() {});
  }

  void onChangeSearchPanne() {
    isShowSearchPannel = !isShowSearchPannel;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'ユーザー一覧';
    return MainBodyWdiget(
        render: FutureBuilder<List>(
      future: loadData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(color: bodyColor, child: _getBody());
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    ));
  }

  Widget _getBody() {
    return Center(
        child: Container(
            padding: paddingMainContent,
            child: Column(children: [
              _getSearchForm(),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                children: [
                  // _getAddTicketButton(),
                  _getGroupOpenButton(),
                  if (isGroupView) _getGroupList(),
                  ...userList.map((e) => _getUserListItem(e)),
                ],
              )))
            ])));
  }
  // TextFormField(
  //   controller: txtSearchController,
  //   decoration: decorationSearch,
  //   onChanged: (value) {
  //     loadinitData();
  //   },
  // )

  Widget _getSearchForm() {
    return Container(
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
      // padding: paddingAdminSearchBottom,
      child: Column(
        children: [
          Container(
              child: Row(
            children: [
              Expanded(child: Text('検索')),
              IconButton(
                  onPressed: () => onChangeSearchPanne(),
                  icon: Icon(isShowSearchPannel
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down))
            ],
          )),
          if (isShowSearchPannel)
            Container(
              child: Column(
                children: [
                  RowLabelInput(
                    label: '名前',
                    renderWidget:
                        TextInputNormal(controller: txtSearchController),
                  ),
                  RowLabelInput(
                    label: '生年月日',
                    renderWidget: Column(
                      children: [
                        Row(
                          children: [
                            Text('From'),
                            SizedBox(width: 4),
                            Flexible(
                                child: DropDownNumberSelect(
                                    isAddNull: true,
                                    max: 12,
                                    value: searchFromBirthMonth,
                                    tapFunc: (v) => searchFromBirthMonth = v)),
                            SizedBox(width: 4),
                            AdminCommentText(label: '月'),
                            SizedBox(width: 12),
                            Flexible(
                                child: DropDownNumberSelect(
                                    max: 31,
                                    isAddNull: true,
                                    value: searchFromBirthDay, //selDateDay,
                                    tapFunc: (v) => searchFromBirthDay = v)),
                            SizedBox(width: 4),
                            AdminCommentText(label: '日'),
                            Expanded(child: Container())
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text('     To'),
                            SizedBox(width: 4),
                            Flexible(
                                child: DropDownNumberSelect(
                                    isAddNull: true,
                                    max: 12,
                                    value: searchToBirthMonth,
                                    tapFunc: (v) => searchToBirthMonth = v)),
                            SizedBox(width: 4),
                            AdminCommentText(label: '月'),
                            SizedBox(width: 12),
                            Flexible(
                                child: DropDownNumberSelect(
                                    max: 31,
                                    isAddNull: true,
                                    value: searchToBirthDay, //selDateDay,
                                    tapFunc: (v) => searchToBirthDay = v)),
                            SizedBox(width: 4),
                            AdminCommentText(label: '日'),
                            Expanded(child: Container())
                          ],
                        )
                      ],
                    ),
                  ),
                  RowLabelInput(
                    label: '性別',
                    renderWidget: Row(
                      children: [
                        _getSexItemContents('0'),
                        Container(child: Text('すべて')),
                        _getSexItemContents('1'),
                        Container(child: Text('男')),
                        _getSexItemContents('2'),
                        Container(child: Text('女')),
                      ],
                    ),
                  ),
                  RowLabelInput(
                    label: '最近来店日',
                    renderWidget: Row(
                      children: [
                        SizedBox(width: 4),
                        Flexible(
                            flex: 3,
                            child: DropDownNumberSelect(
                                min: 2020,
                                isAddNull: true,
                                max: 2050,
                                value: searchEnteringYear,
                                tapFunc: (v) => searchEnteringYear = v)),
                        AdminCommentText(label: '月'),
                        SizedBox(width: 4),
                        Flexible(
                            flex: 2,
                            child: DropDownNumberSelect(
                                isAddNull: true,
                                max: 12,
                                value: searchEnteringMonth,
                                tapFunc: (v) => searchEnteringMonth = v)),
                        AdminCommentText(label: '月'),
                        SizedBox(width: 4),
                        Flexible(
                            flex: 2,
                            child: DropDownNumberSelect(
                                isAddNull: true,
                                max: 31,
                                value: searchEnteringDay, //selDateDay,
                                tapFunc: (v) => searchEnteringDay = v)),
                        AdminCommentText(label: '日'),
                      ],
                    ),
                  ),
                  RowButtonGroup(widgets: [
                    Expanded(child: Container()),
                    PrimaryColButton(
                        label: '検索する', tapFunc: () => loadRefresh()),
                    SizedBox(width: 32),
                    CancelColButton(
                        label: 'クリーア', tapFunc: () => onClearCondition()),
                    Expanded(child: Container()),
                  ])
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _getSexItemContents(String val) {
    return Container(
      child: Radio(
          groupValue: searchSex,
          value: val,
          onChanged: (v) => onChangeSex(v.toString())),
    );
  }

  // Widget _getAddTicketButton() {
  //   return AdminUserTicketAddButton(tapFunc: () => {});
  // }

  Widget _getGroupOpenButton() {
    return Container(
        child: ListTile(
      trailing: isGroupView
          ? Icon(Icons.keyboard_arrow_up)
          : Icon(Icons.keyboard_arrow_down),
      title: Text('グループ分け'),
      onTap: () {
        setState(() {
          isGroupView = !isGroupView;
        });
      },
    ));
  }

  Widget _getGroupList() {
    return Container(
      padding: paddingDivideBottom20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _getAddGroupButton(),
          _getGroupListItem(null, userList.length.toString(), 'すべてのユーザー'),
          ...groupList
              .map((e) => _getGroupListItem(e.groupId, e.userCnt!, e.groupName))
        ],
      ),
    );
  }

  Widget _getAddGroupButton() {
    return Container(
      child: AdminAddButton(
        label: '✛ 新規グループ作成',
        tapFunc: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) {
            return AdminGroupUser();
          }));
          loadinitData();
        },
      ),
    );
  }

  Widget _getGroupListItem(groupId, cnt, groupName) {
    return ListTile(
      contentPadding: EdgeInsets.all(0.0),
      title: Container(
        margin: new EdgeInsets.symmetric(vertical: 4.0),
        padding: paddingItemGroupWithButton,
        decoration: borderAllRadius8,
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: Text(groupName, style: styleItemGroupTitle),
                  ),
                  Container(
                      child: Text('(' + (cnt == null ? 0 : cnt) + ')',
                          style: styleItemGroupTitle))
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.only(top: 10),
                child: Row(children: [
                  Expanded(child: Container()),
                  ElevatedButton(
                    onPressed: (cnt == null || cnt == '0')
                        ? null
                        : () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return AdminMesseageMake(
                                  userId: groupId == null ? '0' : groupId,
                                  userName: groupName,
                                  isGroup: true);
                            }));
                          },
                    child: Text('メッセージを送る'),
                  ),
                  SizedBox(width: 4),
                  if (groupId != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      onPressed: () {
                        deleteGroup(groupId);
                      },
                      child: Text('削除'),
                    )
                ]))
          ],
        ),
      ),
      onTap: groupId == null
          ? null
          : () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) {
                  return AdminGroupUser(groupId: groupId);
                }),
              );
              loadinitData();
            },
    );
  }

  Widget _getUserListItem(e) {
    var userName = e.userFirstName == null
        ? ' '
        : (e.userFirstName! + ' ' + e.userLastName!);

    return Container(
      margin: new EdgeInsets.symmetric(vertical: 12.0),
      child: ElevatedButton(
        child: Container(
          padding: paddingUserNameGruop,
          child: Row(
            children: [
              Expanded(child: Text(userName + '様', style: styleUserName1)),
              Container(
                  child: Text(e.reserveCount! + '/' + e.visitCount!,
                      style: styleUserName1))
            ],
          ),
        ),
        style: styleGroupButton,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) {
            return AdminUserInfo(userId: e.userId);
          }));

          loadinitData();
        },
      ),
    );
  }
}
