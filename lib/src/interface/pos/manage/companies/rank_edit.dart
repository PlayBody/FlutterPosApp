import 'package:staff_pos_app/src/common/business/coupon.dart';
import 'package:staff_pos_app/src/common/business/menu.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/model/couponmodel.dart';
import 'package:staff_pos_app/src/model/menumodel.dart';

import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/model/rankmodel.dart';
import 'package:staff_pos_app/src/model/rankprefermodel.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;

class RankEdit extends StatefulWidget {
  final String companyId;
  final String? rankId;

  const RankEdit({required this.companyId, this.rankId, Key? key})
      : super(key: key);

  @override
  State<RankEdit> createState() => _RankEdit();
}

class _RankEdit extends State<RankEdit> {
  late Future<List> loadData;
  var txtTitleController = TextEditingController();
  var txtMaxStampsController = TextEditingController();
  String? errTitle;
  String? errMaxStamps;

  // String cnt1 = '0+';
  // String cnt2 = '1';

  List<RankPreferModel> prefers = [];
  List<RankPreferViewModel> preferViews = [];
  List<MenuModel> menus = [];
  List<CouponModel> coupons = [];
  final dropdownMenuState = GlobalKey<FormFieldState>();
  final dropdownCouponState = GlobalKey<FormFieldState>();

  int maxStampt = 100;
  int preferNo = 0;

  @override
  void initState() {
    super.initState();

    loadData = loadInitData();
    // txtTitleController.text = widget.organName == null ? '' : widget.organName!;
  }

  Future<List> loadInitData() async {
    menus = await ClMenu().loadCompanyUserMenus(context, widget.companyId);
    coupons = await ClCoupon().loadCoupons(context, widget.companyId);

    if (widget.rankId != null) {
      RankModel rank = await ClCoupon().loadRankInfo(context, widget.rankId!);
      txtTitleController.text = rank.rankName;
      txtMaxStampsController.text = rank.maxStamp;
      // int cntPre = int.parse(rank.maxStamp) ~/ 100;
      // cnt1 = '${cntPre * 100}+';
      // cnt2 = (int.parse(rank.maxStamp) - (cntPre * 100)).toString();

      // ignore: use_build_context_synchronously
      prefers = await ClCoupon().loadRankPrefers(context, '', widget.rankId);

      for (RankPreferModel prefer in prefers) {
        var controller = TextEditingController();
        controller.text = prefer.stampCount.toString();
        preferViews.add(RankPreferViewModel(
            rankPrefer: prefer, controller: controller, error: null));
      }
    }
    setState(() {});
    return [];
  }

