import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/organavaliabletimmodel.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/organsettablemodel.dart';
import 'package:staff_pos_app/src/model/organspecialshifttimemodel.dart';
import 'package:staff_pos_app/src/model/organspecialtimemodel.dart';
import '../apiendpoint.dart';

class ClOrgan {
  Future<List<OrganModel>> loadOrganList(
      context, String companyId, String staffId) async {
    List<OrganModel> organs = [];
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadOrganListUrl, {
      'company_id': companyId,
      'staff_id': staffId
    }).then((v) => {results = v});
    print(companyId);
    print(results);
    if (results['isLoad']) {
      for (var item in results['organs']) {
        organs.add(OrganModel.fromJson(item));
      }
    }
    return organs;
  }

  Future<OrganModel> loadOrganInfo(context, String organId) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadOrganInfo,
        {'organ_id': organId}).then((v) => {results = v});
    return OrganModel.fromJson(results['organ']);
  }

  Future<OrganSetTableModel> loadOrganSetTableData(
      context, String organId, String setNumber) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadOrganSetTableUrl, {
      'organ_id': organId,
      'set_number': setNumber
    }).then((v) => {results = v});

    if (results['set_data'] == null) return OrganSetTableModel.fromJson({});
    return OrganSetTableModel.fromJson(results['set_data']);
  }

  Future<String> loadPrintOrder(
      context, String organId, String printDate) async {
    String api = '$apiBase/api/loadOrganPrintMaxOrder';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, api, {
      'organ_id': organId,
      'print_date': printDate
    }).then((v) => {results = v});
    String no = '00000${results['max_order']}';

    return no.substring(no.length - 5);
  }

  Future<List<int>> loadOrganShiftTime(
      context, String organId, String date) async {
    List<int> times = [];
    String apiURL = '$apiBase/apiorgans/loadOrganShiftTime';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL,
        {'organ_id': organId, 'select_date': date}).then((v) => {results = v});

    for (var item in results['data']) {
      var from = int.parse(item['from_time'].toString().split(':')[0]);
      var to = int.parse(item['to_time'].toString().split(':')[0]);
      if (int.parse(item['to_time'].toString().split(':')[1]) > 0) {
        to++;
      }
      for (var i = from; i <= to; i++) {
        if (!times.contains(i)) {
          times.add(i);
        }
      }
    }
    times.sort();
    if (times.length > 1) times.remove(times.last);
    return times;
  }

  Future<List<OrganAvaliableTimeModel>> loadOrganTimes(
      context, String organId, String type) async {
    List<OrganAvaliableTimeModel> times = [];

    String apiURL = '$apiBase/apiorgans/loadBusinessTimes';
    if (type == 'shift') apiURL = '$apiBase/apiorgans/loadShiftTimes';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiURL, {'organ_id': organId}).then((v) => {results = v});
    if (!results['isLoad']) return [];
    for (var item in results['times']) {
      times.add(OrganAvaliableTimeModel.fromJson(item));
    }
    return times;
  }

  Future<bool> deleteOrganTimes(context, String timeId, String type) async {
    String apiURL = '$apiBase/apiorgans/deleteOrganTime';
    if (type == 'shift') apiURL = '$apiBase/apiorgans/deleteOrganShiftTime';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiURL, {'time_id': timeId}).then((v) => {results = v});

    return results['isDelete'];
  }

  Future<bool> isUseSetInTable(context, String organId) async {
    String apiURL = '$apiBase/apiorgans/isUseSetInTable';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiURL, {'organ_id': organId}).then((v) => {results = v});

    if (!results['isLoad']) return false;
    return results['isUse'];
  }

  Future<List<OrganSpecialTimeModel>> loadOrganSpecialTime(
      context, organId) async {
    String apiURL = '$apiBase/apiorgans/loadOrganSpecialTimes';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiURL, {'organ_id': organId}).then((v) => {results = v});

    List<OrganSpecialTimeModel> times = [];
    if (results['isLoad']) {
      for (var item in results['times']) {
        times.add(OrganSpecialTimeModel.fromJson(item));
      }
    }

    return times;
  }

  Future<List<OrganSpecialShiftTimeModel>> loadOrganSpecialShiftTime(
      context, organId) async {
    String apiURL = '$apiBase/apiorgans/loadOrganSpecialShiftTimes';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiURL, {'organ_id': organId}).then((v) => {results = v});

    List<OrganSpecialShiftTimeModel> times = [];
    if (results['isLoad']) {
      for (var item in results['times']) {
        times.add(OrganSpecialShiftTimeModel.fromJson(item));
      }
    }

    return times;
  }

  Future<bool> deleteOrganSpecialTimes(context, String timeId) async {
    String apiURL = '$apiBase/apiorgans/deleteOrganSpecialTime';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiURL, {'time_id': timeId}).then((v) => {results = v});

    return results['isDelete'];
  }

  Future<dynamic> loadOrganShiftMinMaxHour(
      context, String organId, fromTime, toTime) async {
    String apiURL = '$apiBase/apiorgans/loadOrganMinAndMaxShiftTime';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL, {
      'organ_id': organId,
      'from_time': fromTime,
      'to_time': toTime
    }).then((v) => {results = v});

    return results;
  }
}
