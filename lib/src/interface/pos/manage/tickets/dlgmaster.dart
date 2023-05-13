import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/http/webservice.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/model/companymodel.dart';

import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;

class DlgMaster extends StatefulWidget {
  final String masterId;
  final String title;
  final List<CompanyModel> companyList;
  final String selCompanyId;
  const DlgMaster({required this.masterId, required this.title, required this.companyList, required this.selCompanyId, Key? key})
      : super(key: key);

  @override
  _DlgMaster createState() => _DlgMaster();
}

class _DlgMaster extends State<DlgMaster> {
  var txtTitleController = TextEditingController();
  String selectedCompanyId = '';
  @override
  void initState() {
    super.initState();
    selectedCompanyId = widget.selCompanyId;
    loadInit();
  }

  Future<void> loadInit() async {
    txtTitleController.text = widget.title;
    setState(() {});
  }

  Future<void> saveMaster() async {
    if (globals.auth < constAuthSystem) {
      selectedCompanyId = globals.companyId;
    }
    String apiUrl = apiBase + '/apitickets/updateMaster';
    await Webservice().loadHttp(context, apiUrl, {
      'master_id': widget.masterId,
      'title': txtTitleController.text,
      'company_id': selectedCompanyId
    });
    // if (results['isSave']) {
    Navigator.pop(context);
    // } else {
    //   Dialogs().infoDialog(context, errServerActionFail);
    // }
  }

  Future<void> onSelectCompany(String companyId) async {

    selectedCompanyId = companyId;

    Dialogs().loaderDialogNormal(context);

    setState(() {});

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
      render: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const PosDlgHeaderText(label: 'チケット種類'),
          if (globals.auth > constAuthOwner)
            Padding(
              padding: const EdgeInsets.all(5),
              child: DropDownModelSelect(
                contentPadding: const EdgeInsets.fromLTRB(20, 7, 0, 7),
                value: selectedCompanyId,
                items: [
                  ...widget.companyList.map((e) => DropdownMenuItem(
                      child: Text(e.companyName), value: e.companyId))
                ],
                tapFunc: (v) => onSelectCompany(v.toString()),
              ),
            ),
          RowLabelInput(
              label: 'チケット名',
              renderWidget: TextInputNormal(controller: txtTitleController)),
          RowButtonGroup(widgets: [
            const SizedBox(width: 8),
            PrimaryColButton(label: '保存する', tapFunc: () => saveMaster()),
            const SizedBox(width: 8),
            CancelColButton(
                label: 'キャンセル', tapFunc: () => Navigator.of(context).pop())
          ]),
        ],
      ),
    );
  }
}
