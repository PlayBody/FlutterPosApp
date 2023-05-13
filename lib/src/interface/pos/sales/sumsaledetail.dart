import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/pos/sales/sumsaleitemview.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/saledetailmodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';

class SumSaleDetail extends StatefulWidget {
  final String? organId;
  final DateTime detailDate;
  const SumSaleDetail({this.organId, required this.detailDate, Key? key})
      : super(key: key);

  @override
  _SumSaleDetail createState() => _SumSaleDetail();
}

class _SumSaleDetail extends State<SumSaleDetail> {
  late Future<List> loadData;
  String sumAmount = '';
  double chartWidth = 0;
  String? organId;
  List<OrganModel> organs = [];

  List<SaleDetailModel> tableSaleData = [];

  @override
  void initState() {
    super.initState();
    organId = widget.organId;
    loadData = loadSaleData();
  }

  Future<List> loadSaleData() async {
    organs = await ClOrgan().loadOrganList(context, '', globals.staffId);
    if (organId == null) organId = organs.first.organId;
    if (organId == '') {
      Navigator.pop(context);
    }

    String _dateYear = widget.detailDate.year.toString();
    String _dateMonth = widget.detailDate.month < 10
        ? '0' + widget.detailDate.month.toString()
        : widget.detailDate.month.toString();
    String _dateDay = widget.detailDate.day < 10
        ? '0' + widget.detailDate.day.toString()
        : widget.detailDate.day.toString();

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadSumSaleDetailUrl, {
      'organ_id': organId,
      'select_date': _dateYear + '-' + _dateMonth + '-' + _dateDay
    }).then((v) => {results = v});

    tableSaleData = [];
    if (results['isLoad']) {
      sumAmount = results['sum_amount'].toString();
      var i = 0;
      for (var item in results['sales']) {
        i++;
        item['user_sort'] =
            ('000' + i.toString()).substring(('000' + i.toString()).length - 3);
        tableSaleData.add(SaleDetailModel.fromJson(item));
      }
    }
    setState(() {});
    return tableSaleData;
  }

  Future<void> refreshData() async {
    String _dateYear = widget.detailDate.year.toString();
    String _dateMonth = widget.detailDate.month < 10
        ? '0' + widget.detailDate.month.toString()
        : widget.detailDate.month.toString();
    String _dateDay = widget.detailDate.day < 10
        ? '0' + widget.detailDate.day.toString()
        : widget.detailDate.day.toString();

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadSumSaleDetailUrl, {
      'organ_id': organId,
      'select_date': _dateYear + '-' + _dateMonth + '-' + _dateDay
    }).then((v) => {results = v});

    tableSaleData = [];
    if (results['isLoad']) {
      sumAmount = results['sum_amount'].toString();
      var i = 0;
      for (var item in results['sales']) {
        i++;
        item['user_sort'] =
            ('000' + i.toString()).substring(('000' + i.toString()).length - 3);
        tableSaleData.add(SaleDetailModel.fromJson(item));
      }
    }

    setState(() {});
  }

  Future<void> deleteSaleHistory(delId) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);
    if (!conf) return;
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiDeleteSumSaleUrl,
        {'order_id': delId}).then((value) => results = value);

    if (results['isDelete']) {
      loadSaleData();
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = widget.detailDate.month.toString() +
        '月' +
        widget.detailDate.day.toString() +
        '日売上詳細';
    return MainBodyWdiget(
        render: FutureBuilder<List>(
      future: loadData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            color: bodyColor,
            child: Column(
              children: [
                _getOrganDropDown(),
                Expanded(
                  child: SingleChildScrollView(child: _getDataTable()),
                ),
                _getAllAmount(),
                _getBackButton(),
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

  Widget _getOrganDropDown() {
    return Container(
      padding: EdgeInsets.fromLTRB(50, 20, 50, 10),
      child: DropDownModelSelect(
        value: organId,
        items: [
          ...organs.map((e) =>
              DropdownMenuItem(child: Text(e.organName), value: e.organId))
        ],
        tapFunc: (v) {
          organId = v.toString();
          refreshData();
        },
      ),
    );
  }

  Widget _getDataTable() {
    return Container(
        padding: EdgeInsets.all(20),
        child: DataTable(
          horizontalMargin: 5,
          columnSpacing: ((MediaQuery.of(context).size.width - 60) / 10) * 0.3,
          columns: const <DataColumn>[
            DataColumn(label: Text('来店時間')),
            DataColumn(label: Text('席No')),
            DataColumn(label: Text('売上')),
            DataColumn(label: Text('人数')),
            DataColumn(label: Text('')),
            DataColumn(label: Text('')),
          ],
          rows: [
            ...tableSaleData.map(
              (e) => DataRow(cells: [
                DataCell(Container(
                    width: ((MediaQuery.of(context).size.width - 60) / 10) *
                        1.5, //SET width
                    child: Text(e.startTime))),
                DataCell(Container(
                    width: ((MediaQuery.of(context).size.width - 60) / 10) * 1,
                    child: Text(e.position))),
                DataCell(Container(
                    width:
                        ((MediaQuery.of(context).size.width - 60) / 10) * 1.5,
                    child: Text(e.amount))),
                DataCell(Container(
                    width: ((MediaQuery.of(context).size.width - 60) / 10) *
                        1, //SET width
                    child: Text(e.personCount))),
                DataCell(Container(
                    width: ((MediaQuery.of(context).size.width - 60) / 10) *
                        2, //SET width
                    child: WhiteButton(
                      label: '詳細',
                      tapFunc: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return SumSaleItemView(
                            orderId: e.id,
                            position: e.tablePoistion,
                          );
                        }));
                      },
                    ))),
                DataCell(Container(
                    width: ((MediaQuery.of(context).size.width - 60) / 10) *
                        1, //SET width
                    child: IconWhiteButton(
                      icon: Icons.delete,
                      color: redColor,
                      tapFunc: () {
                        deleteSaleHistory(e.id);
                      },
                    ))),
              ]),
            ),
          ],
        ));
  }

  Widget _getAllAmount() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Text(
        'レジ現金残高    ￥' + Funcs().currencyFormat(sumAmount),
        style: TextStyle(fontSize: 22),
      ),
    );
  }

  Widget _getBackButton() {
    return Container(
        width: 150,
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: CancelColButton(
          label: '戻る',
          tapFunc: () {
            Navigator.pop(context);
          },
        ));
  }
}
