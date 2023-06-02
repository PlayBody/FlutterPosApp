import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/ticket.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/pos/manage/tickets/dlg_ticket_reset_push_setting.dart';
import 'package:staff_pos_app/src/interface/style/textstyles.dart';
import 'package:staff_pos_app/src/model/companymodel.dart';
import 'package:staff_pos_app/src/model/menumodel.dart';
import 'package:staff_pos_app/src/model/menuvariationmodel.dart';
import 'package:staff_pos_app/src/model/ticket_reset_push_setting_model.dart';
import 'package:staff_pos_app/src/model/ticketmastermodel.dart';
import 'package:staff_pos_app/src/model/ticketmodel.dart';
import 'package:staff_pos_app/src/model/variationbackstaffmodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;

// var txtAccountingController = TextEditingController();
// var txtMenuCountController = TextEditingController();
// var txtSetTimeController = TextEditingController();
// var txtSetAmountController = TextEditingController();
// var txtTableAmountController = TextEditingController();

class TicketEdit extends StatefulWidget {
  final String? id;
  final String companyId;
  const TicketEdit({this.id, required this.companyId, Key? key})
      : super(key: key);

  @override
  _TicketEdit createState() => _TicketEdit();
}

class _TicketEdit extends State<TicketEdit> {
  late Future<List> loadData;

  MenuModel? menu;

  String isAdmin = '0';
  List<MenuVariationModel> variationList = [];
  List<MenuModel> menuList = [];
  List<VariationBackStaffModel> vStaffList = [];

  String? ticketMasterId;
  var txtTitleController = TextEditingController();
  var txtDetailController = TextEditingController();
  var txtPriceController = TextEditingController();
  var txtCostController = TextEditingController();
  var txtTaxController = TextEditingController();
  var txtDisamountController = TextEditingController();
  String? ticketCount;

  String? errTitle;
  String? errDetail;
  String? errPrice;
  String? errCost;
  String? errTax;
  String? errDisAmount;

  TicketModel? ticket;

  List<TicketMasterModel> ticketMaster = [];
  List<TicketResetPushSettingModel> resetPushSettings = [];

  bool isUpload = false;
  bool isDeletePhoto = false;
  late File _uploadFile;

  bool isPeriod = false;
  String? periodMonth;

  @override
  void initState() {
    super.initState();
    loadData = loadTicketData();
  }

  Future<List> loadTicketData() async {
    ticketMaster = await ClTicket().loadMasterTicket(context, widget.companyId);

    if (widget.id == null) {
      return [];
    }

    ticket = await ClTicket().loadTicket(context, widget.id);
    if (ticket != null) {
      BuildContext cx = context;
      List<TicketMasterModel> ts =
          await ClTicket().loadMasterTicketById(cx, ticket!.ticketId);
      for (TicketMasterModel tm in ts) {
        int i;
        for (i = 0; i < ticketMaster.length; i++) {
          if (ticketMaster[i].id == tm.id) {
            break;
          }
        }
        if (ticketMaster.length == i) {
          ticketMaster.add(tm);
        }
      }
    }

    if (ticket != null) {
      txtTitleController.text = ticket!.title;
      txtDetailController.text = ticket!.detail;
      txtPriceController.text = ticket!.price;
      txtCostController.text = ticket!.cost;
      txtTaxController.text = ticket!.tax;
      txtDisamountController.text = ticket!.disamount;

      ticketCount = ticket!.cnt;
      isPeriod = ticket!.isPeriod;
      periodMonth = ticket!.periodMonth;

      ticketMasterId = ticket!.ticketId;
    } else {
      return [];
    }

    resetPushSettings = await ClTicket()
        .loadResetPushSettings(context, widget.id == null ? '' : widget.id);

    setState(() {});

    return [];
  }

