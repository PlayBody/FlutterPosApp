import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/business/coupon.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/interface/admin/coupons/admin_coupon_user.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/model/couponmodel.dart';

import '../../../common/globals.dart' as globals;

class AdminCouponSelect extends StatefulWidget {
  const AdminCouponSelect({Key? key}) : super(key: key);

  @override
  _AdminCouponSelect createState() => _AdminCouponSelect();
}

class _AdminCouponSelect extends State<AdminCouponSelect> {
  late Future<List> loadData;
  List<CouponModel> coupons = [];
  String openDetailId = '';
  List<String> selectIds = [];
  List<CouponModel> completeCoupons = [];

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

  void pushSelectUsers() {
    if (selectIds.length < 1) {
      Dialogs().infoDialog(context, '1つ以上のクーポンを選択してください。');
      return;
    }
    completeCoupons = [];
    coupons.forEach((element) {
      if (selectIds.contains(element.couponId)) {
        completeCoupons.add(element);
      }
    });

    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return AdminCouponUsers(selectCoupons: completeCoupons);
    }));
  }

  @override
  Widget build(BuildContext context) {
    globals.adminAppTitle = 'クーポン選択';
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
                        ...coupons.map((e) => _getCouponItem(e)),
                      ],
                    ))),
                    Container(
                      padding: EdgeInsets.only(top: 8),
                      child: ElevatedButton(
                        child: Text('ユーザー選択へ'),
                        onPressed: () {
                          pushSelectUsers();
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
      // drawer: AdminDrawer(),
    );
  }

  Widget _getCouponItem(coupon) {
    return GestureDetector(
      child: Container(
          margin: new EdgeInsets.symmetric(vertical: 12.0),
          padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
          decoration: BoxDecoration(
              color: selectIds.contains(coupon.couponId)
                  ? Color(0xffDBDBDB)
                  : Colors.white,
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
                          child:
                              Text(coupon.couponName, style: styleUserName1)),
                      Container(
                          child: Text(
                              '有効期限: ' + coupon.useDate.replaceAll('-', '/'),
                              style: styleContent)),
                      Container(
                          child: Text(
                              coupon.condition == '1'
                                  ? '他クーポン併用不可'
                                  : '他クーポンと併用化',
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
          )),
      onTap: () {
        if (selectIds.contains(coupon.couponId)) {
          selectIds.remove(coupon.couponId);
        } else {
          selectIds.add(coupon.couponId);
        }
        setState(() {});
      },
    );
  }
}
