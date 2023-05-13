import 'package:flutter/material.dart';
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
import 'package:staff_pos_app/src/interface/pos/manage/tickets/dlgmaster.dart';
import 'package:staff_pos_app/src/model/companymodel.dart';
import 'package:staff_pos_app/src/model/menumodel.dart';
import 'package:staff_pos_app/src/model/ticketmastermodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;

var txtAccountingController = TextEditingController();
var txtMenuCountController = TextEditingController();
var txtSetTimeController = TextEditingController();
var txtSetAmountController = TextEditingController();
var txtTableAmountController = TextEditingController();

class Masters extends StatefulWidget {
  const Masters({Key? key}) : super(key: key);

  @override
  _Masters createState() => _Masters();
}

class _Masters extends State<Masters> {
  late Future<List> loadData;
  String isAdmin = '0';
  List<MenuModel> menuList = [];
  List<CompanyModel> companyList = [];
  String selCompanyId = '';
  String selCompanyName = '';

  List<TicketMasterModel> ticketMaster = [];

  @override
  void initState() {
    super.initState();
    loadData = loadTicketData();
  }

  Future<List> loadTicketData() async {
    await loadCompanyList();
    ticketMaster.clear();
    ticketMaster = await ClTicket().loadMasterTicket(context, selCompanyId);
    setState(() {});
    return [];
  }

  Future<void> loadCompanyList() async {
    companyList.clear();
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiLoadCompanyListUrl, {}).then((v) => {results = v});
    if (results['isLoad']) {
      companyList = [];

      for (var item in results['companies']) {
        companyList.add(CompanyModel.fromJson(item));
      }
    }
    if (companyList.isNotEmpty) {
      selCompanyId = companyList.first.companyId;
      selCompanyName = companyList.first.companyName;
    }
    if (globals.auth < constAuthSystem) {
      selCompanyId = globals.companyId;
    }
    setState(() {});
  }

  Future<bool> deleteTicket(id) async {
    bool isconf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!isconf) return false;
    String apiUrl = apiBase + '/apitickets/deleteMaster';
    await Webservice().loadHttp(context, apiUrl, {'master_id': id});
    loadTicketData();
    return true;
  }

  void editTicket(id, title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DlgMaster(masterId: id, title: title, companyList: companyList, selCompanyId: selCompanyId);
        }).then((_) {
      loadTicketData();
    });
  }

  Future<void> onSelectCompany(String companyId) async {

    selCompanyId = companyId;

    Dialogs().loaderDialogNormal(context);

    ticketMaster.clear();
    ticketMaster = await ClTicket().loadMasterTicket(context, selCompanyId);

    setState(() {});

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'チケット種類';
    return MainBodyWdiget(
        render: FutureBuilder<List>(
            future: loadData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                    color: bodyColor,
                    child: Column(children: [
                      if (globals.auth > constAuthOwner)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: DropDownModelSelect(
                            contentPadding: EdgeInsets.fromLTRB(20, 7, 0, 7),
                            value: selCompanyId,
                            items: [
                              ...companyList.map((e) => DropdownMenuItem(
                                  child: Text(e.companyName), value: e.companyId))
                            ],
                            tapFunc: (v) => onSelectCompany(v.toString()),
                          ),
                        ),
                      Expanded(
                        child: _getTicketListContent(),
                      ),
                      RowButtonGroup(widgets: [
                        PrimaryButton(
                            label: '新規登録', tapFunc: () => editTicket('', ''))
                      ])
                    ]));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return Center(child: CircularProgressIndicator());
            }));
  }

  Widget _getTicketListContent() {
    return ListView(children: [
      ...ticketMaster.map((e) => Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(children: [
            Expanded(child: Text(e.ticketName, style: TextStyle(fontSize: 18))),
            SizedBox(width: 4),
            WhiteButton(
                tapFunc: () => editTicket(e.id, e.ticketName), label: '変更'),
            SizedBox(width: 4),
            DeleteColButton(tapFunc: () => deleteTicket(e.id), label: '削除')
          ])))
    ]);
  }
}
