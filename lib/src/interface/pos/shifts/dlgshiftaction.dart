import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/http/webservice.dart';

import 'package:flutter/material.dart';

class DlgActionShift extends StatefulWidget {
  final String selectDate;
  final dynamic param;

  const DlgActionShift({
    Key? key,
    required this.param,
    required this.selectDate,
  }) : super(key: key);

  @override
  _DlgActionShift createState() => _DlgActionShift();
}

class _DlgActionShift extends State<DlgActionShift> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: const Text(
                    'シフトアクション',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  )),
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: const Text(
                  '', //widget.param['name'],
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Row(
                children: [
                  Expanded(child: Container()),
                  Container(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      widget.selectDate,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  Text(
                      DateFormat('HH:mm')
                          .format(DateTime.parse(widget.param['start_time'])),
                      style: const TextStyle(fontSize: 20)),
                  Container(
                    width: 20,
                    alignment: Alignment.center,
                    child: const Text('~'),
                  ),
                  Text(
                      DateFormat('HH:mm')
                          .format(DateTime.parse(widget.param['end_time'])),
                      style: const TextStyle(fontSize: 20)),
                  Expanded(child: Container()),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 40),
                child: Row(
                  children: [
                    Expanded(child: Container()),
                    ElevatedButton(
                        onPressed: () => actionShift('2'),
                        child:
                            const Text("承認", style: TextStyle(fontSize: 14))),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => actionShift('3'),
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      child: const Text("否決", style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> actionShift(String status) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiActionShiftStatus, {
      'shift_id': widget.param['shift_id'],
      'status': status,
    }).then((v) => {results = v});

    if (results['isUpdate']) {
      Navigator.of(context).pop();
    } else {
      Dialogs().infoDialog(context, '登録に失敗しました。');
    }
  }
}
