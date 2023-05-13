import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/orders.dart';

import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/functions/pos_printers.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/admin/users/admin_user_info.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:staff_pos_app/src/interface/layout/myappbar.dart';
import 'package:staff_pos_app/src/interface/layout/mydrawer.dart';
import 'package:staff_pos_app/src/interface/layout/subbottomnavi.dart';
import 'package:staff_pos_app/src/interface/pos/accounting/dlg_order_from_change.dart';
import 'package:staff_pos_app/src/interface/pos/accounting/dlgentering.dart';
import 'package:staff_pos_app/src/interface/pos/accounting/order.dart';
import 'package:staff_pos_app/src/model/order_menu_model.dart';
import 'package:staff_pos_app/src/model/order_model.dart';
import '../../../common/globals.dart' as globals;

class TableDetail extends StatefulWidget {
  final String orderId;
  final String tablePosition;

  const TableDetail(
      {required this.orderId, required this.tablePosition, Key? key})
      : super(key: key);

  @override
  _TableDetail createState() => _TableDetail();
}

class _TableDetail extends State<TableDetail> {
  late Future<List> loadData;

  String? orderId;
  String tableTitle = '';
  String tableStartTime = '';
  String flowTime = '';
  String amount = '';
  String inputDateTime = "";
  String userName = '';
  String userId = '';

  String tableStatus = constOrderStatusNone;
  String tablePosition = '0';
  String tablePersonCnt = '0';
  String tableAmount = '0';
  String setAmount = '0';
  String btnActionText = '';
  String? reserveUserId;
  var txtUserNameController = TextEditingController();
  bool isEditUserName = false;
  String? payMethod;

  List<OrderMenuModel> menuList = [];

  @override
  void initState() {
    globals.appTitle = '注文・会計';
    super.initState();
    orderId = widget.orderId;
    loadData = loadTableDetail();
  }

