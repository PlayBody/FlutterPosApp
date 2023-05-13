import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/interface/admin/advise/admin_advise_complete.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../../common/globals.dart' as globals;

class AdminAdviseAnswer extends StatefulWidget {
  final String adviseId;

  const AdminAdviseAnswer({required this.adviseId, Key? key}) : super(key: key);

  @override
  _AdminAdviseAnswer createState() => _AdminAdviseAnswer();
}

class _AdminAdviseAnswer extends State<AdminAdviseAnswer> {
  late Future<List> loadData;

  String question = '';
  String questionDate = '';
  String teacherName = '';
  String? errorText;
  var answerController = TextEditingController();

  var aController;
  var qController;
  File? _videoFile;

  @override
  void initState() {
    super.initState();
    loadData = loadInitData();
  }

  @override
  void dispose() {
    qController.dispose();
    super.dispose();
  }

  Future<List> loadInitData() async {
    Map<dynamic, dynamic> results = {};

    await Webservice().loadHttp(context, apiLoadAdviseInfoUrl,
        {'advise_id': widget.adviseId}).then((value) => results = value);

    if (results['isLoad']) {
      question = results['advise']['question'];
      questionDate = DateFormat('yyyy/MM/dd')
          .format(DateTime.parse(results['advise']['create_date']));

      teacherName = results['advise']['teacher_name'];
      answerController.text = results['advise']['answer'] == null
          ? ''
          : results['advise']['answer'];
      if (results['advise']['movie_file'] != null) {
        var vController = VideoPlayerController.network(
            adviseMovieBase + results['advise']['movie_file']);

        bool isLoadMovie = true;
        await vController
            .initialize()
            .onError((error, stackTrace) => isLoadMovie = false);
        if (isLoadMovie)
          qController = ChewieController(
            videoPlayerController: vController,
            autoPlay: false,
            looping: false,
          );
      }

      if (results['advise']['answer_movie_file'] != null) {
        var vController = VideoPlayerController.network(
            adviseMovieBase + results['advise']['answer_movie_file']);

        bool isLoadMovie = true;
        await vController
            .initialize()
            .onError((error, stackTrace) => isLoadMovie = false);

        if (isLoadMovie)
          aController = ChewieController(
            videoPlayerController: vController,
            autoPlay: false,
            looping: false,
          );
      }
    }

    setState(() {});
    return [];
  }

  void pushConfirmAddvise() {
    bool isFormCheck = true;
    if (answerController.text == '') {
      errorText = warningCommonInputRequire;
      isFormCheck = false;
    } else {
      errorText = null;
    }

    setState(() {});
    if (!isFormCheck) return;

    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return AdminAdviseComplete(
        adviseId: widget.adviseId,
        videoFile: _videoFile == null ? null : _videoFile!,
        answer: answerController.text,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    globals.adminAppTitle = 'アドバイス';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                  color: Colors.white,
                  padding: paddingMainContent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _getAdviseTop(),
                      _getMovieView(),
                      SizedBox(height: 10),
                      _getAdviseContent(),
                      _getConfirmButton(),
                    ],
                  ));
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget _getAdviseTop() {
    return Container(
        child: Row(
      children: [
        Container(width: 100, child: Text(questionDate)),
        Container(child: Text(teacherName, style: stylePageSubtitle)),
      ],
    ));
  }

  Widget _getMovieView() {
    if (qController == null) return Container();

    return Container(
        width: 170,
        height: 190,
        child: Chewie(
          controller: qController,
        ));
  }

  Widget _getAnswerMovieView() {
    if (aController == null) return Container();
    return Container(
        width: 170,
        height: 190,
        child: Chewie(
          controller: aController,
        ));
  }

  Widget _getAdviseContent() {
    return Expanded(
        child: Container(
            child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(child: Text('質問内容', style: stylePageSubtitle)),
          Container(child: Text(question, style: styleContent)),
          Container(height: 30),
          Container(child: Text('アドバイス', style: stylePageSubtitle)),
          Container(
            child: TextFormField(
              controller: answerController,
              decoration: InputDecoration(
                errorText: errorText,
                contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                filled: true,
                hintStyle: TextStyle(color: Colors.grey),
                fillColor: Colors.white.withOpacity(0.5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: BorderSide(color: Colors.grey)),
              ),
              maxLines: 10,
            ),
          ),
          SizedBox(height: 20),
          // Container(
          //   child: AdminImageUploadButton(
          //     tapFunc: () {},
          //   ),
          // ),
          _getAnswerMovieView(),
          _getSelectMovie(),
          SizedBox(height: 20),
        ],
      ),
    )));
  }

  Widget _getSelectMovie() {
    final ImagePicker _picker = ImagePicker();
    return Container(
      child: ElevatedButton(
        child: Text(('動画アップロード')),
        onPressed: () async {
          final XFile? video =
              await _picker.pickVideo(source: ImageSource.gallery);

          final path = video!.path;
          _videoFile = File(path);
          if (_videoFile != null) {
            var vController = VideoPlayerController.file(_videoFile!)
              ..initialize().then((_) {});
            aController = ChewieController(
              videoPlayerController: vController,
              aspectRatio: 16 / 9,
              autoPlay: false,
              looping: false,
            );
          }
          setState(() {
            _videoFile = File(video.path);
          });
          // video
        },
      ),
    );
  }

  Widget _getConfirmButton() {
    return Container(
      child: ElevatedButton(
          child: Text('確認画面へ'),
          onPressed: () {
            pushConfirmAddvise();
          }),
    );
  }
}
