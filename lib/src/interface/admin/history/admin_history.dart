import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/orders.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/model/order_model.dart';
import 'package:staff_pos_app/src/interface/admin/style/borders.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/common/functions.dart';

import '../../../common/globals.dart' as globals;

class AdminHistory extends StatefulWidget {
  const AdminHistory({Key? key}) : super(key: key);

  @override
  _AdminHistory createState() => _AdminHistory();
}

class _AdminHistory extends State<AdminHistory> {
  late Future<List> loadData;
  List<OrderModel> orders = [];
  @override
  void initState() {
    super.initState();
    loadData = loadinitData();
  }

  Future<List> loadinitData() async {
    orders = await ClOrder().loadOrderList(context, {
      'staff_id': globals.staffId,
      'company_id': globals.companyId,
      'is_complete': '1'
    });

    setState(() {});

    return [];
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = '履歴一覧';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                  color: bodyColor,
                  padding: paddingMainContent,
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...orders.map((e) => AdminHistoryItem(item: e)),
                    ],
                  )));
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}

class AdminHistoryItem extends StatelessWidget {
  final OrderModel item;
  const AdminHistoryItem({required this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: new EdgeInsets.symmetric(vertical: 8.0),
      padding: paddingItemGroup,
      decoration: borderAllRadius8,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Container(
                      padding: paddingItemGroupTitleSpace,
                      child:
                          Text((item.userName), style: styleItemGroupTitle))),
              Container(
                  alignment: Alignment.topRight,
                  child: Text(
                      '￥' + Funcs().currencyFormat(item.amount.toString())))
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  Container(
                      padding: paddingContentLineSpace,
                      alignment: Alignment.centerLeft,
                      child: Text(
                          item.organName +
                              '   ' +
                              DateFormat('yyyy年MM月dd日' +
                                      '(' +
                                      weekAry[DateTime.parse(item.fromTime)
                                              .weekday -
                                          1] +
                                      ')')
                                  .format(DateTime.parse(item.toTime)),
                          style: styleContent)),
                  Container(
                      padding: EdgeInsets.only(left: 4, bottom: 6),
                      child: Column(
                        children: [
                          ...item.menus.map(
                            (e) => Container(
                                padding: EdgeInsets.only(bottom: 2),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        e.menuTitle,
                                      ),
                                    ),
                                    Container(
                                      child: Text('￥' +
                                          Funcs().currencyFormat(e.menuPrice)),
                                    )
                                  ],
                                )),
                          )
                        ],
                      )),
                ],
              )),
            ],
          )
        ],
      ),
    );
  }
}
