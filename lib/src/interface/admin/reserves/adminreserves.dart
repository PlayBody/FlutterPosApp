import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/admin/style/buttonstyles.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';

import '../../../common/globals.dart' as globals;

class AdminReserves extends StatefulWidget {
  const AdminReserves({Key? key}) : super(key: key);

  @override
  _AdminReserves createState() => _AdminReserves();
}

class _AdminReserves extends State<AdminReserves> {
  bool isGroupView = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    globals.adminAppTitle = '予約一覧';
    return MainBodyWdiget(
      render: Center(
        child: Container(
          color: Colors.white,
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
                children: [
                  AdminUsersListItem(
                      userName: '佐藤　太郎', userAge: '30歳', tapFunc: () {}),
                  AdminUsersListItem(
                      userName: '佐藤　太郎', userAge: '30歳', tapFunc: () {}),
                  AdminUsersListItem(
                      userName: '佐藤　太郎', userAge: '30歳', tapFunc: () {}),
                ],
              )))
            ],
          ),
        ),
      ),
    );
  }
}

class AdminUsersListItem extends StatelessWidget {
  final String userName;
  final String userAge;
  final tapFunc;
  const AdminUsersListItem(
      {required this.userName,
      required this.userAge,
      required this.tapFunc,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: new EdgeInsets.symmetric(vertical: 12.0),
        child: ElevatedButton(
          child: Container(
              padding: paddingUserNameGruop,
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                        Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              userName,
                              style: styleUserName1,
                            )),
                        Text(
                          '2021/08/31 17:00～18:30',
                          style: styleContent,
                        )
                      ])),
                  Container(
                      height: 60,
                      child: Column(children: [
                        Container(
                            width: 90,
                            child: Text(
                              'ジャズコース',
                              style: styleContent,
                            )),
                        Container(
                            width: 90,
                            child: Text(
                              '名古屋店',
                              style: styleContent,
                            )),
                      ]))
                ],
              )),
          style: styleGroupButton,
          onPressed: tapFunc,
        ));
  }
}
