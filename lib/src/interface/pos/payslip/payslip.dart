import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:staff_pos_app/src/common/business/point.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/model/payslip_model.dart';
import 'package:staff_pos_app/src/model/staffpointaddmodel.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/home.dart';
import 'package:open_file_safe/open_file_safe.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;

class PaySlip extends StatefulWidget {
  const PaySlip({Key? key}) : super(key: key);

  @override
  State<PaySlip> createState() => _PaySlip();
}

class _PaySlip extends State<PaySlip> {
  late Future<List> loadData;
  String orderAmount = '';
  String dateYearValue = DateTime.now().year.toString();
  String dateMonthValue = DateTime.now().month.toString();

  String company = '';
  String allWorkTime = '';
  String defualtAmount = '';
  int pointAmount = 0;
  String backAmount = '';
  int allAmount = 0;
  int averageAmount = 0;
  String staffRate = '0';
  List<StaffPointAddModel> points = [];

  bool isShowPointDetail = false;

  int sumAmount = 0;
  List<PaySlipModel> organPoints = [];
  PaySlipModel? showPoint;

  @override
  void initState() {
    super.initState();
    loadData = loadSumData();
  }

  Future<List> loadSumData() async {
    // Map<dynamic, dynamic> results = {};
    // await Webservice().loadHttp(context, apiLoadPaySlipsUrl, {
    //   'staff_id': globals.staffId,
    //   'date_month':
    //       '$dateYearValue-${int.parse(dateMonthValue) < 10 ? ('0$dateMonthValue') : dateMonthValue}'
    // }).then((value) => results = value);

    // allWorkTime =
    //     '${int.parse(results['all_time'].toString()) ~/ 60}時間 ${int.parse(results['all_time'].toString()) % 60}分';

    // staffRate = results['staff_rate'].toString();

    // defualtAmount = results['defualt_amount'].toString();
    // allAmount = defualtAmount == '0' ? 0 : int.parse(defualtAmount);
    // // pointAmount = results['point_amount'].toString();
    // // if (pointAmount != '0')

    // backAmount = results['back_amount'].toString();
    // if (backAmount != '0') allAmount += int.parse(backAmount);

    // averageAmount = (int.parse(results['all_time'].toString()) ~/ 60) == 0
    //     ? allAmount
    //     : allAmount ~/ (int.parse(results['all_time'].toString()) ~/ 60);
    // company = results['company'].toString();

    // String pointMonth =
    //     '$dateYearValue-${int.parse(dateMonthValue) < 10 ? ('0$dateMonthValue') : dateMonthValue}';

    // // ignore: use_build_context_synchronously
    // points = await ClPoint().loadStaffPoints(context, {
    //   'staff_id': globals.staffId,
    //   'point_month': pointMonth,
    //   'status': '2'
    // });

    // for (var element in points) {
    //   pointAmount += int.parse(element.value) * int.parse(element.weight);
    // }

    // allAmount += pointAmount;
    showPoint = null;
    organPoints = [];
    Map<dynamic, dynamic> results = {};
    print(apiLoadSlipsUrl);
    await Webservice().loadHttp(context, apiLoadSlipsUrl, {
      'staff_id': globals.staffId,
      'date_year': dateYearValue,
      'date_month': dateMonthValue,
      // 'date_month':
      //     '$dateYearValue-${int.parse(dateMonthValue) < 10 ? ('0$dateMonthValue') : dateMonthValue}'
    }).then((value) => results = value);
    if (results['is_load']) {
      sumAmount = results['all_amount'] == null
          ? 0
          : int.parse(results['all_amount'].toString());
      if (results['points'] != null) {
        for (var item in results['points']) {
          organPoints.add(PaySlipModel.fromJson(item));
        }
      }
    }

    if (organPoints.isNotEmpty) showPoint = organPoints.first;

    // allWorkTime =
    //     '${int.parse(results['all_time'].toString()) ~/ 60}時間 ${int.parse(results['all_time'].toString()) % 60}分';

    // staffRate = results['staff_rate'].toString();

    // defualtAmount = results['defualt_amount'].toString();
    // allAmount = defualtAmount == '0' ? 0 : int.parse(defualtAmount);
    // // pointAmount = results['point_amount'].toString();
    // // if (pointAmount != '0')

    // backAmount = results['back_amount'].toString();
    // if (backAmount != '0') allAmount += int.parse(backAmount);

    // averageAmount = (int.parse(results['all_time'].toString()) ~/ 60) == 0
    //     ? allAmount
    //     : allAmount ~/ (int.parse(results['all_time'].toString()) ~/ 60);
    // company = results['company'].toString();

    // String pointMonth =
    //     '$dateYearValue-${int.parse(dateMonthValue) < 10 ? ('0$dateMonthValue') : dateMonthValue}';

    // // ignore: use_build_context_synchronously
    // points = await ClPoint().loadStaffPoints(context, {
    //   'staff_id': globals.staffId,
    //   'point_month': pointMonth,
    //   'status': '2'
    // });

    // for (var element in points) {
    //   pointAmount += int.parse(element.value) * int.parse(element.weight);
    // }

    // allAmount += pointAmount;

    setState(() {});
    return [];
  }

