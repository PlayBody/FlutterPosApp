import 'dart:async';

import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/messagemodel.dart';

import '../../common/globals.dart' as globals;

class ClMessage {
  Future<List<MessageModel>> loadMessageList(context, String userId,
      {isGroup = ''}) async {
    Map<dynamic, dynamic> results = {};
    List<MessageModel> messages = [];

    String apiUrl = '$apiBase/apimessages/loadStaffMessages';

    await Webservice().loadHttp(context, apiUrl, {
      'user_id': userId,
      'company_id': globals.companyId,
      'staff_id': globals.staffId,
      'auth': globals.auth.toString(),
      'is_group': isGroup
    }).then((v) => {results = v});

    if (results['isLoad']) {
      for (var item in results['messages']) {
        messages.add(MessageModel.fromJson(item));
      }
    }
    return messages;
  }

  // Future<bool> sendMessage(context, userId, companyId, content, attachType,
  //     fileName, filePath, videoPath,
  //     {isGroup = ''}) async {
  //   String attachFileUrl = '';
  //   String attachVideoFile = '';
  //   if (attachType != '') {
  //     String dateFileName = DateTime.now()
  //         .toString()
  //         .replaceAll(':', '')
  //         .replaceAll('-', '')
  //         .replaceAll('.', '')
  //         .replaceAll(' ', '');
  //     // attachFileUrl = 'msg_attach_file_$dateFileName.jpg';
  //     // // if (attachType == '1') attachFileUrl = attachFileUrl + '.jpg';
  //     // // if (attachType == '2') attachFileUrl = attachFileUrl + '.mp4';
  //     // await Webservice().callHttpMultiPart(
  //     //     'upload', apiUploadMessageAttachFileUrl, filePath, attachFileUrl);

  //     if (attachType == '2') {
  //       // String dateFileName = DateTime.now()
  //       //     .toString()
  //       //     .replaceAll(':', '')
  //       //     .replaceAll('-', '')
  //       //     .replaceAll('.', '')
  //       //     .replaceAll(' ', '');
  //       attachVideoFile = 'msg_video_file_$dateFileName.mp4';

  //       await Webservice().callHttpMultiPartWithProgress(context, 'upload',
  //           apiUploadMessageAttachFileUrl, File(videoPath), attachVideoFile);

  //       // await Webservice().callHttpMultiPart(
  //       //     'upload', apiUploadMessageVideoFileUrl, videoPath, attachVideoFile);
  //     }
  //   }

  // String apiSendMessageUrl = '$apiBase/apimessages/sendStaffMessage';
  // Map<dynamic, dynamic> results = {};
  // await Webservice().loadHttp(context, apiSendMessageUrl, {
  //   'company_id': globals.companyId,
  //   'user_id': userId,
  //   'staff_id': globals.staffId,
  //   'content': content,
  //   'file_type': attachType,
  //   'file_name': fileName,
  //   'file_url': attachFileUrl,
  //   'video_url': attachVideoFile,
  //   'type': '2',
  //   'is_group': isGroup
  // }).then((value) => results = value);

  // return results['isSend'];
  //   return true;
  // }

  Future<String> loadUnreadMessageCount(context) async {
    Map<dynamic, dynamic> results = {};
    String apiUrl = '$apiBase/apimessages/getStaffUnreadCount';
    await Webservice().loadHttp(context, apiUrl, {
      'company_id': globals.companyId,
    }).then((v) => {results = v});
    return results['count'].toString();
  }
}
