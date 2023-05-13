import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/interface/home.dart';
import 'package:staff_pos_app/src/interface/pos/accounting/tables.dart';
import 'package:staff_pos_app/src/interface/pos/manage/point/point_manager.dart';
import 'package:staff_pos_app/src/interface/style/textstyles.dart';

import '../../common/globals.dart' as globals;

class BottomNavi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MediaQuery.of(context).size.width > 600
          ? EdgeInsets.only(left: 40, right: 40)
          : EdgeInsets.all(0),
      height: 80,
      decoration: BoxDecoration(
        boxShadow: [
          if (MediaQuery.of(context).size.width <= 600)
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: Offset(0, -1), // Shadow position
            ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 65,
            color: Colors.white,
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
                    onTap: () => globals.auth > constAuthGuest
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
                    onTap: () => {}),
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
            color: Colors.white,
            height: 15,
            child: Row(
              children: [
                Expanded(child: Container()),
                Container(
                  width: 130,
                  height: 3,
                  color: Color.fromARGB(255, 0, 192, 250),
                ),
                Expanded(child: Container()),
              ],
            ),
          )
        ],
      ),
      // child: Container(

      // ),
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
          child: Container(
              // decoration: BoxDecoration(
              //     border: Border(
              //         // bottom: BorderSide(
              //         //     width: 3, color: Color.fromARGB(255, 0, 192, 250)),
              //         )
              //         ),
              child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(0),
              primary: Colors.white,
              elevation: 0,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(0),
              ),
              textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight
                      .w600), // double.infinity is the width and 30 is the height
            ),
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
            onPressed: onTap,
          ))),
    );
  }
}
