import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/interface/home.dart';
import 'package:staff_pos_app/src/interface/pos/accounting/tables.dart';
import 'package:staff_pos_app/src/interface/pos/manage/organs/organ_setting.dart';
import 'package:staff_pos_app/src/interface/pos/manage/import/shiftimport.dart';
import 'package:staff_pos_app/src/interface/pos/manage/tickets/masters.dart';
import 'package:staff_pos_app/src/interface/pos/manage/tickets/ticketlist.dart';
import 'package:staff_pos_app/src/interface/pos/manage/companies/companies.dart';
import 'package:staff_pos_app/src/interface/pos/manage/menus/menulist.dart';
import 'package:staff_pos_app/src/interface/pos/manage/companies/companyedit.dart';
import 'package:staff_pos_app/src/interface/pos/manage/print/settingprinter.dart';
import 'package:staff_pos_app/src/interface/pos/manage/shifts/settingshiftcount.dart';
import 'package:staff_pos_app/src/interface/pos/staffs/staffedit.dart';
import 'package:staff_pos_app/src/interface/setting.dart';

import '../../common/globals.dart' as globals;
// Set up a mock HTTP client.

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          createDrawerHeader(),
          createDrawerBodyItem(
              icon: Icons.home,
              text: 'ホームに戻る',
              onTap: () => globals.auth > constAuthGuest
                  ? Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return Home();
                    }))
                  : Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return Tables();
                    }))),
          if (globals.auth > constAuthStaff)
            createDrawerBodyItem(
                icon: Icons.card_travel,
                text: 'チケット管理',
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return const TicketList();
                    }))),
          if (globals.auth >= constAuthOwner)
            createDrawerBodyItem(
                icon: Icons.card_travel_outlined,
                text: 'チケット種類管理', // Ticket type manage
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return Masters();
                    }))),
          if (globals.auth > constAuthStaff)
            createDrawerBodyItem(
                icon: Icons.sell,
                text: 'メニュー管理',
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return MenuList();
                    }))),
          if (globals.auth > constAuthStaff)
            createDrawerBodyItem(
                icon: Icons.shopping_bag,
                text: '店舗設定',
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return OrganSetting();
                    }))),
          if (globals.auth < constAuthSystem && globals.auth > constAuthStaff)
            createDrawerBodyItem(
                icon: Icons.filter_tilt_shift,
                text: 'シフト枠設定',
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return SettingShiftCount();
                    }))),
          if (globals.auth > constAuthOwner)
            createDrawerBodyItem(
                icon: Icons.food_bank,
                text: '企業管理',
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return Companies();
                    }))),
          if (globals.auth == constAuthOwner)
            createDrawerBodyItem(
                icon: Icons.food_bank,
                text: '企業管理',
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return CompanyEdit(
                        selComapnyId: globals.companyId,
                      );
                    }))),
          if (globals.auth > constAuthStaff)
            createDrawerBodyItem(
                icon: Icons.import_contacts,
                text: 'シフトExcelインポート',
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return ShiftImport();
                    }))),
          Divider(),
          createDrawerBodyItem(
              icon: Icons.info,
              text: '登録情報',
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return StaffEdit(selectStaffId: globals.staffId);
                  }))),
          createDrawerBodyItem(
              icon: Icons.print,
              text: '印刷設定',
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return SettingPrinter();
                  }))),
          createDrawerBodyItem(
              icon: Icons.settings,
              text: 'アプリ設定',
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return Setting();
                  }))),
          createDrawerBodyItem(
              icon: Icons.logout,
              text: 'ログアウト',
              onTap: () => Funcs().logout(context)),
        ],
      ),
    );
  }
}

Widget createDrawerHeader() {
  return Container(
      height: 80.0,
      color: Colors.grey,
      child: DrawerHeader(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: Stack(children: <Widget>[
            Positioned(
                bottom: 12.0,
                left: 16.0,
                child: Text("VISIT",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500))),
          ])));
}

Widget createDrawerBodyItem(
    {required IconData icon, required String text, GestureTapCallback? onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Icon(icon),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(text),
        )
      ],
    ),
    onTap: onTap,
  );
}
