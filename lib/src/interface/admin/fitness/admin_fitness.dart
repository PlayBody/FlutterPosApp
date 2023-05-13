// import 'dart:io';

// import 'package:chewie/chewie.dart';
// import 'package:dio/dio.dart';
// import 'package:external_path/external_path.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:staff_pos_app/src/common/apiendpoint.dart';
// import 'package:staff_pos_app/src/common/business/message.dart';
// import 'package:staff_pos_app/src/common/business/notification.dart';
// import 'package:staff_pos_app/src/common/dialogs.dart';
// import 'package:staff_pos_app/src/common/functions/chats.dart';
// import 'package:staff_pos_app/src/common/functions/seletattachement.dart';
// import 'package:staff_pos_app/src/common/messages.dart';
// import 'package:staff_pos_app/src/http/webservice.dart';
// import 'package:staff_pos_app/src/interface/admin/component/adminbutton.dart';
// import 'package:staff_pos_app/src/interface/admin/component/adminchat.dart';
// import 'package:staff_pos_app/src/interface/admin/component/admintextformfield.dart';
// import 'package:staff_pos_app/src/interface/admin/messages/dialog_attach_preview.dart';
// import 'package:staff_pos_app/src/model/fitnessmodel.dart';
// import 'package:staff_pos_app/src/model/messagemodel.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';

// import '../../../common/globals.dart' as globals;
// import '../layout/adminappbar.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// class AdminFitness extends StatefulWidget {
//   final String groupId;
//   const AdminFitness({required this.groupId, Key? key}) : super(key: key);

//   @override
//   _AdminFitness createState() => _AdminFitness();
// }

// class _AdminFitness extends State<AdminFitness> {
//   late Future<List> loadData;
//   List<MessageModel> messages = [];
//   String? token;
//   bool isSending = false;
//   bool isDownLoading = false;
//   var downloadingStr = '';
//   String filePath = '';
//   String fileName = '';
//   String videoPath = '';
//   String attachType = '';

//   var contentController = TextEditingController();
//   ScrollController _scrollController = new ScrollController();

//   // DatabaseReference _messagesRef =
//   //     FirebaseDatabase.instance.reference().child('messages');
//   // DatabaseReference _listRef =
//   //     FirebaseDatabase.instance.reference().child('lists');

//   //DatabaseReference _smslistRef =
//   //    FirebaseDatabase.instance.reference().child('sms_list');
//   //FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   bool isPageLoad = false;

//   @override
//   void initState() {
//     super.initState();

//     isPageLoad = true;
//     loadData = loadMessage();

//     FirebaseMessaging.onMessage.listen((event) {
//       if (isPageLoad) loadMessage();
//     });
//   }

//   Future<List<MessageModel>> loadMessage() async {
//     messages =
//         await ClMessage().loadMessageList(globals.companyId, '1', isGroup: '1');

//     contentController.clear();
//     filePath = '';
//     attachType = '';
//     return messages;
//   }

//   Future<void> sendMessage() async {
//     if (isSending) return;
//     if (contentController.text == '') {
//       isSending = false;
//       return;
//     }

//     isSending = true;
//     setState(() {});

//     bool isSend = await ClMessage().sendMessage(globals.companyId,
//         contentController.text, attachType, fileName, filePath, videoPath,
//         groupId: widget.groupId);

//     if (isSend) {
//       // await ClNotification().sendNotification(
//       //     'message',
//       //     '',
//       //     contentController.text,
//       //     globals.staffId,
//       //     '1',
//       //     jsonEncode([widget.userId]),
//       //     '2');

//       messages = await loadMessage();
//     } else {
//       Dialogs().infoDialog(context, errServerActionFail);
//     }
//     isSending = false;
//     setState(() {});
//   }

//   Future<void> selectPhoto() async {
//     var _select = await SelectAttachments().selectImageWithFile();
//     if (_select['file_path'] == null) return;
//     attachType = '1';
//     filePath = _select['file_path'];
//     fileName = _select['file_name'];
//     setState(() {});
//   }

//   Future<void> selectVideo() async {
//     var _select = await SelectAttachments().selectFileMovie();
//     if (_select['file_path'] == null) return;
//     attachType = '2';
//     filePath = _select['file_path'];
//     fileName = _select['file_name'];
//     videoPath = _select['video_file'];

//     setState(() {});
//   }

//   Future<void> clearAttachment() async {
//     filePath = '';
//     attachType = '';
//     videoPath = '';

//     setState(() {});
//   }

//   void pushPreviewAttach(String fileType, String fileUrl) {
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return DialogAttachPreview(
//               previewType: fileType,
//               attachUrl: apiBase + '/assets/messages/' + fileUrl);
//         });
//   }

//   Future<void> downloadFile(fileUrl, String fileName) async {
//     Dialogs().loaderDialogNormal(context);
//     await ChatsFunc().downloadAttachFile(fileUrl, fileName);
//     Navigator.pop(context);
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         0.0,
//         curve: Curves.easeOut,
//         duration: const Duration(milliseconds: 300),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     isPageLoad = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     globals.adminAppTitle = 'フィットネス';
//     WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToBottom());
//     return Scaffold(
//       // resizeToAvoidBottomInset: false,
//       appBar: AdminAppBar(),
//       body: FutureBuilder<List>(
//         future: loadData,
//         builder: (context, snapshot) {
//           if (snapshot.hasData && isDownLoading == false) {
//             return Column(children: [
//               _getChatListContent(),
//               SizedBox(height: 12),
//               ChatAttachContent(
//                 attachType: attachType,
//                 filePath: filePath,
//                 tapFunc: () => clearAttachment(),
//               ),
//               ChatInputContent(controller: contentController),
//               ChatInputButtons(
//                 tapPhotoFunc: () => selectPhoto(),
//                 tapVideoFunc: () => selectVideo(),
//                 tapSendFunc: () => sendMessage(),
//                 isSending: isSending,
//               ),
//             ]);
//           } else if (snapshot.hasError) {
//             return Text("${snapshot.error}");
//           }

//           // By default, show a loading spinner.
//           return Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }

//   Widget _getChatListContent() {
//     return Expanded(
//       child: ListView(
//         controller: _scrollController,
//         reverse: true,
//         shrinkWrap: true,
//         children: [
//           ...messages.map(
//             (e) => Container(
//               padding: e.type == '2'
//                   ? EdgeInsets.only(left: 120, right: 20, top: 20)
//                   : EdgeInsets.only(left: 20, right: 120, top: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   if (e.fileType != '')
//                     ChatListAttach(
//                         fileName: e.fileName,
//                         fileUrl: e.fileUrl,
//                         type: e.fileType,
//                         prevFunc: () => e.fileType == '2'
//                             ? pushPreviewAttach(e.fileType,
//                                 e.videoUrl == null ? '' : e.videoUrl!)
//                             : pushPreviewAttach(e.fileType, e.fileUrl),
//                         downloadFunc: () {
//                           downloadFile(
//                               e.fileType == '2'
//                                   ? (e.videoUrl == null ? '' : e.videoUrl)
//                                   : e.fileUrl,
//                               e.fileName);
//                         }),
//                   ChatListContent(
//                       content: e.content, type: e.type, readflag: e.readflag),
//                   ChatListDate(date: e.createDate),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