  Future<void> saveTicketData() async {
    bool isCheck = true;

    if (ticketMasterId == null) {
      errTitle = warningCommonInputRequire;
      isCheck = false;
    } else {
      if (txtTitleController.text == '') {
        txtTitleController.text = ticketMaster
            .firstWhere((element) => element.id == ticketMasterId)
            .ticketName;
      }
      errTitle = null;
    }
    if (txtDetailController.text == '') {
      errDetail = warningCommonInputRequire;
      isCheck = false;
    } else {
      errDetail = null;
    }
    if (txtPriceController.text == '') {
      errPrice = warningCommonInputRequire;
      isCheck = false;
    } else {
      errPrice = null;
    }
    // if (txtCostController.text == '') {
    //   errCost = warningCommonInputRequire;
    //   isCheck = false;
    // } else {
    //   errCost = null;
    // }
    // if (txtTaxController.text == '') {
    //   errTax = warningCommonInputRequire;
    //   isCheck = false;
    // } else {
    //   errTax = null;
    // }
    if (txtDisamountController.text == '') {
      errDisAmount = warningCommonInputRequire;
      isCheck = false;
    } else {
      errDisAmount = null;
    }

    if (isCheck && ticketCount == null) {
      isCheck = false;
      Dialogs().infoDialog(context, '追加枚数を選択してください。');
    }
    setState(() {});
    if (!isCheck) return;

    Dialogs().loaderDialogNormal(context);

    String imagename = '';
    if (isUpload) {
      imagename = await ClTicket().uploadTicketImage(context, _uploadFile);
    }
    bool isSave = await ClTicket().saveTicket(context, {
      'id': widget.id == null ? '' : widget.id,
      'company_id': widget.companyId == ''
          ? ticketMaster
              .firstWhere((element) => element.id == ticketMasterId)
              .companyId
          : widget.companyId,
      'ticket_id': ticketMasterId,
      'ticket_title': txtTitleController.text,
      'ticket_detail': txtDetailController.text,
      'ticket_image': imagename,
      'price': txtPriceController.text,
      'cost': txtCostController.text,
      'tax': txtTaxController.text,
      'disamount': txtDisamountController.text,
      'ticket_count': ticketCount!,
      'is_period': isPeriod ? '1' : '0',
      'period_month': periodMonth == null ? '' : periodMonth
    });

    Navigator.pop(context);
    if (isSave) {
      Navigator.pop(context);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> deleteTicket() async {
    if (widget.id == null) return;
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);

    if (!conf) return;

    Dialogs().loaderDialogNormal(context);
    bool isDelete = await ClTicket().deleteTicket(context, widget.id);
    Navigator.pop(context);
    if (isDelete) {
      Navigator.pop(context);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> deletePushSetting(String _delId) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;
    Dialogs().loaderDialogNormal(context);
    await ClTicket().deleteResetPushSettings(context, _delId);
    await loadTicketData();
    Navigator.pop(context);
  }

  void addTicketResetPushSetting() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgTicketResetPushSetting(ticketId: widget.id!);
        }).then((_) {
      loadTicketData();
    });
  }

  _getFromPhoto() async {
    XFile? image;

    // if (_libType == '1') {
    //   image = await ImagePicker().pickImage(source: ImageSource.camera);
    // } else {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    // }
    if (image == null) return;

    final path = image.path;
    setState(() {
      isUpload = true;
      isDeletePhoto = false;
      _uploadFile = File(path);
    });
  }

  // _getRemovePhoto() async {
  //   // _uploadFile.delete();
  // }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'チケット管理';
    return MainBodyWdiget(
        render: FutureBuilder<List>(
      future: loadData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _getBody();
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    ));
  }

  Widget _getBody() {
    return Container(
      color: bodyColor,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _getMenuContent(),
                  _getTicketSettingAdd(),
                  if (widget.id != null) _setTicketPushSettings(),
                ],
              ),
            ),
          ),
          _getBottomButton()
        ],
      ),
    );
  }

  Widget _getMenuContent() {
    return Container(
      padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
      child: Column(
        children: [
          RowLabelInput(
            label: 'チケット画像',
            renderWidget: Container(
              alignment: Alignment.centerLeft,
              height: 120,
              child: (isUpload)
                  ? Image.file(_uploadFile)
                  : (ticket == null || ticket!.image == null)
                      ? Text('設定なし')
                      : Image.network(ticketImageUrl + ticket!.image!),
            ),
          ),
          RowLabelInput(
            label: '',
            renderWidget: Row(
              children: [
                WhiteButton(tapFunc: () => _getFromPhoto(), label: '画像を選択'),
                // SizedBox(width: 8),
                // if (isUpload || ticket!.image != null)
                //   DeleteButton(tapFunc: () => _getRemovePhoto(), label: '削除'),
              ],
            ),
          ),
          SizedBox(height: 8),
          RowLabelInput(
              label: 'チケット種別名', // Ticekt type name
              renderWidget: DropDownModelSelect(
                value: ticketMasterId,
                items: [
                  ...ticketMaster.map((e) => DropdownMenuItem(
                        child: Text(e.ticketName),
                        value: e.id,
                      ))
                ],
                tapFunc: (v) {
                  ticketMasterId = v;
                  if (txtTitleController.text == '' ||
                      ticketMaster
                              .where((element) =>
                                  element.ticketName == txtTitleController.text)
                              .length >
                          0)
                    txtTitleController.text = ticketMaster
                        .firstWhere((element) => element.id == v)
                        .ticketName;
                  setState(() {});
                },
              )),
          SizedBox(height: 8),
          RowLabelInput(
              label: 'チケット名',
              renderWidget: TextInputNormal(
                  controller: txtTitleController, errorText: errTitle)),
          SizedBox(height: 8),
          RowLabelInput(
              label: '説明',
              renderWidget: TextInputNormal(
                  multiLine: 3,
                  controller: txtDetailController,
                  errorText: errDetail)),
          SizedBox(height: 8),
          RowLabelInput(
              label: '税抜価格',
              renderWidget: TextInputNormal(
                  controller: txtPriceController,
                  errorText: errPrice,
                  inputType: TextInputType.number)),
          // SizedBox(height: 8),
          // RowLabelInput(
          //     label: '原価',
          //     renderWidget: TextInputNormal(
          //         controller: txtCostController,
          //         errorText: errCost,
          //         inputType: TextInputType.number)),
          // SizedBox(height: 8),
          // RowLabelInput(
          //     label: '消費税率',
          //     renderWidget: TextInputNormal(
          //         controller: txtTaxController,
          //         errorText: errTax,
          //         inputType: TextInputType.number)),
          SizedBox(height: 8),
          RowLabelInput(
              label: '割引金額 ',
              renderWidget: TextInputNormal(
                  controller: txtDisamountController,
                  errorText: errDisAmount,
                  inputType: TextInputType.number)),
          SizedBox(height: 8),
          RowLabelInput(
              label: '追加枚数',
              renderWidget: Row(children: [
                Flexible(
                  child: DropDownNumberSelect(
                    value: ticketCount,
                    min: 1,
                    max: 99,
                    tapFunc: (v) {
                      ticketCount = v;
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(width: 12),
                Text('数', style: bodyTextStyle),
                SizedBox(width: 32),
              ])),
        ],
      ),
    );
  }

  Widget _getTicketSettingAdd() {
    return Container(
      // padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
      child: Column(
        children: [
          PageSubHeader(label: 'チケット期限設定'),
          Container(
              padding: EdgeInsets.only(left: 40),
              child: RowLabelInput(
                  labelWidth: 120,
                  label: '有効期限設定',
                  renderWidget: Switch(
                      value: isPeriod,
                      onChanged: (v) {
                        isPeriod = v;
                        setState(() {});
                      }))),
          Container(
              padding: EdgeInsets.only(left: 40),
              child: Row(
                children: [
                  Text('購入月から'),
                  Container(
                      width: 80,
                      child: DropDownNumberSelect(
                          value: periodMonth,
                          max: 25,
                          tapFunc: isPeriod
                              ? (v) {
                                  periodMonth = v;
                                  setState(() {});
                                }
                              : null)),
                  Text('カ月後の月末まで'),
                ],
              )),
          SizedBox(height: 12)
        ],
      ),
    );
  }

  Widget _setTicketPushSettings() {
    return Container(
      child: Column(
        children: [
          PageSubHeader(label: '回数券リミット通知設定'),
          ...resetPushSettings.map((e) => Container(
              padding: EdgeInsets.only(left: 30, top: 12),
              child: Row(
                children: [
                  Icon(Icons.mark_as_unread),
                  SizedBox(width: 16),
                  Text(e.beforeDay + '日前の' + e.pushTime + '時に通知'),
                  IconButton(
                      splashRadius: 16,
                      onPressed: () => deletePushSetting(e.id),
                      icon: Icon(Icons.delete, size: 22))
                ],
              ))),
          SizedBox(height: 16),
          WhiteButton(
              label: '通知設定の追加', tapFunc: () => addTicketResetPushSetting())
        ],
      ),
    );
  }

  Widget _getBottomButton() {
    return RowButtonGroup(
      widgets: [
        PrimaryButton(label: '保存', tapFunc: () => saveTicketData()),
        SizedBox(width: 8),
        CancelButton(
          label: '戻る',
          tapFunc: () => Navigator.pop(context),
        ),
        SizedBox(width: 8),
        DeleteButton(
            label: '削除',
            tapFunc: widget.id == null ? null : () => deleteTicket()),
      ],
    );
  }
}
