import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/menu.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/checkboxs.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/components/textformfields.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/pos/manage/menus/menuvariation.dart';
import 'package:staff_pos_app/src/interface/style/textstyles.dart';
import 'package:staff_pos_app/src/model/menumodel.dart';
import 'package:staff_pos_app/src/model/menuvariationmodel.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/variationbackstaffmodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';

// var txtAccountingController = TextEditingController();
// var txtMenuCountController = TextEditingController();
// var txtSetTimeController = TextEditingController();
// var txtSetAmountController = TextEditingController();
// var txtTableAmountController = TextEditingController();

class MenuEdit extends StatefulWidget {
  final String companyId;
  final String? menuId;
  const MenuEdit({required this.companyId, this.menuId, Key? key})
      : super(key: key);

  @override
  _MenuEdit createState() => _MenuEdit();
}

class _MenuEdit extends State<MenuEdit> {
  late Future<List> loadData;

  MenuModel? menu;

  String isAdmin = '0';
  List<MenuVariationModel> variationList = [];
  List<MenuModel> menuList = [];
  List<VariationBackStaffModel> vStaffList = [];

  var txtTitleController = TextEditingController();
  var txtDetailController = TextEditingController();
  var txtPriceController = TextEditingController();
  var txtStockController = TextEditingController();
  var txtCostController = TextEditingController();
  var txtTaxController = TextEditingController();
  var txtCommentController = TextEditingController();
  bool isUserMenu = false;
  bool isGoods = false;
  String? menuTime;
  String? menuInterval;

  String? errTitle;
  String? errDetail;
  String? errPrice;
  String? errStock;
  String? errCost;
  String? errTax;
  String? errComment;
  String? menuImage;

  bool isphoto = false;
  late File _photoFile;
  String? editMenuId;

  List<OrganModel> organList = [];

  bool isAllOrgan = false;
  List<String> menuOrgans = [];

  bool isStockInfinity = false;

  @override
  void initState() {
    super.initState();
    editMenuId = widget.menuId;
    loadData = loadMenuData();
  }

  Future<List> loadMenuData() async {
    organList = await ClOrgan().loadOrganList(context, widget.companyId, '');
    if (editMenuId == null) {
      return [];
    }

    MenuModel? menu = await ClMenu().loadMenuInfo(context, editMenuId);

    if (menu != null) {
      txtTitleController.text = menu.menuTitle;
      txtDetailController.text = menu.menuDetail;
      txtPriceController.text = menu.menuPrice;
      txtStockController.text =
          int.parse(menu.menuStock) < 0 ? '無限' : menu.menuStock;
      txtCostController.text = menu.menuCost;
      txtTaxController.text = menu.menuTax;
      txtCommentController.text = menu.menuComment;
      isStockInfinity = int.parse(menu.menuStock) < 0 ? true : false;
      isUserMenu = menu.isUserMenu;
      isGoods = menu.isGoods;
      menuTime = menu.menuTime;
      menuInterval = menu.menuInterval;

      menuImage = menu.image;

      menuOrgans =
          await ClMenu().loadMenuOrgans(context, {'menu_id': editMenuId});

      vStaffList = await ClMenu().loadBackStaffs(context, widget.companyId);
      // for (var item in results['staffs']) {
      //   vStaffList.add(VariationBackStaffModel(
      //       backId: item['staff_id'],
      //       backName: item['staff_nick'] == null
      //           ? item['staff_first_name'] + '　' + item['staff_last_name']
      //           : item['staff_nick'],
      //       type: 'staff'));
      // }

      variationList = await ClMenu().loadVariations(context, editMenuId);
    }

    setState(() {});

    return [];
  }

  Future<void> saveMenuData() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    bool isCheck = true;
    String? errTxtTitle;
    String? errTxtPrice;
    String? errTxtCost;
    String? errTxtTax;

