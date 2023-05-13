import 'dart:convert';
import 'dart:io';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_pos_app/src/http/webservice.dart';

import '../apiendpoint.dart';

class ClCommon {
  Future<bool> loadAppVersion(context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    Map<dynamic, dynamic> results = {};

    String apiUrl = '$apiBase/api/loadAppVersion';
    await Webservice().loadHttp(context, apiUrl, {
      'app_id': packageInfo.packageName,
      'os_type': Platform.operatingSystem
    }).then((v) => {results = v});

    String testFlag = results['test_flag'] ?? '0';
    if (testFlag == '1' ||
        (packageInfo.version == results['version'] &&
            packageInfo.buildNumber == results['build'])) {
      return true;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('is_old_run', false);

      return false;
    }
  }

  Future<bool> isNetworkFile(context, String path, String? fileUrl) async {
    if (fileUrl == null) return false;
    String apiUrl = '$apiBase/api/isFileCheck';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiUrl, {'path': path + fileUrl}).then((v) => {results = v});

    if (results['isFile'] == null) {
      return false;
    }
    return results['isFile'];
  }

  Future<bool> updateHomeMenuOrder(context, companyId, menuId, mode) async {
    String apiUrl = '$apiBase/api/updateOrderHomeMenu';
    await Webservice().loadHttp(context, apiUrl,
        {'company_id': companyId, 'menu_id': menuId, 'mode': mode});

    return true;
  }

  Future<List<String>> loadStaffShiftSort(context, String staffId) async {
    String apiUrl = '$apiBase/api/loadStaffSort';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiUrl, {'staff_id': staffId}).then((v) => {results = v});

    List<String> sorts = [];
    if (results['isLoad']) {
      for (var item in results['sorts']) {
        sorts.add(item['show_staff_id'].toString());
      }
    }
    return sorts;
  }

  Future<bool> saveStaffShiftSort(
      context, String staffId, List<String> showSorts) async {
    String apiUrl = '$apiBase/api/saveStaffSort';
    await Webservice().loadHttp(context, apiUrl, {
      'staff_id': staffId,
      'sorts': jsonEncode(showSorts).toString(),
    });
    return true;
  }

  Future<bool> exchangeStaffShiftSort(context, staffId, move, target) async {
    String apiUrl = '$apiBase/api/exchangeSort';
    await Webservice().loadHttp(context, apiUrl,
        {'staff_id': staffId, 'move_staff': move, 'target_staff': target});
    return true;
  }

  Future<bool> registerDeviceToken(context, staffId, deviceToken) async {
    Map<dynamic, dynamic> results = {};

    String apiURL = '$apiBase/api/registerDeviceToken';
    await Webservice().loadHttp(context, apiURL, {
      'staff_id': staffId,
      'device_token': deviceToken
    }).then((value) => results = value);
    return results['isSave'];
  }

  /* get Attend Status
  *  param staffId
  *  return if Attend organId else null
  */
  Future<String?> getStaffAttend(context, staffId) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiGetAttendStatus,
        {'staff_id': staffId}).then((value) => results = value);
    if (results['is_attend']) return results['organ_id'].toString();
    return null;
  }

  /* update Attend Status
  *  param staffId, organId, type : 1:attend, 2:revoke
  *  return if Attend organId else null
  */
  Future<bool> updateAttend(context, staffId, organId, type) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUpdateAttend, {
      'staff_id': staffId,
      'organ_id': organId,
      'type': type,
    }).then((value) => results = value);
    return results['is_update'];
  }
}
