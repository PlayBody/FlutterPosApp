import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/pos/manage/companies/companyedit.dart';
import 'package:staff_pos_app/src/model/companymodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';

var txtAccountingController = TextEditingController();
var txtMenuCountController = TextEditingController();
var txtSetTimeController = TextEditingController();
var txtSetAmountController = TextEditingController();
var txtTableAmountController = TextEditingController();

class Companies extends StatefulWidget {
  const Companies({Key? key}) : super(key: key);

  @override
  _Companies createState() => _Companies();
}

class _Companies extends State<Companies> {
  late Future<List> loadData;
  List<CompanyModel> companyList = [];

  @override
  void initState() {
    super.initState();
    loadData = loadCompanyList();
  }

  Future<List> loadCompanyList() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiLoadCompanyListUrl, {}).then((v) => {results = v});
    if (results['isLoad']) {
      companyList = [];

      for (var item in results['companies']) {
        companyList.add(CompanyModel.fromJson(item));
      }
    }
    setState(() {});
    return companyList;
  }

  Future<void> deleteOrgan(_id) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);

    if (!conf) return;

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiDeleteOrganUrl,
        {'organ_id': _id}).then((v) => {results = v});
    if (!results['isDelete']) {
      Dialogs().infoDialog(context, errServerActionFail);
    }
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
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                        child: Scrollbar(
                      child: ListView(
                        children: [
                          ...companyList.map(
                            (e) => Container(
                                decoration: BoxDecoration(
                                  color: (e.visible == '1')
                                      ? Colors.white
                                      : Colors.grey.withOpacity(0.4),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromARGB(255, 230, 230, 230),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                padding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      e.companyName,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )),
                                    WhiteButton(
                                        label: '変更',
                                        tapFunc: () async {
                                          await Navigator.push(context,
                                              MaterialPageRoute(builder: (_) {
                                            return CompanyEdit(
                                              selComapnyId: e.companyId,
                                            );
                                          }));
                                          loadCompanyList();
                                        }),
                                    // Container(width: 5),
                                    // ElevatedButton(
                                    //   onPressed: () {
                                    //     deleteOrgan(e.organId);
                                    //   },
                                    //   child: Text('削除'),
                                    //   style: deleteButtonStyle,
                                    // )
                                  ],
                                )),
                          )
                        ],
                      ),
                    )),
                    Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                        child: Row(children: [
                          PrimaryButton(
                            label: '新規登録',
                            tapFunc: () async {
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return CompanyEdit();
                              }));
                              loadCompanyList();
                            },
                          )
                        ]))
                  ],
                ));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //     Navigator.push(context, MaterialPageRoute(builder: (_) {
      //       return CompanyEdit();
      //     }));
      //   },
      // ),
    );
  }

}