  Future<void> updateTitle(String _title) async {
    Navigator.of(context).pop();
    if (_title == '') return;

    bool isUpdate = await ClOrder().updateTableTitle(
        context, globals.organId, widget.tablePosition, _title);
    if (isUpdate) {
      tableTitle = _title;
      setState(() {});
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> pushUserDetail() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return AdminUserInfo(userId: userId);
    }));
  }

  Future<void> psuhOrder() async {
    if (orderId == null) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return Order(
        orderId: orderId!,
      );
    }));

    loadTableDetail();
  }

  Future<List> loadTableDetail() async {
    isEditUserName = false;
    OrderModel? _order;

    if (orderId != null) {
      _order = await ClOrder().loadOrderInfo(context, orderId);
    }

    if (_order != null) {
      tableTitle = _order.tableTitle;
      inputDateTime = _order.fromTime;
      tableStartTime = _order.fromTime;
      int flowH = _order.flowTime ~/ 60;
      int flowM = _order.flowTime % 60;
      flowTime = (flowH < 10 ? '0' : '') + flowH.toString() + ' 時間  ';
      flowTime += (flowM < 10 ? '0' : '') + flowM.toString() + ' 分';
      amount = _order.amount.toString();
      tableStatus = _order.status;
      userName = _order.userInputName;
      userId = _order.userId;
      menuList = _order.menus;
      if (_order.status == constOrderStatusReserveApply)
        reserveUserId = _order.userId;

      payMethod = _order.payMethod;
    } else {
      inputDateTime = '';
      tableStartTime = '';
      flowTime = '';
      amount = '';
      tableStatus = constOrderStatusNone;
      userName = '';
      menuList = [];
      tableTitle = await ClOrder()
          .loadTableTitle(context, globals.organId, widget.tablePosition);
    }
    if (tableStatus == constOrderStatusNone ||
        tableStatus == constOrderStatusReserveApply) this.btnActionText = '入 店';
    if (tableStatus == constOrderStatusTableStart) this.btnActionText = '清 算';
    if (tableStatus == constOrderStatusTableEnd) this.btnActionText = 'リセット';
    setState(() {});
    return [];
  }

  Future<bool> updateStatus() async {
    if (tableStatus == constOrderStatusTableStart) {
      bool conf = await Dialogs().confirmDialog(context, qTableExit);
      if (!conf) return false;
      bool isUpdate = await ClOrder().exitOrder(context, orderId);
      if (isUpdate) refreshLoad();
      return false;
    }
    if (tableStatus == constOrderStatusTableEnd) {
      bool conf = await Dialogs().confirmDialog(context, qTableReset);
      if (!conf) return false;
      Dialogs().loaderDialogNormal(context);
      dynamic printData = {
        'position': tablePosition,
        'person_cnt': tablePersonCnt,
        'menus': menuList,
        'amount': amount,
        'table_amount': tableAmount,
        'set_amount': setAmount,
      };
      await PosPrinters().receiptPrint(context, printData, globals.organId);
      Navigator.pop(context);

      if (payMethod == null)
        payMethod =
            await Dialogs().selectDialog(context, 'お支払い方法の選択', constPayMethod);
      if (payMethod == null) {
        return false;
      }
      bool isUpdate = await ClOrder().resetOrder(context, orderId, payMethod);
      if (isUpdate) {
        orderId = null;
        refreshLoad();
      }
    }

    return true;
  }

  Future<void> deleteTableMenu(String? _id) async {
    if (_id == null) return;
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (conf) {
      Dialogs().loaderDialogNormal(context);
      bool isDelete = await ClOrder().deleteOrderMenu(context, _id);
      Navigator.pop(context);

      if (isDelete) {
        setState(() {
          loadData = loadTableDetail();
        });
      } else {
        Dialogs().infoDialog(context, '操作が失敗しました。');
      }
    }
  }

  void titleChangeDialog(String txtInputTitle) {
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
            onPressed: () => {updateTitle(_controller.text)},
          ),
          TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void timeChangeDialog() {
    DateTime _date = DateTime.parse(inputDateTime.toString());

    var txthourController = TextEditingController();
    var txtminController = TextEditingController();

    txthourController.text = _date.hour.toString();
    txtminController.text = _date.minute.toString();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgOrderFromChange(date: inputDateTime);
        }).then((value) => updateStartTime(value));
  }

  Future<void> updateStartTime(updateTime) async {
    if (orderId == null) return;
    if (updateTime == null) return;
    bool isUpdate = await ClOrder()
        .updateOrder(context, {'reserve_id': orderId, 'from_time': updateTime});
    if (isUpdate) refreshLoad();
  }

  Future<void> enteringOrgan() async {
    orderId = await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return DlgEntering(
        userId: reserveUserId,
        orderId: orderId,
        tablePosition: widget.tablePosition,
      );
    }));
    refreshLoad();
  }

  Future<void> updateOrderData(updateData) async {
    updateData['id'] = orderId;
    Dialogs().loaderDialogNormal(context);
    await ClOrder().updateOrder(context, updateData);
    await loadTableDetail();
    Navigator.pop(context);
  }

  Future<void> refreshLoad() async {
    Dialogs().loaderDialogNormal(context);
    await loadTableDetail();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: MyAppBar(),
        body: OrientationBuilder(builder: (context, orientation) {
          return FutureBuilder<List>(
            future: loadData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  padding: globals.isWideScreen
                      ? EdgeInsets.only(left: 120, right: 120)
                      : EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      _getTableInfoContent(orientation),
                      Container(
                        padding: EdgeInsets.only(top: 15, bottom: 15),
                        child: Text('注文履歴',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22)),
                      ),
                      if (orientation == Orientation.portrait)
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                  child: Container(
                                      padding: globals.isWideScreen
                                          ? EdgeInsets.only(top: 35, bottom: 35)
                                          : EdgeInsets.only(
                                              top: 20, bottom: 20),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            ...menuList.map((e) =>
                                                TableDetailItemList(
                                                  item: e,
                                                  rowNm: menuList.indexOf(e),
                                                  onTap: () =>
                                                      deleteTableMenu(e.id!),
                                                )),
                                          ],
                                        ),
                                      ))),
                              Container(
                                padding: globals.isWideScreen
                                    ? EdgeInsets.only(bottom: 35)
                                    : EdgeInsets.only(bottom: 15),
                                child: Column(
                                  children: <Widget>[
                                    ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(
                                          width:
                                              globals.isWideScreen ? 350 : 250),
                                      child: ElevatedButton(
                                        child: Text(btnActionText),
                                        onPressed: tableStatus ==
                                                    constOrderStatusNone ||
                                                tableStatus ==
                                                    constOrderStatusReserveApply
                                            ? () {
                                                enteringOrgan();
                                              }
                                            : () {
                                                updateStatus();
                                              },
                                        style: ElevatedButton.styleFrom(
                                            primary:
                                                Color.fromRGBO(17, 127, 193, 1),
                                            elevation: 0,
                                            padding: EdgeInsets.all(4),
                                            textStyle: TextStyle(
                                                fontSize: globals.isWideScreen
                                                    ? 24
                                                    : 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    Container(
                                        height: globals.isWideScreen ? 20 : 5),
                                    ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(
                                          width:
                                              globals.isWideScreen ? 350 : 250),
                                      child: ElevatedButton(
                                        child: Text('注 文'),
                                        onPressed: tableStatus ==
                                                constOrderStatusTableStart //status == '0'
                                            ? () => psuhOrder()
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                            primary:
                                                Color.fromRGBO(17, 127, 193, 1),
                                            elevation: 0,
                                            padding: EdgeInsets.all(4),
                                            textStyle: TextStyle(
                                                fontSize: globals.isWideScreen
                                                    ? 24
                                                    : 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                        )),
                      if (orientation == Orientation.landscape)
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Container(
                                      padding: globals.isWideScreen
                                          ? EdgeInsets.only(top: 35, bottom: 35)
                                          : EdgeInsets.only(
                                              top: 20, bottom: 20),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            ...menuList.map((e) =>
                                                TableDetailItemList(
                                                  item: e,
                                                  rowNm: menuList.indexOf(e),
                                                  onTap: () =>
                                                      deleteTableMenu(e.id!),
                                                )),
                                          ],
                                        ),
                                      ))),
                              Container(
                                padding: globals.isWideScreen
                                    ? EdgeInsets.only(
                                        bottom: 35, left: 20, top: 30)
                                    : EdgeInsets.only(
                                        bottom: 15, left: 10, top: 20),
                                child: Column(
                                  children: <Widget>[
                                    ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(
                                          width:
                                              globals.isWideScreen ? 350 : 250),
                                      child: ElevatedButton(
                                        child: Text(btnActionText),
                                        onPressed: tableStatus ==
                                                    constOrderStatusNone ||
                                                tableStatus ==
                                                    constOrderStatusReserveApply
                                            ? () {
                                                enteringOrgan();
                                              }
                                            : () {
                                                updateStatus();
                                              },
                                        style: ElevatedButton.styleFrom(
                                            primary:
                                                Color.fromRGBO(17, 127, 193, 1),
                                            elevation: 0,
                                            padding: EdgeInsets.all(15),
                                            textStyle: TextStyle(
                                                fontSize: globals.isWideScreen
                                                    ? 24
                                                    : 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    Container(
                                        height: globals.isWideScreen ? 20 : 5),
                                    ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(
                                          width:
                                              globals.isWideScreen ? 350 : 250),
                                      child: ElevatedButton(
                                        child: Text('注 文'),
                                        onPressed: tableStatus ==
                                                constOrderStatusTableStart //status == '0'
                                            ? () => psuhOrder()
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                            primary:
                                                Color.fromRGBO(17, 127, 193, 1),
                                            elevation: 0,
                                            padding: EdgeInsets.all(
                                                globals.isWideScreen ? 15 : 4),
                                            textStyle: TextStyle(
                                                fontSize: globals.isWideScreen
                                                    ? 24
                                                    : 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                        )),
                      // Expanded(),
                      Container(height: 15)
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return Center(child: CircularProgressIndicator());
            },
          );
        }),
        drawer: MyDrawer(),
        bottomNavigationBar: SubBottomNavi(),
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _getTableInfoContent(orientation) {
    return Container(
      margin: globals.isWideScreen
          ? EdgeInsets.only(top: orientation == Orientation.portrait ? 40 : 0)
          : EdgeInsets.all(0),
      padding: globals.isWideScreen
          ? EdgeInsets.only(left: 40, right: 40, bottom: 12)
          : EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        GestureDetector(
          child: Container(
              padding: EdgeInsets.only(top: 8, bottom: 8, right: 12, left: 20),
              child: Row(children: [
                Expanded(
                    child: Text(this.tableTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(17, 127, 193, 1),
                          fontSize: globals.isWideScreen ? 32 : 20,
                        ))),
                Icon(Icons.edit, color: Colors.grey)
              ]),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Color.fromRGBO(17, 127, 193, 1), width: 2)))),
          onLongPress: globals.auth < constAuthBoss
              ? null
              : () => titleChangeDialog(tableTitle),
        ),
        Container(
            padding: globals.isWideScreen
                ? EdgeInsets.only(
                    left: orientation == Orientation.portrait ? 40 : 150,
                    right: orientation == Orientation.portrait ? 40 : 150,
                    top: 20)
                : EdgeInsets.only(left: 20, right: 20, top: 12),
            child: Row(children: [
              Container(
                  child:
                      Text('お客様の名前', style: tableDetailhedaerLabelTextStyle)),
              if (!isEditUserName)
                Expanded(
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          userName,
                          style: tableDetailTimeStyle,
                        ))),
              if (isEditUserName)
                Flexible(
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: TextInputNormal(
                            controller: txtUserNameController))),
              if (isEditUserName)
                Container(
                    width: 40,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: IconWhiteButton(
                        color: primaryColor,
                        icon: Icons.save,
                        tapFunc: () => updateOrderData(
                            {'user_input_name': txtUserNameController.text}))),
              if (int.parse(tableStatus) > 0)
                Row(
                  children: [
                    Container(
                        width: 30,
                        child: IconWhiteButton(
                            icon: isEditUserName ? Icons.close : Icons.edit,
                            tapFunc: () {
                              isEditUserName = !isEditUserName;
                              txtUserNameController.text = userName;
                              setState(() {});
                            })),
                    const SizedBox(width: 5,),
                    Container(
                        width: 30,
                        child: IconWhiteButton(
                            icon: Icons.person,
                            tapFunc: () {
                              pushUserDetail();
                            })),
                  ],
                ),
            ])),
        Container(
            padding: globals.isWideScreen
                ? EdgeInsets.only(
                    left: orientation == Orientation.portrait ? 40 : 150,
                    right: orientation == Orientation.portrait ? 40 : 150,
                    top: 20)
                : EdgeInsets.only(left: 20, right: 20, top: 12),
            child: Row(children: [
              Expanded(
                  child: Text('入店時間', style: tableDetailhedaerLabelTextStyle)),
              if (tableStartTime != '')
                GestureDetector(
                    child: Container(
                        child: Row(children: [
                      _getInputTimeContent(
                          true,
                          DateFormat('MM')
                              .format(DateTime.parse(tableStartTime))),
                      _getInputTimeContent(false, '月'),
                      _getInputTimeContent(
                          true,
                          DateFormat('dd')
                              .format(DateTime.parse(tableStartTime))),
                      _getInputTimeContent(false, '日'),
                      _getInputTimeContent(
                          true,
                          DateFormat('HH')
                              .format(DateTime.parse(tableStartTime))),
                      _getInputTimeContent(false, '時'),
                      _getInputTimeContent(
                          true,
                          DateFormat('mm')
                              .format(DateTime.parse(tableStartTime))),
                      _getInputTimeContent(false, '分'),
                    ])),
                    onLongPress: globals.auth < constAuthBoss
                        ? null
                        : () => timeChangeDialog())
            ])),
        Container(
            padding: globals.isWideScreen
                ? EdgeInsets.only(
                    left: orientation == Orientation.portrait ? 40 : 150,
                    right: orientation == Orientation.portrait ? 40 : 150,
                    top: 20)
                : EdgeInsets.only(left: 20, right: 20, top: 12),
            child: Row(
              children: [
                Expanded(
                    child:
                        Text('経過時間', style: tableDetailhedaerLabelTextStyle)),
                if (flowTime != '')
                  Container(
                    child: Text(flowTime, style: tableDetailTimeStyle),
                  )
              ],
            )),
        Container(
            padding: globals.isWideScreen
                ? EdgeInsets.only(
                    left: orientation == Orientation.portrait ? 40 : 150,
                    right: orientation == Orientation.portrait ? 40 : 150,
                    top: 20)
                : EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Row(children: [
              Expanded(
                  child:
                      Text('現在のお会計', style: tableDetailhedaerLabelTextStyle)),
              if (this.amount != '')
                Container(
                    child: Text(
                        '¥ ' + Funcs().currencyFormat(this.amount) + '-',
                        style: tableDetailAllAmountStyle)),
              Container(
                  margin: EdgeInsets.only(left: 12),
                  width: 32,
                  height: 32,
                  child: IconWhiteButton(
                      icon: Icons.refresh, tapFunc: () => refreshLoad()))
            ])),
      ]),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _getInputTimeContent(bool isTime, String str) {
    return Container(
        padding: EdgeInsets.only(left: 5),
        child: Text(str,
            style: isTime ? tableDetailTimeStyle : tableDetailTimeLabel));
  }
}

