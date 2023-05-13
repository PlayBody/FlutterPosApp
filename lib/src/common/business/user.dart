import 'dart:convert';

import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/usermodel.dart';

class ClUser {
  Future<List<UserModel>> loadUserList(
      context, String companyId, dynamic param) async {
    String apiUrl = '$apiBase/apiusers/loadUserList';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'company_id': companyId,
      'condition': param == null ? '' : jsonEncode(param),
    }).then((v) => {results = v});
    List<UserModel> users = [];
    if (results['isLoad']) {
      for (var item in results['users']) {
        users.add(UserModel.fromJson(item));
      }
    }
    return users;
  }

  Future<bool> deleteUser(context, String userId) async {
    String apiUrl = '$apiBase/apiusers/deleteUser';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'user_id': userId,
    }).then((v) => {results = v});

    return results['isDelete'];
  }

  Future<dynamic> loadUserInfo(context, String userId) async {
    String apiUrl = '$apiBase/apiusers/loadUserInfo';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'user_id': userId,
    }).then((v) => {results = v});

    return results['user'];
  }
}
