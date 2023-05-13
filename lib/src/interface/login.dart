// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:staff_pos_app/src/common/business/common.dart';
import 'package:staff_pos_app/src/common/business/organ.dart';
import 'package:staff_pos_app/src/common/business/staffs.dart';
import 'package:staff_pos_app/src/common/business/user.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/interface/admin/messages/admin_messeage_make.dart';
import 'package:staff_pos_app/src/interface/home.dart';
import 'package:staff_pos_app/src/interface/pos/accounting/tables.dart';
import 'package:staff_pos_app/src/interface/pos/shifts/shift.dart';
import 'package:staff_pos_app/src/interface/pos/staffs/staffpoint.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_pos_app/src/interface/style/sizes.dart';
import 'package:staff_pos_app/src/interface/style/textstyles.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/staff_model.dart';
import 'package:local_auth/local_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../common/globals.dart' as globals;

class Login extends StatefulWidget {
  const Login({
    Key? key,
  }) : super(key: key);

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  late Future<String> loadData;
  String? email;
  String? password;
  String errMsg = '';
  bool isSaveLoginInfo = true;

  bool isFaceId = true;

  int checkAuthCountByFaceId = 0;

  var emailController = TextEditingController();
  var passController = TextEditingController();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;

  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> checkDeviceSupported() async {
    final bool isDeviceSupported = await auth.isDeviceSupported();
    if (isDeviceSupported) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> normalAuthenticate() async {
    try {
      final bool didAuthenticate =
          await auth.authenticate(localizedReason: '認証してください。');
      if (didAuthenticate) {
        await loginProcess(email!, password!, true);
      }
      return didAuthenticate;
    } on PlatformException catch (e) {
      Fluttertoast.showToast(
          msg: 'システム設定でデバイスパスワードを設定してください。', toastLength: Toast.LENGTH_LONG);
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    checkAuthCountByFaceId = 0;
    loadData = loadSaveInfo();

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'visit-pos-id', // id
        'visit-pos-title', // title
        description: 'visit-pos-description', // description
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {});

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                // channelDescriptoion: channel.description,
                icon: 'launch_background',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (!globals.isLogin) return;
      String notificationType = message.data['type'].toString();

      if (notificationType == '16') {
        if (message.data['sender_id'] == null) return;
        pushMessageMake(message.data['sender_id'].toString());
      }

      if (notificationType == '11' ||
          notificationType == '12' ||
          notificationType == '13' ||
          notificationType == '15') {
        pushShift();
      }

      if (notificationType == 'add_point_request') {
        pushPointApply(message.data['sender_id'].toString());
      }
    });
  }

  Future<void> pushMessageMake(String userId) async {
    var user = await ClUser().loadUserInfo(context, userId);
    if (user['user_id'] == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return AdminMesseageMake(
          userId: user['user_id'],
          userName: user['user_first_name'] + ' ' + user['user_last_name'],
          isGroup: false);
    }));
  }

  Future<void> pushShift() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return Shift();
    }));
  }

  Future<void> pushPointApply(staffId) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return StaffPoint(staffId: staffId);
    }));
  }

  Future<String> loadSaveInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('login_id') ?? '';
    password = prefs.getString('login_password') ?? '';
    isSaveLoginInfo = prefs.getBool(globals.isSaveLoginInfoKey) ?? false;
    if (isSaveLoginInfo) {
      emailController.text = email == null ? '' : email!;
      passController.text = password == null ? '' : password!;
    }
    bool faceAuthDeviceStatus = await checkDeviceSupported();
    if (!faceAuthDeviceStatus) {
      isFaceId = false;
    } else {
      String faceIdStatus = prefs.getString(globals.isBiometricEnableKey) ?? '';
      if (faceIdStatus == 'yes') {
        isFaceId = true;
        bool status = await normalAuthenticate();
        if (status) {
          // await loginProcess(email!, password!, true);
        } else {}
      } else {
        isFaceId = false;
      }
    }

    setState(() {});
    return '';
  }

  Future<void> loginProcess(
      String email, String password, bool isBiometric) async {
    if (!isFormInputCheck() && !isBiometric) {
      setState(() {});
      return;
    }

    Dialogs().loaderDialogNormal(context);
    StaffModel? staff = await ClStaff().login(context, email, password);

    if (staff == null) {
      Navigator.pop(context);
      globals.isLogin = false;
      this.errMsg = 'メールアドレス、パスワードが正しくありません。';
      setState(() {});
      return;
    }

    String? deviceToken;
    await FirebaseMessaging.instance.getToken().then((token) {
      deviceToken = token;
    }).catchError(() {
      deviceToken = '';
    });
    await ClCommon().registerDeviceToken(context, staff.staffId, deviceToken);

    globals.isLogin = true;
    globals.staffId = staff.staffId;
    globals.auth = int.parse(staff.auth);
    globals.companyId = staff.companyId;
    globals.loginEmail = staff.mail;
    globals.loginName = staff.nick;
    if (staff.nick == '') {
      globals.loginName = staff.firstName + ' ' + staff.lastName;
    }
    Navigator.pop(context);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // if (isSaveLoginInfo) {
    prefs.setBool(globals.isSaveLoginInfoKey, isSaveLoginInfo);
    prefs.setString('login_id', emailController.text);
    prefs.setString('login_password', passController.text);
    // if (!isBiometric) {
    if (isFaceId) {
      prefs.setString(globals.isBiometricEnableKey, 'yes');
    } else {
      prefs.setString(globals.isBiometricEnableKey, 'no');
    }
    // } else {
    //   // prefs.setString('login_id', '');
    //   // prefs.setString('login_password', '');
    // }

    if (globals.auth == constAuthGuest) {
      List<OrganModel> organs =
          await ClOrgan().loadOrganList(context, '', staff.staffId);

      if (organs.isNotEmpty) {
        globals.organId = organs.first.organId;
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return Tables();
      }));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return Home();
      }));
    }
  }

  bool isFormInputCheck() {
    if (emailController.text == '') {
      errMsg = 'メールアドレスをありません。';
      return false;
    }
    if (passController.text == '') {
      errMsg = 'パスワードをありません。';
      return false;
    }
    return true;
  }

  Future<void> changeBiometricStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      prefs.setString(globals.isBiometricEnableKey, 'yes');
    } else {
      prefs.setString(globals.isBiometricEnableKey, 'no');
    }
    if (await checkDeviceSupported()) {
      isFaceId = value;
    } else {
      Fluttertoast.showToast(
          msg: 'システム設定でデバイスパスワードを設定してください。', toastLength: Toast.LENGTH_LONG);
      isFaceId = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    globals.isWideScreen = (MediaQuery.of(context).size.height > 600 &&
        MediaQuery.of(context).size.width > 600);
    return WillPopScope(
        onWillPop: () async => false,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: FutureBuilder<String>(
                  future: loadData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return OrientationBuilder(
                          builder: (context, orientation) {
                        return _getBodyContent();
                      });
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    // By default, show a loading spinner.
                    return const Center(child: CircularProgressIndicator());
                  },
                )),
          ),
        ));
  }

  Widget _getBodyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _getTopSapceContent(),
          _getTitleContent(),
          Container(
            width: 500,
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _getErrMessage(),
                _getInputLabel('メールアドレス'),
                _getInputMailAddress(),
                const SizedBox(height: 20),
                _getInputLabel('パスワード'),
                _getInputPasswordContent(),
                _getSaveLoginInfo(),
                _getBiometricSettingView(),
                const SizedBox(height: 25),
                _getLoginBtn(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTopSapceContent() {
    return (MediaQuery.of(context).size.height > 700)
        ? Container(
            height: (MediaQuery.of(context).size.height - 650) / 2,
          )
        : Container();
  }

  Widget _getTitleContent() {
    return Center(
      child: Text(
        'Visit',
        style: globals.isWideScreen ? styleLogoTitleTablet : styleLogoTitle,
      ),
    );
  }

  Widget _getBiometricSettingView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          '次回以後ログイン設定',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        Switch(
          value: isFaceId,
          onChanged: (value) {
            changeBiometricStatus(value);
          },
          activeTrackColor: Colors.lightGreenAccent,
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _getSaveLoginInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Expanded(child: Container()),
        Theme(
          data: ThemeData(unselectedWidgetColor: Colors.white),
          child: Checkbox(
            checkColor: Colors.blue,
            activeColor: Colors.white,
            value: isSaveLoginInfo,
            onChanged: (v) {
              setState(() {
                isSaveLoginInfo = v!;
              });
            },
          ),
        ),
        const Text(
          'メールアドレス / ログインIDを保存する',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        // Expanded(child: Container()),
      ],
    );
  }

  Widget _getLoginBtn() {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        width: !globals.isWideScreen
            ? sizeLoginButtonWidth
            : sizeLoginButtonWidthTablet,
      ),
      child: ElevatedButton(
        onPressed: () =>
            loginProcess(emailController.text, passController.text, false),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          primary: Colors.white.withOpacity(0.7),
          onPrimary: Colors.blue,
          padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          textStyle:
              !globals.isWideScreen ? styleLoginButton : styleLoginButtonTablet,
        ),
        child: const Text('ログイン'),
      ),
    );
  }

  Widget _getErrMessage() {
    return Text(
      errMsg,
      style: const TextStyle(color: Colors.red, wordSpacing: -1),
    );
  }

  Widget _getInputLabel(String label) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(5),
      child: Text(label,
          style: !globals.isWideScreen
              ? styleTextFormLabel
              : styleTextFormLabelTablet),
    );
  }

  Widget _getInputMailAddress() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: emailController,
      // autofocus: email == '',
      textInputAction: TextInputAction.next,
      style: !globals.isWideScreen
          ? styleTextFormFieldLogin
          : styleTextFormFieldLoginTablet,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.account_circle,
            size: !globals.isWideScreen ? sizeInputIcon : sizeInputIconTablet),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        filled: true,
        hintText: 'メールアドレスまたはログインID',
        hintStyle: const TextStyle(color: Colors.grey),
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide.none),
      ),
      enableInteractiveSelection: true,
      onTap: () => emailController.selection = TextSelection(
          baseOffset: 0, extentOffset: emailController.value.text.length),
    );
  }

  Widget _getInputPasswordContent() {
    return TextFormField(
      style: !globals.isWideScreen
          ? styleTextFormFieldLogin
          : styleTextFormFieldLoginTablet,
      controller: passController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock,
            size: !globals.isWideScreen ? sizeInputIcon : sizeInputIconTablet),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        fillColor: Colors.white.withOpacity(0.5),
        filled: true,
        hintText: '○〜○文字の半角英数',
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide.none),
      ),
      obscureText: true,
      onTap: () => passController.selection = TextSelection(
          baseOffset: 0, extentOffset: passController.value.text.length),
    );
  }
}
