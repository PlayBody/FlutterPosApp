import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/pos/sales/sumsaledetail.dart';
import 'package:staff_pos_app/src/model/ordinalsales.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';

class SumSale extends StatefulWidget {
  const SumSale({Key? key}) : super(key: key);

  @override
  _SumSale createState() => _SumSale();
}

class _SumSale extends State<SumSale> {
  late Future<List> loadData;
  DateRangePickerController _datePickerController = DateRangePickerController();
  String orderAmount = '';
  // String dateYearValue = '2020';
  // String dateMonthValue = '5';
  int _selectYear = 2021;
  int _selectMonth = 1;
  int _fromDay = 1;
  int _toDay = 1;
  String? organId;

  double chartWidth = 0;

  List<OrdinalSales> graphSaleData = [];
  List<OrdinalSales> tableSaleData = [];
  List<OrganModel> organs = [];

  @override
  void initState() {
    super.initState();
    loadData = loadSumData();
  }

  Future<List> loadSumData() async {
    organs = await ClOrgan().loadOrganList(context, '', globals.staffId);
    if (organId == null) organId = organs.first.organId;
    if (organId == null) Navigator.pop(context);

    final now = new DateTime.now();
    _selectYear = int.parse(DateFormat('yyyy').format(now));
    _selectMonth = int.parse(DateFormat('M').format(now));
    _fromDay = 1;
    _toDay = 31;

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadSumSalesUrl, {
      'organ_id': organId,
      'select_year': _selectYear.toString(),
      'select_month': _selectMonth.toString(),
      'from_day': _fromDay.toString(),
      'to_day': _toDay.toString()
    }).then((v) => {results = v});

    graphSaleData = [];
    tableSaleData = [];
    if (results['isLoaded']) {
      results['graphs'].forEach((key, element) {
        graphSaleData.add(OrdinalSales(element['yobi'], key, element['cnt'],
            element['all'], element['average']));
        if (element['cnt'] > 0) {
          tableSaleData.add(OrdinalSales(element['yobi'], key, element['cnt'],
              element['all'], element['average']));
        }
      });
    }
    chartWidth = graphSaleData.length * 40 + 250;

