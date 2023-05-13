import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/interface/layout/myappbartmp.dart';
import 'package:staff_pos_app/src/interface/layout/mydrawer.dart';
import 'package:staff_pos_app/src/model/menuvariationmodel.dart';
import 'package:staff_pos_app/src/model/variationbackstaffmodel.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';

var txtAccountingController = TextEditingController();
var txtMenuCountController = TextEditingController();
var txtSetTimeController = TextEditingController();
var txtSetAmountController = TextEditingController();
var txtTableAmountController = TextEditingController();

class MenuVariation extends StatefulWidget {
  final String menuId;
  final String? variationId;
  final String? variationTitle;
  final String? variationPrice;
  final List<VariationBackStaffModel>? variationStaff;
  final String? variationAmount;

  final List<VariationBackStaffModel> vStaffList;
  const MenuVariation(
      {required this.menuId,
      required this.vStaffList,
      this.variationId,
      this.variationTitle,
      this.variationPrice,
      this.variationStaff,
      this.variationAmount,
      Key? key})
      : super(key: key);

  @override
  _MenuVariation createState() => _MenuVariation();
}

class _MenuVariation extends State<MenuVariation> {
  late Future<List> loadData;
  String? selQuantity;
  MenuVariationModel? record;

  var txtNameController = TextEditingController();
  var txtPriceController = TextEditingController();
  var txtBackAmountController = TextEditingController();
  var _items;
  var backStaffs = [];

  String title = '';
  String price = '';
  String amount = '';
  var selStaff;

  @override
  void initState() {
    txtNameController.text =
        widget.variationTitle == null ? '' : widget.variationTitle!;
    txtPriceController.text =
        widget.variationPrice == null ? '' : widget.variationPrice!;

    txtBackAmountController.text =
        widget.variationAmount == null ? '' : widget.variationAmount!;

    super.initState();
    loadData = loadVariationData();
  }

  Future<List> loadVariationData() async {
    _items = [];
    widget.vStaffList.forEach((element) {
      //print(element.toJson());
      _items.add(element.toJson());
    });
    print(_items);
    // _items = widget.vStaffList
    //     .map((e) => MultiSelectItem<VariationBackStaffModel>(e, e.backName))
    //     .toList();
    selStaff = [];
    if (widget.variationStaff != null) {
      widget.variationStaff!.forEach((element) {
        selStaff.add(element.backId);
        backStaffs.add(element.backId);
      });
    }
    setState(() {});
    return [];
  }

  Future<void> saveVariation() async {
    title = txtNameController.text;
    price = txtPriceController.text;
    amount = txtBackAmountController.text;
    bool isCheck = true;
    if (title == '') {
      isCheck = false;
    }
    if (price == '') {
      isCheck = false;
    }
    if (!isCheck) {
      Dialogs().infoDialog(context, '入力データを確認してください。');
      return;
    }
    Map<dynamic, dynamic> results = {};
    print(jsonEncode(backStaffs));
    await Webservice().loadHttp(context, apiSaveMenuVariationUrl, {
      'variation_id': widget.variationId == null ? '' : widget.variationId,
      'menu_id': widget.menuId,
      'title': title,
      'price': price,
      'staff_type': 'staff',
      'staff': backStaffs.length < 1 ? '' : jsonEncode(backStaffs),
      'amount': amount
    }).then((v) => results = v);

    if (results['isSave']) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'メニュー登録・変更';
    return Scaffold(
      appBar: MyAppBarTmp(),
      body: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _getBody();
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
      drawer: MyDrawer(),
    );
  }

  Widget _getBody() {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _getTitle(),
              _getVariationName(),
              _getVariationPrice(),
              _getVariationBackStaff(),
              _getVariationBackAmount(),
              _getButton(),
            ],
          ),
        ));
  }

  var txtDecoration = InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
    border: OutlineInputBorder(borderSide: const BorderSide()),
  );

  Widget _getTitle() {
    return Container(
        padding: EdgeInsets.only(bottom: 30),
        child: Text('バリエーション',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)));
  }

  Widget _getVariationName() {
    return Container(
        padding: EdgeInsets.only(bottom: 15),
        child: Row(
          children: <Widget>[
            Container(
              width: 100,
              child: Text('バリエーション名', style: TextStyle(fontSize: 12)),
            ),
            Flexible(
              child: TextFormField(
                controller: txtNameController,
                decoration: txtDecoration,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ));
  }

  Widget _getVariationPrice() {
    return Container(
        padding: EdgeInsets.only(bottom: 15),
        child: Row(
          children: <Widget>[
            Container(
              width: 100,
              child: Text('税抜価格', style: TextStyle(fontSize: 12)),
            ),
            Flexible(
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: txtPriceController,
                decoration: txtDecoration,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ));
  }

  Widget _getVariationBackStaff() {
    return Container(
        padding: EdgeInsets.only(bottom: 15),
        child: Row(
          children: <Widget>[
            Container(
              width: 100,
              child: Text('バックスタッフ', style: TextStyle(fontSize: 12)),
            ),
            // Flexible(
            //   child: MultiSelectDialogField(
            //     items: _items,
            //     title: Text("バックスタッフ"),
            //     selectedColor: Colors.blue,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.all(Radius.circular(5)),
            //       border: Border.all(color: Colors.black),
            //     ),
            //     // chipDisplay: MultiSelectChipDisplay.none(),
            //     initialValue: selStaff,
            //     buttonIcon: Icon(Icons.arrow_drop_down),
            //     buttonText: Text("スタッフを選択", style: TextStyle(fontSize: 14)),
            //     onConfirm: (results) {
            //       backStaffs = results;
            //       setState(() {});
            //     },
            //     onSaved: (v) {
            //       print(v);
            //     },
            //   ),
            // ),
            Flexible(
              child: MultiSelect(
                  //autovalidate: false,
                  titleText: "バックスタッフ",
                  cancelButtonText: 'キャンセル',
                  saveButtonText: '確定',
                  clearButtonText: 'クリア',
                  searchBoxHintText: '検索',
                  selectedOptionsInfoText: "選択したスタッフリスト（解除するにはタップしてください）",
                  maxLengthText: '',
                  maxLength: 10,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select one or more option(s)';
                    }
                    return null;
                  },
                  errorText: 'Please select one or more option(s)',
                  dataSource: _items,
                  textField: 'back_name',
                  valueField: 'back_id',
                  filterable: true,
                  initialValue: selStaff,
                  required: true,
                  value: null,
                  onSaved: (value) {
                    print(value);
                    if (value == null) {
                      backStaffs = [];
                      txtBackAmountController.clear();
                    } else {
                      backStaffs = value;
                    }
                    setState(() {});
                  }),
              // change: (value) {
              //   print('The selected values are $value');
              // })
            )
          ],
        ));
  }

  Widget _getVariationBackAmount() {
    return Container(
        padding: EdgeInsets.only(bottom: 15),
        child: Row(
          children: <Widget>[
            Container(
              width: 100,
              child: Text('バック金額', style: TextStyle(fontSize: 12)),
            ),
            Flexible(
              child: TextFormField(
                readOnly: backStaffs.length < 1 ? true : false,
                keyboardType: TextInputType.number,
                controller: txtBackAmountController,
                decoration: txtDecoration,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ));
  }

  Widget _getButton() {
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: Row(
        children: [
          Expanded(child: Container()),
          ElevatedButton(
              onPressed: () => saveVariation(),
              child: Text("保存", style: TextStyle(fontSize: 14))),
          Container(width: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("いいえ", style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              primary: Colors.grey,
              textStyle: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