  Future<void> dateMove(type) async {
    int tmpMonth = int.parse(dateMonthValue);
    int tmpYear = int.parse(dateYearValue);
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

    dateMonthValue = tmpMonth.toString();
    dateYearValue = tmpYear.toString();

    Dialogs().loaderDialogNormal(context);
    await loadSumData();
    Navigator.pop(context);
  }

  Future<File> exportPdf() async {
    PdfDocument document = PdfDocument();

    final PdfPage page = document.pages.add();

    double pt = 170;
    page.graphics.drawString(
        '2021年11月給与明細', PdfCjkStandardFont(PdfCjkFontFamily.heiseiMinchoW3, 32),
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(120, 60, 300, 50));

    page.graphics.drawString(
        '勤務時間合計', PdfCjkStandardFont(PdfCjkFontFamily.heiseiMinchoW3, 24),
        brush: PdfBrushes.black, bounds: Rect.fromLTWH(30, pt, 300, 50));

    page.graphics.drawString(
        allWorkTime, PdfCjkStandardFont(PdfCjkFontFamily.heiseiMinchoW3, 24),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(
            (460 - allWorkTime.length * 16).toDouble(), pt, 300, 50));

    pt += 80;
    page.graphics.drawString(
        '標準金額', PdfCjkStandardFont(PdfCjkFontFamily.heiseiMinchoW3, 24),
        brush: PdfBrushes.black, bounds: Rect.fromLTWH(30, pt, 300, 50));

    page.graphics.drawString(Funcs().currencyFormat(defualtAmount),
        PdfCjkStandardFont(PdfCjkFontFamily.heiseiMinchoW3, 24),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(
            (460 - defualtAmount.length * 16).toDouble(), pt, 300, 50));

    if (company != '2') {
      pt += 80;
      page.graphics.drawString(
          'バック金額', PdfCjkStandardFont(PdfCjkFontFamily.heiseiMinchoW3, 24),
          brush: PdfBrushes.black, bounds: Rect.fromLTWH(30, pt, 300, 50));

      page.graphics.drawString(Funcs().currencyFormat(backAmount),
          PdfCjkStandardFont(PdfCjkFontFamily.heiseiMinchoW3, 24),
          brush: PdfBrushes.black,
          bounds: Rect.fromLTWH(
              (460 - backAmount.length * 16).toDouble(), pt, 300, 50));
    }
    if (company == '2') {
      pt += 80;
      page.graphics.drawString(
          '獲得ポイント合計', PdfCjkStandardFont(PdfCjkFontFamily.heiseiMinchoW3, 24),
          brush: PdfBrushes.black, bounds: Rect.fromLTWH(30, pt, 300, 50));

      page.graphics.drawString(Funcs().currencyFormat(pointAmount.toString()),
          PdfCjkStandardFont(PdfCjkFontFamily.heiseiMinchoW3, 24),
          brush: PdfBrushes.black,
          bounds: Rect.fromLTWH(
              (460 - pointAmount.toString().length * 16).toDouble(),
              pt,
              300,
              50));
    }

    pt += 80;
    page.graphics.drawString(
        '予定総支給額', PdfCjkStandardFont(PdfCjkFontFamily.heiseiMinchoW3, 24),
        brush: PdfBrushes.black, bounds: Rect.fromLTWH(30, pt, 300, 50));
    page.graphics.drawString(Funcs().currencyFormat(allAmount.toString()),
        PdfCjkStandardFont(PdfCjkFontFamily.heiseiMinchoW3, 24),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(
            (460 - allAmount.toString().length * 16).toDouble(), pt, 300, 50));

    pt += 80;
    page.graphics.drawString(
        '平均時給', PdfCjkStandardFont(PdfCjkFontFamily.heiseiMinchoW3, 24),
        brush: PdfBrushes.black, bounds: Rect.fromLTWH(30, pt, 300, 50));

    page.graphics.drawString(Funcs().currencyFormat(averageAmount.toString()),
        PdfCjkStandardFont(PdfCjkFontFamily.heiseiMinchoW3, 24),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(
            (460 - averageAmount.toString().length * 16).toDouble(),
            pt,
            300,
            50));

    Directory output = await getTemporaryDirectory();
    final file = File('${output.path}/payslip.pdf');
    file.writeAsBytesSync(await document.save());
    document.dispose();
    OpenFile.open(file.path);
    // file.open(); // Page
    return file;
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = '給与明細';
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
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _getTopTitle(),
                        const SizedBox(height: 15),
                        _getAllContent('合計金額',
                            Funcs().currencyFormat(sumAmount.toString())),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                            child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.only(right: 20),
                                    alignment: Alignment.centerRight,
                                    width: 60,
                                    child: const Text(
                                      '店舗',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    )),
                                Flexible(
                                    child: DropDownModelSelect(
                                        value: showPoint,
                                        items: [
                                          ...organPoints
                                              .map((e) => DropdownMenuItem(
                                                    value: e,
                                                    child:
                                                        Text(e.organ.organName),
                                                  )),
                                        ],
                                        tapFunc: (v) {
                                          setState(() {
                                            showPoint = v;
                                          });
                                        }))
                              ],
                            )),
                        _getSumContent(
                            '月額',
                            showPoint == null
                                ? 0
                                : Funcs().currencyFormat(
                                    showPoint!.monthlyAmount.toString())),
                        _getContent(
                            '時間数',
                            showPoint == null
                                ? 0
                                : Funcs().currencyFormat(
                                    showPoint!.attendTime.toString())),
                        _getContent(
                            '施術数',
                            showPoint == null
                                ? 0
                                : Funcs().currencyFormat(
                                    showPoint!.reserveTime.toString())),
                        _getContent(
                            '追加ポイント',
                            showPoint == null
                                ? 0
                                : Funcs().currencyFormat(
                                    showPoint!.sumAddPoint.toString())),
                        ...showPoint!.addPoints.map((e) => _getContent(
                            '     ${e.comment}',
                            (int.parse(e.weight) * int.parse(e.value))
                                .toString())),
                        _getContent(
                            '施術単価',
                            showPoint == null
                                ? 0
                                : Funcs().currencyFormat(
                                    showPoint!.reserveCost.toString())),
                        _getContent('レート効果', ''),
                        _getContent(
                            '    個人レートなし',
                            showPoint == null
                                ? 0
                                : Funcs().currencyFormat(
                                    showPoint!.defualtAmount.toString())),
                        _getContent(
                            '    倍率',
                            showPoint == null
                                ? 0
                                : showPoint!.rate
                                    .toStringAsFixed(2)
                                    .toString()),
                        _getContent(
                            '時給',
                            showPoint == null
                                ? 0
                                : Funcs().currencyFormat(
                                    showPoint!.attendCost.toString())),
                      ],
                    ),
                  )),
                  _getButtons()
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _getTopTitle() {
    return Container(
      width: 300,
      padding: const EdgeInsets.only(top: 30),
      child: Row(children: [
        TextButton(onPressed: () => dateMove('prev'), child: const Text('≪')),
        SizedBox(
          width: 150,
          child: Text('$dateYearValue年$dateMonthValue月',
              style: const TextStyle(fontSize: 26),
              textAlign: TextAlign.center),
        ),
        TextButton(onPressed: () => dateMove('next'), child: const Text('≫')),
      ]),
    );
  }

  Widget _getContent(label, content, {isArrow = false}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(60, 8, 60, 0),
      child: Row(children: [
        SizedBox(
            width: 180,
            child: Text(label, style: const TextStyle(fontSize: 16))),
        if (isArrow)
          Icon(isShowPointDetail
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: Text(content, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ]),
    );
  }

  Widget _getSumContent(label, content, {isArrow = false}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 8, 60, 12),
      child: Row(children: [
        SizedBox(
            width: 180,
            child: Text(label, style: const TextStyle(fontSize: 16))),
        if (isArrow)
          Icon(isShowPointDetail
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: Text(content, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ]),
    );
  }

  Widget _getAllContent(label, content, {isArrow = false}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(140, 0, 40, 0),
      child: Row(children: [
        SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 20))),
        if (isArrow)
          Icon(isShowPointDetail
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: Text(content, style: const TextStyle(fontSize: 20)),
          ),
        ),
      ]),
    );
  }

  Widget _getButtons() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PrimaryButton(
            label: '明細をPDFで出力',
            tapFunc: () async {
              await exportPdf();
            },
          ),
          // const SizedBox(height: 12),
          // CancelButton(
          //   label: '戻る',
          //   tapFunc: () =>
          //       Navigator.push(context, MaterialPageRoute(builder: (_) {
          //     return const Home();
          //   })),
          // ),
        ],
      ),
    );
  }
}
