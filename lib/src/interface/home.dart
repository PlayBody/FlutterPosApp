import 'package:flutter/material.dart';

import 'package:staff_pos_app/src/common/business/common.dart';
import 'package:staff_pos_app/src/common/business/notification.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/admin/adminhome.dart';
import 'package:staff_pos_app/src/interface/components/badge_content.dart';
import 'package:staff_pos_app/src/interface/layout/bottomnavi.dart';
import 'package:staff_pos_app/src/interface/layout/myappbar.dart';
import 'package:staff_pos_app/src/interface/layout/mydrawer.dart';
import 'package:staff_pos_app/src/interface/dlgattendance.dart';
import 'package:staff_pos_app/src/interface/pos/event/event.dart';
import 'package:staff_pos_app/src/interface/pos/payslip/payslip.dart';
import 'package:staff_pos_app/src/interface/pos/shift/shift_make.dart';
import 'package:staff_pos_app/src/interface/pos/staffs/stafflist.dart';
import 'package:staff_pos_app/src/interface/pos/sales/sumsale.dart';
import 'package:staff_pos_app/src/interface/style/sizes.dart';
import 'package:staff_pos_app/src/interface/style/spacings.dart';
import 'package:staff_pos_app/src/interface/style/textstyles.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';

import '../common/globals.dart' as globals;
import '../common/functions.dart';

import 'components/styles.dart';
import 'pos/accounting/tables.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  late Future<List> loadData;

  List<OrganModel> organList = [];
  int shiftBadgeCount = 0;
  int adminBadgeCount = 0;

  @override
  void initState() {
    super.initState();
    loadData = loadAttandanceData();
  }

  Future<List> loadAttandanceData() async {
    if (!globals.isLogin) {
      Funcs().logout(context);
    }

    String? attendOrganId =
        await ClCommon().getStaffAttend(context, globals.staffId);

    globals.isAttendance = attendOrganId != null;
    globals.organId = attendOrganId ?? '';

    await loadBadgeCount();

    organList = await ClOrgan()
        .loadOrganList(context, globals.companyId, globals.staffId);

    setState(() {});
    return [];
  }

  Future<void> loadBadgeCount() async {
    shiftBadgeCount = await ClNotification().getBageCountDetail(context, {
      'receiver_id': globals.staffId,
      'receiver_type': '1',
      'in_type': '5,11,12'
    });

    adminBadgeCount = await ClNotification().getBageCountDetail(context, {
      'receiver_id': globals.staffId,
      'receiver_type': '1',
      'in_type': '13,16'
    });
    setState(() {});
  }

  Future<void> attendanceAction() async {
    if (!globals.isAttendance) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return DlgAttendance(organList: organList);
          }).then((_) {
        loadAttandanceData();
      });
    } else {
      if (await Dialogs().confirmDialog(context, qAttendanceInactive)) {
        bool isRevoke = await ClCommon()
            .updateAttend(context, globals.staffId, globals.organId, '2');
        if (isRevoke) {
          globals.organId = '';
          globals.isAttendance = false;
          Funcs().logout(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'ホーム';
    return Container(
      decoration: mainBackDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: MyAppBar(),
        body: OrientationBuilder(builder: (context, orientation) {
          return FutureBuilder<List>(
            future: loadData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _getBodyContent(orientation);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner.
              return const Center(child: CircularProgressIndicator());
            },
          );
        }),
        drawer: MyDrawer(),
        bottomNavigationBar: BottomNavi(),
      ),
    );
  }

  Widget _getBodyContent(orientation) {
    return Container(
      padding: MediaQuery.of(context).size.width <= 600
          ? paddingHomeMenuArea
          : paddingHomeMenuAreaTablet,
      child: ClipRRect(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          child: Container(
              color: Colors.white,
              child: GridView.count(
                  padding: !globals.isWideScreen
                      ? paddingHomMenuGrid
                      : paddingHomMenuGridTablet,
                  crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                  crossAxisSpacing: !globals.isWideScreen
                      ? spacingHomeMenuGridSpace
                      : spacingHomeMenuGridSpaceTablet,
                  mainAxisSpacing: !globals.isWideScreen
                      ? spacingHomeMenuGridSpace
                      : spacingHomeMenuGridSpaceTablet,
                  childAspectRatio: !globals.isWideScreen ? 1.6 : 1.8,
                  children: _getMenusContent()))),
    );
  }

  List<Widget> _getMenusContent() {
    return [
      _getMenuTile(
        '出退勤',
        const AssetImage('images/icon_menu_attendance.png'),
        () => attendanceAction(),
      ),
      _getMenuTile(
          '注文・会計',
          const AssetImage('images/icon_menu_accounting.png'),
          globals.isAttendance
              ? () => Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return const Tables();
                  }))
              : null),
      _getMenuTile(
        '給与明細',
        const AssetImage('images/icon_menu_payslip.png'),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) {
          return const PaySlip();
        })),
      ),
      _getMenuTile('シフト', const AssetImage('images/icon_menu_shift.png'),
          () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) {
          return const ShiftMake();
        })).then((value) => loadBadgeCount());
      }, badgeCount: shiftBadgeCount),
      if (globals.auth > constAuthStaff)
        _getMenuTile(
          '売上集計',
          const AssetImage('images/icon_menu_sale.png'),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) {
            return const SumSale();
          })),
        ),
      if (globals.auth >= constAuthStaff)
        _getMenuTile(
          '顧客管理',
          const AssetImage('images/icon_menu_customer.png'),
          (globals.auth == constAuthStaff && !globals.isAttendance && adminBadgeCount < 1)
              ? null
              : () => Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return const AdminHome();
                  })),
          badgeCount: adminBadgeCount,
        ),
      if (globals.auth > constAuthStaff)
        _getMenuTile(
            'スタッフ管理',
            const AssetImage('images/icon_menu_staff.png'),
            () => Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return const StaffList();
                }))),
      if (globals.auth > constAuthStaff)
        _getMenuTile(
            'イベント',
            const AssetImage('images/icon_menu_staff.png'),
            () => Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return const Event();
                }))),
    ];
  }

  Widget _getMenuTile(title, icon, onTap, {int badgeCount = 0}) {
    return Stack(
      children: [
        Positioned.fill(
            child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: const Color.fromARGB(255, 241, 251, 255),
              onPrimary: Colors.blue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0))),
          onPressed: onTap,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                    image: icon,
                    width: !globals.isWideScreen
                        ? sizeHomeMenuImageSize
                        : sizeHomeMenuImageSizeTablet,
                    height: !globals.isWideScreen
                        ? sizeHomeMenuImageSize
                        : sizeHomeMenuImageSizeTablet),
                Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(title,
                        style: !globals.isWideScreen
                            ? styleHomeMenuBtnText
                            : styleHomeMenuBtnTextTablet))
              ]),
        )),
        if (badgeCount > 0)
          Positioned(right: 0, child: BadgeContent(badgeCount: badgeCount))
      ],
    );
  }
}
