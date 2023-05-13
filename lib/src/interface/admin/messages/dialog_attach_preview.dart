import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/functions/seletattachement.dart';
import 'package:staff_pos_app/src/interface/admin/component/adminbutton.dart';

class DialogAttachPreview extends StatefulWidget {
  final String previewType;
  final String attachUrl;

  const DialogAttachPreview({
    Key? key,
    required this.previewType,
    required this.attachUrl,
  }) : super(key: key);

  @override
  _DialogAttachPreview createState() => _DialogAttachPreview();
}

class _DialogAttachPreview extends State<DialogAttachPreview> {
  var videoController;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();

    loadShift();
  }

  @override
  void dispose() {
    if (videoController != null) videoController.dispose();
    super.dispose();
  }

  Future<void> loadShift() async {
    if (widget.previewType == '2') {
      videoController = await SelectAttachments()
          .loadVideoNetWorkController(widget.attachUrl);
    }
    isLoading = false;
    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          // borderRadius: BorderRadius.circular(AppConst.padding),
          ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()), height: 120)
          : contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (widget.previewType == '1')
          Positioned(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    child: Image.network(widget.attachUrl, fit: BoxFit.contain))
              ],
            ),
          ),
        if (widget.previewType == '2')
          Positioned(
              child: videoController == null
                  ? Container()
                  : Container(
                      height: MediaQuery.of(context).size.height * 0.85,
                      child: Chewie(
                        controller: videoController,
                      ))),
        Positioned(
            right: -40,
            top: 0,
            child: AdminBtnCircleClose(tapFunc: () => Navigator.pop(context))),
      ],
    );
  }
}