    if (txtTitleController.text == '') {
      errTxtTitle = warningCommonInputRequire;
      isCheck = false;
    }
    if (txtPriceController.text == '') {
      errTxtPrice = warningCommonInputRequire;
      isCheck = false;
    }
    // if (txtCostController.text == '') {
    //   errTxtCost = warningCommonInputRequire;
    //   isCheck = false;
    // }
    // if (txtTaxController.text == '') {
    //   errTxtTax = warningCommonInputRequire;
    //   isCheck = false;
    // }

    setState(() {
      errTitle = errTxtTitle;
      errPrice = errTxtPrice;
      errCost = errTxtCost;
      errTax = errTxtTax;
    });

    if (!isCheck) return;

    Dialogs().loaderDialogNormal(context);

    String imagename = '';
    if (isphoto) {
      if (isphoto) {
        imagename = 'menus-' +
            DateTime.now()
                .toString()
                .replaceAll(':', '')
                .replaceAll('-', '')
                .replaceAll('.', '')
                .replaceAll(' ', '') +
            '.jpg';
        await Webservice().callHttpMultiPart(
            'picture', apiUploadMenuPhoto, _photoFile.path, imagename);
      }
      print(imagename);
    }

    String saveMenuId = await ClMenu().saveMenu(context, {
      'company_id': widget.companyId,
      'menu_id': editMenuId == null ? '' : editMenuId,
      'title': txtTitleController.text,
      'detail': txtDetailController.text,
      'price': txtPriceController.text,
      'stock': isStockInfinity ? '-1' : txtStockController.text,
      'comment': txtCommentController.text,
      'is_user_menu': isUserMenu ? '1' : '',
      'is_goods': isGoods ? '1' : '0',
      'menu_time': (!isUserMenu || menuTime == null) ? '' : menuTime,
      'menu_interval': (!isUserMenu) ? '' : menuInterval,
      'image': imagename,
      'menu_organs': jsonEncode(menuOrgans)
    });
    print(jsonEncode(menuOrgans));
    Navigator.pop(context);
    if (saveMenuId == '') {
      Dialogs().infoDialog(context, errServerActionFail);
    } else {
      editMenuId = saveMenuId;
      loadData = loadMenuData();
    }
  }

  Future<void> deleteMenuData() async {
    print('asdf');
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);

    if (!conf) return;

    Dialogs().loaderDialogNormal(context);
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiDeleteMenuUrl,
        {'menu_id': widget.menuId}).then((v) => results = v);

    Navigator.pop(context);
    if (results['isDelete']) {
      Navigator.pop(context);
    }
  }

  Future<void> deleteVariation(String _id) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);

    if (!conf) return;

    Dialogs().loaderDialogNormal(context);
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiDeleteMenuVariationUrl,
        {'variation_id': _id}).then((v) => results = v);

    Navigator.pop(context);
    if (results['isDelete']) {
      setState(() {
        loadData = loadMenuData();
      });
    }
  }

  Future<void> variationEdit(MenuVariationModel? item) async {
    if (item == null) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) {
        return MenuVariation(
          menuId: editMenuId!,
          vStaffList: vStaffList,
        );
      }));
    } else {
      await Navigator.push(context, MaterialPageRoute(builder: (_) {
        return MenuVariation(
          menuId: widget.menuId!,
          vStaffList: vStaffList,
          variationId: item.variationId,
          variationTitle: item.variationTitle,
          variationPrice: item.variationPrice,
          variationStaff: item.backs,
          variationAmount:
              item.variationAmount == null ? '' : item.variationAmount,
        );
      }));
    }
    loadMenuData();
  }

  void onChangeOrganAll() {
    menuOrgans = [];
    isAllOrgan = !isAllOrgan;
    if (isAllOrgan) {
      organList.forEach((element) {
        menuOrgans.add(element.organId);
      });
    }
    setState(() {});
  }

  void onChangeMenuOrgan(v, _organId) {
    print(menuOrgans);
    if (menuOrgans.contains(_organId)) {
      menuOrgans.remove(_organId);
    } else {
      menuOrgans.add(_organId);
    }
    print(menuOrgans);
    isAllOrgan = true;
    organList.forEach((element) {
      if (!menuOrgans.contains(element.organId)) {
        isAllOrgan = false;
      }
    });
    setState(() {});
  }

  _getFromPhoto(int _libType) async {
    XFile? image;

    if (_libType == 1) {
      image = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker().pickImage(source: ImageSource.gallery);
    }

    final path = image!.path;
    setState(() {
      isphoto = true;
      _photoFile = File(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'メニュー';
    return MainBodyWdiget(
        render: FutureBuilder<List>(
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
    ));
  }

  Widget _getBody() {
    return Container(
      color: bodyColor,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _getMenuContent(),
                  _getVariationHeader(),
                  ...variationList.map(
                    (e) => MenuEditVariationTile(
                      item: e,
                      editFunc: () => variationEdit(e),
                      delFunc: () {
                        setState(() {
                          deleteVariation(e.variationId);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          _getBottomButton()
        ],
      ),
    );
  }

  Widget _getMenuContent() {
    return Container(
      padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
      child: Column(
        children: [
          _getAvatarContent(),
          SizedBox(height: 12),
          RowLabelInput(
              label: 'メニュー名',
              renderWidget: TextInputNormal(
                  multiLine: 2,
                  controller: txtTitleController,
                  errorText: errTitle)),
          SizedBox(height: 8),
          RowLabelInput(
              label: 'メニュー詳細 ',
              labelPadding: 4,
              renderWidget: TextInputNormal(
                  multiLine: 5,
                  controller: txtDetailController,
                  errorText: errDetail)),
          SizedBox(height: 8),
          RowLabelInput(
              label: '税抜価格',
              renderWidget: TextInputNormal(
                  controller: txtPriceController,
                  errorText: errPrice,
                  inputType: TextInputType.number)),
          RowLabelInput(
              label: '在庫',
              renderWidget: Row(children: [
                Flexible(
                    child: TextInputNormal(
                  controller: txtStockController,
                  errorText: errStock,
                  inputType: TextInputType.number,
                  isEnable: !isStockInfinity,
                )),
                SizedBox(width: 24),
                InputLeftText(label: '無限大', rPadding: 4, width: 50),
                CheckNomal(
                  label: '',
                  value: isStockInfinity,
                  scale: 1.5,
                  tapFunc: (v) {
                    isStockInfinity = v;
                    setState(() {});
                  },
                ),
              ])),
          SizedBox(height: 8),
          RowLabelInput(
              label: 'ユーザーメニュー',
              renderWidget: Row(children: [
                CheckNomal(
                  label: '',
                  value: isUserMenu,
                  scale: 1.5,
                  tapFunc: (v) {
                    isUserMenu = v;
                    if (isUserMenu && menuInterval == null) menuInterval = '15';
                    setState(() {});
                  },
                ),
                SizedBox(width: 24),
                InputLeftText(label: '時間', rPadding: 4, width: 50),
                Flexible(
                    child: DropDownNumberSelect(
                        value: menuTime,
                        min: 0,
                        max: 360,
                        diff: 5,
                        tapFunc: isUserMenu
                            ? (v) {
                                menuTime = v;
                                setState(() {});
                              }
                            : null)),
                SizedBox(width: 4),
                Text('分', style: bodyTextStyle)
              ])),
          SizedBox(height: 12),
          RowLabelInput(
              label: '',
              renderWidget: Row(children: [
                Expanded(child: Container()),
                InputLeftText(label: 'インターバル', rPadding: 4, width: 50),
                Flexible(
                    child: DropDownNumberSelect(
                        value: menuInterval,
                        min: 0,
                        max: 360,
                        diff: 5,
                        tapFunc: isUserMenu
                            ? (v) {
                                menuInterval = v;
                                setState(() {});
                              }
                            : null)),
                SizedBox(width: 4),
                Text('分', style: bodyTextStyle)
              ])),
          SizedBox(height: 8),
          RowLabelInput(
            label: '物販',
            renderWidget: CheckNomal(
              label: '',
              value: isGoods,
              scale: 1.5,
              tapFunc: (v) {
                isGoods = v;

                setState(() {});
              },
            ),
          ),
          SizedBox(height: 8),
          RowLabelInput(
              labelWidth: 60,
              isLabelTop: true,
              label: '\n対象店舗',
              labelPadding: 4,
              renderWidget: _getMenuOrgans()),
        ],
      ),
    );
  }

  Widget _getMenuOrgans() {
    return Container(
        child: Column(
      children: [
        CheckNomal(
          label: '全店舗選択',
          value: isAllOrgan,
          scale: 1.0,
          tapFunc: (v) => onChangeOrganAll(),
        ),
        ...organList.map((e) => Container(
            margin: EdgeInsets.only(left: 20),
            child: CheckNomal(
              label: e.organName,
              value: menuOrgans.contains(e.organId),
              scale: 1.0,
              tapFunc: (v) => onChangeMenuOrgan(v.toString(), e.organId),
            )))
      ],
    ));
  }

  Widget _getAvatarContent() {
    return Container(
        child: Column(children: [
      Container(
        height: 120,
        child: isphoto
            ? Image.file(_photoFile)
            : menuImage == null
                ? Image.asset('images/no_image.jpg')
                : Image.network(menuImageUrl + menuImage!),
      ),
      Container(
          padding: EdgeInsets.only(right: 30),
          alignment: Alignment.topRight,
          child: DropdownButton(
              items: [
                DropdownMenuItem(child: Text("カメラ撮る"), value: 1),
                DropdownMenuItem(child: Text("アルバム"), value: 2)
              ],
              onChanged: (int? v) {
                if (v == 1 || v == 2) {
                  _getFromPhoto(v!);
                }
              },
              hint: Text("画像変更")))
    ]));
  }

  Widget _getVariationHeader() {
    if (editMenuId == null || variationList.length >= 15) {
      return Container();
    } else {
      return Container(
        child: Row(
          children: [
            Container(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Text('バリエーション')),
            WhiteButton(tapFunc: () => variationEdit(null), label: '追加')
          ],
        ),
      );
    }
  }

  Widget _getBottomButton() {
    return RowButtonGroup(
      widgets: [
        PrimaryButton(label: '保存', tapFunc: () => saveMenuData()),
        SizedBox(width: 8),
        CancelButton(label: '戻る', tapFunc: () => Navigator.pop(context)),
        SizedBox(width: 8),
        DeleteButton(
            label: '削除',
            tapFunc: editMenuId == null ? null : () => deleteMenuData()),
      ],
    );
  }
}

class MenuEditVariationTile extends StatelessWidget {
  final MenuVariationModel item;
  final editFunc;
  final delFunc;
  const MenuEditVariationTile(
      {required this.item,
      required this.editFunc,
      required this.delFunc,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
        color: Color.fromARGB(255, 220, 220, 220),
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.only(bottom: 15),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text('バリエーション名', style: TextStyle(fontSize: 12)),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 30),
                      child: Text(item.variationTitle),
                    ),
                  ],
                )),
            Container(
                padding: EdgeInsets.only(bottom: 15),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text('税抜価格', style: TextStyle(fontSize: 12)),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 30),
                      child: Text(item.variationPrice),
                    ),
                  ],
                )),
            Container(
                padding: EdgeInsets.only(bottom: 15),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text('バックスタッフ', style: TextStyle(fontSize: 12)),
                    ),
                    SizedBox(width: 30),
                    Flexible(
                      // padding: EdgeInsets.only(left: 30),
                      child: Column(children: [
                        item.staffName == null
                            ? Text('')
                            : Text(item.staffName!)
                      ]),
                    ),
                  ],
                )),
            Container(
                padding: EdgeInsets.only(bottom: 15),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text('バック金額', style: TextStyle(fontSize: 12)),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 30),
                      child: Text(item.variationAmount!),
                    ),
                  ],
                )),
            RowButtonGroup(bgColor: Colors.transparent, widgets: [
              Expanded(child: Container()),
              PrimaryButton(
                label: '変更',
                tapFunc: editFunc,
              ),
              SizedBox(width: 8),
              DeleteButton(
                label: '削除',
                tapFunc: delFunc,
              )
            ])
          ],
        ),
      ),
    );
  }
}
