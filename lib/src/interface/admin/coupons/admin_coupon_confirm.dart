import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/coupon.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/model/usermodel.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/model/couponmodel.dart';

import '../../../common/globals.dart' as globals;

class AdminCouponConfirm extends StatefulWidget {
  final List<CouponModel> selectCoupons;
  final List<UserModel> selectUsers;
  const AdminCouponConfirm(
      {required this.selectCoupons, required this.selectUsers, Key? key})
      : super(key: key);

  @override
  State<AdminCouponConfirm> createState() => _AdminCouponConfirm();
}

class _AdminCouponConfirm extends State<AdminCouponConfirm> {
  late Future<List> loadData;
  List<CouponModel> coupons = [];
  String openDetailId = '';

  @override
  void initState() {
    super.initState();
    loadData = loadCouponList();
  }

  Future<List> loadCouponList() async {
    coupons = await ClCoupon().loadCoupons(context, globals.companyId);

    setState(() {});
    return [];
  }

  Future<void> saveUserCouponData() async {
    bool conf = await Dialogs().confirmDialog(context, qCommonSave);
    if (!conf) return;

    Dialogs().loaderDialogNormal(context);
    List<String> userIds = [];
    List<String> couponIds = [];
    widget.selectUsers.forEach((element) {
      userIds.add(element.userId);
    });
    widget.selectCoupons.forEach((element) {
      couponIds.add(element.couponId);
    });

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiSaveUserCouponUrl, {
      'user_ids': jsonEncode(userIds),
      'coupon_ids': jsonEncode(couponIds),
      'staff_id': globals.staffId
    }).then((value) => results = value);
    Navigator.pop(context);

    if (results['isSave']) {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.adminAppTitle = 'クーポン付与確認';
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                      children: [
                        Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '付与するクーポン',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )),
                        ...widget.selectCoupons.map((e) => _getCouponItem(e)),
                        Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '付与するユーザー',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )),
                        ...widget.selectUsers.map((e) => _getUserItem(e)),
                      ],
                    ))),
                    Container(
                      padding: EdgeInsets.only(top: 8),
                      child: ElevatedButton(
                        child: Text('クーポンを付与する'),
                        onPressed: () {
                          saveUserCouponData();
                        },
                      ),
                    )
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
      ),
    );
  }

  Widget _getCouponItem(coupon) {
    return Container(
        margin: new EdgeInsets.symmetric(vertical: 12.0),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey)),
        child: Column(
          children: [
            Container(
                child: Row(
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(coupon.couponName, style: styleUserName1)),
                    Container(
                        child: Text(
                            '有効期限: ' + coupon.useDate.replaceAll('-', '/'),
                            style: styleContent)),
                    Container(
                        child: Text(
                            coupon.condition == '1' ? '他クーポン併用不可' : '他クーポンと併用化',
                            style: styleContent)),
                  ],
                )),
                Container(
                  width: 130,
                  alignment: Alignment.center,
                  child: Column(children: [
                    if (coupon.discountAmount != null)
                      Text(
                        Funcs().currencyFormat(coupon.discountAmount!) +
                            '円 OFF',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    if (coupon.discountRate != null)
                      Text(coupon.discountRate! + '％OFF',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    if (coupon.discountRate != null &&
                        coupon.upperAmount != null)
                      Text(
                          '上限' +
                              Funcs().currencyFormat(coupon.upperAmount!) +
                              '円',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                )
              ],
            )),
            if (openDetailId == coupon.couponId)
              Container(
                  padding: EdgeInsets.only(top: 8),
                  alignment: Alignment.centerLeft,
                  child: Text(coupon.comment)),
            Row(
              children: [
                Container(
                    child: TextButton(
                  child: Row(
                    children: [
                      Text('詳細を見る'),
                      Icon(openDetailId == coupon.couponId
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down)
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      if (openDetailId == coupon.couponId) {
                        openDetailId = '';
                      } else {
                        openDetailId = coupon.couponId;
                      }
                    });
                  },
                )),
                Expanded(
                    child: Container(
                  height: 20,
                )),
              ],
            ),
          ],
        ));
  }

  Widget _getUserItem(user) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey), color: Colors.white),
          padding: paddingUserNameGruop,
          child: Row(
            children: [
              Expanded(
                  child: Text(
                user.userFirstName == ''
                    ? user.userNick
                    : user.userFirstName + ' ' + user.userLastName,
                style: styleUserName1,
              )),
              Text(
                user.userBirth == null
                    ? ''
                    : (DateTime.now().year -
                                DateTime.parse(user.userBirth!).year)
                            .toString() +
                        '歳' +
                        (user.groupId == null ? '' : user.groupId!),
                style: styleUserName1,
              )
            ],
          )),
    );
  }
}
