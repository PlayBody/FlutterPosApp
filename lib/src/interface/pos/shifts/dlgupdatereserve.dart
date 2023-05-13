import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/business/shift.dart';
import 'package:staff_pos_app/src/common/functions.dart';

import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/interface/components/timepicker.dart';
import 'package:staff_pos_app/src/model/stafflistmodel.dart';

class DlgUpdateReserve extends StatefulWidget {
  final String? staffId;
  final String reserveTime;
  final String reserveId;
  final List<StaffListModel> organStaffs;
  const DlgUpdateReserve({
    this.staffId,
    required this.reserveTime,
    required this.organStaffs,
    required this.reserveId,
    Key? key,
  }) : super(key: key);

  @override
  _DlgUpdateReserve createState() => _DlgUpdateReserve();
}

class _DlgUpdateReserve extends State<DlgUpdateReserve> {
  String? selStaffId;
  String selTime = '';
  String reserveTime = '';

  @override
  void initState() {
    super.initState();
    loadInit();
  }

  void loadInit() {
    selStaffId = widget.staffId;
    reserveTime = widget.reserveTime;
    selTime = DateFormat('HH:mm:ss').format(DateTime.parse(widget.reserveTime));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
        render: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PosDlgHeaderText(label: '施術変更'),
        RowLabelInput(
            label: 'スタッフ',
            renderWidget: DropDownModelSelect(
                value: selStaffId,
                items: [
                  ...widget.organStaffs.map((e) => DropdownMenuItem(
                        child: Text(e.staffNick == ''
                            ? (e.staffFirstName! + ' ' + e.staffLastName!)
                            : e.staffNick),
                        value: e.staffId,
                      ))
                ],
                tapFunc: (v) {
                  selStaffId = v;
                })),
        RowLabelInput(
            label: '時間',
            renderWidget: PosTimePicker(
                date: selTime,
                confFunc: (v) {
                  selTime = Funcs().getDurationTime(v);
                  reserveTime = DateFormat('yyyy-MM-dd')
                          .format(DateTime.parse(widget.reserveTime)) +
                      ' ' +
                      Funcs().getDurationTime(v);
                  setState(() {});
                })),
        RowButtonGroup(widgets: [
          PrimaryButton(
            label: 'はい',
            tapFunc: () async {
              await ClShift().updateReserveItem(context, widget.reserveId,
                  reserveTime, selStaffId == null ? '' : selStaffId!);
              Navigator.pop(context);
            },
          ),
          SizedBox(width: 16),
          CancelButton(
            label: 'いいえ',
            tapFunc: () => Navigator.pop(context),
          ),
        ]),
      ],
    ));
  }
}
