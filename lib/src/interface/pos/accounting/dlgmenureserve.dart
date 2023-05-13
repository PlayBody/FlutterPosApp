import 'package:staff_pos_app/src/common/business/ticket.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/model/menumodel.dart';
import 'package:staff_pos_app/src/model/menuvariationmodel.dart';

import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/model/order_menu_model.dart';
import 'package:staff_pos_app/src/model/userticketmodel.dart';
import '../../../common/globals.dart' as globals;

class DlgMenuReserve extends StatefulWidget {
  final MenuModel item;
  final String userId;
  final List<MenuVariationModel> variationList;
  const DlgMenuReserve(
      {required this.item,
      required this.userId,
      required this.variationList,
      Key? key})
      : super(key: key);

  @override
  _DlgMenuReserve createState() => _DlgMenuReserve();
}

class _DlgMenuReserve extends State<DlgMenuReserve> {
  String selQuantity = '1';
  MenuVariationModel? selVariation;
  List<UserTicketModel> userTickets = [];
  List<String> errMsgs = [];

  @override
  void initState() {
    super.initState();
    loadInit();
  }

  Future<void> loadInit() async {
    userTickets = await ClTicket().loadUserTickets(context, widget.userId, '');

    setState(() {});
    return;
  }

  Future<void> menuAdd() async {
    errMsgs = [];
    bool isCheck = true;
    // if (selQuantity == null) {
    //   errMsgs.add('数量を選択してください。');
    //   isCheck = false;
    // }

    int ticketSumAmount = 0;
    dynamic inuseTickets = {};
    userTickets.forEach((element) {
      if (element.usecount != null) {
        ticketSumAmount +=
            int.parse(element.price02) * int.parse(element.usecount!);
        inuseTickets[element.ticketId] = element.usecount;
      }
    });

    if ((int.parse(widget.item.menuPrice) * int.parse(selQuantity)) <
        ticketSumAmount) {
      errMsgs.add('回収券利用金額を超過しました。');
      isCheck = false;
    }
    setState(() {});
    if (!isCheck) return;
    Funcs().orderInputListAdd(
        context,
        OrderMenuModel(
            menuTitle: widget.item.menuTitle +
                (selVariation == null
                    ? ''
                    : (' (' + selVariation!.variationTitle + ')')),
            quantity: selQuantity,
            menuPrice: selVariation == null
                ? widget.item.menuPrice
                : selVariation!.variationPrice,
            menuId: widget.item.menuId,
            variationId:
                selVariation == null ? null : selVariation!.variationId,
            useTickets: inuseTickets));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
      render: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PosDlgHeaderText(label: qMenuReserve),
          if (errMsgs.length > 0)
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...errMsgs.map((e) => Text(
                        e,
                        style: TextStyle(color: redColor),
                      )),
                  SizedBox(height: 10)
                ],
              ),
            ),
          if (widget.variationList.length > 0)
            Container(
              child: DropDownModelSelect(
                hint: warningSelectMenuVariation,
                items: [
                  ...widget.variationList.map((e) => DropdownMenuItem(
                        child: Text(e.variationTitle),
                        value: e,
                      ))
                ],
                tapFunc: (v) {
                  selVariation = v!;
                },
              ),
            ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.only(bottom: 15),
            child: DropDownNumberSelect(
              hint: hintSelectQuantity,
              value: selQuantity,
              max: 50,
              tapFunc: (String? v) {
                selQuantity = v.toString();
              },
            ),
          ),
          if (globals.companyId == '2' && int.parse(widget.userId) > 1)
            ...userTickets.map((e) => Container(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Flexible(
                      child: DropDownNumberSelect(
                    value: e.usecount,
                    hint: e.title + 'の利用枚数',
                    max: e.count == null ? 0 : int.parse(e.count!),
                    tapFunc: (String? v) {
                      e.usecount = v;
                      setState(() {});
                    },
                  )),
                  if (e.usecount != null)
                    IconButton(
                      icon: Icon(Icons.close, color: redColor),
                      onPressed: () {
                        e.usecount = null;
                        setState(() {});
                      },
                    )
                ]))),
          Container(
            padding: EdgeInsets.only(top: 40),
            child: Row(
              children: [
                Expanded(child: Container()),
                PrimaryButton(label: 'はい', tapFunc: () => menuAdd()),
                SizedBox(width: 12),
                CancelButton(
                    label: 'いいえ', tapFunc: () => Navigator.of(context).pop()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
