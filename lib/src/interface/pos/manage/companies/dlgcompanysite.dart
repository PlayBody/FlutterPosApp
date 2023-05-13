import 'package:staff_pos_app/src/common/business/company.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/model/menuvariationmodel.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DlgCompanySites extends StatefulWidget {
  final String companyId;
  final String? siteId;

  const DlgCompanySites({required this.companyId, this.siteId, Key? key})
      : super(key: key);

  @override
  _DlgCompanySites createState() => _DlgCompanySites();
}

class _DlgCompanySites extends State<DlgCompanySites> {
  String? selQuantity;
  MenuVariationModel? record;

  String? testAdditionalRate;
  String? qualityAdditionalRate;

  var txtTitleController = TextEditingController();
  var txturlController = TextEditingController();
  String? errTitle;
  String? errUrl;

  @override
  void initState() {
    super.initState();
    // txtTitleController.text = widget.organName == null ? '' : widget.organName!;
  }

  Future<void> saveSite() async {
    bool isCheck = true;
    if (txtTitleController.text == '') {
      errTitle = warningCommonInputRequire;
      isCheck = false;
    } else {
      errTitle = null;
    }

    if (txtTitleController.text == '') {
      errUrl = warningCommonInputRequire;
      isCheck = false;
    } else {
      errUrl = null;
    }

    setState(() {});
    if (!isCheck) return;

    await ClCompany().saveCompanySite(context, widget.companyId, widget.siteId,
        txtTitleController.text, txturlController.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
      render: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PosDlgHeaderText(label: 'Site'),
          RowLabelInput(
              label: 'タイトル',
              labelWidth: 80,
              labelPadding: 4,
              renderWidget: TextInputNormal(
                controller: txtTitleController,
                errorText: errTitle,
              )),
          SizedBox(height: 12),
          RowLabelInput(
              label: 'URL',
              labelWidth: 80,
              labelPadding: 4,
              renderWidget: TextInputNormal(
                controller: txturlController,
                errorText: errUrl,
              )),
          // PosDlgInputLabelText(label: 'タイトル'),
          // TextInputNormal(controller: txtTitleController, errorText: errTitle),
          SizedBox(height: 25),
          Container(
            child: Row(
              children: [
                PrimaryButton(label: '保存', tapFunc: () => saveSite()),
                SizedBox(width: 8),
                CancelButton(
                    label: '保存せず戻る',
                    tapFunc: () => Navigator.of(context).pop()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