class TableDetailItemList extends StatelessWidget {
  final item;
  final rowNm;
  final GestureTapCallback? onTap;

  const TableDetailItemList(
      {required this.item, required this.rowNm, this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: rowNm % 2 == 1 ? Colors.white : Color.fromRGBO(238, 250, 255, 1),
        padding: globals.isWideScreen
            ? EdgeInsets.only(bottom: 8, left: 40, right: 40)
            : EdgeInsets.only(bottom: 8, left: 10, right: 10),
        child: Row(
          children: [
            Expanded(
                // padding: EdgeInsets.only(top: 12),
                // width: 180,
                child: Container(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    // width: 110,
                    child: Text(item.menuTitle,
                        style: TextStyle(
                            fontSize: globals.isWideScreen ? 20 : 16,
                            color: Color.fromRGBO(70, 88, 134, 1),
                            fontWeight: FontWeight.bold)),
                  ),
                  Text(' × ',
                      style: TextStyle(
                          fontSize: globals.isWideScreen ? 20 : 16,
                          color: Color.fromRGBO(70, 88, 134, 1),
                          fontWeight: FontWeight.bold)),
                  Container(
                    width: 30,
                    alignment: Alignment.centerRight,
                    child: Text(item.quantity,
                        style: TextStyle(
                            fontSize: globals.isWideScreen ? 20 : 16,
                            color: Color.fromRGBO(70, 88, 134, 1),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )),
            Container(width: 25),
            GestureDetector(
              child: Container(
                  margin: EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  width: 100,
                  child: Text(
                    'キャンセル',
                    style: TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(70, 88, 134, 1),
                        fontWeight: FontWeight.bold),
                  )),
              onTap: onTap,
            ),
          ],
        ));
  }
}

const tableDetailhedaerLabelTextStyle = TextStyle(
    fontSize: 16, color: Color(0xff465886), fontWeight: FontWeight.bold);
const tableDetailTimeLabel = TextStyle(
    fontSize: 14, color: Color(0xff465886), fontWeight: FontWeight.bold);
const tableDetailTimeStyle = TextStyle(
    fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff073c5b));
const tableDetailAllAmountStyle = TextStyle(
    fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xff073c5b));
var tableDetailItemListTitle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: globals.isWideScreen ? 26 : 18);
