import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/company_site_model.dart';
import 'package:staff_pos_app/src/model/companymodel.dart';

import '../apiendpoint.dart';

class ClCompany {
  Future<List<CompanyModel>> loadCompanyList(context) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiLoadCompanyListUrl, {}).then((v) => {results = v});
    List<CompanyModel> companies = [];
    if (results['isLoad']) {
      for (var item in results['companies']) {
        companies.add(CompanyModel.fromJson(item));
      }
    }
    return companies;
  }

  Future<CompanyModel> loadCompanyInfo(context, String companyId) async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadCompanyInfoUrl,
        {'company_id': companyId}).then((v) => {results = v});
    if (results['isLoad']) {
      return CompanyModel.fromJson(results['company']);
    }
    return const CompanyModel(
        companyId: '',
        companyName: '',
        companyDomain: '',
        ecUrl: '',
        companyReceiptNumber: '',
        companyPrintOrder: '',
        visible: '');
  }

  Future<CompanyModel> loadCompanyPrintInfo(context, String companyId) async {
    String api = '$apiBase/apicompanies/loadPrintCompanyInfo';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, api, {'company_id': companyId}).then((v) => {results = v});
    if (results['isLoad']) {
      return CompanyModel.fromJson(results['company']);
    }
    return const CompanyModel(
        companyId: '',
        companyName: '',
        companyDomain: '',
        ecUrl: '',
        companyReceiptNumber: '',
        companyPrintOrder: '',
        visible: '');
  }

  Future<List<CompanySiteModel>> loadCompanySites(
      context, String companyId) async {
    List<CompanySiteModel> sites = [];

    String apiUrl = '$apiBase/apicompanies/getCompanySites';
    await Webservice()
        .loadHttp(context, apiUrl, {'company_id': companyId}).then(
            (results) => {
                  for (var item in results['sites'])
                    {sites.add(CompanySiteModel.fromJson(item))}
                });

    return sites;
  }

  Future<void> saveCompanySite(
      context, String companyId, siteId, title, url) async {
    String apiUrl = '$apiBase/apicompanies/saveCompanySite';
    await Webservice().loadHttp(context, apiUrl, {
      'company_id': companyId,
      'site_id': siteId ?? '',
      'site_title': title,
      'site_url': url
    });
  }

  Future<void> deleteCompanySite(context, siteId) async {
    String apiUrl = '$apiBase/apicompanies/deleteCompanySite';
    await Webservice().loadHttp(context, apiUrl, {
      'site_id': siteId,
    });
  }
}
