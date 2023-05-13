import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/orders.dart';
import 'package:staff_pos_app/src/common/business/user.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/admin/component/admin_lines.dart';
import 'package:staff_pos_app/src/interface/admin/component/admin_rows.dart';
import 'package:staff_pos_app/src/interface/admin/component/admin_texts.dart';
import 'package:staff_pos_app/src/interface/admin/messages/admin_messeage_make.dart';
import 'package:staff_pos_app/src/interface/admin/users/admin_user_edit.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/model/order_model.dart';
import 'package:staff_pos_app/src/interface/admin/style/borders.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/common/functions.dart';

import '../../../common/globals.dart' as globals;

class AdminUserInfo extends StatefulWidget {
  final String userId;
  const AdminUserInfo({required this.userId, Key? key}) : super(key: key);

  @override
  _AdminUserInfo createState() => _AdminUserInfo();
}

class _AdminUserInfo extends State<AdminUserInfo> {
  late Future<List> loadData;

  List<OrderModel> orders = [];

  String userName = '';
  String userAge = '';
  String userSex = '';
  String userPhone = '';
  String userEmail = '';
  String userBirth = '';
  String userTicket = '';
  String userGroupName = '';
  String userComment = '';

  String isTicketReset = '0';
  String ticketResetType = '1';
  String ticketResetMonthDay = '1';
  String ticketResetWeekDay = '1';
  String ticketResetValue = '0';

  @override
  void initState() {
    super.initState();
    loadData = loadinitData();
  }

  Future<List> loadinitData() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadUserInfoUrl, {
      'user_id': widget.userId,
      'is_reserve_list': '1'
    }).then((value) => results = value);

    if (results['isLoad']) {
      var user = results['user'];
      userName =
          (user['user_first_name'] == null ? '' : user['user_first_name']) +
              ' ' +
              (user['user_last_name'] == null ? '' : user['user_last_name']);
      userAge = user['user_birthday'] == null
          ? ''
          : (DateTime.now().year - DateTime.parse(user['user_birthday']).year)
              .toString();
      userSex = user['user_sex'] == null
          ? ' '
          : user['user_sex'] == '1'
              ? '男'
              : '女';
      userPhone = user['user_tel'] == null ? '' : user['user_tel'];
      userEmail = user['user_email'] == null ? '' : user['user_email'];
      userBirth = user['user_birthday'] == null
          ? ''
          : Funcs().dateFormatJP1(user['user_birthday']);
      userTicket =
          user['user_ticket'] == null ? '' : user['user_ticket'].toString();
      userGroupName = user['group'] == null ? '' : user['group']['group_name'];

      userComment = user['user_comment'] == null ? '' : user['user_comment'];
      var ticketReset = results['ticket_reset'];

      if (ticketReset != null) {
        isTicketReset = ticketReset['is_enable'] == null
            ? '0'
            : ticketReset['is_enable'].toString();

        ticketResetType = ticketReset['time_type'] == null
            ? '1'
            : ticketReset['time_type'].toString();

        if (ticketResetType == '1') {
          ticketResetMonthDay = ticketReset['time_value'] == null
              ? '1'
              : ticketReset['time_value'].toString();
        } else {
          String tmpday = ticketReset['time_value'] == null
              ? '1'
              : ticketReset['time_value'].toString();
          for (var item in constWeeks) {
            if (item['value'] == tmpday) {
              ticketResetWeekDay = item['val'];
              break;
            }
          }
        }

        ticketResetValue = ticketReset['ticket_value'] == null
            ? '1'
            : ticketReset['ticket_value'].toString();
      }
    }

    orders = await ClOrder().loadOrderList(
        context, {'user_id': widget.userId, 'is_reserve_and_complete': '1'});

    setState(() {});

    return [];
  }

  Future<void> pushUserEdit() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return AdminUserEdit(userId: widget.userId);
    }));
    loadinitData();
  }

  Future<void> deleteUser(String userId) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;
    Dialogs().loaderDialogNormal(context);
    bool isDelete = await ClUser().deleteUser(context, userId);
    Navigator.pop(context);
    if (isDelete) {
      Navigator.pop(context);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'アカウント情報';
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
                        child: Container(
                      // padding: paddingMainContent,
                      child: SingleChildScrollView(
                          child: Column(
                        children: [
                          _getMainContent(),
                          ...orders
                              .map((e) => AdminUserInfoHistoryItem(item: e))
                        ],
                      )),
                    )),
                    _getBottonButton(),
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

  Widget _getMainContent() {
    return Container(
      child: Column(
        children: [
          _getHeaderContent(),
          AdminLineH1(),
          _getRowContent('電話番号', userPhone),
          AdminLineH1(),
          _getRowContent('メールアドレス', userEmail),
          AdminLineH1(),
          _getRowContent('生年月日', userBirth),
          AdminLineH1(),
          _getRowContent('グループ分け', userGroupName),
          AdminLineH1(),
          _getRowContent('メモ', userComment),
          AdminLineH1(),
          // _getRowContent('チケット枚数', userTicket),
          // AdminLineH1(),
          // _getRowContent('チケット初期化', isTicketReset == '1' ? '設定済み' : '設定なし'),
          // if (isTicketReset == '1')
          //   _getRowContent(
          //       '初期化timing',
          //       (ticketResetType == '1' ? '毎月' : '毎週') +
          //           '  ' +
          //           (ticketResetType == '1'
          //               ? (ticketResetMonthDay + 'day')
          //               : ticketResetWeekDay)),
          // if (isTicketReset == '1')
          //   _getRowContent('リセットする枚数', ticketResetValue),
          // AdminLineH1(),
        ],
      ),
    );
  }

  Widget _getHeaderContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      child: Row(
        children: [
          Expanded(
              child:
                  Container(width: 100, child: AdminHeader4(label: userName))),
          Container(
              height: 35,
              alignment: Alignment.bottomCenter,
              child: AdminCommentText(
                  label: '年齢 ' + userAge + '歳 /    性別 ' + userSex)),
        ],
      ),
    );
  }

  Widget _getRowContent(label, value) {
    return AdminRowForm(
      labelWidth: 140,
      hMargin: 30,
      vMargin: 8,
      label: label,
      renderWidget: AdminCommentText(label: value),
    );
  }

  Widget _getBottonButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(child: Container()),
        PrimaryColButton(label: '編集', tapFunc: () => pushUserEdit()),
        SizedBox(width: 6),
        // if (globals.auth >= constAuthManager)
        DeleteColButton(
            label: 'このユーザーを削除', tapFunc: () => deleteUser(widget.userId)),
        SizedBox(width: 6),
        WhiteButton(
            label: 'メッセージ',
            tapFunc: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return AdminMesseageMake(
                      isGroup: false,
                      userName: userName,
                      userId: widget.userId);
                }))),
        Expanded(child: Container()),
      ]),
    );
  }
}

