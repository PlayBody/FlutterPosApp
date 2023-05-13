import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/admin/component/adminbutton.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/admin/style/inputformfields.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';

import '../../../common/globals.dart' as globals;

class AdminCuponAdd extends StatefulWidget {
  final String? couponId;
  const AdminCuponAdd({this.couponId, Key? key}) : super(key: key);

  @override
  State<AdminCuponAdd> createState() => _AdminCuponAdd();
}

class _AdminCuponAdd extends State<AdminCuponAdd> {
  late Future<List> loadData;
  List<String> percents = [];

  String? selCouponId;
  var nameController = TextEditingController();
  var commentController = TextEditingController();
  var discountAmountController = TextEditingController();
  var codeController = TextEditingController();
  var upperController = TextEditingController();

  bool isRate = true;

  String? useDate;
  String? useDateValue;
  String? condition;
  String? discountRate;
  String? useOrgan;

  String? errName;
  String? errDate;
  String? errCondition;
  String? errOrgan;
  String? errDisCountAmount;
  String? errDisCountRate;
  String? errUpper;
  String? errCode;
  String? errComment;

  List<OrganModel> organs = [];

  @override
  void initState() {
    super.initState();
    selCouponId = widget.couponId;
    loadData = loadCouponData();
  }

  Future<List> loadCouponData() async {
    percents = [];
    for (int i = 0; i <= 100; i++) {
      percents.add(i.toString());
    }
    Map<dynamic, dynamic> organResults = {};

    await Webservice().loadHttp(context, apiLoadOrganListUrl, {
      'company_id': globals.companyId
    }).then((value) => organResults = value);

    if (organResults['isLoad']) {
      for (var item in organResults['organs']) {
        organs.add(OrganModel.fromJson(item));
      }
    }

    if (selCouponId == null) {
      setState(() {});
      return [];
    }

    Map<dynamic, dynamic> results = {};

    await Webservice().loadHttp(context, apiLoadCouponInfoUrl,
        {'coupon_id': selCouponId}).then((value) => results = value);

    if (results['isLoad']) {
      nameController.text = results['coupon']['coupon_name'];
      useDateValue = results['coupon']['use_date'];
      useDate = DateFormat('yyyy年MM月dd日')
          .format(DateTime.parse(results['coupon']['use_date']));
      condition = results['coupon']['condition'];
      useOrgan = results['coupon']['use_organ_id'];
      commentController.text = results['coupon']['comment'];
      codeController.text = results['coupon']['coupon_code'];
      discountRate = results['coupon']['discount_rate'];
      discountAmountController.text =
          results['coupon']['discount_amount'] == null
              ? ''
              : results['coupon']['discount_amount'];
      upperController.text = results['coupon']['upper_amount'] == null
          ? ''
          : results['coupon']['upper_amount'];
      isRate = results['coupon']['discount_rate'] == null;
    }
    setState(() {});

    return [];
  }

  Future<void> saveCoupon() async {
    bool isCheck = true;
    if (nameController.text == '') {
      isCheck = false;
      errName = warningCommonInputRequire;
    } else {
      errName = null;
    }
    if (useDateValue == null) {
      isCheck = false;
      errDate = warningCommonInputRequire;
    } else {
      errDate = null;
    }

    if (condition == null) {
      isCheck = false;
      errCondition = warningCommonInputRequire;
    } else {
      errCondition = null;
    }

    if (useOrgan == null) {
      isCheck = false;
      errOrgan = warningCommonInputRequire;
    } else {
      errOrgan = null;
    }
    if (commentController.text == '') {
      isCheck = false;
      errComment = warningCommonInputRequire;
    } else {
      errComment = null;
    }
    if (codeController.text == '') {
      isCheck = false;
      errCode = warningCommonInputRequire;
    } else {
      errCode = null;
    }
    if (discountRate == null && discountAmountController.text == '') {
      isCheck = false;
      errDisCountAmount = warningCommonInputRequire;
      errDisCountRate = warningCommonInputRequire;
    } else {
      errDisCountAmount = null;
      errDisCountRate = null;
    }

    if (!isRate && upperController.text == '') {
      errUpper = warningCommonInputRequire;
      isCheck = false;
    } else {
      errUpper = null;
    }

    setState(() {});

    if (!isCheck) return;

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiSaveCouponUrl, {
      'company_id': globals.companyId,
      'coupon_id': selCouponId == null ? '' : selCouponId,
      'coupon_name': nameController.text,
      'coupon_code': codeController.text,
      'discount_rate': discountRate == null ? '' : discountRate,
      'discount_amount': discountAmountController.text,
      'upper_amount': upperController.text,
      'use_date': useDateValue,
      'condition': condition,
      'staff_id': globals.staffId,
      'use_organ': useOrgan,
      'comment': commentController.text
    }).then((value) => results = value);

