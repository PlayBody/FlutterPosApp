import 'package:flutter/material.dart';

import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/dropdowns.dart';

import 'messages.dart';
import 'globals.dart' as globals;

class Dialogs {
  Future<void> loaderDialogNormal(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Center(child: CircularProgressIndicator()),
          );
        });
  }

  Future<void> loaderDialogNormalWithProgress(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: SizedBox(
              width: 120,
              height: 150,
              child: Column(children: [
                Text('Uploading...${globals.progressPercent}%'),
                const Center(child: CircularProgressIndicator())
              ]),
            ),
          );
        });
  }

  void infoDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<bool> confirmDialog(BuildContext context, String message) async {
    final value = await showPlatformDialog(
      context: context,
      builder: (context) => BasicDialogAlert(
        title: Text(message),
        // content: Text("Action cannot be undone."),
        actions: <Widget>[
          BasicDialogAction(
            title: const Text("はい"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          BasicDialogAction(
            title: const Text("いいえ"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );
    return value == true;
  }

  Future<bool> confirmWithWidgetDialog(
      BuildContext context, String message, Widget widget) async {
    final value = await showPlatformDialog(
      context: context,
      builder: (context) => BasicDialogAlert(
          title: Text(message),
          content: widget,
          actions: <Widget>[
            BasicDialogAction(
                title: const Text("はい"),
                onPressed: () => Navigator.of(context).pop(true)),
            BasicDialogAction(
                title: const Text("いいえ"),
                onPressed: () => Navigator.of(context).pop(false)),
          ]),
    );

    return value == true;
  }

  Future<String> confirmWithSelectNumberDialog(BuildContext context,
      String message, String selectMessage, int max) async {
    String sel = '1';
    final value = await showPlatformDialog(
      context: context,
      builder: (context) => BasicDialogAlert(
          title: Text(message),
          content: SizedBox(
              height: 90,
              child: Column(children: [
                Text(selectMessage),
                const SizedBox(height: 12),
                DropDownNumberSelect(
                    value: sel,
                    max: max,
                    tapFunc: (v) {
                      sel = v;
                    })
              ])),
          actions: <Widget>[
            BasicDialogAction(
                title: const Text("はい"),
                onPressed: () => Navigator.of(context).pop(sel)),
            BasicDialogAction(
                title: const Text("いいえ"),
                onPressed: () => Navigator.of(context).pop('0')),
          ]),
    );
    return value;
  }

  Future<String?> selectDialog(
      BuildContext context, String title, List<dynamic> listString) async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        actions: [
          Row(children: [
            ...listString.map((e) => Expanded(
                child: Container(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: PrimaryColButton(
                      label: e['val'],
                      tapFunc: () => Navigator.of(context).pop(e['key']),
                    ))))
          ])
        ],
      ),
    );
    if (value == null) return null;
    return value.toString();
  }

  Future<bool> waitDialog(BuildContext context, String msg) async {
    final value = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(msg),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => {Navigator.of(context).pop(true)},
          ),
        ],
      ),
    );
    return value == true;
  }

  Future<bool> oldVersionDialog(BuildContext context, String url) async {
    final value = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(warningVersionUpdate),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => {Navigator.of(context).pop(true)},
          ),
        ],
      ),
    );
    return value == true;
  }

  Future<bool> retryOrExit(BuildContext context, String message) async {
    final value = await showPlatformDialog(
      context: context,
      builder: (context) => BasicDialogAlert(
        title: Text(message),
        // content: Text("Action cannot be undone."),
        actions: <Widget>[
          BasicDialogAction(
            title: const Text("リトライ"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          BasicDialogAction(
            title: const Text("終了"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );
    return value == true;
  }
}
