import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/business/orders.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/pos/accounting/dlgentering.dart';
import 'package:staff_pos_app/src/interface/pos/accounting/tabledetail.dart';
import 'package:staff_pos_app/src/model/order_model.dart';
import '../../../common/globals.dart' as globals;

class Tables extends StatefulWidget {
  const Tables({Key? key}) : super(key: key);

  @override
  _Tables createState() => _Tables();
}

class _Tables extends State<Tables> {
  late Future<List> loadData;
  List<OrderModel> tableList = [];
  List<OrderModel> currentRequestTableList = [];
  String posAmount = '0';

  @override
  void initState() {
    super.initState();
    loadData = loadTables();

  }

  Future<void> currentOrderAccept(OrderModel currentOrder) async {
    Navigator.of(context).pop();
    Dialogs().loaderDialogNormal(context);
    await ClOrder().acceptOrderRequestTables(context, currentOrder.orderId, globals.staffId);
    Navigator.of(context).pop();
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return DlgEntering(
        userId: currentOrder.userId,
        orderId: currentOrder.orderId,
        tablePosition: currentOrder.seatno
      );
    }));

    Dialogs().loaderDialogNormal(context);
    await loadTables();
    Navigator.of(context).pop();
  }

  Future<List> loadTables() async {
    tableList = [];
    tableList = await ClOrder()
        .loadOrganTables(context, globals.organId, globals.staffId);
    currentRequestTableList = [];
    currentRequestTableList = await ClOrder().loadCureentRequestTables(context, globals.organId, globals.staffId);
    for(var item in currentRequestTableList) {
      if (item.userName != '') {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${globals.loginName}さんをご指名のお客様を対応しますか？'),
            actions: [
              TextButton(
                child: const Text('はい'),
                onPressed: () =>  {
                  currentOrderAccept(item)
                },
              ),
              TextButton(
                child: const Text('いいえ'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
    setState(() {});
    return tableList;
  }

  Future<void> pushTableDetail(orderId, position) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return TableDetail(
        orderId: orderId,
        tablePosition: position,
      );
    }));

    loadTables();
  }

  Future<void> updateTitle(String _title, position) async {
    Navigator.of(context).pop();
    if (_title == '') return;

    bool isUpdate = await ClOrder()
        .updateTableTitle(context, globals.organId, position, _title);
    if (isUpdate) {
      loadTables();
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  void titleChangeDialog(String txtInputTitle, String position) {
    final _controller = TextEditingController();

    _controller.text = txtInputTitle;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: txtInputTitle.length,
    );

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(qChangeTitle),
        content: TextField(
          autofocus: true,
          // onChanged: (v) {
          //   titleNew = v;
          // },
          controller: _controller,
          decoration: InputDecoration(
            hintText: hintInputTitle,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('変更'),
            onPressed: () => {updateTitle(_controller.text, position)},
          ),
          TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = '注文・会計';
    return MainBodyWdiget(
      render: OrientationBuilder(builder: (context, orientation) {
        return Center(
          child: FutureBuilder<List>(
            future: loadData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _getBodyContent(orientation);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        );
      }),
    );
  }

  Widget _getBodyContent(orientation) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 4),
              child: DeleteColButton(
                  label: '入店お断り',
                  tapFunc: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) {
                      return DlgEntering(
                        isReject: true,
                        tablePosition: 'widget.tableId',
                      );
                    }));
                  })),
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: globals.isWideScreen
                          ? EdgeInsets.fromLTRB(150, 0, 120, 20)
                          : EdgeInsets.fromLTRB(40, 0, 40, 20),
                      crossAxisCount:
                          orientation == Orientation.portrait ? 2 : 3,
                      crossAxisSpacing: globals.isWideScreen ? 60 : 15,
                      mainAxisSpacing: globals.isWideScreen ? 30 : 25,
                      childAspectRatio: 0.95,
                      children: [
                        ...tableList.map((d) => _getTableItemContent(d))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          // if (globals.auth > AUTH_STAFF)
          //   Container(
          //     height: 60,
          //     padding: EdgeInsets.only(top: 10, bottom: 10),
          //     child: Column(
          //       children: <Widget>[
          //         Container(
          //           child: Text(
          //             'レジ現金残高    ￥' + Funcs().currencyFormat(posAmount),
          //             style: TextStyle(
          //                 fontSize: 22,
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.bold),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _getTableItemContent(OrderModel item) {
    return Stack(
      children: [
        Positioned.fill(
            left: 10,
            right: 10,
            bottom: 10,
            child: GestureDetector(
                onLongPress: () =>
                    titleChangeDialog(item.tableTitle, item.seatno),
                child: _getTableItemButton(item))),
        Positioned(right: 0, bottom: 0, child: _getItemPlusMark(item))
      ],
    );
  }

  Widget _getTableItemButton(OrderModel item) {
    return ElevatedButton(
        onPressed: () => pushTableDetail(item.orderId, item.seatno),
        child: Column(children: [
          Expanded(child: Container()),
          Container(
              child: Text(item.seatno,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          Container(
              padding: EdgeInsets.only(bottom: 8),
              margin: EdgeInsets.symmetric(
                  vertical: globals.isWideScreen ? 28 : 16),
              child: Column(children: [
                Text(item.tableTitle,
                    style: TextStyle(fontSize: globals.isWideScreen ? 32 : 20)),
                if (item.status != constOrderStatusReserveApply)
                  Text(item.staffName,
                      style:
                          TextStyle(fontSize: globals.isWideScreen ? 24 : 14)),
                if (item.status == constOrderStatusReserveApply)
                  Text(item.userName,
                      style:
                          TextStyle(fontSize: globals.isWideScreen ? 24 : 14)),
              ])),
          Expanded(child: Container()),
        ]),
        style: ElevatedButton.styleFrom(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(15.0)),
          elevation: 0,
          primary: Colors.white.withOpacity(0.8),
          onPrimary: (item.status == constOrderStatusTableStart ||
                  item.status == constOrderStatusTableEnd)
              ? Color.fromRGBO(255, 137, 155, 1)
              : (item.status == constOrderStatusReserveApply
                  ? Color(0xFF00856a)
                  : Color.fromRGBO(24, 100, 123, 1)),
          textStyle: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ));
  }

  Widget _getItemPlusMark(OrderModel item) {
    return Container(
        width: globals.isWideScreen ? 60 : 45,
        height: globals.isWideScreen ? 60 : 45,
        decoration: BoxDecoration(
            color: (item.status == constOrderStatusTableStart ||
                    item.status == constOrderStatusTableEnd)
                ? Color.fromRGBO(255, 137, 155, 1)
                : (item.status == constOrderStatusReserveApply
                    ? Color(0xFF00856a)
                    : Color.fromRGBO(24, 100, 123, 1)),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(
          (item.status == constOrderStatusTableStart ||
                  item.status == constOrderStatusTableEnd)
              ? Icons.check
              : (item.status == constOrderStatusReserveApply
                  ? Icons.lock_clock
                  : Icons.add),
          size: 28,
          color: Colors.white,
        ));
  }
}