class AdminUserInfoContent extends StatelessWidget {
  final String label;
  final String value;
  const AdminUserInfoContent(
      {required this.label, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: paddingListLineSpace,
        decoration: borderTopLine,
        child: Row(
          children: [
            Container(
                width: 120,
                child: Text(
                  label,
                  style: styleContent,
                )),
            Flexible(child: Text(value)),
          ],
        ));
  }
}

class AdminUserInfoHistoryItem extends StatelessWidget {
  final OrderModel item;
  const AdminUserInfoHistoryItem({required this.item, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: new EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      padding: paddingItemGroup,
      decoration: BoxDecoration(
          color: item.status == constOrderStatusTableComplete
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
                      child: Text(item.organName, style: styleItemGroupTitle))),
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
                      padding: EdgeInsets.only(left: 4, bottom: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                    // Container(
                                    //   child: Text('￥' +
                                    //       Funcs().currencyFormat(e.menuPrice)),
                                    // )
                                  ],
                                )),
                          )
                        ],
                      )),
                  if (item.staffName != '')
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text('【' + item.staffName + '】')),
                  Container(
                      padding: paddingContentLineSpace,
                      alignment: Alignment.centerLeft,
                      child: Text(
                          DateFormat('yyyy年MM月dd日' +
                                  '(' +
                                  weekAry[
                                      DateTime.parse(item.fromTime).weekday -
                                          1] +
                                  ')')
                              .format(DateTime.parse(item.toTime)),
                          style: styleContent))
                ],
              )),
            ],
          )
        ],
      ),
    );
  }
}
