import 'package:staff_pos_app/src/common/business/point.dart';
import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/model/organ_point_setting_model.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;

class DlgPointSubmit extends StatefulWidget {
  final String organId;
  final String pointDate;
  const DlgPointSubmit(
      {required this.organId, required this.pointDate, Key? key})
      : super(key: key);

  @override
  _DlgPointSubmit createState() => _DlgPointSubmit();
}

class _DlgPointSubmit extends State<DlgPointSubmit> {
  String points = '1';
  String? pointSettingId;

  List<OrganPointSettingModel> pointSettings = [];

  String errMsg = "";

  @override
  void initState() {
    super.initState();
    loadInit();
  }

  Future<void> loadInit() async {
    pointSettings =
        await ClPoint().loadOrganPointSettings(context, widget.organId);
    setState(() {});
  }

  Future<void> summitPoint() async {
    if (pointSettingId == null) {
      errMsg = 'ポイント種類を選択してください。';
      setState(() {});
      return;
    }

    await ClPoint().submitPoint(context, globals.staffId, widget.organId,
        widget.pointDate, pointSettingId!, points);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
        render: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      const PosDlgHeaderText(label: 'ポイント申請'),
      Text(errMsg, style: const TextStyle(color: Colors.red)),
      const SizedBox(height: 6),
      RowLabelInput(
          label: 'ポイント種類',
          renderWidget: DropDownModelSelect(
            value: pointSettingId,
            items: [
              ...pointSettings.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text(
                        '${e.title}(${constPointUnit.elementAt(e.type - 1).toString()})'),
                  ))
            ],
            tapFunc: (v) => pointSettingId = v,
          )),
      const SizedBox(height: 12),
      RowLabelInput(
          label: 'ポイント',
          renderWidget: DropDownNumberSelect(
              max: 99, value: points, tapFunc: (v) => points = v)),
      RowButtonGroup(widgets: [
        const SizedBox(width: 8),
        PrimaryColButton(label: '保存する', tapFunc: () => summitPoint()),
        const SizedBox(width: 8),
        CancelColButton(
            label: 'キャンセル', tapFunc: () => Navigator.of(context).pop())
      ]),
    ]));
  }
}
