import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';

import '../../../common/globals.dart' as globals;

class AdminFavoriteQuestionAdd extends StatefulWidget {
  const AdminFavoriteQuestionAdd({Key? key}) : super(key: key);

  @override
  _AdminFavoriteQuestionAdd createState() => _AdminFavoriteQuestionAdd();
}

class _AdminFavoriteQuestionAdd extends State<AdminFavoriteQuestionAdd> {
  var questionController = TextEditingController();
  var answerController = TextEditingController();

  String? errQuestion;
  String? errAnswer;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    globals.adminAppTitle = 'よくある質問登録';
    return MainBodyWdiget(
      render: Container(
        color: Colors.white,
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 15, bottom: 10),
              child: Text(
                '質問内容',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child: TextFormField(
                  controller: questionController,
                  decoration: InputDecoration(
                      errorText: errQuestion,
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(10))),
            ),
            Container(
              padding: EdgeInsets.only(top: 15, bottom: 10),
              child: Text('質問答え',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Container(
              child: TextFormField(
                  controller: answerController,
                  maxLines: 5,
                  decoration: InputDecoration(
                      errorText: errAnswer,
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(10))),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveQuestion() async {
    bool isCheck = true;
    if (questionController.text == '') {
      isCheck = false;
      errQuestion = warningCommonInputRequire;
    } else {
      errQuestion = null;
    }

    if (answerController.text == '') {
      isCheck = false;
      errAnswer = warningCommonInputRequire;
    } else {
      errAnswer = null;
    }

    setState(() {});
    if (!isCheck) return;

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiSaveFavortieQuestionUrl, {
      'company_id': globals.companyId,
      'question': questionController.text,
      'answer': answerController.text
    }).then((value) => results = value);

    if (results['isSave']) {
      Navigator.pop(context);
      // Navigator.push(context, MaterialPageRoute(builder: (_) {
      //   return AdminFavoriteQuestions();
      // }));
    }
  }
}
