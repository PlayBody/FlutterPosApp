import 'dart:io';

import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import '../apiendpoint.dart';

class ChatsFunc {
  Future<void> downloadAttachFile(fileUrl, String fileName) async {
    try {
      Dio dio = Dio();
      String savePath = '';
      if (Platform.isAndroid) {
        savePath = (await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS));
      } else {
        Directory dirPath = await getApplicationDocumentsDirectory();
        savePath = dirPath.path;
      }
      String filePath = '$savePath/$fileName';

      int i = 0;
      while (File(filePath).existsSync()) {
        i++;
        filePath =
            '$savePath/${fileName.substring(0, fileName.length - 4)}[$i]${fileName.substring(fileName.length - 4)}';
      }

      await dio.download('$apiBase/assets/messages/$fileUrl', filePath,
          onReceiveProgress: (rec, total) {
        // setState(() {
        //   isDownLoading = true;
        //   // download = (rec / total) * 100;
        //   downloadingStr = "Downloading : $rec";
        // });
      });

      Fluttertoast.showToast(msg: 'ダウンロードされました。$filePath');
    } catch (e) {
      //print(e.toString());
    }
  }
}
