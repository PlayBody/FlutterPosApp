import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/model/questionmodel.dart';

import '../../../common/globals.dart' as globals;

class AdminQuestions extends StatefulWidget {
  const AdminQuestions({Key? key}) : super(key: key);

  @override
  _AdminQuestions createState() => _AdminQuestions();
}

class _AdminQuestions extends State<AdminQuestions> {
  late Future<List> loadData;
  List<QuestionModel> questions = [];
  List<String> openQuerys = [];

  @override
  void initState() {
    super.initState();
    loadData = loadQuestions();
  }

  Future<List> loadQuestions() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadQuestionUrl,
        {'company_id': globals.companyId}).then((value) => results = value);
    questions = [];
    if (results['isLoad']) {
      for (var item in results['questions']) {
        questions.add(QuestionModel.fromJson(item));
      }
    }

    setState(() {});
    return [];
  }

  @override
  Widget build(BuildContext context) {
    globals.adminAppTitle = 'お客様からのお問い合わせ';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: 30),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...questions.map((e) => _getQuestionContent(e)),
                    ]),
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

  Widget _getQuestionContent(QuestionModel item) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      padding: EdgeInsets.only(top: 12, left: 12, right: 12),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          child: Text(
            item.questionTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (openQuerys.contains(item.questionId))
          Container(
            padding: EdgeInsets.only(top: 25, bottom: 15),
            child: Text(
              item.userName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        if (openQuerys.contains(item.questionId))
          Container(
            child: Text(
              item.question,
              style: TextStyle(fontSize: 14),
            ),
          ),
        if (openQuerys.contains(item.questionId))
          Container(
            padding: EdgeInsets.only(top: 8),
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              child: Text('返答する'),
              onPressed: item.answer == null ? () {} : null,
            ),
          ),
        Container(
          child: TextButton(
            child: Row(children: [
              openQuerys.contains(item.questionId) ? Text('非表示') : Text('表示'),
              openQuerys.contains(item.questionId)
                  ? Icon(Icons.keyboard_arrow_up)
                  : Icon(Icons.keyboard_arrow_down)
            ]),
            onPressed: () {
              if (openQuerys.contains(item.questionId)) {
                openQuerys.remove(item.questionId);
              } else {
                openQuerys.add(item.questionId);
              }
              setState(() {});
            },
          ),
        )
      ]),
    );
  }
}
