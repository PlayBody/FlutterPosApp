import 'dart:convert';

import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/organ_point_setting_model.dart';
import 'package:staff_pos_app/src/model/staffpointaddmodel.dart';

class ClPoint {
  Future<List<OrganPointSettingModel>> loadOrganPointSettings(
      context, organId) async {
    List<OrganPointSettingModel> settings = [];
    String apiURL = '$apiBase/apipoints/loadOrganPointSettings';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL, {
      'organ_id': organId,
    }).then((v) => {results = v});

    if (results['isLoad']) {
      for (var item in results['settings']) {
        settings.add(OrganPointSettingModel.fromJson(item));
      }
    }
    return settings;
  }

  Future<bool> saveOrganPointSetting(context, String organId, String title,
      String points, String pointType) async {
    String apiURL = '$apiBase/apipoints/saveOrganPointSetting';
    await Webservice().loadHttp(context, apiURL, {
      'organ_id': organId,
      'title': title,
      'point_value': points,
      'point_type': pointType
    });
    return true;
  }

  Future<bool> deleteOrganPointSetting(context, String organPointId) async {
    String apiURL = '$apiBase/apipoints/deleteOrganPointSetting';
    await Webservice()
        .loadHttp(context, apiURL, {'organ_point_id': organPointId});
    return true;
  }

  Future<bool> submitPoint(context, String staffId, String organId,
      String pointDate, String organPointSettingId, String points) async {
    String apiURL = '$apiBase/apipoints/submitPoint';
    await Webservice().loadHttp(context, apiURL, {
      'staff_id': staffId,
      'organ_id': organId,
      'point_date': pointDate,
      'point_setting_id': organPointSettingId,
      'point': points
    });
    return true;
  }

  Future<bool> deleteStaffPoint(context, String pointId) async {
    String apiURL = '$apiBase/apipoints/deleteStaffPoints';
    await Webservice().loadHttp(context, apiURL, {'point_id': pointId});
    return true;
  }

  Future<bool> updatePointStatus(context, String id, String status) async {
    String apiURL = '$apiBase/apipoints/updatePointStatus';
    await Webservice()
        .loadHttp(context, apiURL, {'point_id': id, 'status': status});
    return true;
  }

  Future<List<StaffPointAddModel>> loadStaffPoints(context, param) async {
    String apiURL = '$apiBase/apipoints/loadStaffPoints';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL,
        {'condition': jsonEncode(param)}).then((value) => results = value);

    List<StaffPointAddModel> points = [];
    if (results['isLoad']) {
      for (var item in results['points']) {
        points.add(StaffPointAddModel.fromJson(item));
      }
    }
    return points;
  }
}
