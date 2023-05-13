import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/common.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/functions.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dialog_widgets.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';

import '../common/globals.dart' as globals;
import 'package:flutter/material.dart';

class DlgAttendance extends StatefulWidget {
  final List<OrganModel> organList;
  const DlgAttendance({required this.organList, Key? key}) : super(key: key);

  @override
  State<DlgAttendance> createState() => _DlgAttendance();
}

class _DlgAttendance extends State<DlgAttendance> {
  String? selOrganId;

  Future<void> attendance() async {
    if (selOrganId == null) return;

    Dialogs().loaderDialogNormal(context);

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location Not Available');
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    Map<dynamic, dynamic> organResults = {};
    await Webservice().loadHttp(context, apiLoadOrganInfo,
        {'organ_id': selOrganId}).then((value) => organResults = value);
    Navigator.pop(context);

    if (organResults['isLoad']) {
      var organLat = organResults['organ']['lat'] ?? '0';
      var organLon = organResults['organ']['lon'] ?? '0';
      if (double.tryParse(organLat) == null) organLat = '0';
      if (double.tryParse(organLon) == null) organLon = '0';
      int distance = Funcs().clacDistance(
          LatLng(position.latitude, position.longitude),
          LatLng(double.parse(organLat), double.parse(organLon)));
      int organDistance = organResults['organ']['distance'] == null
          ? 0
          : int.parse(organResults['organ']['distance']);
      // if (distance > organDistance) {
      //   Dialogs().infoDialog(context, '選択した店舗と現在位置が異なります');
      //   return;
      // }
    } else {
      Dialogs().infoDialog(context, '店舗の位置情報を確認することができません。');
    }

    bool isAttend = await ClCommon()
        .updateAttend(context, globals.staffId, selOrganId, '1');

    if (isAttend) {
      Navigator.of(context).pop();
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PushDialogs(
        render: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PosDlgHeaderText(label: qAttendanceActive),
        DropDownModelSelect(items: [
          ...widget.organList.map((e) =>
              DropdownMenuItem(value: e.organId, child: Text(e.organName)))
        ], tapFunc: (v) => selOrganId = v.toString()),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(child: Container()),
            PrimaryColButton(label: '出勤', tapFunc: () => attendance()),
            const SizedBox(width: 12),
            CancelColButton(
                label: 'キャンセル', tapFunc: () => Navigator.of(context).pop()),
          ],
        ),
      ],
    ));
  }
}
