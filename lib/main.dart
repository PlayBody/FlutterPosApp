import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_pos_app/src/common/business/common.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/common/global_service.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/interface/license.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/interface/login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)
      .then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: MaterialApp(
        navigatorKey: GlobalService.navigatorKey,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        // ignore: prefer_const_literals_to_create_immutables
        supportedLocales: [
          const Locale('ja'),
          const Locale('en'),
        ],
        locale: const Locale('ja'),
        debugShowCheckedModeBanner: false,
        title: 'Form Samples',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AppInit(), //ConnectRegister(), //AdminHome(), //AppInit(),
        routes: <String, WidgetBuilder>{
          '/Login': (BuildContext context) => const Login(),
          '/License': (BuildContext context) => const LicenseView()
        },
      ),
    );
  }
}

class AppInit extends StatefulWidget {
  const AppInit({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  State<AppInit> createState() => _AppInit();
}

class _AppInit extends State<AppInit> {
  late Future<List> loadData;
  Future<void>? launched;

  @override
  void initState() {
    super.initState();
    loadData = loadAppData();
  }

  Future<List> loadAppData() async {
    bool isVersionOK = await ClCommon().loadAppVersion(context);

    if (isVersionOK) {
      if (await isFirstTime()) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/License');
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/Login');
      }
    } else {
      bool conf =
          // ignore: use_build_context_synchronously
          await Dialogs().oldVersionDialog(context, warningVersionUpdate);
      if (conf) {
        launched = _launchInBrowser();
        setState(() {});
      }
    }
    return [];
  }

  Future<bool> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('is_old_run') == null ||
        prefs.getBool('is_old_run') == false) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _launchInBrowser() async {
    String url = consAndroidStore;
    launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container();
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
