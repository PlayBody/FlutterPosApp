import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/business/coupon.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/pos/manage/companies/dlgstamp.dart';
import 'package:staff_pos_app/src/interface/pos/manage/companies/rank_edit.dart';
import 'package:staff_pos_app/src/model/companymodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/rankmodel.dart';
import 'package:staff_pos_app/src/model/rankprefermodel.dart';

var txtAccountingController = TextEditingController();
var txtMenuCountController = TextEditingController();
var txtSetTimeController = TextEditingController();
var txtSetAmountController = TextEditingController();
var txtTableAmountController = TextEditingController();

class Stamps extends StatefulWidget {
  final String companyId;
  const Stamps({required this.companyId, Key? key}) : super(key: key);

  @override
  State<Stamps> createState() => _Stamps();
}

class _Stamps extends State<Stamps> {
  late Future<List> loadData;
  List<CompanyModel> companyList = [];
  List<RankModel> ranks = [];
  List<RankPreferModel> prefers = [];

  @override
  void initState() {
    super.initState();
    loadData = loadCompanyList();
  }

  Future<List> loadCompanyList() async {
    ranks = await ClCoupon().loadRanks(context, widget.companyId);
    prefers = await ClCoupon().loadRankPrefers(context, widget.companyId, '');
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiLoadCompanyListUrl, {}).then((v) => {results = v});
    if (results['isLoad']) {
      companyList = [];

      for (var item in results['companies']) {
        companyList.add(CompanyModel.fromJson(item));
      }
    }
    setState(() {});
    return companyList;
  }

  Future<void> deleteOrgan(_id) async {
    bool conf = await Dialogs().confirmDialog(context, qCommonDelete);

    if (!conf) return;

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiDeleteOrganUrl,
        {'organ_id': _id}).then((v) => {results = v});
    if (!results['isDelete']) {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  Future<void> showStampEdit(String? rankId) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return RankEdit(rankId: rankId, companyId: widget.companyId);
    }));

    Dialogs().loaderDialogNormal(context);
    await loadCompanyList();
    Navigator.pop(context);
    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return DlgStamp(
    //         rankId: rankId,
    //         companyId: widget.companyId,
    //       );
    //     }).then((_) {
    //   setState(() {
    //     loadData = loadCompanyList();
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'スタンプ管理';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...ranks.map((e) => _getRankItemContent(e)),
                        ],
                      ),
                    )),
                    Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                        child: Row(children: [
                          PrimaryButton(
                            label: 'ランクの追加',
                            tapFunc: () async => showStampEdit(null),
                          )
                        ]))
                  ],
                ));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _getRankItemContent(RankModel rank) {
    return GestureDetector(
        onTap: () => showStampEdit(rank.rankId),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ListHeader1(label: rank.rankName),
              Row(
                children: [
                  Text(rank.rankName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Expanded(child: Container()),
                  SizedBox(width: 120, child: Text('最大スタンプ数 ${rank.maxStamp}')),
                ],
              ),
              const SizedBox(height: 12),
              ...prefers
                  .where((element) => element.rankId == rank.rankId)
                  .toList()
                  .map((e) => Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(child: Text('特典１'), width: 60),
                          Container(child: Text('スタンプ数'), width: 80),
                          Container(
                              alignment: Alignment.centerRight,
                              child: Text(e.stampCount.toString()),
                              width: 30),
                          SizedBox(width: 16),
                          Expanded(
                              child: Text(
                            e.prefType == '1' ? e.menuName : e.couponName,
                            style: TextStyle(fontSize: 10),
                          ))
                        ],
                      ))),
              // WhiteButton(label: '特典の追加', tapFunc: () {})
            ],
          ),
        ));
  }
}
