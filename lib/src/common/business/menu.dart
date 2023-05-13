import 'dart:convert';

import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/menumodel.dart';
import 'package:staff_pos_app/src/model/menuvariationmodel.dart';
import 'package:staff_pos_app/src/model/variationbackstaffmodel.dart';

import '../apiendpoint.dart';

class ClMenu {
  Future<List<MenuModel>> loadCompanyUserMenus(context, companyId) async {
    String apiUrl = '$apiBase/apimenus/loadCompanyUserMenus';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'company_id': companyId,
    }).then((v) => {results = v});

    List<MenuModel> menus = [];
    for (var item in results['menus']) {
      menus.add(MenuModel.fromJson(item));
    }

    return menus;
  }

  Future<bool> exchangeMenuSort(context, moveMenuId, targetMenuId) async {
    String apiUrl = '$apiBase/apimenus/exchangeMenuSort';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'move_menu': moveMenuId,
      'target_menu': targetMenuId
    }).then((v) => {results = v});

    return results['isUpdate'];
  }

  Future<MenuModel?> loadMenuInfo(context, menuId) async {
    String apiUrl = '$apiBase/apimenus/loadMenuInfo';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'menu_id': menuId,
    }).then((v) => {results = v});
    if (!results['isLoad']) return null;
    return MenuModel.fromJson(results['menu']);
  }

  Future<List<MenuVariationModel>> loadVariations(context, menuId) async {
    String apiUrl = '$apiBase/apimenus/loadVaritions';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'menu_id': menuId,
    }).then((v) => {results = v});

    List<MenuVariationModel> vas = [];
    if (!results['isLoad']) return [];
    for (var item in results['variations']) {
      vas.add(MenuVariationModel.fromJson(item));
    }
    return vas;
  }

  Future<List<VariationBackStaffModel>> loadBackStaffs(context, organId) async {
    String apiUrl = '$apiBase/apimenus/loadBackStaffs';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'organ_id': organId,
    }).then((v) => {results = v});

    List<VariationBackStaffModel> vas = [];
    for (var item in results['staffs']) {
      vas.add(VariationBackStaffModel.fromJson(item));
    }
    return vas;
  }

  Future<List<MenuModel>> loadMenuList(context, param) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadMenuListUrl,
        {'condition': jsonEncode(param)}).then((v) => {results = v});
    List<MenuModel> menuList = [];
    if (results['isLoad']) {
      menuList = [];
      for (var item in results['menus']) {
        menuList.add(MenuModel.fromJson(item));
      }
      return menuList;
    }
    return [];
  }

  Future<String> saveMenu(context, param) async {
    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiSaveMenuUrl, param)
        .then((v) => {results = v});
    if (results['isSave']) {
      return results['select_menu_id'].toString();
    } else {
      return '';
    }
  }

  Future<List<String>> loadMenuOrgans(context, param) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadMenuOrgansUrl, {
      'condition': jsonEncode(param),
    }).then((v) => {results = v});
    List<String> organs = [];
    if (results['isLoad']) {
      for (var item in results['organ_menus']) {
        organs.add(item['organ_id'].toString());
      }
    }
    return organs;
  }
}
