import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/admin/advise/admin_advise_answer.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';

// import 'package:staff_pos_app/src/interface/admin/advise/admin_teacher_add.dart';
import 'package:staff_pos_app/src/model/advisemodel.dart';
import 'package:staff_pos_app/src/model/stafflistmodel.dart';
// import 'package:staff_pos_app/src/model/teachermodel.dart';
// import 'package:staff_pos_app/src/interface/admin/component/adminbutton.dart';
import 'package:staff_pos_app/src/interface/admin/component/adminsearch.dart';
import 'package:staff_pos_app/src/interface/admin/style/borders.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';

import 'package:video_player/video_player.dart';

import '../../../common/globals.dart' as globals;

class AdminAdvises extends StatefulWidget {
  const AdminAdvises({Key? key}) : super(key: key);

  @override
  _AdminAdvises createState() => _AdminAdvises();
}

class _AdminAdvises extends State<AdminAdvises> {
  late Future<List> loadData;

  bool isTeacherList = false;
  List<StaffListModel> teachers = [];
  List<AdviseModel> advises = [];

  @override
  void initState() {
    super.initState();
    loadData = loadInitData();
  }

  Future<List> loadInitData() async {
    Map<dynamic, dynamic> resultsTeacher = {};
    await Webservice().loadHttp(context, apiLoadCompanyStaffListUrl, {
      'company_id': globals.companyId
    }).then((value) => resultsTeacher = value);
    teachers = [];
    if (resultsTeacher['isLoad']) {
      for (var item in resultsTeacher['data']) {
        teachers.add(StaffListModel.fromJson(item));
      }
    }
    Map<dynamic, dynamic> resultsAdvise = {};
    await Webservice().loadHttp(context, apiLoadAdviseListUrl, {
      'company_id': globals.companyId
    }).then((value) => resultsAdvise = value);

    advises = [];
    if (resultsAdvise['isLoad']) {
      for (var item in resultsAdvise['advise_list']) {
        var _controller =
            VideoPlayerController.network(adviseMovieBase + item['movie_file']);
        bool isLoadMovie = true;
        await _controller
            .initialize()
            .onError((error, stackTrace) => isLoadMovie = false);

        if (isLoadMovie) item['controller'] = _controller;
        advises.add(AdviseModel.fromJson(item));
      }
    }

    setState(() {});
    return [];
  }

  @override
  Widget build(BuildContext context) {
    globals.adminAppTitle = 'アドバイス質問一覧';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: Colors.white,
              padding: paddingMainContent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminSearch(tapFunc: (v) {}),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          trailing: isTeacherList
                              ? Icon(Icons.keyboard_arrow_up)
                              : Icon(Icons.keyboard_arrow_down),
                          title: Text('先生一覧'),
                          onTap: () {
                            setState(() {
                              isTeacherList = !isTeacherList;
                            });
                          },
                        ),
                        if (isTeacherList)
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Container(
                                //   child: AdminAddButton(
                                //     label: '✛ 先生の追加',
                                //     tapFunc: () async {
                                //       await Navigator.push(context,
                                //           MaterialPageRoute(builder: (_) {
                                //         return AdminTeacherAdd();
                                //       }));
                                //       loadInitData();
                                //     },
                                //   ),
                                // ),
                                ...teachers.map((e) => Container(
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      padding: paddingUserNameGruop,
                                      decoration: borderAllRadius8,
                                      child: Text(
                                        e.staffFirstName! +
                                            ' ' +
                                            e.staffLastName!,
                                        style: styleUserName1,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        Container(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: Text('アドバイス待ち一覧', style: stylePageSubtitle)),
                        ...advises.map(
                          (e) => Container(
                              padding: EdgeInsets.only(bottom: 12),
                              child: _getAdviseItem(e)),
                        )
                      ],
                    ),
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

  Widget _getAdviseItem(AdviseModel item) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return AdminAdviseAnswer(adviseId: item.adviseId);
          }));
        },
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
            primary: Colors.white,
            onPrimary: Colors.black,
            side: BorderSide(
              width: 1,
              color: Color.fromARGB(255, 200, 200, 200),
            ),
            elevation: 0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Container(
                      width: 80,
                      child: Text(
                        item.updateDate,
                        style: styleContent,
                      )),
                  Container(
                      width: 110,
                      child: item.teacherName == null
                          ? Text('')
                          : Text(item.teacherName!, style: styleUserName1)),
                  Container(child: Text(item.userName, style: styleUserName1)),
                ],
              ),
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getMovieView(item.videoController, item.adviseId),
                  // Container(
                  //   padding: EdgeInsets.only(right: 20, top: 5),
                  //   width: 170,
                  //   height: 120,
                  //   child: Image.asset(
                  //     'images/background.jpg',
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  Expanded(
                      child: Container(
                          child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          child: Text(
                        '質問内容',
                        style: styleItemGroupTitle,
                      )),
                      Container(
                          padding: paddingContentLineSpace,
                          child: Text(item.question)),
                      Container(
                          child: ElevatedButton(
                        child: Text(item.answer == null ? '回答する' : '回答済み'),
                        onPressed: () {},
                      ))
                    ],
                  ))),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _getMovieView(_controller, adviseId) {
    if (_controller == null) return Container(width: 170);

    return Container(
        padding: EdgeInsets.only(right: 20),
        width: 170,
        child: Stack(children: [
          _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
              : Container(),
          if (_controller != null)
            Positioned.fill(
                child: Center(
              child: FloatingActionButton(
                heroTag: "btn" + adviseId,
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            ))
        ]));
  }
}
