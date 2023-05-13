import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/common.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/layout/myappbartmp.dart';
import 'package:staff_pos_app/src/model/companymodel.dart';
import '../../common/globals.dart' as globals;
import '../../http/webservice.dart';

var txtAccountingController = TextEditingController();
var txtMenuCountController = TextEditingController();
var txtSetTimeController = TextEditingController();
var txtSetAmountController = TextEditingController();
var txtTableAmountController = TextEditingController();
var txtActiveStartController = TextEditingController();
var txtActiveEndController = TextEditingController();

class AdminSettingConnectMenu extends StatefulWidget {
  const AdminSettingConnectMenu({Key? key}) : super(key: key);

  @override
  State<AdminSettingConnectMenu> createState() => _AdminSettingConnectMenu();
}

class _AdminSettingConnectMenu extends State<AdminSettingConnectMenu> {
  late Future<List> loadData;

  List<dynamic> menus = [];
  List<CompanyModel> companies = [];
  String selCompanyId = globals.companyId;

  @override
  void initState() {
    super.initState();
    loadData = loadSettingData();
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = '店舗アプリ項目の設定';
    return Scaffold(
      appBar: MyAppBarTmp(),
      body: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
                child: Column(children: [
              if (globals.auth > constAuthOwner)
                Container(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Row(children: [
                    Container(
                        padding: const EdgeInsets.only(right: 20),
                        child: const Text('企業名')),
                    Flexible(
                        child: DropdownButtonFormField(
                            isExpanded: true,
                            value: selCompanyId,
                            items: [
                              ...companies.map((e) => DropdownMenuItem(
                                  value: e.companyId,
                                  child: Text(e.companyName)))
                            ],
                            onChanged: (v) {
                              selCompanyId = v.toString();
                              setState(() {});
                              refreshLoad();
                            }))
                  ]),
                ),
              ...menus.map((e) => _settingContentRow(e)),
            ]));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return const Center(child: CircularProgressIndicator());
        },
      ),
      // drawer: MyDrawer(),
    );
  }

  Future<List> loadSettingData() async {
    if (globals.auth > constAuthOwner) {
      Map<dynamic, dynamic> companyResults = {};
      await Webservice().loadHttp(context, apiLoadCompanyListUrl, {}).then(
          (value) => companyResults = value);
      companies = [];
      if (companyResults['isLoad']) {
        for (var item in companyResults['companies']) {
          companies.add(CompanyModel.fromJson(item));
        }
        // selCompanyId = companies[0].companyId;
      }
    }
    await refreshLoad();
    return [];
  }

  Future<void> refreshLoad() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadConnectHomeMenus, {
      'company_id': selCompanyId,
      'is_admin': '1'
    }).then((v) => {results = v});
    menus = [];
    if (results['isLoad']) {
      for (var item in results['menus']) {
        menus.add({
          'setting_id': item['id'],
          'title': item['menu_name'],
          'key': item['menu_key'],
          'is_use': item['is_use']
        });
      }
    }
    setState(() {});
  }

  Future<void> saveSetting(settingId, value) async {
    Dialogs().loaderDialogNormal(context);
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiSaveConnectHomeMenus, {
      'setting_id': settingId,
      'value': value,
    }).then((v) => {results = v});

    if (!results['isSave']) {
      Dialogs().infoDialog(context, errServerActionFail);
    }
    await refreshLoad();
    Navigator.pop(context);
  }

  Future<void> updateOrder(menuId, mode) async {
    Dialogs().loaderDialogNormal(context);
    await ClCommon().updateHomeMenuOrder(context, selCompanyId, menuId, mode);

    await loadSettingData();
    Navigator.pop(context);
  }

  Widget _settingContentRow(menu) {
    return Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color.fromARGB(255, 230, 230, 230),
              width: 1,
            ),
          ),
        ),
        child: ListTile(
          trailing: SizedBox(
              width: 100,
              child: DropDownModelSelect(
                value: menu['is_use'],
                items: const [
                  DropdownMenuItem(value: '0', child: Text('使用しない')),
                  DropdownMenuItem(value: '1', child: Text('使用する')),
                  DropdownMenuItem(value: '2', child: Text('ユーザー限定')),
                ],
                tapFunc: (v) => saveSetting(menu['setting_id'], v),
              )),
          // trailing: Switch(
          //   value: menu['is_use'] == '1',
          //   onChanged: (value) {
          //     saveSetting(menu['setting_id'], value);
          //     refreshLoad();
          //   },
          //   activeTrackColor: Colors.lightGreenAccent,
          //   activeColor: Colors.green,
          // ),
          contentPadding:
              const EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 5),
          title: Row(
            children: [
              Expanded(child: Text(menu['title'])),
              IconButton(
                  onPressed: () => updateOrder(menu['setting_id'], 'down'),
                  icon: const Icon(Icons.keyboard_arrow_down)),
              IconButton(
                  onPressed: () => updateOrder(menu['setting_id'], 'up'),
                  icon: const Icon(Icons.keyboard_arrow_up))
            ],
          ),
        ));
  }
}

// class SettingContentRow extends StatelessWidget {
//   final String label;
//   final bool isSubItem;
//   final Widget trailingContent;
//   final GestureTapCallback? ontap;

//   const SettingContentRow(
//       {required this.label,
//       required this.trailingContent,
//       required this.isSubItem,
//       this.ontap,
//       Key? key})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return;
//   }
// }

class SettingFormLabel extends StatelessWidget {
  final String label;

  const SettingFormLabel({required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}
