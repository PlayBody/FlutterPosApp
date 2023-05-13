import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/orders.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../http/webservice.dart';
import '../../../common/globals.dart' as globals;

class DlgEntering extends StatefulWidget {
  final String? userId;
  final String? orderId;
  final bool? isReject;
  final String tablePosition;
  const DlgEntering(
      {this.userId,
      this.orderId,
      required this.tablePosition,
      this.isReject,
      Key? key})
      : super(key: key);

  @override
  _DlgEntering createState() => _DlgEntering();
}

class _DlgEntering extends State<DlgEntering> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  String quantitiy = '1';
  String setNum = '1';
  bool isUseSet = false;

  List<dynamic> memList = [
    {'id': '1', 'label': '人1', 'sex': '1', 'age': '20'},
    {'id': '2', 'label': '人2', 'sex': '1', 'age': '20'},
    {'id': '3', 'label': '人3', 'sex': '1', 'age': '20'},
    {'id': '4', 'label': '人4', 'sex': '1', 'age': '20'},
    {'id': '5', 'label': '人5', 'sex': '1', 'age': '20'},
    {'id': '6', 'label': '人6', 'sex': '1', 'age': '20'},
    {'id': '7', 'label': '人7', 'sex': '1', 'age': '20'},
    {'id': '8', 'label': '人8', 'sex': '1', 'age': '20'},
    {'id': '9', 'label': '人9', 'sex': '1', 'age': '20'},
    {'id': '10', 'label': '人10', 'sex': '1', 'age': '20'},
  ];

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = '入店';
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(child: _buildQrView(context)),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: Row(
                    children: [
                      // if (widget.userId == null)
                        WhiteButton(
                            label: '一見', tapFunc: () => selectUnknownUser()),
                      Expanded(
                        child: Container(),
                      ),
                      CancelColButton(
                          label: '戻る', tapFunc: () => Navigator.pop(context, widget.orderId))
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      String checkQRMessage = Funcs().checkQrCode(scanData);
      if (checkQRMessage == "QROK") {
        String userId = await isLoadUser(scanData);
        if (userId == '') {
          await Dialogs().waitDialog(context, errUnknownQRCode);
        } else {
          if (widget.userId != null) {
            if (widget.userId == userId) {
              await updateOrder(widget.orderId);
            } else {
              await Dialogs().waitDialog(context, '予約されたユーザーではありません。');
            }
            Navigator.pop(context);
          } else {
            String confString = await enteringDialog(
                (widget.isReject != null && widget.isReject!)
                    ? qRejectOrgan
                    : qEnteringOrgan);
            if (confString == '1') {
              await createOrder(userId);
            } else if (confString == '3') {
              await ClOrder().rejectOrder(context, globals.organId, userId);
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          }
        }
      } else {
        await Dialogs().waitDialog(context, checkQRMessage);
      }
      controller.resumeCamera();
      result = scanData;
    });
    setState(() {});
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<String> isLoadUser(Barcode scanData) async {
    String userNo = scanData.code!.split('!')[1];

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadUserFromQrCodeUrl,
        {'user_no': userNo}).then((v) => results = v);

    String userId = '';
    if (results['isLoad']) {
      userId = results['user']['user_id'];
    }
    return userId;
  }

  Future<void> selectUnknownUser() async {
    setState(() {
      controller?.pauseCamera();
    });
    String confString = await enteringDialog(
        (widget.isReject != null && widget.isReject!)
            ? qRejectOrgan
            : qEnteringOrgan);
    if (confString == '1') {
      await createOrder('1');
    } else if (confString == '3') {
      await ClOrder().rejectOrder(context, globals.organId, '1');
      Navigator.pop(context);
    } else {
      Navigator.pop(context, widget.orderId);
    }
  }

  Future<bool> updateOrder(orderId) async {
    if (orderId == null) return false;
    await ClOrder().updateOrder(
        context, {'id': orderId, 'status': constOrderStatusTableEnd});
    return true;
  }

  Future<bool> createOrder(userId) async {
    String _orderId = await ClOrder().addOrder(context, {
      'organ_id': globals.organId,
      'table_position': widget.tablePosition,
      'user_id': userId,
      'staff_id': globals.staffId,
      'user_count': quantitiy,
      'set_number': isUseSet ? setNum : '',
      'status': constOrderStatusTableStart
    });
    if (_orderId == '') {
      Navigator.pop(context, widget.orderId);
    } else {
      Navigator.pop(context, _orderId);
    }
    return true;
  }

  Future<String> enteringDialog(String message) async {
    isUseSet = await ClOrgan().isUseSetInTable(context, globals.organId);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(message),
              ),
              if (isUseSet &&
                  (widget.isReject == null || widget.isReject == false))
                RowLabelInput(
                    label: 'セット設定',
                    renderWidget: DropDownNumberSelect(
                      value: setNum,
                      max: 5,
                      tapFunc: (v) {
                        setState(() {
                          setNum = v;
                        });
                      },
                    )),
              SizedBox(height: 8),
              if (widget.isReject == null || widget.isReject == false)
                RowLabelInput(
                    label: '人数',
                    renderWidget: DropDownNumberSelect(
                      value: quantitiy,
                      max: 99,
                      tapFunc: (v) {
                        setState(() {
                          quantitiy = v.toString();
                        });
                      },
                    )),
            ],
          ),
        ),
        actions: [
          if (widget.isReject == null || widget.isReject == false)
            TextButton(
              child: const Text('はい'),
              onPressed: () => Navigator.of(context).pop('1'),
            ),
          if (widget.isReject != null && widget.isReject == true)
            TextButton(
              child: const Text('はい'),
              onPressed: () => Navigator.of(context).pop('3'),
            ),
          TextButton(
            child: const Text('いいえ'),
            onPressed: () => Navigator.of(context).pop('2'),
          ),
        ],
      ),
    );

    return value == null ? '2' : value;
  }
}

class EnteringOrganBottomButton extends StatelessWidget {
  final String label;
  final tapFunc;
  final btnStyle;
  const EnteringOrganBottomButton(
      {required this.label,
      required this.tapFunc,
      required this.btnStyle,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: ElevatedButton(
        child: Text(label),
        onPressed: tapFunc,
        style: this.btnStyle,
      ),
    );
  }
}