    if (results['isSave']) {
      selCouponId = results['coupon_id'].toString();
      Navigator.pop(context);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'クーポン登録';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: bodyColor,
              padding: paddingMainContent,
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdminInputFormField(
                    hintText: 'クーポン名',
                    txtController: nameController,
                    errorText: errName,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: DropdownButtonFormField(
                      value: discountRate,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: '割引率（％）',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          )),
                      items: [
                        ...percents.map((e) => DropdownMenuItem(
                              value: e,
                              child: Text('$e%'),
                            ))
                      ],
                      onChanged: (v) {
                        setState(() {
                          isRate = v == null;
                          if (isRate) discountAmountController.text = '';
                        });
                        discountRate = v.toString();
                      },
                    ),
                  ),
                  if (errDisCountRate != null)
                    Text(
                      errDisCountRate!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 14),
                    ),
                  if (!isRate)
                    Container(
                        padding: const EdgeInsets.only(top: 20),
                        child: AdminInputFormField(
                          hintText: '上限金額(円）',
                          txtController: upperController,
                          errorText: errUpper,
                        )),
                  if (isRate)
                    Container(
                        padding: const EdgeInsets.only(top: 20),
                        child: AdminInputFormField(
                          hintText: '割引(円）',
                          txtController: discountAmountController,
                          errorText: errDisCountAmount,
                        )),
                  Container(
                      padding: EdgeInsets.only(top: 20),
                      child: GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(useDate == null ? '有効期限' : useDate!),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey)),
                        ),
                        onTap: () {
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              currentTime: useDate == null
                                  ? DateTime.now()
                                  : DateTime.parse(useDateValue!),
                              minTime: DateTime(2021, 1, 1),
                              maxTime: DateTime(2050, 12, 31),
                              onConfirm: (date) {
                            setState(() {
                              useDate = date.year.toString() +
                                  '年' +
                                  date.month.toString() +
                                  '月' +
                                  date.day.toString() +
                                  '日';
                              useDateValue =
                                  DateFormat('yyyy-MM-dd').format(date);
                            });
                          }, locale: LocaleType.jp);
                        },
                      )),
                  if (errDate != null)
                    Container(
                      child: Text(
                        errDate!,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    ),
                  Container(
                      padding: EdgeInsets.only(top: 20),
                      child: DropdownButtonFormField(
                        value: condition,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            hintText: '条件',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            )),
                        items: [
                          ...constCouponCondition.map((e) => DropdownMenuItem(
                                child: Text(e['val']),
                                value: e['key'],
                              ))
                        ],
                        onChanged: (v) {
                          condition = v.toString();
                        },
                      )),
                  if (errCondition != null)
                    Container(
                      child: Text(
                        errCondition!,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    ),
                  Container(
                      padding: EdgeInsets.only(top: 20),
                      child: DropdownButtonFormField(
                        value: useOrgan,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            hintText: '使用可能店舗',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            )),
                        items: [
                          DropdownMenuItem(
                            child: Text('すべて'),
                            value: '0',
                          ),
                          ...organs.map((e) => DropdownMenuItem(
                                child: Text(e.organName),
                                value: e.organId,
                              ))
                        ],
                        onChanged: (v) {
                          useOrgan = v.toString();
                        },
                      )),
                  if (errOrgan != null)
                    Container(
                      child: Text(
                        errOrgan!,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    ),
                  Container(
                      padding: EdgeInsets.only(top: 20),
                      child: AdminInputFormField(
                        hintText: 'クーポンコード',
                        txtController: codeController,
                        errorText: errCode,
                      )),
                  Container(
                      padding: EdgeInsets.only(top: 20),
                      child: AdminInputFormField(
                        hintText: 'その他・備考',
                        txtController: commentController,
                        maxLine: 5,
                        errorText: errComment,
                      )),
                  SizedBox(height: 12),
                  AdminPrimaryBtn(label: '作成', tapFunc: () => saveCoupon())
                ],
              )),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
