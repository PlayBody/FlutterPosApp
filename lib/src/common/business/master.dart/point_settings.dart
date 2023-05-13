import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/master/point_rate_special_limit_model.dart';
import 'package:staff_pos_app/src/model/master/point_rate_special_period_model.dart';

class PointMaster {
  Future<List<PointRateSpecialPeriodModel>> loadPointSettingSpecialPeriod(
      context, organId) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadMasterPointSpecialPeriodSetting,
        {'organ_id': organId}).then((value) => results = value);

    if (!results['is_load']) return [];

    List<PointRateSpecialPeriodModel> rates = [];
    for (var item in results['rates']) {
      rates.add(PointRateSpecialPeriodModel.fromJson(item));
    }
    return rates;
  }

  Future<bool> savePointSettingSpecialPeriod(context, param) async {
    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiSaveMasterPointSpecialPeriodSetting, param)
        .then((value) => results = value);

    return results['is_save'];
  }

  Future<bool> deletePointSettingSpecialPeriod(context, id) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context,
        apiDeleteMasterPointSpecialPeriodSetting,
        {'id': id}).then((value) => results = value);

    return results['is_delete'];
  }

  Future<List<PointRateSpecialLimitModel>> loadPointSettingSpecialLimit(
      context, organId) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadMasterPointSpeicalLimits,
        {'organ_id': organId}).then((value) => results = value);

    if (!results['is_load']) return [];
    List<PointRateSpecialLimitModel> rates = [];
    for (var item in results['rates']) {
      rates.add(PointRateSpecialLimitModel.fromJson(item));
    }
    return rates;
  }

  Future<bool> savePointSettingSpecialLimit(context, param) async {
    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiSaveMasterPointSpeicalLimits, param)
        .then((value) => results = value);

    return results['is_save'];
  }

  Future<bool> deletePointSettingSpecialLimit(context, id) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiDeleteMasterPointSpeicalLimit,
        {'id': id}).then((value) => results = value);

    return results['is_delete'];
  }
}
