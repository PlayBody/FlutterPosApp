import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import '../../../common/globals.dart' as globals;

class AdminQrcodeReader extends StatefulWidget {
  const AdminQrcodeReader({Key? key}) : super(key: key);

  @override
  _AdminQrcodeReader createState() => _AdminQrcodeReader();
}

class _AdminQrcodeReader extends State<AdminQrcodeReader> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

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
    globals.adminAppTitle = 'QRコードリーダー';
    return MainBodyWdiget(
      render: Column(
        children: <Widget>[
          Expanded(child: _buildQrView(context)),
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
    controller.scannedDataStream.listen((scanData) {
      setState(() async {
        controller.pauseCamera();
        bool checkQR = await isCheckQRcode(context, scanData);
        if (checkQR) {
          Dialogs().infoDialog(context, scanData.code.toString());
        } else {
          await Dialogs().waitDialog(context, errUnknownQRCode);
        }
        controller.resumeCamera();
        result = scanData;
      });
    });
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

  Future<bool> isCheckQRcode(BuildContext context, Barcode scanData) async {
    String _format = describeEnum(scanData.format);
    String? _code = scanData.code;
    bool isCheck = false;

    if (_code==null) return false;
    if (_format == 'qrcode') {
      if (_code.indexOf('!') > 0) {
        List<String> _data = _code.split('!');
        if (_data.length == 5) {
          String user = _data[1];
          int sum = 0;
          for (var i = 0; i < user.length; i++) {
            sum = sum + int.parse(user.substring(i, i + 1));
          }
          //if (sum.toString() == _data[4]) {
          isCheck = true;
          //}
        }
      }
    }
    return isCheck;
  }
}
