import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/business/company.dart';
import 'package:staff_pos_app/src/common/business/notification.dart';
import 'package:staff_pos_app/src/common/business/orders.dart';
import 'package:staff_pos_app/src/common/business/user.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/interface/admin/admin_setting_connect_menu.dart';
import 'package:staff_pos_app/src/interface/admin/advise/admin_advises.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/admin/coupons/admin_coupon_list.dart';
import 'package:staff_pos_app/src/interface/admin/history/admin_history.dart';
import 'package:staff_pos_app/src/interface/admin/messages/admin_messeage_list.dart';
import 'package:staff_pos_app/src/interface/admin/reserves/adminreserves.dart';
import 'package:staff_pos_app/src/interface/admin/qrcode/admin_qrcode_reader.dart';
import 'package:staff_pos_app/src/interface/admin/questions/admin_questions.dart';
import 'package:staff_pos_app/src/interface/admin/users/admin_user_index.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/model/companymodel.dart';
import 'package:staff_pos_app/src/model/usermodel.dart';
import 'favorite_questions/admin_favorite_questions.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';

import '../../common/globals.dart' as globals;

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHome();
}

class _AdminHome extends State<AdminHome> {
  List<CompanyModel> companies = [];
  late Future<List> loadData;
  String unreadMessage = '';
  int reserveBadge = 0;
  List<String> userIds = [];
  @override
  void initState() {
    super.initState();
    if (globals.companyId == '') globals.companyId = '1';
    loadData = loadHomeData();

    // FirebaseMessaging.onMessage.listen((event) {
    //   loadHomeData();
    // });
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = '管理者ホーム';
    return MainBodyWdiget(
        render: FutureBuilder<List>(
      future: loadData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
              color: bodyColor,
              padding: paddingMainContent,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (globals.auth > 4)
                          DropdownButtonFormField(
                              value: globals.companyId,
                              onChanged: (value) => {
                                    globals.companyId = value.toString(),
                                  },
                              items: [
                                ...companies.map((e) => DropdownMenuItem(
                                      value: e.companyId,
                                      child: Text(e.companyName),
                                    )),
                              ]),
                        if (globals.auth > constAuthStaff)
                          AdminHomeMenuItem(
                              label: 'ユーザー一覧',
                              tapFunc: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return AdminUserIndex(userIds: [],);
                                  }))),
                        // AdminHomeMenuItem(
                        //     label: 'メニュー一覧',
                        //     tapFunc: () => Navigator.push(context,
                        //             MaterialPageRoute(builder: (_) {
                        //           return AdminMenuList();
                        //         }))),
                        if (globals.auth == constAuthSystem)
                          AdminHomeMenuItem(
                              label: '予約一覧',
                              tapFunc: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return const AdminReserves();
                                  }))),
                        // AdminHomeMenuItem(
                        //   label: '店舗一覧',
                        //   tapFunc: () => Navigator.push(context,
                        //       MaterialPageRoute(builder: (_) {
                        //     return AdminOrganList();
                        //   })),
                        // ),
                        if (globals.auth > constAuthStaff)
                          AdminHomeMenuItem(
                            label: 'クーポン一覧',
                            tapFunc: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return const AdminCuponList();
                            })),
                          ),
                        if (globals.auth == constAuthStaff && reserveBadge > 0)
                          Stack(
                            children: [
                              Positioned(
                                child: AdminHomeMenuItem(
                                  label: 'ユーザー一覧',
                                    tapFunc: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) {
                                          return AdminUserIndex(userIds: userIds,);
                                        }))),
                              ),
                                Positioned(
                                    right: 10,
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          color: Colors.red),
                                      width: 30,
                                      height: 30,
                                      child: Text(
                                        reserveBadge.toString(),
                                        style:
                                        const TextStyle(color: Colors.white),
                                      ),
                                    ))
                            ],
                          ),
                        Stack(
                          children: [
                            Positioned(
                              child: AdminHomeMenuItem(
                                label: 'メッセージ',
                                tapFunc: () => pushMessage(),
                              ),
                            ),
                            if (unreadMessage != '' && unreadMessage != '0')
                              Positioned(
                                  right: 10,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Colors.red),
                                    width: 30,
                                    height: 30,
                                    child: Text(
                                      unreadMessage,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ))
                          ],
                        ),
                        AdminHomeMenuItem(
                            label: '履歴一覧',
                            tapFunc: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) {
                                  return const AdminHistory();
                                }))),
                        AdminHomeMenuItem(
                          label: 'お客様からのお問い合わせ',
                          tapFunc: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return const AdminQuestions();
                          })),
                        ),
                        if (globals.auth > constAuthStaff)
                          AdminHomeMenuItem(
                            label: 'お問い合わせ一覧',
                            tapFunc: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return const AdminFavoriteQuestions();
                            })),
                          ),
                        if (globals.auth > constAuthStaff)
                          AdminHomeMenuItem(
                              label: 'アドバイス質問一覧',
                              tapFunc: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return const AdminAdvises();
                                  }))),
                        if (globals.auth > constAuthStaff)
                          AdminHomeMenuItem(
                              label: 'QR読み取り',
                              tapFunc: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return const AdminQrcodeReader();
                                  }))),
                        if (globals.auth > constAuthOwner)
                          AdminHomeMenuItem(
                              label: '店舗アプリ項目の設定',
                              tapFunc: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return const AdminSettingConnectMenu();
                                  }))),
                      ],
                    )),
                  )
                ],
              ));
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return const Center(child: CircularProgressIndicator());
      },
    ));
  }

  Future<List> loadHomeData() async {
    companies = await ClCompany().loadCompanyList(context);

    int badgeCnt = await ClNotification().getBageCountDetail(context, {
      'receiver_id': globals.staffId,
      'receiver_type': '1',
      'in_type': '16'
    });

    unreadMessage = badgeCnt.toString();

    reserveBadge = await ClNotification().getBageCountDetail(context, {
      'receiver_id': globals.staffId,
      'receiver_type': '1',
      'in_type': '13'
    });

    userIds = await ClOrder().loadOrderUserIds(context, globals.staffId);

    setState(() {});
    return [];
  }

  Future<void> pushMessage() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return const AdminMesseageList();
    }));
    loadHomeData();
  }
}

class AdminHomeMenuItem extends StatelessWidget {
  final String label;
  final GestureTapCallback tapFunc;
  const AdminHomeMenuItem(
      {required this.label, required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(10),
              // side: BorderSide(
              //   width: 0.5,
              //   color: Colors.grey,
              // ),
              primary:
                  const Color(0xffe3e3e3), //Color.fromARGB(255, 160, 30, 30),
              onPrimary: const Color(0xff454545),
              elevation: 0,
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          onPressed: tapFunc,
          child: Text(label)),
    );
  }
}
