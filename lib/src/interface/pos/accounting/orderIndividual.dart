import 'package:flutter/material.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/interface/layout/myappbar.dart';
import 'package:staff_pos_app/src/interface/layout/mydrawer.dart';
import 'package:staff_pos_app/src/interface/layout/subbottomnavi.dart';
import 'package:staff_pos_app/src/model/order_menu_model.dart';
import '../../../common/dialogs.dart';
import '../../../common/globals.dart' as globals;

var txtIndividualAmountController = TextEditingController();
bool isMinus = false;
String? orderIndividualAmount;

class OrderIndividual extends StatefulWidget {
  const OrderIndividual({Key? key}) : super(key: key);

  @override
  _OrderIndividual createState() => _OrderIndividual();
}

class _OrderIndividual extends State<OrderIndividual> {
  late Future<List> loadData;
  String? selQuantity;
  String? menuTitle;

  List<String> numItems = [
    '7',
    '8',
    '9',
    '4',
    '5',
    '6',
    '1',
    '2',
    '3',
    '+/-',
    '0',
    'C',
  ];

  @override
  void initState() {
    super.initState();
    globals.orderQuantity = '数量';
    orderIndividualAmount = '0';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: MyAppBar(),
        body: OrientationBuilder(builder: (context, orientation) {
          return SingleChildScrollView(
              child: Center(
                  child: Container(
            padding: globals.isWideScreen
                ? EdgeInsets.only(
                    left: 120,
                    right: 120,
                    top: orientation == Orientation.portrait ? 40 : 10)
                : EdgeInsets.all(0),
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 30),
                alignment: Alignment.centerLeft,
                child: Text(
                  'メニュー名',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: globals.isWideScreen ? 24 : 16),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: new Theme(
                    data: new ThemeData(
                      primaryColor: Colors.grey,
                    ),
                    child: TextFormField(
                      onChanged: (val) {
                        this.menuTitle = val;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide.none),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'メニュー名',
                        // border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                      ),
                      style:
                          TextStyle(fontSize: globals.isWideScreen ? 24 : 16),
                    )),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
                child: new Theme(
                    data: new ThemeData(
                      primaryColor: Colors.grey,
                    ),
                    child: TextField(
                      controller: txtIndividualAmountController,
                      textAlign: TextAlign.right,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(0),
                      ),
                      style: TextStyle(
                          fontSize: globals.isWideScreen ? 52 : 42,
                          color: Color(0xff0a2364),
                          fontWeight: FontWeight.bold),
                    )),
              ),
              if (orientation == Orientation.portrait || !globals.isWideScreen)
                GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(30, 10, 30, 30),
                    crossAxisCount: 3,
                    crossAxisSpacing: globals.isWideScreen ? 50 : 20,
                    mainAxisSpacing: globals.isWideScreen ? 40 : 20,
                    childAspectRatio: 1.4,
                    children: [...numItems.map((num) => NumberPad(num: num))]),
              if (orientation == Orientation.portrait)
                Container(
                    padding: globals.isWideScreen
                        ? EdgeInsets.only(left: 60, right: 60)
                        : EdgeInsets.only(left: 30, right: 30),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 5),
                          width: 120,
                          child: NumberInputPrefabbed.roundedButtons(
                            style: TextStyle(
                              color: Color(0xff465886),
                              fontSize: 32,
                            ),
                            numberFieldDecoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.only(top: 8, bottom: 8)),
                            min: 1,
                            max: 10,
                            incIconSize: 18,
                            decIconSize: 18,
                            incIcon: Icons.add,
                            decIcon: Icons.remove,
                            controller: TextEditingController(),
                            incDecBgColor: Color(0xffe0e0e0),
                            buttonArrangement: ButtonArrangement.rightEnd,
                            onIncrement: (v) {
                              selQuantity = v.toString();
                            },
                            onDecrement: (v) {
                              selQuantity = v.toString();
                            },
                            onChanged: (v) {
                              selQuantity = v.toString();
                            },
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        Container(width: 12),
                        Expanded(
                            child: ElevatedButton(
                          child: Text('入力完了'),
                          onPressed: () => orderAdd(),
                          style: ElevatedButton.styleFrom(
                              primary: Color(0xff117fc1),
                              padding: EdgeInsets.all(16),
                              textStyle: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ))
                      ],
                    )),
              if (orientation == Orientation.landscape && globals.isWideScreen)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                        child: GridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.fromLTRB(30, 10, 30, 30),
                            crossAxisCount: 3,
                            crossAxisSpacing: globals.isWideScreen ? 50 : 20,
                            mainAxisSpacing: globals.isWideScreen ? 20 : 20,
                            childAspectRatio: 1.9,
                            children: [
                          ...numItems.map((num) => NumberPad(num: num))
                        ])),
                    Container(
                        width: 200,
                        padding: EdgeInsets.only(right: 30, bottom: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              child: Text(
                                '数量',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 5),
                              child: NumberInputPrefabbed.roundedButtons(
                                style: TextStyle(
                                  color: Color(0xff465886),
                                  fontSize: 42,
                                ),
                                numberFieldDecoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.only(top: 8, bottom: 8)),
                                min: 1,
                                max: 10,
                                incIconSize: 22,
                                decIconSize: 22,
                                incIcon: Icons.add,
                                decIcon: Icons.remove,
                                controller: TextEditingController(),
                                incDecBgColor: Color(0xffe0e0e0),
                                buttonArrangement: ButtonArrangement.rightEnd,
                                onIncrement: (v) {
                                  selQuantity = v.toString();
                                },
                                onDecrement: (v) {
                                  selQuantity = v.toString();
                                },
                                onChanged: (v) {
                                  selQuantity = v.toString();
                                },
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            Container(height: 40),
                            Container(
                                height: 100,
                                child: ElevatedButton(
                                  child: Text('入力完了'),
                                  onPressed: () => orderAdd(),
                                  style: ElevatedButton.styleFrom(
                                      // minimumSize:
                                      //     Size(double.infinity, double.infinity),
                                      primary: Color(0xff117fc1),
                                      padding: EdgeInsets.all(16),
                                      textStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ))
                          ],
                        ))
                  ],
                )

              // Container(
              //   padding: EdgeInsets.fromLTRB(40, 0, 40, 10),
              //   child: DropdownButtonFormField(
              //     hint: Text(hintSelectQuantity),
              //     items: [
              //       ...menuQuantity.map((e) => DropdownMenuItem(
              //             child: Text(e),
              //             value: e,
              //           ))
              //     ],
              //     onChanged: (String? v) {
              //       selQuantity = v;
              //     },
              //   ),
              // ),
            ]),
          )));
        }),
        drawer: MyDrawer(),
        bottomNavigationBar: SubBottomNavi(),
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void updateOrderQuantity(String val) {
    Navigator.of(context).pop();
    setState(() {
      globals.orderQuantity = val;
    });
  }

  Future<void> orderAdd() async {
    if (menuTitle == null) {
      Dialogs().infoDialog(context, 'メニュー名を入力してください。');
      return;
    }
    if (orderIndividualAmount == '0') {
      Dialogs().infoDialog(context, '金額を入力してください。');
      return;
    }
    if (selQuantity == null) {
      Dialogs().infoDialog(context, '数量を選択してください。');
      return;
    }
    if (Funcs().orderInputListAdd(
        context,
        OrderMenuModel(
            menuTitle: menuTitle!,
            quantity: selQuantity!,
            menuPrice: orderIndividualAmount!))) {
      Navigator.pop(context);
      // Navigator.push(context, MaterialPageRoute(builder: (_) {
      //   return Order();
      // }));
    }
  }
}

