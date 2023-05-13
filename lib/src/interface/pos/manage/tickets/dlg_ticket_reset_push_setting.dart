import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/http/webservice.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/components/timepicker.dart';

class DlgTicketResetPushSetting extends StatefulWidget {
  final String ticketId;
  const DlgTicketResetPushSetting({required this.ticketId, Key? key})
      : super(key: key);

  @override
  _DlgTicketResetPushSetting createState() => _DlgTicketResetPushSetting();
}

class _DlgTicketResetPushSetting extends State<DlgTicketResetPushSetting> {
  String beforeDay = '1';
  String pushHour = '12:00';

  @override
  void initState() {
    super.initState();
  }

  Future<void> savePushSetting() async {
    String apiUrl = apiBase + '/apitickets/savePushSetting';
    await Webservice().loadHttp(context, apiUrl, {
      'ticket_id': widget.ticketId,
      'before_day': beforeDay,
      'push_time': pushHour
    });
    // if (results['isSave']) {
    Navigator.pop(context);
    // } else {
    //   Dialogs().infoDialog(context, errServerActionFail);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
      render: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PosDlgHeaderText(label: '通知設定の追加'),
          Row(
            children: [
              Flexible(
                  flex: 4,
                  child: DropDownNumberSelect(
                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                      max: 30,
                      value: beforeDay,
                      tapFunc: (v) => beforeDay = v)),
              Text('日前の'),
              Flexible(
                  flex: 8,
                  child: PosTimePicker(
                    date: pushHour,
                    confFunc: (date) {
                      pushHour = Funcs().getDurationTime(date,
                          duration: 15, isShowSecond: false);
                      setState(() {});
                    },
                  )),
              Text('時に通知'),
            ],
          ),
          RowButtonGroup(widgets: [
            SizedBox(width: 8),
            PrimaryColButton(label: '保存する', tapFunc: () => savePushSetting()),
            SizedBox(width: 8),
            CancelColButton(
                label: 'キャンセル', tapFunc: () => Navigator.of(context).pop())
          ]),
        ],
      ),
    );
  }
}
