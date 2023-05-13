import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/business/coupon.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/admin/coupons/admin_coupon_add.dart';
import 'package:staff_pos_app/src/interface/admin/coupons/admin_coupon_select.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/admin/component/adminbutton.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/model/couponmodel.dart';

import '../../../common/globals.dart' as globals;

class AdminCuponList extends StatefulWidget {
  const AdminCuponList({Key? key}) : super(key: key);

  @override
  _AdminCuponList createState() => _AdminCuponList();
}

class _AdminCuponList extends State<AdminCuponList>
    with WidgetsBindingObserver {
  late Future<List> loadData;
  List<CouponModel> coupons = [];
  List<String> openDetailList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadData = loadCouponList();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //do your stuff
    }
  }

  Future<List> loadCouponList() async {
    coupons = await ClCoupon()
        .loadCoupons(context, globals.companyId, isGetDelete: true);

    setState(() {});
    return [];
  }

  Future<void> deleteCouponInfo(couponId) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;

    Dialogs().loaderDialogNormal(context);
    await ClCoupon().deleteCoupon(context, couponId);
    await loadCouponList();
    Navigator.pop(context);
  }

  Future<void> pushCouponAdd() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return AdminCuponAdd();
    }));

    loadCouponList();
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'クーポン一覧';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
                color: bodyColor,
                padding: paddingMainContent,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                          child: AdminAddButton(
                              label: '✛ クーポンの追加',
                              tapFunc: () => pushCouponAdd())),
                      Container(
                          child: AdminAddButton(
                              label: '✛ クーポンの付与',
                              tapFunc: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return AdminCouponSelect();
                                  })))),
                      Expanded(
                          child: SingleChildScrollView(
                              child: Column(
                        children: [...coupons.map((e) => _couponContent(e))],
                      )))
                    ]));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _couponContent(CouponModel e) {
    return Container(
        margin: new EdgeInsets.symmetric(vertical: 12.0),
        padding: paddingUserNameGruop,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey)),
        child: Column(children: [
          Row(
            children: [
              Container(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text(e.couponName, style: styleUserName1)),
              Expanded(child: Container()),
              if (e.staffName != '') Icon(Icons.person, color: Colors.grey),
              Container(
                child: Text(e.staffName),
              )
            ],
          ),
          Container(
              child: Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (e.couponCode != '')
                    Container(child: Text(e.couponCode, style: styleContent)),
                  Container(
                      padding: paddingContentLineSpace,
                      child: Text('有効期限: ' + e.useDate.replaceAll('-', '/'),
                          style: styleContent)),
                  Container(
                      padding: paddingContentLineSpace,
                      child: Text(
                          e.condition == '1' ? '他クーポン併用不可' : '他クーポンと併用化',
                          style: styleContent)),
                ],
              )),
              Container(
                width: 130,
                alignment: Alignment.center,
                child: Column(children: [
                  if (e.discountAmount != null)
                    Text(Funcs().currencyFormat(e.discountAmount!) + '円 OFF',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  if (e.discountRate != null)
                    Text(e.discountRate! + '％OFF',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  if (e.discountRate != null && e.upperAmount != null)
                    Text('上限' + Funcs().currencyFormat(e.upperAmount!) + '円',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                ]),
              )
            ],
          )),
          if (openDetailList.contains(e.couponId))
            Container(
              padding: EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(child: Text(e.comment)),
                  SizedBox(height: 20),
                  Text('【発送履歴】'),
                  if (e.staffs.length < 1) Text('なし'),
                  ...e.staffs.map((eStaff) => Container(
                        child: Text(eStaff.staffNick != ''
                            ? eStaff.staffNick
                            : (eStaff.staffFirstName! +
                                ' ' +
                                eStaff.staffLastName!)),
                      ))
                ],
              ),
            ),
          Row(children: [
            Container(
                padding: paddingContentLineSpace,
                child: TextButton(
                  child: Row(children: [
                    Text('詳細を見る'),
                    Icon(openDetailList.contains(e.couponId)
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down)
                  ]),
                  onPressed: () {
                    setState(() {
                      if (openDetailList.contains(e.couponId)) {
                        openDetailList.remove(e.couponId);
                      } else {
                        openDetailList.add(e.couponId);
                      }
                    });
                  },
                )),
            Expanded(child: Container(height: 20)),
            IconButton(
                onPressed: e.visible
                    ? () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return AdminCuponAdd(couponId: e.couponId);
                        }));
                      }
                    : null,
                icon: Icon(Icons.edit, size: 20)),
            IconButton(
                onPressed:
                    e.visible ? () => deleteCouponInfo(e.couponId) : null,
                icon: Icon(Icons.delete, size: 20)),
          ])
        ]));
  }
}
