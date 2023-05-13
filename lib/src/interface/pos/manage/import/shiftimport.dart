import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/business/settingshift.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:file_picker/file_picker.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;

class ShiftImport extends StatefulWidget {
  const ShiftImport({Key? key}) : super(key: key);

  @override
  _ShiftImport createState() => _ShiftImport();
}

class _ShiftImport extends State<ShiftImport> {
  late Future<List> loadData;

  String selYear = DateTime.now().year.toString();
  String? selMonth = DateTime.now().month < 10
      ? '0' + DateTime.now().month.toString()
      : DateTime.now().month.toString();
  String? selOrganId;
  String? fileName;
  int maxDay = 0;

  List<OrganModel> organList = [];

  String? filePath;

  String? dateMonth;
  bool isShiftCountTable = false;
  bool isCountImport = false;
  bool isImportLoading = false;

  @override
  void initState() {
    super.initState();

    loadData = loadSettingData();
  }

  Future<List> loadSettingData() async {
    organList = await ClOrgan().loadOrganList(context, '', globals.staffId);
    if (selOrganId == null) selOrganId = organList.first.organId;
    return [];
  }

  Future<void> importData() async {
    if (selOrganId == null) return;
    if (filePath == null) {
      Dialogs().infoDialog(context, 'ファイルを選択してください。');
      return;
    }

    bool conf = await Dialogs().confirmDialog(context, 'データを入力しますか？');
    if (!conf) return;

    setState(() {
      isImportLoading = true;
    });
    var file = filePath;
    var bytes = File(file!).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    isShiftCountTable = false;
    isCountImport = false;
    for (var table in excel.tables.keys) {
      if (table == 'コマ数原本') {
        if (excel.tables[table]!.row(0)[0] == null ||
            excel.tables[table]!.row(0)[1] == null) continue;
        isShiftCountTable = true;
        isCountImport = await importCountData(excel, table);
        // for (var row in excel.tables[table]!.rows) {}
      }
    }

    fileName = null;
    filePath = null;
    setState(() {
      isImportLoading = false;
    });

    if (isCountImport) {
      Dialogs().infoDialog(context, 'シフトフレームのインポートに成功!');
    }
    if (!isShiftCountTable) {
      Dialogs().infoDialog(context, 'データ形式が正しくありません。');
    }
  }

  Future<void> fileSelectTap() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx', 'xlsm'],
    );
    if (result == null) return;
    fileName = result.files.first.name;
    filePath = result.files.first.path;
    setState(() {});
  }

  Future<bool> importCountData(excel, table) async {
    var sheet = excel.tables[table];
    if (sheet == null) return false;

    selYear = sheet.row(0)[0]!.value.toString();
    selMonth = sheet.row(0)[1]!.value.toString();

    if (int.parse(selMonth!) < 10) selMonth = '0' + selMonth!;
    dateMonth = selYear + '-' + selMonth!;
    maxDay = Funcs().getMaxDay(selYear, selMonth);

    int maxCol = excel.tables[table]!.row(1).length;

    List<dynamic> shiftCounts = [];
    for (int i = 2; i < maxDay + 2; i++) {
      String dayStr = (((i - 1) < 10) ? '0' : '') + (i - 1).toString();

      String countValue = '';
      String fromTime = '';
      String toTime = '';
      String shiftDate = dateMonth! + '-' + dayStr;

      for (int j = 1; j < maxCol; j++) {
        String item =
            sheet.row(i)[j] == null ? '' : sheet.row(i)[j].value.toString();

        if (item != countValue) {
          String hour = sheet.row(1)[j].value.toString();
          if (int.parse(hour) < 10) hour = '0' + hour;

          if (fromTime != '') {
            toTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                .format(DateTime.parse(shiftDate + ' ' + hour + ':00:00'));

            shiftCounts.add({
              'from_time': fromTime,
              'to_time': toTime,
              'count': countValue
            });
          }
          countValue = item;
          if (item == '' || item == '0') {
            fromTime = '';
          } else {
            fromTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                .format(DateTime.parse(shiftDate + ' ' + hour + ':00:00'));
          }
        }
      }

      if (fromTime == '') continue;
      if (countValue != '' && countValue != '0') {
        int lastHour = sheet.row(1)[maxCol - 1]!.value + 1;
        String lastHourStr = '';
        if (lastHour == 24) {
          lastHourStr = '23:59:59';
        } else {
          lastHourStr =
              (lastHour < 10 ? '0' : '') + lastHourStr.toString() + ':00:00';
        }

        shiftCounts.add({
          'from_time': fromTime,
          'to_time': DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(DateTime.parse(shiftDate + ' ' + lastHourStr)),
          'count': countValue
        });
      }
    }

    bool isImport = await ClSettingShift().importShiftCount(
        context, selYear + '-' + selMonth!, selOrganId!, shiftCounts);

    return isImport;
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'シフトインポート';
    return MainBodyWdiget(
        resizeBottom: true,
        render: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _getBodyContent();
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator());
          },
        ));
  }

  Widget _getBodyContent() {
    return Container(
      color: Color(0xfffbfbfb),
      child: Column(
        children: [
          SizedBox(height: 48),
          _getOrganList(),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 60),
            child: Text(
              'シフトを入力したいExcelファイルを選択してください。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Container(
              child: WhiteButton(
                  label: 'ファイルを選択',
                  tapFunc: isImportLoading ? null : () => fileSelectTap())),
          if (fileName != null)
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(fileName!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.blue)),
            ),
          if (isImportLoading)
            Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator()),
          SizedBox(height: 64),
          RowButtonGroup(widgets: [
            SizedBox(width: 30),
            PrimaryButton(
                label: '保存する',
                tapFunc: isImportLoading ? null : () => importData()),
            SizedBox(width: 30),
          ]),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _getOrganList() {
    return Container(
      child: Row(
        children: [
          Expanded(child: Container()),
          Container(
            width: 250,
            child: DropDownModelSelect(
              value: selOrganId,
              items: [
                ...organList.map((e) => DropdownMenuItem(
                    child: Text(e.organName), value: e.organId))
              ],
              tapFunc:
                  isImportLoading ? null : (v) => selOrganId = v!.toString(),
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
