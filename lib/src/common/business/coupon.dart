import 'dart:convert';

import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/couponmodel.dart';
import 'package:staff_pos_app/src/model/rankmodel.dart';
import 'package:staff_pos_app/src/model/rankprefermodel.dart';

import '../apiendpoint.dart';

class ClCoupon {
  Future<List<RankModel>> loadRanks(context, companyId) async {
    String apiURL = '$apiBase/apicoupons/loadRanks';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL,
        {'company_id': companyId}).then((value) => results = value);

    List<RankModel> ranks = [];
    for (var item in results['ranks']) {
      ranks.add(RankModel.fromJson(item));
    }
    return ranks;
  }

  Future<RankModel> loadRankInfo(context, rankId) async {
    String apiURL = '$apiBase/apicoupons/loadRankInfo';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiURL, {'rank_id': rankId}).then((value) => results = value);
    return RankModel.fromJson(results['rank']);
  }

  Future<List<RankPreferModel>> loadRankPrefers(
      context, companyId, rankId) async {
    String apiURL = '$apiBase/apicoupons/loadRankPrefers';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL, {
      'company_id': companyId,
      'rank_id': rankId
    }).then((value) => results = value);

    List<RankPreferModel> prefers = [];

    for (var item in results['prefers']) {
      prefers.add(RankPreferModel.fromJson(item));
    }
    return prefers;
  }

  Future<bool> saveStamp(
      context, rankId, companyId, rankName, maxStamp, prefers) async {
    String apiURL = '$apiBase/apicoupons/saveStamp';
    await Webservice().loadHttp(context, apiURL, {
      'rank_id': rankId,
      'company_id': companyId,
      'rank_name': rankName,
      'max_stamp': maxStamp,
      'prefer_json': jsonEncode(prefers)
    });
    return true;
  }

  Future<bool> delteRank(context, rankId) async {
    String apiURL = '$apiBase/apicoupons/deleteRanks';
    await Webservice().loadHttp(context, apiURL, {
      'rank_id': rankId,
    });
    return true;
  }

  Future<List<CouponModel>> loadCoupons(context, companyId,
      {isGetDelete = false}) async {
    String apiURL = '$apiBase/apicoupons/loadCouponList';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL, {
      'company_id': companyId,
      'is_get_delete': isGetDelete ? '1' : '0',
    }).then((value) => results = value);

    List<CouponModel> coupons = [];
    if (results['isLoad']) {
      for (var item in results['coupons']) {
        coupons.add(CouponModel.fromJson(item));
      }
    }

    return coupons;
  }

  Future<bool> deleteCoupon(context, delId, {bool isForce = false}) async {
    String apiURL = '$apiBase/apicoupons/deleteCouponInfo';
    await Webservice().loadHttp(context, apiURL, {
      'coupon_id': delId,
      'is_force': isForce ? '1' : '0',
    });
    return true;
  }
}
