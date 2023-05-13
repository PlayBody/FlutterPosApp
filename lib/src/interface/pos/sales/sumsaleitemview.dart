import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/interface/admin/users/admin_user_info.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/model/historymenumodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';

class SumSaleItemView extends StatefulWidget {
  final String orderId;
  final String position;
  const SumSaleItemView(
      {required this.orderId, required this.position, Key? key})
      : super(key: key);

  @override
  _SumSaleItemView createState() => _SumSaleItemView();
}

class _SumSaleItemView extends State<SumSaleItemView> {
  late Future<List> loadData;

  String tablePosition = '';
  String startTime = '';
  String endTime = '';
  String userNick = '';
  String tableAmount = '';
  String tableChargeAmount = '';
  String setAmount = '';
  String userId = '';
  List<HistoryMenuModel> menuList = [];

  @override
  void initState() {
    super.initState();
    loadData = loadSaleData();
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = '売上詳細';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: bodyColor,
              child: Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                          child: Container(
                              padding: EdgeInsets.all(30),
                              child: Column(
                                children: [
                                  SumSaleItemViewContentRow(
                                      label: 'お客様No.', val: widget.position),
                                  SumSaleItemViewContentRow(
                                      label: '席No.', val: tablePosition),
                                  SumSaleItemViewContentRow(
                                      label: '入店時間',
                                      val: (startTime == ''
                                              ? ''
                                              : Funcs().getTimeFormatHHMM(
                                                  DateTime.parse(startTime))) +
                                          ' ~ ' +
                                          (endTime == ''
                                              ? ''
                                              : Funcs().getTimeFormatHHMM(
                                                  DateTime.parse(endTime)))),
                                  SumSaleItemViewContentRow(
                                      label: '人数',
                                      val: menuList.length > 0
                                          ? menuList.length.toString()
                                          : ''),
                                  Container(
                                    padding: EdgeInsets.only(bottom: 15),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 180,
                                          child: Text('代表者様名',
                                              style: TextStyle(fontSize: 22)),
                                        ),
                                        Container(
                                          child: Text(userNick,
                                              style: TextStyle(fontSize: 22)),
                                        ),
                                        if (userId != '1')
                                          IconButton(
                                              onPressed: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (_) {
                                                  return AdminUserInfo(
                                                      userId: userId);
                                                }));
                                              },
                                              icon: Icon(Icons.link,
                                                  color: Colors.blue, size: 35))
                                      ],
                                    ),
                                  ),
                                  // SumSaleItemViewContentRow(
                                  //     label: '代表者様名', val: userNick),
                                  SumSaleItemViewContentRow(
                                      label: '売上', val: tableAmount),
                                  Container(
                                      padding:
                                          EdgeInsets.only(top: 30, bottom: 25),
                                      child: Text('注文内容内訳',
                                          style: TextStyle(fontSize: 32))),
                                  if (tableChargeAmount != '')
                                    SumSaleItemViewListRow(
                                      label: 'テーブルチャージ',
                                      val: tableChargeAmount,
                                    ),
                                  if (setAmount != '')
                                    SumSaleItemViewListRow(
                                      label: 'セット料金',
                                      val: setAmount,
                                    ),
                                  ...menuList.map((e) => SumSaleItemViewListRow(
                                        label: e.menuTitle,
                                        quantity: e.quantity,
                                        val: '￥' +
                                            Funcs().currencyFormat(
                                                (int.parse(e.menuPrice) *
                                                        int.parse(e.quantity))
                                                    .toString()),
                                      ))
                                ],
                              )))),
                  Container(
                      width: 150,
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: CancelColButton(
                        label: '戻る',
                        tapFunc: () {
                          Navigator.pop(context);
                        },
                      ))
                ],
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

  Future<List> loadSaleData() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadSumSaleItemUrl,
        {'order_id': widget.orderId}).then((v) => {results = v});

    if (results['isLoad']) {
      var order = results['order'];
      tablePosition = order['table_position'].toString();
      userNick =
          results['user'] == null ? '' : results['user']['user_nick'] + '様';
      startTime = order['from_time'];
      endTime = order['to_time'];

      tableAmount = double.parse(order['amount'].toString()).toInt() > 0
          ? '￥' +
              Funcs().currencyFormat(
                  double.parse(order['amount'].toString()).toInt().toString())
          : '';
      tableChargeAmount = order['charge_amount'] == null ||
              double.parse(order['charge_amount']).toInt() == 0
          ? ''
          : '￥' +
              Funcs().currencyFormat(
                  double.parse(order['charge_amount']).toInt().toString());
      setAmount = order['set_amount'] == null ||
              double.parse(order['set_amount']).toInt() == 0
          ? ''
          : '￥' +
              Funcs().currencyFormat(
                  double.parse(order['set_amount']).toInt().toString());
      menuList = [];
      for (var item in results['menus']) {
        menuList.add(HistoryMenuModel.fromJson(item));
      }

      userId = order['user_id'] == null ? '1' : order['user_id'].toString();
    }
    return [];
  }
}

class SumSaleItemViewContentRow extends StatelessWidget {
  final String label;
  final String val;
  const SumSaleItemViewContentRow(
      {required this.label, required this.val, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 180,
            child: Text(label, style: TextStyle(fontSize: 22)),
          ),
          Container(
            child: Text(val, style: TextStyle(fontSize: 22)),
          )
        ],
      ),
    );
  }
}

class SumSaleItemViewListRow extends StatelessWidget {
  final String label;
  final String? quantity;
  final String val;
  const SumSaleItemViewListRow(
      {required this.label, required this.val, this.quantity, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: quantity == null ? 200 : 150,
            child: Text(label, style: TextStyle(fontSize: 22)),
          ),
          if (quantity != null)
            Container(
              alignment: Alignment.centerRight,
              width: 50,
              child: Text('× ' + quantity!, style: TextStyle(fontSize: 22)),
            ),
          Expanded(
              child: Container(
            alignment: Alignment.centerRight,
            child: Text(val, style: TextStyle(fontSize: 22)),
          ))
        ],
      ),
    );
  }
}
