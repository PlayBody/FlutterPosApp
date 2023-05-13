import 'package:staff_pos_app/src/common/business/coupon.dart';
import 'package:staff_pos_app/src/common/business/menu.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/model/menumodel.dart';

import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/model/rankmodel.dart';
import 'package:staff_pos_app/src/model/rankprefermodel.dart';

class DlgStamp extends StatefulWidget {
  final String companyId;
  final String? rankId;

  const DlgStamp({required this.companyId, this.rankId, Key? key})
      : super(key: key);

  @override
  State<DlgStamp> createState() => _DlgStamp();
}

class _DlgStamp extends State<DlgStamp> {
  var txtTitleController = TextEditingController();
  String? errTitle;

  String cnt1 = '0+';
  String cnt2 = '1';

  List<RankPreferModel> prefers = [];
  List<MenuModel> menus = [];

  int maxStampt = 100;
  int preferNo = 0;

  @override
  void initState() {
    super.initState();

    loadData();
    // txtTitleController.text = widget.organName == null ? '' : widget.organName!;
  }

  Future<void> loadData() async {
    menus = await ClMenu().loadCompanyUserMenus(context, widget.companyId);

    if (widget.rankId != null) {
      RankModel rank = await ClCoupon().loadRankInfo(context, widget.rankId!);
      txtTitleController.text = rank.rankName;
      int cntPre = int.parse(rank.maxStamp) ~/ 100;
      cnt1 = '${cntPre * 100}+';
      cnt2 = (int.parse(rank.maxStamp) - (cntPre * 100)).toString();

      // ignore: use_build_context_synchronously
      prefers = await ClCoupon().loadRankPrefers(context, '', widget.rankId);
    }
    setState(() {});
  }

  Future<void> saveStamp() async {
    bool isCheck = true;
    if (txtTitleController.text == '') {
      errTitle = warningCommonInputRequire;
      isCheck = false;
    } else {
      errTitle = null;
    }

    dynamic menuParam = {};
    int ii = 0;
    for (var element in prefers) {
      ii++;
      if (element.stampCount != null && element.menuId != null) {
        menuParam[ii.toString()] = {
          'rank_prefer_id': element.rankPreferId,
          'stamp_count': element.stampCount,
          'menu_id': element.menuId,
          'is_delete': element.isDelete ? '1' : '0'
        };
      }
    }

    String maxStamp =
        (int.parse(cnt1.replaceAll('+', '')) + int.parse(cnt2)).toString();

    setState(() {});
    if (!isCheck) return;

    await ClCoupon().saveStamp(context, widget.rankId ?? '', widget.companyId,
        txtTitleController.text, maxStamp, menuParam);
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

    return PushDialogs(
      render: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const PosDlgHeaderText(label: 'スタンプ管理'),
          RowLabelInput(
              label: 'ランク名',
              labelWidth: 120,
              labelPadding: 4,
              renderWidget: TextInputNormal(
                controller: txtTitleController,
                errorText: errTitle,
              )),
          const SizedBox(height: 12),
          RowLabelInput(
              label: '最大スタンプ数',
              labelWidth: 120,
              labelPadding: 4,
              renderWidget: Row(
                children: [
                  Flexible(
                      child: DropDownNumberSelect(
                    value: cnt1,
                    min: 0,
                    max: 900,
                    diff: 100,
                    isPlusLabel: true,
                    tapFunc: (v) {
                      cnt1 = v.toString();
                    },
                  )),
                  const SizedBox(width: 8),
                  Flexible(
                      child: DropDownNumberSelect(
                    value: cnt2,
                    min: 0,
                    max: 99,
                    tapFunc: (v) {
                      cnt2 = v.toString();
                    },
                  )),
                ],
              )),
          // PosDlgInputLabelText(label: 'タイトル'),
          // TextInputNormal(controller: txtTitleController, errorText: errTitle),
          const SizedBox(height: 25),
          ...prefers.map((e) => _getPreferRow(e)),
          RowButtonGroup(widgets: [
            WhiteButton(
                label: '特典の追加',
                tapFunc: () {
                  prefers.add(RankPreferModel.fromJson({}));
                  setState(() {});
                })
          ]),
          Row(
            children: [
              Expanded(child: Container()),
              PrimaryColButton(label: '保存', tapFunc: () => saveStamp()),
              const SizedBox(width: 8),
              DeleteColButton(label: '削除', tapFunc: () => deleteRank()),
              const SizedBox(width: 8),
              CancelColButton(
                  label: '保存せず戻る', tapFunc: () => Navigator.of(context).pop()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getPreferRow(RankPreferModel item) {
    preferNo++;
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              '特典$preferNo',
              style: TextStyle(
                  color: item.isDelete ? Colors.red : Colors.black,
                  decoration: item.isDelete
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Flexible(
                child: DropDownNumberSelect(
              caption: '必要数',
              value: item.stampCount,
              min: 1,
              max: maxStampt,
              tapFunc: (v) {
                item.stampCount = v;
              },
            )),
            const SizedBox(width: 8),
            Flexible(
                flex: 2,
                child: DropDownModelSelect(
                  value: item.menuId,
                  items: [
                    ...menus.map((e) => DropdownMenuItem(
                          value: e.menuId,
                          child: Text(
                            e.menuTitle,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ))
                  ],
                  tapFunc: (v) {
                    item.menuId = v.toString();
                  },
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
                    prefers.remove(item);
                  } else {
                    item.isDelete = true;
                  }
                  setState(() {});
                },
              ),
          ],
        ));
  }
}