    setState(() {});
    return graphSaleData;
  }

  void dateMove(type) {
    int tmpYear = _selectYear;
    int tmpMonth = _selectMonth;
    if (type == 'prev') {
      if (tmpMonth <= 1) {
        tmpMonth = 12;
        tmpYear = tmpYear - 1;
      } else {
        tmpMonth = tmpMonth - 1;
      }
    }
    if (type == 'next') {
      if (tmpMonth >= 12) {
        tmpMonth = 1;
        tmpYear = tmpYear + 1;
      } else {
        tmpMonth = tmpMonth + 1;
      }
    }

    setState(() {
      _selectYear = tmpYear;
      _selectMonth = tmpMonth;
      _fromDay = 1;
      _toDay = 31;
      _datePickerController.displayDate = DateTime(_selectYear, _selectMonth);
      initView();
    });
  }

  Future<void> initView() async {
    Map<dynamic, dynamic> results = {};

    await Webservice().loadHttp(context, apiLoadSumSalesUrl, {
      'organ_id': organId,
      'select_year': _selectYear.toString(),
      'select_month': _selectMonth.toString(),
      'from_day': _fromDay.toString(),
      'to_day': _toDay.toString()
    }).then((v) => {results = v});

    setState(() {
      graphSaleData = [];
      tableSaleData = [];
      if (results['isLoaded']) {
        results['graphs'].forEach((key, element) {
          graphSaleData.add(OrdinalSales(element['yobi'], key, element['cnt'],
              element['all'], element['average']));
          if (element['cnt'] > 0) {
            tableSaleData.add(OrdinalSales(element['yobi'], key, element['cnt'],
                element['all'], element['average']));
          }
        });
      }
      chartWidth = graphSaleData.length * 40 + 250;
    });
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = '売上集計';
    return MainBodyWdiget(
        render: FutureBuilder<List>(
      future: loadData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
              color: bodyColor,
              child: SingleChildScrollView(
                  child: Center(
                child: Column(
                  children: [
                    //if (globals.auth > constAuthBoss)
                    _getOrganDropDown(),
                    _getMonthNav(),
                    _getMothCalander(),
                    _getChatArea(),
                    _getDataTable(),
                  ],
                ),
              )));
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    ));
  }

  Future<void> pushSaleDetail(e) async {
    String _dYear = _selectYear.toString();
    String _dMonth = _selectMonth < 10
        ? '0' + _selectMonth.toString()
        : _selectMonth.toString();
    String _dDay = int.parse(e.day) < 10 ? '0' + e.day : e.day;
    DateTime selectDate = DateTime.parse(_dYear + '-' + _dMonth + '-' + _dDay);
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return SumSaleDetail(
        organId: organId,
        detailDate: selectDate,
      );
    }));

    loadSumData();
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
          initView();
        },
      ),
    );
  }

  Widget _getMonthNav() {
    return Container(
      width: 300,
      padding: EdgeInsets.only(bottom: 20),
      child: Row(children: [
        TextButton(onPressed: () => dateMove('prev'), child: Text('≪')),
        Container(
          width: 150,
          child: Text(
              _selectYear.toString() + '年' + _selectMonth.toString() + '月',
              style: TextStyle(fontSize: 26),
              textAlign: TextAlign.center),
        ),
        TextButton(onPressed: () => dateMove('next'), child: Text('≫')),
      ]),
    );
  }

  Widget _getMothCalander() {
    return Container(
      width: 320,
      child: SfDateRangePicker(
        selectionMode: DateRangePickerSelectionMode.range,
        headerHeight: 0,
        monthViewSettings: DateRangePickerMonthViewSettings(
          viewHeaderStyle: DateRangePickerViewHeaderStyle(
              textStyle: TextStyle(color: Colors.blue, fontSize: 18)),
          weekendDays: [7],
        ),
        monthCellStyle: DateRangePickerMonthCellStyle(
          textStyle: TextStyle(color: Colors.black, fontSize: 18),
          weekendTextStyle: TextStyle(color: Colors.red, fontSize: 18),
        ),
        selectionTextStyle: TextStyle(color: Colors.black, fontSize: 18),
        rangeTextStyle: TextStyle(color: Colors.black, fontSize: 18),
        controller: _datePickerController,
        onSelectionChanged: (args) {
          if (args.value is PickerDateRange) {
            if (args.value.startDate != null && args.value.endDate != null) {
              _selectYear =
                  int.parse(DateFormat("yyyy").format(args.value.startDate));
              _selectMonth =
                  int.parse(DateFormat('M').format(args.value.startDate));
              _fromDay =
                  int.parse(DateFormat('d').format(args.value.startDate));
              _toDay = int.parse(DateFormat('d').format(args.value.endDate));

              initView();
            }
          }
        },
      ),
    );
  }

  Widget _getChatArea() {
    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              width: chartWidth,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<OrdinalSales, String>(
                    dataSource: graphSaleData,
                    xValueMapper: (OrdinalSales data, _) => data.dayChat,
                    yValueMapper: (OrdinalSales data, _) => data.sales,
                  ),
                  LineSeries<OrdinalSales, String>(
                    dataSource: graphSaleData,
                    xValueMapper: (OrdinalSales data, _) => data.dayChat,
                    yValueMapper: (OrdinalSales data, _) => data.average,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getDataTable() {
    return Container(
      padding: EdgeInsets.all(30),
      child: DataTable(
        columnSpacing: ((MediaQuery.of(context).size.width - 60) / 10) * 0.5,
        columns: const <DataColumn>[
          DataColumn(label: Text('集計期間')),
          DataColumn(label: Text('売上')),
          DataColumn(label: Text('客数')),
          DataColumn(label: Text('')),
        ],
        rows: [
          ...tableSaleData.map(
            (e) => DataRow(
              cells: [
                DataCell(Container(
                    width: ((MediaQuery.of(context).size.width - 60) / 10) *
                        2, //SET width
                    child: Text(_selectMonth.toString() +
                        '月' +
                        e.day.toString() +
                        '日'))),
                DataCell(Container(
                    width: ((MediaQuery.of(context).size.width - 60) / 10) * 2,
                    child: Text(e.sales.toString()))),
                DataCell(Container(
                    width: ((MediaQuery.of(context).size.width - 60) / 10) *
                        1.5, //SET width
                    child: Text(e.cnt.toString()))),
                DataCell(
                  Container(
                    width: ((MediaQuery.of(context).size.width - 60) / 10) *
                        2, //SET width
                    child: WhiteButton(
                        label: '詳細', tapFunc: () => pushSaleDetail(e)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
