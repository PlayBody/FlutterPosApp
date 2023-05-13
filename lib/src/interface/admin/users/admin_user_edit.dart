import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/orders.dart';
import 'package:staff_pos_app/src/common/business/ticket.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/admin/component/admin_lines.dart';
import 'package:staff_pos_app/src/interface/admin/component/admin_rows.dart';
import 'package:staff_pos_app/src/interface/admin/component/admin_textinputs.dart';
import 'package:staff_pos_app/src/interface/admin/component/admin_texts.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:staff_pos_app/src/model/order_model.dart';
import 'package:staff_pos_app/src/model/userticketmodel.dart';

import '../../../common/globals.dart' as globals;
import 'package:fluttertoast/fluttertoast.dart';

class AdminUserEdit extends StatefulWidget {
  final String userId;
  const AdminUserEdit({required this.userId, Key? key}) : super(key: key);

  @override
  _AdminUserEdit createState() => _AdminUserEdit();
}

class _AdminUserEdit extends State<AdminUserEdit> {
  late Future<List> loadData;

  List<OrderModel> orders = [];

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var phoneController = TextEditingController();
  var mailController = TextEditingController();
  var commentController = TextEditingController();
  var pwController = TextEditingController();
  var pwConfController = TextEditingController();

  String userSex = "1";
  String userBirthday = "";
  String userTicket = '0';
  String companyId = '';
  String selDateYear = DateTime.now().year.toString();
  String selDateMonth = DateTime.now().month.toString();
  String selDateDay = DateTime.now().day.toString();

  String groupName = '';

  String? errFirstName;
  String? errLastName;
  String? errPhone;
  String? errEmail;

  String isTicketReset = '0';
  String ticketResetType = '1';
  String ticketResetMonthDay = '1';
  String ticketResetWeekDay = '1';
  String ticketResetValue = '0';

  List<UserTicketModel> userTickets = [];
  Map<dynamic, dynamic> ticketResets = {};

  int k = 0;

  @override
  void initState() {
    super.initState();
    loadData = loadUserInfo();
  }

  Future<List> loadUserInfo() async {
    k = 0;
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadUserInfoUrl,
        {'user_id': widget.userId}).then((value) => results = value);

    if (results['isLoad']) {
      var user = results['user'];
      firstNameController.text =
          user['user_first_name'] == null ? '' : user['user_first_name'];
      lastNameController.text =
          user['user_last_name'] == null ? '' : user['user_last_name'];
      userSex = user['user_sex'] == null ? '1' : user['user_sex'];
      companyId = user['company_id'] == null ? '' : user['company_id'];

      phoneController.text = user['user_tel'] == null ? '' : user['user_tel'];
      mailController.text =
          user['user_email'] == null ? '' : user['user_email'];
      commentController.text =
          user['user_comment'] == null ? '' : user['user_comment'];

      if (user['user_birthday'] != null && user['user_birthday'] != '') {
        var birthdayDateTime =
            DateTime.parse(user['user_birthday'] + ' 00:00:00');
        selDateYear = birthdayDateTime.year.toString();
        selDateMonth = birthdayDateTime.month.toString();
        selDateDay = birthdayDateTime.day.toString();
      }
      if (user['user_ticket'] != null) userTicket = user['user_ticket'];
      if (user['group'] != null && user['group']['group_name'] != null)
        groupName = user['group']['group_name'];

      // var ticketReset = results['ticket_reset'];
      // if (ticketReset != null) {
      //   isTicketReset = ticketReset['is_enable'] == null
      //       ? '0'
      //       : ticketReset['is_enable'].toString();

      //   ticketResetType = ticketReset['time_type'] == null
      //       ? '1'
      //       : ticketReset['time_type'].toString();

      //   if (ticketResetType == '1') {
      //     ticketResetMonthDay = ticketReset['time_value'] == null
      //         ? '1'
      //         : ticketReset['time_value'].toString();
      //     ticketResetWeekDay = '1';
      //   } else {
      //     ticketResetWeekDay = ticketReset['time_value'] == null
      //         ? '1'
      //         : ticketReset['time_value'].toString();
      //     ticketResetMonthDay = '1';
      //   }

      //   ticketResetValue = ticketReset['ticket_value'] == null
      //       ? '1'
      //       : ticketReset['ticket_value'].toString();
      // }

      userTickets =
          await ClTicket().loadUserTickets(context, widget.userId, companyId);
    }

