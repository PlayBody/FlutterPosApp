import 'dart:io';

import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/admin/advise/admin_advises.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:video_player/video_player.dart';

import '../../../common/globals.dart' as globals;

class AdminAdviseComplete extends StatefulWidget {
  final String adviseId;
  final File? videoFile;
  final String answer;
  const AdminAdviseComplete(
      {required this.adviseId, this.videoFile, required this.answer, Key? key})
      : super(key: key);

  @override
  _AdminAdviseComplete createState() => _AdminAdviseComplete();
}

class _AdminAdviseComplete extends State<AdminAdviseComplete> {
  late Future<List> loadData;
  String question = '';
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    loadData = loadAdviseData();
  }

  Future<List> loadAdviseData() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadAdviseInfoUrl,
        {'advise_id': widget.adviseId}).then((value) => results = value);

    if (results['isLoad']) {
      question = results['advise']['question'];
    }

    if (widget.videoFile != null)
      _controller = VideoPlayerController.file(widget.videoFile!)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
        });
    setState(() {});
    return [];
  }

  Future<void> saveAdvise() async {
    String videoFileName = '';
    if (widget.videoFile != null) {
      videoFileName = 'advise-video' +
          DateTime.now()
              .toString()
              .replaceAll(':', '')
              .replaceAll('-', '')
              .replaceAll('.', '')
              .replaceAll(' ', '') +
          '.mp4';

      await Webservice().callHttpMultiPart('upload', apiUploadAdviseVideo,
          widget.videoFile!.path, videoFileName);
    }

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiSaveAdviseInfoUrl, {
      'advise_id': widget.adviseId,
      'answer': widget.answer,
      'answer_movie_file': videoFileName,
    }).then((value) => results = value);
    if (results['isSave']) {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return AdminAdvises();
      }));
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
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
                      _getAdviseContent(),
                      _getSubmitButton(),
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

  Widget _getAdviseContent() {
    return Expanded(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(child: Text('質問内容', style: stylePageSubtitle)),
            Container(child: Text(question, style: styleContent)),
            Container(height: 50),
            Container(child: Text('アドバイス', style: stylePageSubtitle)),
            Container(child: Text(widget.answer, style: styleContent)),
            SizedBox(height: 30),
            _getMovieView()
          ],
        ),
      ),
    );
  }

  Widget _getMovieView() {
    if (_controller == null) return Container();

    return Container(
        padding: EdgeInsets.only(right: 20),
        child: Stack(children: [
          _controller!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
              : Container(),
          if (_controller != null)
            Positioned.fill(
                child: Center(
              child: FloatingActionButton(
                heroTag: "btn",
                onPressed: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
                child: Icon(
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            ))
        ]));
  }

  Widget _getSubmitButton() {
    return Container(
      child: ElevatedButton(
          child: Text('確定'),
          onPressed: () {
            saveAdvise();
          }),
    );
  }
}