class QuantityList extends StatelessWidget {
  final String quantity;
  final GestureTapCallback? tap;

  const QuantityList({required this.quantity, this.tap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(this.quantity), onTap: this.tap);
  }
}

class NumberPad extends StatelessWidget {
  final String num;

  const NumberPad({required this.num, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (num == 'C') {
            isMinus = false;
            orderIndividualAmount = '0';
          } else {
            if (num == '+/-') {
              isMinus = !isMinus;
              if (isMinus) {
                orderIndividualAmount = "-" + orderIndividualAmount!;
              } else {
                orderIndividualAmount =
                    orderIndividualAmount!.replaceAll("-", '');
              }
            } else if (orderIndividualAmount == '0') {
              if (num != '000') {
                orderIndividualAmount = num;
              }
            } else if (orderIndividualAmount == '-0') {
              if (num != '000') {
                orderIndividualAmount = '-' + num;
              }
            } else {
              orderIndividualAmount = orderIndividualAmount! + num;
            }
          }
          txtIndividualAmountController.text = isMinus
              ? '-' +
                  Funcs().currencyFormat(
                      orderIndividualAmount!.replaceAll('-', ''))
              : Funcs().currencyFormat(orderIndividualAmount!);
        },
        child: Container(
          alignment: Alignment.center,
          child: Text(
            num,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xff465886)),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          // ElevatedButton.styleFrom(
          //   primary: Colors.white,
          //   onPrimary: Colors.grey,
          //   elevation: 0,
          //   // side: BorderSide(color: Colors.grey),
          //   shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12)),

          //   textStyle: TextStyle(
          //       color: Colors.black,
          //       fontSize: 18,
          //       fontWeight: FontWeight.w600),
          // ))
        ));
  }
}
