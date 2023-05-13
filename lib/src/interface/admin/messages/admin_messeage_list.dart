import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/admin/messages/admin_messeage_make.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/admin/style/buttonstyles.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/model/messageusermodel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../common/globals.dart' as globals;

class AdminMesseageList extends StatefulWidget {
  const AdminMesseageList({Key? key}) : super(key: key);

  @override
  _AdminMesseageList createState() => _AdminMesseageList();
}

class _AdminMesseageList extends State<AdminMesseageList> {
  late Future<List> loadData;
  List<MessageUserModel> messageUsers = [];
  bool isPageLoad = false;

  var searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData = loadMessageUserList();
    isPageLoad = true;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String notificationType = message.data['type'].toString();
      if (notificationType == 'message') {
        loadMessageUserList();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    isPageLoad = false;
  }

  Future<List> loadMessageUserList() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadMessageUserListUrl, {
      'company_id': globals.companyId,
      'search': searchController.text
    }).then((value) => results = value);
    messageUsers = [];

    if (results['isLoad']) {
      for (var item in results['message_users']) {
        messageUsers.add(MessageUserModel.fromJson(item));
      }
    }

    setState(() {});
    return [];
  }

  Future<void> pushMessageMake(user) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return AdminMesseageMake(
        userId: user.userId,
        userName: user.userName,
        isGroup: false,
      );
    }));
    loadMessageUserList();
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'メッセージ一覧';
    return MainBodyWdiget(
        render: FutureBuilder<List>(
      future: loadData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
              color: bodyColor,
              padding: paddingMainContent,
              child: Column(
                children: [
                  _getSearchContent(),
                  _getUserListContent(),
                ],
              ));
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    ));
  }

  Widget _getSearchContent() {
    return Container(
      child: Container(
        padding: paddingAdminSearchBottom,
        child: TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, size: 24, color: Colors.grey),
            contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            filled: true,
            hintText: '検索',
            hintStyle: TextStyle(color: Colors.grey),
            fillColor: Colors.white.withOpacity(0.5),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(color: Colors.grey)),
          ),
          onChanged: (v) => loadMessageUserList(),
        ),
      ),
    );
  }

  Widget _getUserListContent() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [...messageUsers.map((e) => _getMessageItemContent(e))],
        ),
      ),
    );
  }

  Widget _getMessageItemContent(MessageUserModel item) {
    return Container(
        margin: new EdgeInsets.symmetric(vertical: 12.0),
        child: ElevatedButton(
          child: Stack(
            children: [
              Positioned(
                  child: Container(
                      padding: paddingUserNameGruop,
                      child: Row(children: [
                        Container(
                            width: 120,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.organName != '')
                                    Text('to ' + item.organName,
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.green)),
                                  Text(item.userName, style: styleUserName1)
                                ])),
                        Container(
                            child: Text(
                                item.content.length > 9
                                    ? item.content.substring(0, 9) + '｡｡｡'
                                    : item.content,
                                style: styleContent))
                      ]))),
              if (item.unreadCnt != '' && item.unreadCnt != '0')
                Positioned(
                    right: 10,
                    child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.red),
                        width: 30,
                        height: 30,
                        child: Text(item.unreadCnt,
                            style: TextStyle(color: Colors.white))))
            ],
          ),
          style: styleGroupButton,
          onPressed: () => pushMessageMake(item),
        ));
  }
}
