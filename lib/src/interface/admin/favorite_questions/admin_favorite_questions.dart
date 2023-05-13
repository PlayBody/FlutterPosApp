import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/admin/favorite_questions/admin_favorite_question_add.dart';
import 'package:staff_pos_app/src/interface/admin/style/borders.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/model/favoritequestionmodel.dart';

import '../../../common/globals.dart' as globals;
import 'admin_favorite_question_add.dart';

class AdminFavoriteQuestions extends StatefulWidget {
  const AdminFavoriteQuestions({Key? key}) : super(key: key);

  @override
  _AdminFavoriteQuestions createState() => _AdminFavoriteQuestions();
}

class _AdminFavoriteQuestions extends State<AdminFavoriteQuestions> {
  late Future<List> loadData;
  List<FavoriteQuestionModel> questions = [];
  List<String> openQuerys = [];

  @override
  void initState() {
    super.initState();
    loadData = loadFavoriteQuestion();
  }

  @override
  Widget build(BuildContext context) {
    globals.adminAppTitle = 'お問い合わせ一覧';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                            decoration: borderBottomLine,
                            child: Text(
                              'よくあるご質問',
                              style: styleItemGroupTitle,
                            )),
                        ...questions.map((e) => Container(
                              padding: paddingItemGroupTitleSpace,
                              decoration: borderBottomLine,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      trailing: openQuerys.contains(e.id)
                                          ? Icon(Icons.keyboard_arrow_up)
                                          : Icon(Icons.keyboard_arrow_down),
                                      title: Text('Q. ' + e.question),
                                      onTap: () {
                                        if (openQuerys.contains(e.id)) {
                                          openQuerys.remove(e.id);
                                        } else {
                                          openQuerys.add(e.id);
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    if (openQuerys.contains(e.id))
                                      Container(
                                          padding: EdgeInsets.fromLTRB(
                                              30, 10, 40, 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text('A. '),
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                              ),
                                              Flexible(
                                                child: Text(e.answer),
                                              )
                                            ],
                                          ))
                                  ]),
                            )),
                      ]))),
                  Container(
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                              child: Text('よくある質問の追加'),
                              onPressed: () async {
                                await Navigator.push(context,
                                    MaterialPageRoute(builder: (_) {
                                  return AdminFavoriteQuestionAdd();
                                }));

                                loadFavoriteQuestion();
                              }),
                        ],
                      ))
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<List> loadFavoriteQuestion() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadFavortieQuestionUrl,
        {'company_id': globals.companyId}).then((value) => results = value);
    questions = [];
    if (results['isLoad']) {
      for (var item in results['questions']) {
        questions.add(FavoriteQuestionModel.fromJson(item));
      }
    }

    setState(() {});
    return [];
  }
}
