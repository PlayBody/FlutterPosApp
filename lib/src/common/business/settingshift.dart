import 'dart:convert';

import 'package:staff_pos_app/src/http/webservice.dart';

import '../apiendpoint.dart';

class ClSettingShift {
  Future<bool> importShiftCount(context, String dateMonth, String organId,
      List<dynamic> importData) async {
    String apiUrl = '$apiBase/apishiftsettings/importExeclCount';
    Map<dynamic, dynamic> results = {};

    await Webservice().loadHttp(context, apiUrl, {
      'organ_id': organId,
      'date_month': dateMonth,
      'import_data': jsonEncode(importData)
    }).then((v) => {results = v});

    return results['isImport'];
  }
}
