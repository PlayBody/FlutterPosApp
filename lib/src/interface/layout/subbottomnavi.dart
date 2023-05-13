import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/interface/home.dart';
import 'package:staff_pos_app/src/interface/pos/accounting/tables.dart';
import 'package:staff_pos_app/src/interface/pos/manage/point/point_manager.dart';
import 'package:staff_pos_app/src/interface/style/textstyles.dart';

import '../../common/globals.dart' as globals;

class SubBottomNavi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: globals.isWideScreen
          ? Colors.transparent
          : Colors.white.withOpacity(0.4),
      padding: MediaQuery.of(context).size.width > 600
          ? EdgeInsets.only(left: 40, right: 40)
          : EdgeInsets.all(0),
      height: 80,
      child: Column(
        children: [
          Container(
            height: 65,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width <= 600
                        ? 10
                        : (MediaQuery.of(context).size.width - 480) / 2),
                BottomNavItem(
                    label: 'ホーム',
                    icon: AssetImage('images/icon/icon_home.png'),
                    onTap: () => globals.auth > 0
                        ? Navigator.push(context,
                            MaterialPageRoute(builder: (_) {
                            return Home();
                          }))
                        : Navigator.push(context,
                            MaterialPageRoute(builder: (_) {
                            return Tables();
                          }))),
                BottomNavItem(
                    label: '戻る',
                    icon: AssetImage('images/icon/icon_back.png'),
                    onTap: () => {Navigator.pop(context)}),
                // BottomNavItem(
                //     label: '進む',
                //     icon: AssetImage('images/icon/icon_forward.png'),
                //     onTap: () => {}),
                // BottomNavItem(
                //     label: '設定',
                //     icon: AssetImage('images/icon/icon_setting.png'),
                //     onTap: () =>
                //         Navigator.push(context, MaterialPageRoute(builder: (_) {
                //           return Setting();
                //         }))),
                // BottomNavItem(
                //     label: '予定',
                //     icon: AssetImage('images/icon/icon_shift.png'),
                //     onTap: () =>
                //         Navigator.push(context, MaterialPageRoute(builder: (_) {
                //           return ShiftDay(
                //               isEdit: true,
                //               initOrgan: null,
                //               initDate: DateTime.now());
                //         }))),
                if (globals.companyId == '2' || globals.auth == constAuthSystem)
                  BottomNavItem(
                      label: 'ポイント管理',
                      icon: AssetImage('images/icon/icon_point.png'),
                      onTap: (globals.isAttendance ||
                              globals.auth > constAuthStaff)
                          ? () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return PointManager();
                              }))
                          : null),
                Container(
                    width: MediaQuery.of(context).size.width <= 600
                        ? 10
                        : (MediaQuery.of(context).size.width - 480) / 2),
              ],
            ),
          ),
          Container(
            // color: Colors.white,
            height: 15,
            child: Row(
              children: [
                Expanded(child: Container()),
                Container(
                  width: 130,
                  height: 3,
                  color: globals.isWideScreen
                      ? Color(0xfffcff23)
                      : Color.fromARGB(255, 29, 72, 116),
                ),
                Expanded(child: Container()),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final String label;
  final AssetImage icon;
  final GestureTapCallback? onTap;

  const BottomNavItem(
      {required this.label, required this.icon, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
          padding: EdgeInsets.all(0),
          child: GestureDetector(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                      image: this.icon,
                      color: Color.fromARGB(255, 29, 72, 116),
                      width: 24
                      // size: globals.isWideScreen
                      //     ? sizeBottomNaviImageSizeTablet
                      //     : sizeBottomNaviImageSize,
                      ),
                  Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        label,
                        style: globals.isWideScreen
                            ? styleBottomNaviMenuTablet
                            : styleBottomNaviMenu,
                      ))
                ],
              ),
            ),
            onTap: onTap,
          )),
    );
  }
}