    orders = await ClOrder().loadOrderList(context, {
      'user_id': widget.userId,
      'is_reserve_list': '1',
    });
    setState(() {});
    return [];
  }

  Future<void> saveUserInfo() async {
    bool isFormCheck = true;
    if (firstNameController.text == '') {
      Fluttertoast.showToast(
          msg: '名前を入力してください。', toastLength: Toast.LENGTH_SHORT);
      return;
    } else {
      errFirstName = null;
    }

    if (lastNameController.text == '') {
      Fluttertoast.showToast(
          msg: '名前を入力してください。', toastLength: Toast.LENGTH_SHORT);
      return;
    } else {
      errLastName = null;
    }

    if (phoneController.text == '') {
      Fluttertoast.showToast(
          msg: '電話番号を入力してください。', toastLength: Toast.LENGTH_SHORT);
    } else {
      errPhone = null;
    }

    if (pwController.text != pwConfController.text) {
      Fluttertoast.showToast(
          msg: 'パスワードとパスワード確認は同一の内容をを入力してください。',
          toastLength: Toast.LENGTH_SHORT);
      return;
    }

    setState(() {});

    // if (!isFormCheck) return;

    List<dynamic> paramTickets = [];

    userTickets.forEach((element) {
      if (element.isInfinityCount != null && element.isInfinityCount == true) {
        element.maxCount = '-1';
      }
      paramTickets.add(element.toJson());
      // paramTickets.addAll(element.toJson());
    });

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiSaveUserInfoUrl, {
      'user_id': widget.userId,
      'user_email': mailController.text,
      'user_password': pwController.text,
      'user_first_name': firstNameController.text,
      'user_last_name': lastNameController.text,
      'user_sex': userSex,
      'user_tel': phoneController.text,
      'user_birthday': selDateYear + "-" + selDateMonth + '-' + selDateDay,
      'user_comment': commentController.text,
      'user_tickets': jsonEncode(paramTickets),
      // 'user_ticket': userTicket,
      // 'is_reset_ticket': isTicketReset,
      // 'ticket_reset_type': ticketResetType,
      // 'ticket_reset_day':
      //     ticketResetType == '1' ? ticketResetMonthDay : ticketResetWeekDay,
      // 'ticket_reset_value': ticketResetValue
    }).then((value) => results = value);

    if (results['isSave']) {
      Navigator.pop(context);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> deleteReserve(orderId) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);

    if (!conf) return;
    Dialogs().loaderDialogNormal(context);
    bool isDelete = await ClOrder().deleteOrder(context, orderId);

    if (isDelete) {
      await loadUserInfo();
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'アカウント編集';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Center(
                child: Container(
                  color: bodyColor,
                  child: Column(
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 16),
                              child: _getNameAndSexRow(),
                            ),
                            AdminLineH1(),
                            _getRowContent(
                                '電話番号',
                                AdminTextInputNormal(
                                    errorText: errPhone,
                                    controller: phoneController)),
                            AdminLineH1(),
                            _getRowContent(
                                'メールアドレス',
                                AdminTextInputNormal(
                                    controller: mailController)),
                            if (globals.auth > constAuthGuest) AdminLineH1(),
                            if (globals.auth > constAuthGuest)
                              _getRowContent(
                                  'パスワード',
                                  AdminTextInputNormal(
                                    controller: pwController,
                                    inputType: TextInputType.visiblePassword,
                                    obscureText: true,
                                  )),
                            if (globals.auth > constAuthGuest) AdminLineH1(),
                            if (globals.auth > constAuthGuest)
                              _getRowContent(
                                  'パスワード確認',
                                  AdminTextInputNormal(
                                    controller: pwConfController,
                                    inputType: TextInputType.visiblePassword,
                                    obscureText: true,
                                  )),
                            AdminLineH1(),
                            _getRowContent('生年月日', _getBirthDayRender()),
                            AdminLineH1(),
                            _getRowContent(
                                'グループ分け', AdminCommentText(label: groupName)),
                            AdminLineH1(),
                            _getRowContent(
                                'メモ',
                                TextInputNormal(
                                    controller: commentController,
                                    multiLine: 5)),

                            AdminLineH1(),
                            ...userTickets.map((e) => _getUserTicketContent(e)),
                            // _getRowContent(
                            //     'チケット枚数',
                            //     DropDownNumberSelect(
                            //         contentPadding: EdgeInsets.all(6),
                            //         max: 99,
                            //         min: 0,
                            //         value: userTicket,
                            //         tapFunc: (v) => userTicket = v)),
                            // AdminLineH1(),
                            // _getRowContent(
                            //     'チケット初期化',
                            //     Switch(
                            //         value: isTicketReset == '1',
                            //         onChanged: (v) {
                            //           isTicketReset = v ? '1' : '0';
                            //           setState(() {});
                            //         }),
                            //     vMargin: 0),
                            // _getRowContent('時間', _getResetTime(), vMargin: 0),
                            // _getRowContent(
                            //     'リセット枚数',
                            //     DropDownNumberSelect(
                            //       contentPadding: EdgeInsets.all(6),
                            //       value: ticketResetValue,
                            //       max: 99,
                            //       min: 0,
                            //       tapFunc: isTicketReset == '0'
                            //           ? null
                            //           : (v) {
                            //               ticketResetValue = v;
                            //               setState(() {});
                            //             },
                            //     )),
                            // AdminLineH1(),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.all(30),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ...orders
                                        .map((e) => AdminUserEditHistoryItem(
                                              order: e,
                                              delFunc: () =>
                                                  deleteReserve(e.orderId),
                                            ))
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      RowButtonGroup(widgets: [
                        PrimaryButton(
                            label: '更新', tapFunc: () => saveUserInfo())
                      ])
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  var dropdownPadding = EdgeInsets.fromLTRB(6, 6, 0, 6);

  Widget _getBirthDayRender() {
    return Row(
      children: [
        Flexible(
            flex: 3,
            child: DropDownNumberSelect(
                contentPadding: dropdownPadding,
                max: 2030,
                min: 1970,
                value: selDateYear,
                tapFunc: (v) {
                  selDateYear = v;
                  setState(() {});
                })),
        AdminCommentText(label: '年'),
        SizedBox(width: 4),
        Flexible(
            flex: 2,
            child: DropDownNumberSelect(
                contentPadding: dropdownPadding,
                max: 12,
                value: selDateMonth,
                tapFunc: (v) {
                  selDateMonth = v;
                  setState(() {});
                })),
        AdminCommentText(label: '月'),
        SizedBox(width: 4),
        Flexible(
            flex: 2,
            child: DropDownNumberSelect(
                contentPadding: dropdownPadding,
                max: Funcs().getMaxDay(selDateYear, selDateMonth),
                value: selDateDay,
                tapFunc: (v) {
                  selDateDay = v;
                  setState(() {});
                })),
        AdminCommentText(label: '日'),
      ],
    );
  }

  Widget _getNameAndSexRow() {
    return Row(
      children: [
        Flexible(
            child: AdminTextInputNormal(
                controller: firstNameController, fontsize: 22)),
        SizedBox(width: 8),
        Flexible(
            child: AdminTextInputNormal(
                controller: lastNameController, fontsize: 22)),
        Container(
          child: Radio(
              groupValue: userSex,
              value: '1',
              onChanged: (v) {
                userSex = v.toString();
                setState(() {});
              }),
        ),
        Container(child: Text('男')),
        Container(
          child: Radio(
              groupValue: userSex,
              value: '2',
              onChanged: (v) {
                userSex = v.toString();
                setState(() {});
              }),
        ),
        Container(child: Text('女')),
      ],
    );
  }

  Widget _getUserTicketContent(item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xffcfcfCf),
        border: Border(bottom: BorderSide(width: 1, color: Colors.grey)),
      ),
      child: Column(children: [
        RowLabelInput(
            labelWidth: 180,
            labelPadding: 6,
            label: '最大保有チケット数',
            renderWidget: Row(children: [
              Flexible(
                  child: DropDownNumberSelect(
                      contentPadding: EdgeInsets.all(6),
                      max: 99,
                      min: 0,
                      value:
                          int.parse(item.maxCount) >= 0 ? item.maxCount : '0',
                      tapFunc: item.isInfinityCount
                          ? null
                          : (v) {
                              item.maxCount = v;
                              setState(() {});
                            })),
              SizedBox(width: 24),
              //InputLeftText(label: '無限大', rPadding: 4, width: 50),
              Switch(
                  value: item.isInfinityCount,
                  onChanged: (v) {
                    item.isInfinityCount = v;
                    setState(() {});
                  }),
            ])),
        RowLabelInput(
            labelWidth: 180,
            labelPadding: 6,
            label: item.title + ' [' + item.name + ']',
            renderWidget: item.isInfinityCount
                ? TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(6),
                      fillColor: Colors.white,
                      filled: true,
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFbebebe)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFbebebe)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFbebebe)),
                      ),
                    ),
                    initialValue: item.count,
                    onChanged: (value) => item.count = value,
                  )
                : DropDownNumberSelect(
                    contentPadding: EdgeInsets.all(6),
                    max: int.parse(item.maxCount),
                    min: 0,
                    value: int.parse(item.count) > int.parse(item.maxCount)
                        ? item.maxCount
                        : item.count,
                    tapFunc: (v) => item.count = v)),
        RowLabelInput(
          labelWidth: 180,
          labelPadding: 6,
          label: 'チケット初期化',
          renderWidget: Switch(
              value: item.isReset == '1',
              onChanged: (v) {
                item.isReset = v ? '1' : '0';
                setState(() {});
              }),
        ),
        Row(
          children: [
            _groupYMWRadio(item, '2'),
            Text('毎年'),
            _groupYMWRadio(item, '1'),
            Text('毎週'),
            _groupYMWRadio(item, '3'),
            Text('毎月'),
            SizedBox(width: 4),
            if (item.resetTimeType != '0')
              Flexible(
                child: item.resetTimeType != '1'
                    ? DropDownNumberSelect(
                        contentPadding: dropdownPadding,
                        value: item.resetTimeValue,
                        max: item.resetTimeType == '2' ? 12 : 31,
                        label: item.resetTimeType == '2' ? '月末' : '日',
                        tapFunc: item.isReset == '0'
                            ? null
                            : (v) {
                                item.resetTimeValue = v;
                                setState(() {});
                              })
                    : DropDownModelSelect(
                        contentPadding: EdgeInsets.all(6),
                        value: item.resetTimeValue,
                        items: [
                          ...constWeeks.map((e) => DropdownMenuItem(
                                child: Text(e['val']),
                                value: e['value'],
                              )),
                        ],
                        tapFunc: item.isReset == '0'
                            ? null
                            : (v) {
                                item.resetTimeValue = v;
                                setState(() {});
                              }),
              ),
          ],
        ),
        RowLabelInput(
            labelWidth: 180,
            labelPadding: 6,
            label: 'リセット枚数',
            renderWidget: item.isInfinityCount
                ? TextFormField(
                    keyboardType: TextInputType.number,
                    enabled: item.isReset == '0' ? false : true,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(6),
                      fillColor: Colors.white,
                      filled: true,
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFbebebe)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFbebebe)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFbebebe)),
                      ),
                    ),
                    initialValue: item.resetCount,
                    onChanged: (value) => item.resetCount = value,
                  )
                : DropDownNumberSelect(
                    contentPadding: EdgeInsets.all(6),
                    value: int.parse(item.resetCount) > int.parse(item.maxCount)
                        ? item.maxCount
                        : item.resetCount,
                    plusnum: 10,
                    max: int.parse(item.maxCount),
                    min: 0,
                    tapFunc: item.isReset == '0'
                        ? null
                        : (v) {
                            item.resetCount = v;
                            setState(() {});
                          },
                  )),
      ]),
    );
  }

  Widget _groupYMWRadio(item, String value) {
    return Radio(
      groupValue: item.resetTimeType,
      value: value,
      onChanged: item.isReset == '0'
          ? null
          : (v) {
              item.resetTimeValue = '1';
              item.resetTimeType = v.toString();
              setState(() {});
            },
    );
  }

  Widget _getRowContent(label, render, {double vMargin = 8}) {
    return AdminRowForm(
      labelWidth: 110,
      labelPadding: 4,
      hMargin: 20,
      vMargin: vMargin,
      label: label,
      renderWidget: render,
    );
  }
}

