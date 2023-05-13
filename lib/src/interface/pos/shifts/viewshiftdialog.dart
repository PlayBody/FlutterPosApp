import 'package:flutter/material.dart';

class ViewShiftDialog extends StatefulWidget {
  final String selectDate;
  final String txtStatus;
  final dynamic param;

  const ViewShiftDialog({
    Key? key,
    required this.param,
    required this.txtStatus,
    required this.selectDate,
  }) : super(key: key);

  @override
  _ViewShiftDialog createState() => _ViewShiftDialog();
}

class _ViewShiftDialog extends State<ViewShiftDialog> {
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
          padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
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
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text(
                    'シフト表示',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  )),
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  widget.param['name'],
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                child: Row(
                  children: [
                    Expanded(child: Container()),
                    Container(
                      padding: EdgeInsets.only(right: 20),
                      child: Text(
                        widget.selectDate,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Container(
                      child: Text(widget.param['start_time'],
                          style: TextStyle(fontSize: 20)),
                    ),
                    Container(
                      width: 20,
                      alignment: Alignment.center,
                      child: Text('~'),
                    ),
                    Container(
                      child: Text(widget.param['end_time'],
                          style: TextStyle(fontSize: 20)),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 40),
                child: Row(
                  children: [
                    Expanded(child: Container(child: Text(widget.txtStatus))),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "閉じる",
                          style: TextStyle(fontSize: 14),
                        )),
                    Container(
                      width: 12,
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
}
