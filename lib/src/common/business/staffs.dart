import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/staff_model.dart';
import 'package:staff_pos_app/src/model/stafflistmodel.dart';
import 'package:staff_pos_app/src/model/stafforgangroupmodel.dart';
import 'package:staff_pos_app/src/model/staffpointaddmodel.dart';

import '../apiendpoint.dart';
import '../../common/globals.dart' as globals;

class ClStaff {
  Future<StaffModel?> login(context, staffMail, password) async {
    Map<dynamic, dynamic> results = {};
    String apiUrl = '$apiBase/apistaffs/login';
    await Webservice().loadHttp(context, apiUrl,
        {'email': staffMail, 'password': password!}).then((v) => results = v);

    if (results['isLogin']) {
      return StaffModel.fromJson(results['staff']);
    }
    return null;
  }

  Future<List<StaffOrganGroupModel>> loadStaffByGroupList(
      BuildContext context) async {
    List<StaffOrganGroupModel> staffList = [];

    Map<dynamic, dynamic> results = {};
    String apiURL = '$apiBase/apistaffs/loadStaffByGroupList';
    await Webservice().loadHttp(context, apiURL,
        {'staff_id': globals.staffId}).then((v) => {results = v});
    if (results['isLoad']) {
      for (var item in results['data']) {
        staffList.add(StaffOrganGroupModel.fromJson(item));
      }
    }

    return staffList;
  }

  Future<StaffModel> loadStaffInfo(BuildContext context, staffId) async {
    StaffModel staffInfo = StaffModel.fromJson({});

    Map<dynamic, dynamic> results = {};
    String apiURL = '$apiBase/apistaffs/loadStaffDetail';
    await Webservice().loadHttp(
        context, apiURL, {'staff_id': staffId}).then((v) => {results = v});
    if (results['isLoad']) {
      staffInfo = StaffModel.fromJson(results['staff']);
    }

    return staffInfo;
  }

  Future<dynamic> loadStaffAddPoints(context, String organId, String staffId,
      String dateYear, String dateMonth,
      {String type = ''}) async {
    String apiStaffLoadAddpointUrl = '$apiBase/apistaffs/loadAddPoints';

    List<StaffPointAddModel> points = [];
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiStaffLoadAddpointUrl, {
      'organ_id': organId,
      'staff_id': staffId,
      'date_year': dateYear,
      'date_month': dateMonth,
      'type': type,
    }).then((v) => {results = v});

    points = [];
    String sumPoints = '0';
    if (results['isLoad']) {
      for (var item in results['points']) {
        points.add(StaffPointAddModel.fromJson(item));
      }

      sumPoints = results['points_sum'].toString();
    } else {
      return {'points': points, 'sum_points': '0'};
    }

    return {'points': points, 'sum_points': sumPoints};
  }

  Future<bool> deleteStaffAddPoint(context, String pointId) async {
    String apiUrl = '$apiBase/apistaffs/deleteAddPoint';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'point_id': pointId,
    }).then((v) => {results = v});

    if (results['isDelete']) {
      return true;
    }
    return false;
  }

  Future<bool> applyStaffAddPoint(context, String pointId) async {
    String apiUrl = '$apiBase/apistaffs/applyAddPoint';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'point_id': pointId,
    }).then((v) => {results = v});

    if (results['isUpdate']) {
      return true;
    }
    return false;
  }

  Future<bool> exchangeStaffSort(context, moveStaffId, targetStaffId) async {
    String apiUrl = '$apiBase/apistaffs/exchangeStaffSort';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'move_staff': moveStaffId,
      'target_staff': targetStaffId
    }).then((v) => {results = v});

    return results['isUpdate'];
  }

  Future<bool> updateStaffPush(context, bool isPush) async {
    String apiUrl = '$apiBase/apistaffs/updateStaffPush';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'staff_id': globals.staffId,
      'is_push': isPush ? '1' : '0'
    }).then((v) => {results = v});

    return results['isUpdate'];
  }

  Future<List<StaffListModel>> loadStaffs(context, param) async {
    String apiUrl = '$apiBase/apistaffs/getStaffs';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl,
        {'condition': jsonEncode(param)}).then((v) => {results = v});
    if (!results['isLoad']) return [];
    List<StaffListModel> staffs = [];
    for (var item in results['staffs']) {
      staffs.add(StaffListModel.fromJson(item));
    }
    return staffs;
  }

  Future<List<String>> loadStaffEnableMenus(context, staffId, organId) async {
    List<String> menus = [];
    String apiUrl = '$apiBase/apistaffs/getStaffEnableMenus';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl,
        {'staff_id': staffId, 'organ_id': organId}).then((v) => {results = v});
    if (results['isLoad']) {
      for (var item in results['menus']) {
        menus.add(item['menu_id']);
      }
    }
    return menus;
  }

  Future<bool> updateStaffEnableMenu(context, staffId, menuId) async {
    String apiUrl = '$apiBase/apistaffs/updateStaffEnableMenu';

    await Webservice()
        .loadHttp(context, apiUrl, {'staff_id': staffId, 'menu_id': menuId});

    return true;
  }
}
