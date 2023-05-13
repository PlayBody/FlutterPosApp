import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/functions/pos_printers.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;

var txtAccountingController = TextEditingController();
var txtMenuCountController = TextEditingController();
var txtSetTimeController = TextEditingController();
var txtSetAmountController = TextEditingController();
var txtTableAmountController = TextEditingController();

class SettingPrinter extends StatefulWidget {
  const SettingPrinter({Key? key}) : super(key: key);

  @override
  _SettingPrinter createState() => _SettingPrinter();
}

class _SettingPrinter extends State<SettingPrinter> {
  late Future<List> loadData;
  var txtIPController = TextEditingController();
  var txtPortController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData = loadSettingData();
  }

  Future<List> loadSettingData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    txtIPController.text = prefs.getString('printer_ip') == null
        ? ''
        : prefs.getString('printer_ip')!;

    txtPortController.text = prefs.getString('printer_port') == null
        ? '9100'
        : prefs.getString('printer_port')!;

    return [];
  }

  void testPrinter() async {
    if (txtIPController.text == '') {
      Fluttertoast.showToast(msg: 'IPを設定してください');
      return;
    }

    if (txtPortController.text == '') {
      Fluttertoast.showToast(msg: 'ポートを設定してください');
      return;
    }

    await PosPrinters()
        .testPrinter(txtIPController.text, txtPortController.text);
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = '印刷設定';
    return MainBodyWdiget(
        render: Container(
      color: bodyColor,
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          _getIpContent(),
          SizedBox(height: 12),
          _getPortContent(),
          SizedBox(height: 12),
          _getTestButton()
        ],
      ),
    ));
  }

  var txtDecoration = InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.all(12),
    border: OutlineInputBorder(
      borderSide: BorderSide(width: 1),
    ),
  );
  Widget _getIpContent() {
    return RowLabelInput(
        label: 'IP',
        renderWidget: TextInputNormal(
            controller: txtIPController,
            inputType: TextInputType.numberWithOptions(decimal: true)));
  }

  Widget _getPortContent() {
    return RowLabelInput(
        label: 'Port',
        renderWidget: TextInputNormal(
            controller: txtPortController, inputType: TextInputType.number));
  }

  Widget _getTestButton() {
    return RowButtonGroup(widgets: [
      PrimaryButton(
        label: '保存する',
        tapFunc: () {
          testPrinter();
        },
      )
    ]);
  }
}