  Future<void> saveStamp() async {
    Dialogs().loaderDialogNormal(context);
    bool isCheck = true;
    if (txtTitleController.text == '') {
      errTitle = warningCommonInputRequire;
      isCheck = false;
    } else {
      errTitle = null;
    }
    if (txtMaxStampsController.text == '') {
      txtMaxStampsController.text = '0';
    }

    dynamic menuParam = {};
    int ii = 0;
    for (var preferView in preferViews) {
      var element = preferView.rankPrefer;
      ii++;
      if (element.stampCount != null &&
          element.prefType != null &&
          (element.menuId != null || element.couponId != null)) {
        menuParam[ii.toString()] = {
          'rank_prefer_id': element.rankPreferId,
          // 'stamp_count': element.stampCount,
          'stamp_count': int.parse(preferView.controller.text) >
                  int.parse(txtMaxStampsController.text)
              ? txtMaxStampsController.text
              : preferView.controller.text,
          'type': element.prefType,
          'menu_id': element.menuId ?? '',
          'coupon_id': element.couponId ?? '',
          'is_delete': element.isDelete ? '1' : '0'
        };
      }
    }
    // String maxStamp =
    //     (int.parse(cnt1.replaceAll('+', '')) + int.parse(cnt2)).toString();

    setState(() {});
    if (!isCheck) return;

    await ClCoupon().saveStamp(context, widget.rankId ?? '', widget.companyId,
        txtTitleController.text, txtMaxStampsController.text, menuParam);

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<void> deleteRank() async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;
    await ClCoupon().delteRank(context, widget.rankId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    preferNo = 0;

    globals.appTitle = 'スタンプ管理';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: Colors.white,
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  _getMainContent(),
                  _getButtonGroupContent(),
                ]));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _getMainContent() {
    return Expanded(
        child: SingleChildScrollView(
            child: Column(
      children: [
        RowLabelInput(
            label: 'ランク名',
            labelWidth: 120,
            labelPadding: 4,
            renderWidget: TextInputNormal(
                controller: txtTitleController, errorText: errTitle)),
        const SizedBox(height: 12),
        // RowLabelInput(
        //     label: '最大スタンプ数',
        //     labelWidth: 120,
        //     labelPadding: 4,
        //     renderWidget: Row(
        //       children: [
        //         Flexible(
        //             child: DropDownNumberSelect(
        //                 value: cnt1,
        //                 min: 0,
        //                 max: 900,
        //                 diff: 100,
        //                 isPlusLabel: true,
        //                 tapFunc: (v) => cnt1 = v.toString())),
        //         const SizedBox(width: 8),
        //         Flexible(
        //             child: DropDownNumberSelect(
        //                 value: cnt2,
        //                 min: 0,
        //                 max: 99,
        //                 tapFunc: (v) => cnt2 = v.toString())),
        //       ],
        //     )),
        RowLabelInput(
            label: '最大スタンプ数',
            labelWidth: 120,
            labelPadding: 4,
            renderWidget: TextInputNormal(
              controller: txtMaxStampsController,
              errorText: errMaxStamps,
              inputType: TextInputType.number,
            )),
        const SizedBox(height: 12),
        // TextInputNormal(controller: txtTitleController, errorText: errTitle),
        const SizedBox(height: 25),
        const PosDlgInputLabelText(label: '特典'),
        // ...prefers.map((e) => _getPreferRow(e)),
        ...preferViews.map((e) => _getPreferRow(e)),
        RowButtonGroup(widgets: [
          WhiteButton(
              label: '特典追加',
              tapFunc: () {
                preferViews.add(RankPreferViewModel(
                    rankPrefer: RankPreferModel.fromJson({}),
                    controller: TextEditingController(),
                    error: null));
                // prefers.add(RankPreferModel.fromJson({}));
                setState(() {});
              })
        ]),
      ],
    )));
  }

  Widget _getButtonGroupContent() {
    return Row(
      children: [
        Expanded(child: Container()),
        PrimaryColButton(label: '保存', tapFunc: () => saveStamp()),
        const SizedBox(width: 8),
        DeleteColButton(label: '削除', tapFunc: () => deleteRank()),
        const SizedBox(width: 8),
        CancelColButton(
            label: '保存せず戻る', tapFunc: () => Navigator.of(context).pop()),
      ],
    );
  }

  Widget _getPreferRow(RankPreferViewModel preferView) {
    var item = preferView.rankPrefer;
    preferNo++;
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$preferNo',
              style: TextStyle(
                  color: item.isDelete ? Colors.red : Colors.black,
                  decoration: item.isDelete
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            _getStampNumberContent(preferView),
            const SizedBox(width: 8),
            Flexible(
                flex: 2,
                child: Column(
                  children: [
                    _getPrefType(item),
                    const SizedBox(height: 8),
                    if (item.prefType == null || item.prefType == '1')
                      _getPrefMenuSelectContent(item),
                    if (item.prefType != null && item.prefType == '2')
                      _getPrefCouponSelectContent(item),
                  ],
                )),
            if (item.isDelete)
              GestureDetector(
                child: const Icon(Icons.restart_alt, color: Colors.green),
                onTap: () {
                  item.isDelete = false;
                  setState(() {});
                },
              ),
            if (!item.isDelete)
              GestureDetector(
                child: const Icon(Icons.delete, color: Colors.red),
                onTap: () {
                  if (item.rankPreferId == '') {
                    // prefers.remove(item);
                    preferViews.remove(item);
                  } else {
                    item.isDelete = true;
                  }
                  setState(() {});
                },
              ),
          ],
        ));
  }

  Widget _getStampNumberContent(RankPreferViewModel item) {
    if (item.controller.text == '') {
      item.controller.text = '0';
      item.rankPrefer.stampCount = '0';
    } else if (int.parse(txtMaxStampsController.text) <
        int.parse(item.controller.text)) {
      item.controller.text = txtMaxStampsController.text;
    }
    return Flexible(
        // child: DropDownNumberSelect(
        //     caption: '必要数',
        //     value: item.stampCount,
        //     min: 1,
        //     max: maxStampt,
        //     tapFunc: (v) => item.stampCount = v));
        child: TextInputNormal(
      controller: item.controller,
      errorText: item.error,
      inputType: TextInputType.number,
    ));
  }

  Widget _getPrefType(item) {
    return DropDownModelSelect(
      value: item.prefType,
      tapFunc: (v) {
        item.prefType = v;
        setState(() {});
      },
      items: const [
        DropdownMenuItem(value: '1', child: Text('メニュー')),
        DropdownMenuItem(value: '2', child: Text('クーポン'))
      ],
    );
  }

  Widget _getPrefMenuSelectContent(item) {
    return DropDownModelSelect(
      dropdownState: GlobalKey<FormFieldState>(),
      value: item.menuId,
      items: [
        ...menus.map((e) => DropdownMenuItem(
            value: e.menuId,
            child: Text(
              e.menuTitle,
              style: const TextStyle(fontSize: 12),
            ))),
      ],
      tapFunc: (v) => item.menuId = v.toString(),
    );
  }

  Widget _getPrefCouponSelectContent(item) {
    return DropDownModelSelect(
      dropdownState: GlobalKey<FormFieldState>(),
      value: item.couponId,
      items: [
        ...coupons.map((e) => DropdownMenuItem(
            value: e.couponId,
            child: Text(
              e.couponName,
              style: const TextStyle(fontSize: 12),
            )))
      ],
      tapFunc: (v) => item.couponId = v.toString(),
    );
  }
}

class RankPreferViewModel {
  final RankPreferModel rankPrefer;
  final TextEditingController controller;
  String? error;

  RankPreferViewModel({
    required this.rankPrefer,
    required this.controller,
    required this.error,
  });
}