class AdminUserEditHistoryItem extends StatelessWidget {
  final OrderModel order;
  final delFunc;
  const AdminUserEditHistoryItem(
      {required this.order, required this.delFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: new EdgeInsets.symmetric(vertical: 8.0),
      padding: paddingItemGroup,
      decoration: BoxDecoration(
          color: order.status == constOrderStatusReserveApply
              ? Color(0xffCECECE)
              : Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Container(
                      padding: paddingItemGroupTitleSpace,
                      child:
                          Text(order.organName, style: styleItemGroupTitle))),
              Container(
                  alignment: Alignment.topRight,
                  child: Text(
                      '￥' + Funcs().currencyFormat(order.amount.toString())))
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  Container(
                      padding: EdgeInsets.only(left: 4, bottom: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...order.menus.map(
                            (e) => Container(
                                padding: EdgeInsets.only(bottom: 2),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Expanded(child: Text(e.menuTitle)),
                                    // Container(
                                    //     child: Text('￥' +
                                    //         Funcs()
                                    //             .currencyFormat(e.menuPrice)))
                                  ],
                                )),
                          )
                        ],
                      )),
                  if (order.staffId != '')
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text('【' + order.staffName + '】')),
                  Container(
                      padding: paddingContentLineSpace,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                              DateFormat('yyyy年MM月dd日' +
                                      '(' +
                                      weekAry[DateTime.parse(order.fromTime)
                                              .weekday -
                                          1] +
                                      ')')
                                  .format(DateTime.parse(order.fromTime)),
                              style: styleContent),
                          Expanded(child: Container()),
                          ElevatedButton(onPressed: delFunc, child: Text('削除'))
                        ],
                      ))
                ],
              )),
            ],
          )
        ],
      ),
    );
  }
}
