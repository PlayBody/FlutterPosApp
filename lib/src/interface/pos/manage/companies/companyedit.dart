import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/company.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/pos/manage/companies/dlgcompanysite.dart';
import 'package:staff_pos_app/src/interface/pos/manage/companies/stamps.dart';
import 'package:staff_pos_app/src/model/company_site_model.dart';
import 'package:staff_pos_app/src/model/companymodel.dart';
import 'package:staff_pos_app/src/model/menumodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';

class CompanyEdit extends StatefulWidget {
  final String? selComapnyId;
  const CompanyEdit({this.selComapnyId, Key? key}) : super(key: key);

  @override
  _CompanyEdit createState() => _CompanyEdit();
}

class _CompanyEdit extends State<CompanyEdit> {
  late Future<List> loadData;

  MenuModel? menu;

  String isAdmin = '0';
  List<CompanySiteModel> sites = [];

  var txtTitleController = TextEditingController();
  var txtDomainController = TextEditingController();
  var txtUrlController = TextEditingController();
  var txtReceiptNumController = TextEditingController();

  String? errTitle;
  String? errDomain;
  String? errReceiptNum;
  String? editComapnyId;
  String? cVisible;

  @override
  void initState() {
    if (widget.selComapnyId != null) editComapnyId = widget.selComapnyId;
    super.initState();
    loadData = loadFormInit();
  }

  Future<List> loadFormInit() async {
    if (this.editComapnyId == null) return [];

    CompanyModel company =
        await ClCompany().loadCompanyInfo(context, this.editComapnyId!);
    txtTitleController.text = company.companyName;
    txtDomainController.text = company.companyDomain;
    txtUrlController.text = company.ecUrl;
    txtReceiptNumController.text = company.companyReceiptNumber;
    cVisible = company.visible;

    sites = await ClCompany().loadCompanySites(context, this.editComapnyId!);
    return [];
  }

  Future<void> saveCompanyData() async {
    bool isCheck = true;
    String? errTxtTitle;
    String? errTxtDomain;

    if (txtTitleController.text == '') {
      errTxtTitle = warningCommonInputRequire;
      isCheck = false;
    }
    if (txtDomainController.text == '') {
      errTxtDomain = warningCommonInputRequire;
      isCheck = false;
    }
    if (txtReceiptNumController.text == '') {
      errReceiptNum = warningCommonInputRequire;
      isCheck = false;
    } else {
      errReceiptNum = null;
    }

    setState(() {
      errTitle = errTxtTitle;
      errDomain = errTxtDomain;
    });

    if (!isCheck) return;

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiSaveCompanyData, {
      'company_id': this.editComapnyId == null ? '' : this.editComapnyId,
      'company_name': txtTitleController.text,
      'company_domain': txtDomainController.text,
      'ec_site_url': txtUrlController.text,
      'company_receipt_number': txtReceiptNumController.text
    }).then((v) => results = v);

    if (results['isSave']) {
      setState(() {
        this.editComapnyId = results['company_id'].toString();
      });
      Dialogs().infoDialog(context, successUpdateAction);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> restoreCompany() async {
    if (this.editComapnyId == null) return;
    bool conf = await Dialogs().confirmDialog(context, '使用を回復しますか？');

    if (!conf) return;

    Dialogs().loaderDialogNormal(context);
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiDeleteCompanyData, {
      'company_id': editComapnyId,
      'is_restore': '1'
    }).then((v) => {results = v});
    Navigator.pop(context);
    if (!results['isDelete']) {
      Dialogs().infoDialog(context, errServerActionFail);
    } else {
      setState(() {
        loadData = loadFormInit();
      });
    }
  }

  Future<void> deleteCompany() async {
    if (this.editComapnyId == null) return;
    bool conf = await Dialogs().confirmDialog(context, '使用を中止しますか？');

    if (!conf) return;

    Dialogs().loaderDialogNormal(context);
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiDeleteCompanyData,
        {'company_id': editComapnyId}).then((v) => {results = v});
    Navigator.pop(context);
    if (!results['isDelete']) {
      Dialogs().infoDialog(context, errServerActionFail);
    } else {
      setState(() {
        loadData = loadFormInit();
      });
    }
  }

  Future<void> deleteSite(_id) async {
    if (this.editComapnyId == null) return;
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);

    if (!conf) return;

    Dialogs().loaderDialogNormal(context);

    await ClCompany().deleteCompanySite(context, _id);
    setState(() {
      loadData = loadFormInit();
    });
    Navigator.pop(context);
  }

  Future<void> showSiteEdit() async {
    if (this.editComapnyId == null) return;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgCompanySites(
            companyId: this.editComapnyId!,
          );
        }).then((_) {
      setState(() {
        loadData = loadFormInit();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = '会社管理';
    return MainBodyWdiget(
        render: FutureBuilder<List>(
      future: loadData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            color: bodyColor,
            child: Column(
              children: [
                _getContents(),
                SizedBox(height: 8),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    ));
  }

  Widget _getCompanyInfo() {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RowLabelInput(
            label: '会社名',
            renderWidget: TextInputNormal(
                controller: txtTitleController, errorText: errTitle),
          ),
          SizedBox(height: 12),
          RowLabelInput(
            label: 'ドメイン',
            renderWidget: TextInputNormal(
                controller: txtDomainController, errorText: errDomain),
          ),
          SizedBox(height: 12),
          RowLabelInput(
            label: '適格領収書番号',
            renderWidget: TextInputNormal(
                controller: txtReceiptNumController, errorText: errReceiptNum),
          ),
          SizedBox(height: 24),
          WhiteButton(
              label: 'ランキング管理',
              tapFunc: editComapnyId == null
                  ? null
                  : () =>
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return Stamps(companyId: editComapnyId!);
                      })))
        ],
      ),
    );
  }

  Widget _getContents() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            PageSubHeader(label: '会社情報'),
            _getCompanyInfo(),
            _getBottomButton(),
            if (globals.auth > constAuthOwner) PageSubHeader(label: 'サイト'),
            if (this.editComapnyId != null && globals.auth > constAuthOwner)
              Container(
                  padding: EdgeInsets.only(top: 12),
                  width: 150,
                  child: WhiteButton(
                      label: 'サイトの追加',
                      tapFunc: (cVisible == null || cVisible != '1')
                          ? null
                          : () => showSiteEdit())),
            if (this.editComapnyId != null && globals.auth > constAuthOwner)
              ...sites.map((e) => _getSiteItemContent(e))
          ],
        ),
      ),
    );
  }

  Widget _getSiteItemContent(e) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Row(
        children: [
          Container(
            width: 90,
            child:
                Container(child: Text(e.title, style: TextStyle(fontSize: 18))),
          ),
          Expanded(
            child:
                Container(child: Text(e.url, style: TextStyle(fontSize: 18))),
          ),
          Container(
            child: TextButton(
                child: Text('削除'), onPressed: () => deleteSite(e.siteId)),
          )
        ],
      ),
    );
  }

  Widget _getBottomButton() {
    return RowButtonGroup(widgets: [
      PrimaryButton(
          label: '保存',
          tapFunc: (cVisible == null || cVisible != '1')
              ? null
              : () => saveCompanyData()),
      SizedBox(width: 16),
      CancelButton(label: '戻る', tapFunc: () => Navigator.pop(context)),
      SizedBox(width: 16),
      if (cVisible == null || cVisible != '1')
        PrimaryButton(label: '使用回復', tapFunc: () => restoreCompany()),
      if (cVisible != null && cVisible == '1')
        DeleteButton(label: '使用中止', tapFunc: () => deleteCompany()),
    ]);
  }
}
