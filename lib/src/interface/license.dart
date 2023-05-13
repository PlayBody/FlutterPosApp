import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/interface/login.dart';
import 'package:flutter_html/flutter_html.dart';

class LicenseView extends StatefulWidget {
  const LicenseView({Key? key}) : super(key: key);

  @override
  _LicenseView createState() => _LicenseView();
}

class _LicenseView extends State<LicenseView> {
  late Future<List> loadData;

  bool ischeck = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            body: Center(
                child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 30),
                child: Text(
                  '利用規約',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: [
                Container(
                    padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                    child: Html(
                      data: licenseHtml,
                      style: {
                        'h5':
                            Style(padding: EdgeInsets.only(top: 20, bottom: 5))
                      },
                    )),
                Container(
                    padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                    child: Row(
                      children: [
                        Checkbox(
                            value: ischeck,
                            onChanged: (v) {
                              setState(() {
                                ischeck = v!;
                              });
                            }),
                        Container(child: Text('すべて読みました。'))
                      ],
                    ))
              ]))),
              Container(
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Color.fromARGB(255, 230, 230, 230),
                                  width: 1,
                                ),
                                right: BorderSide(
                                  color: Color.fromARGB(255, 230, 230, 230),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: TextButton(
                              child: Text('同意します。'),
                              onPressed: ischeck
                                  ? () {
                                      acceptLicense();
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (_) {
                                        return Login();
                                      }));
                                    }
                                  : null,
                            ))),
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Color.fromARGB(255, 230, 230, 230),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: TextButton(
                              child: Text('同意しない。'),
                              onPressed: () {
                                exit(1);
                              },
                            )))
                  ],
                ),
              )
            ],
          ),
        ))));
  }

  Future<void> acceptLicense() async {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('is_old_run', true);
  }
}
