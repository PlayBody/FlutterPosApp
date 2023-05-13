import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/business/company.dart';
import 'package:staff_pos_app/src/common/business/menu.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/pos/manage/menus/menuedit.dart';
import 'package:staff_pos_app/src/model/companymodel.dart';
import 'package:staff_pos_app/src/model/menumodel.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;

var txtAccountingController = TextEditingController();
var txtMenuCountController = TextEditingController();
var txtSetTimeController = TextEditingController();
var txtSetAmountController = TextEditingController();
var txtTableAmountController = TextEditingController();

class MenuList extends StatefulWidget {
  final String? organId;
  const MenuList({this.organId, Key? key}) : super(key: key);

  @override
  _MenuList createState() => _MenuList();
}

class _MenuList extends State<MenuList> {
  late Future<List> loadData;
  String isAdmin = '0';
  List<MenuModel> menuList = [];
  String? selOrganId;
  String? selCompanyId;

  List<OrganModel> organList = [];
  List<CompanyModel> companyList = [];

  @override
  void initState() {
    super.initState();
    selOrganId = widget.organId;
    loadData = loadInitData();
  }

  Future<List<MenuModel>> loadInitData() async {
    companyList = await ClCompany().loadCompanyList(context);
    if (selCompanyId == null) selCompanyId = companyList.first.companyId;

    if (globals.auth < constAuthSystem) selCompanyId = globals.companyId;

    organList = await ClOrgan().loadOrganList(context, selCompanyId!, '');
    organList.forEach((element) {
      print(element.organId);
    });
    menuList = await ClMenu().loadMenuList(context, {
      'company_id': selCompanyId,
      'organ_id': selOrganId == null ? '' : selOrganId
    });
    setState(() {});
    return menuList;
  }

  Future<void> refreshLoad() async {
    Dialogs().loaderDialogNormal(context);
    await loadInitData();
    Navigator.pop(context);
  }

  Future<void> exchangeMenuSort(moveId, targetId) async {
    Dialogs().loaderDialogNormal(context);
    await ClMenu().exchangeMenuSort(context, moveId, targetId);

    refreshLoad();
    Navigator.pop(context);
  }

  Future<void> onMenuEdit(String? _menuId) async {
    // globals.editMenuId = _menuId;
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return MenuEdit(
        menuId: _menuId,
        companyId: selCompanyId!,
      );
    }));
    refreshLoad();
  }

  void onOrganChange(String? _organId) {
    selOrganId = _organId;
    refreshLoad();
  }

  void onCompanyChange(String _companyId) {
    selCompanyId = _companyId;
    selOrganId = null;
    refreshLoad();
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'メニュー管理';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _getBodyContents();
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget _getBodyContents() {
    return Container(
      color: bodyColor,
      child: Column(children: [
        if (globals.auth == constAuthSystem) _getTopCompanies(),
        _getTopOrgans(),
        Expanded(
            child: SingleChildScrollView(
                child: Column(
                    children: [...menuList.map((e) => _getMenuRow(e))]))),
        RowButtonGroup(widgets: [
          PrimaryButton(label: '新規登録', tapFunc: () => onMenuEdit(null))
        ])
      ]),
    );
  }

  Widget _getTopCompanies() {
    return Container(
      padding: EdgeInsets.all(20),
      child: DropDownModelSelect(
          value: selCompanyId,
          items: [
            ...companyList.map((e) => DropdownMenuItem(
                child: Text(e.companyName), value: e.companyId))
          ],
          tapFunc: (v) => onCompanyChange(v.toString())),
    );
  }

  Widget _getTopOrgans() {
    return Container(
      padding: EdgeInsets.all(20),
      child: DropDownModelSelect(
          value: selOrganId,
          items: [
            DropdownMenuItem(child: Text('すべて'), value: null),
            ...organList.map((e) =>
                DropdownMenuItem(child: Text(e.organName), value: e.organId))
          ],
          tapFunc: (v) => onOrganChange(v)),
    );
  }

  Widget _getMenuRow(e) {
    return LongPressDraggable(
      data: e.menuId,
      child: DragTarget(
          builder: (context, candidateData, rejectedData) =>
              _getMenuRowContent(e),
          onAccept: (menuId) => exchangeMenuSort(menuId, e.menuId)),
      feedback: Container(
        color: Colors.grey.withOpacity(0.3),
        child: Text(e.menuTitle,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _getMenuRowContent(e) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 2),
        child: Row(children: [
          Expanded(
              child: Text(e.menuTitle,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          WhiteButton(tapFunc: () => onMenuEdit(e.menuId), label: '変更')
        ]));
  }
}
